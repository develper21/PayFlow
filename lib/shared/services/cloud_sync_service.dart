import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/models/user_model.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  bool get isAuthenticated => _userId != null;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _userBillsCollection {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(_userId).collection('bills');
  }

  // Sync local bills to cloud
  Future<void> syncToCloud(List<BoletoModel> boletos) async {
    if (!isAuthenticated) {
      log('User not authenticated, skipping cloud sync');
      return;
    }

    try {
      final batch = _firestore.batch();
      final billsRef = _userBillsCollection;

      // Get existing cloud bills to handle deletions
      final snapshot = await billsRef.get();
      final cloudBills = snapshot.docs.map((d) => d.id).toSet();
      final localIds = boletos.map((b) => _getBillId(b)).toSet();

      // Delete bills that exist in cloud but not locally
      for (final cloudId in cloudBills) {
        if (!localIds.contains(cloudId)) {
          batch.delete(billsRef.doc(cloudId));
        }
      }

      // Add or update local bills
      for (final boleto in boletos) {
        final docRef = billsRef.doc(_getBillId(boleto));
        batch.set(docRef, {
          ...boleto.toMap(),
          'lastSynced': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Update last sync time
      await _updateLastSyncTime();

      log('Synced ${boletos.length} bills to cloud');
    } catch (e, stackTrace) {
      log('Error syncing to cloud: $e');
      log('Stack trace: $stackTrace');
      throw Exception('Failed to sync to cloud: $e');
    }
  }

  // Fetch bills from cloud and merge with local
  Future<List<BoletoModel>> syncFromCloud() async {
    if (!isAuthenticated) {
      log('User not authenticated, skipping cloud fetch');
      return [];
    }

    try {
      final snapshot = await _userBillsCollection
          .orderBy('lastSynced', descending: true)
          .get();

      final cloudBills = snapshot.docs.map((doc) {
        final data = doc.data();
        return BoletoModel.fromMap(data);
      }).toList();

      await _updateLastSyncTime();

      log('Fetched ${cloudBills.length} bills from cloud');
      return cloudBills;
    } catch (e, stackTrace) {
      log('Error fetching from cloud: $e');
      log('Stack trace: $stackTrace');
      throw Exception('Failed to fetch from cloud: $e');
    }
  }

  // Merge cloud bills with local bills (cloud wins on conflict)
  Future<List<BoletoModel>> mergeBills(
    List<BoletoModel> localBills,
    List<BoletoModel> cloudBills,
  ) async {
    final merged = <String, BoletoModel>{};

    // Add all local bills
    for (final bill in localBills) {
      merged[_getBillId(bill)] = bill;
    }

    // Overwrite with cloud bills (cloud takes precedence)
    for (final bill in cloudBills) {
      merged[_getBillId(bill)] = bill;
    }

    return merged.values.toList();
  }

  // Full two-way sync
  Future<List<BoletoModel>> fullSync(List<BoletoModel> localBills) async {
    if (!isAuthenticated) {
      log('User not authenticated, returning local bills only');
      return localBills;
    }

    try {
      // First, sync local to cloud
      await syncToCloud(localBills);

      // Then, fetch from cloud (gets any bills added from other devices)
      final cloudBills = await syncFromCloud();

      // Merge and resolve conflicts
      final merged = await mergeBills(localBills, cloudBills);

      // Save merged result locally
      await _saveLocalBills(merged);

      // Sync merged result back to cloud
      await syncToCloud(merged);

      log('Full sync completed. Total bills: ${merged.length}');
      return merged;
    } catch (e) {
      log('Full sync failed: $e');
      return localBills; // Return local bills on error
    }
  }

  // Save a single bill to cloud
  Future<void> saveBillToCloud(BoletoModel boleto) async {
    if (!isAuthenticated) return;

    try {
      await _userBillsCollection.doc(_getBillId(boleto)).set({
        ...boleto.toMap(),
        'lastSynced': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('Error saving bill to cloud: $e');
    }
  }

  // Delete a bill from cloud
  Future<void> deleteBillFromCloud(BoletoModel boleto) async {
    if (!isAuthenticated) return;

    try {
      await _userBillsCollection.doc(_getBillId(boleto)).delete();
    } catch (e) {
      log('Error deleting bill from cloud: $e');
    }
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_cloud_sync');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Update last sync time
  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_cloud_sync', DateTime.now().millisecondsSinceEpoch);
  }

  // Save bills locally
  Future<void> _saveLocalBills(List<BoletoModel> bills) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'boletos',
      bills.map((b) => b.toJson()).toList(),
    );
  }

  // Generate unique ID for a bill
  String _getBillId(BoletoModel bill) {
    // Use barcode + due date as unique identifier
    return '${bill.barcode}_${bill.dueDate}'.replaceAll('/', '-');
  }

  // Stream of cloud bills for real-time updates
  Stream<List<BoletoModel>> getCloudBillsStream() {
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    return _userBillsCollection
        .orderBy('lastSynced', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BoletoModel.fromMap(doc.data())).toList();
    });
  }
}
