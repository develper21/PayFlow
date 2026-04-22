import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/services/cloud_sync_service.dart';
import 'package:payflow/shared/services/encryption_service.dart';

class BoletoListController {
  BoletoListController() {
    getBoletos();
  }

  final boletosNotifier = ValueNotifier<List<BoletoModel>>(<BoletoModel>[]);
  final filteredBoletosNotifier = ValueNotifier<List<BoletoModel>>(<BoletoModel>[]);
  final selectedCategoryNotifier = ValueNotifier<String>('All');
  final selectedStatusNotifier = ValueNotifier<String>('All'); // All, Paid, Pending
  final searchQueryNotifier = ValueNotifier<String>('');
  final isSyncingNotifier = ValueNotifier<bool>(false);
  final lastSyncTimeNotifier = ValueNotifier<DateTime?>(null);

  List<BoletoModel> _allBoletos = [];
  final CloudSyncService _cloudSync = CloudSyncService();
  final EncryptionService _encryption = EncryptionService();

  List<BoletoModel> get boletos => filteredBoletosNotifier.value;
  set boletos(List<BoletoModel> value) {
    _allBoletos = value;
    _applyFilter();
  }

  String get selectedCategory => selectedCategoryNotifier.value;
  set selectedCategory(String value) {
    selectedCategoryNotifier.value = value;
    _applyFilter();
  }

  String get searchQuery => searchQueryNotifier.value;
  set searchQuery(String value) {
    searchQueryNotifier.value = value;
    _applyFilter();
  }

  String get selectedStatus => selectedStatusNotifier.value;
  set selectedStatus(String value) {
    selectedStatusNotifier.value = value;
    _applyFilter();
  }

  void _applyFilter() {
    var filtered = _allBoletos;

    // Apply status filter
    if (selectedStatus == 'Paid') {
      filtered = filtered.where((b) => b.isPaid).toList();
    } else if (selectedStatus == 'Pending') {
      filtered = filtered.where((b) => !b.isPaid).toList();
    }

    // Apply category filter
    if (selectedCategory != 'All') {
      filtered = filtered
          .where((boleto) => boleto.category == selectedCategory)
          .toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((boleto) {
        return boleto.name.toLowerCase().contains(query) ||
            boleto.category.toLowerCase().contains(query) ||
            boleto.barcode.toLowerCase().contains(query) ||
            boleto.dueDate.contains(query);
      }).toList();
    }

    filteredBoletosNotifier.value = filtered;
  }

  Future<void> togglePaid(BoletoModel boleto) async {
    final index = _allBoletos.indexWhere((b) =>
        b.name == boleto.name &&
        b.dueDate == boleto.dueDate &&
        b.barcode == boleto.barcode);

    if (index != -1) {
      // Toggle the paid status
      final updated = _allBoletos[index].copyWith(isPaid: !_allBoletos[index].isPaid);
      _allBoletos[index] = updated;

      // Save with encryption
      await _saveBillsSecurely();

      _applyFilter();
    }
  }

  Future<void> deleteBoleto(BoletoModel boleto) async {
    _allBoletos.removeWhere((b) =>
        b.name == boleto.name &&
        b.dueDate == boleto.dueDate &&
        b.barcode == boleto.barcode);

    // Save with encryption
    await _saveBillsSecurely();

    // Delete from cloud
    await _cloudSync.deleteBillFromCloud(boleto);

    _applyFilter();
  }

  Future<void> updateBoleto(BoletoModel oldBoleto, BoletoModel newBoleto) async {
    final index = _allBoletos.indexWhere((b) =>
        b.name == oldBoleto.name &&
        b.dueDate == oldBoleto.dueDate &&
        b.barcode == oldBoleto.barcode);

    if (index != -1) {
      _allBoletos[index] = newBoleto;

      // Save with encryption
      await _saveBillsSecurely();

      // Sync to cloud
      await _cloudSync.saveBillToCloud(newBoleto);

      _applyFilter();
    }
  }

  // Cloud sync methods
  Future<void> syncWithCloud() async {
    if (isSyncingNotifier.value) return;

    isSyncingNotifier.value = true;

    try {
      final syncedBills = await _cloudSync.fullSync(_allBoletos);
      _allBoletos = syncedBills;
      _applyFilter();

      // Update last sync time
      lastSyncTimeNotifier.value = await _cloudSync.getLastSyncTime();
    } catch (e) {
      debugPrint('Cloud sync error: $e');
    } finally {
      isSyncingNotifier.value = false;
    }
  }

  Future<void> fetchFromCloud() async {
    if (isSyncingNotifier.value) return;

    isSyncingNotifier.value = true;

    try {
      final cloudBills = await _cloudSync.syncFromCloud();
      final merged = await _cloudSync.mergeBills(_allBoletos, cloudBills);
      _allBoletos = merged;

      // Save merged to local
      final instance = await SharedPreferences.getInstance();
      await instance.setStringList(
        'boletos',
        _allBoletos.map((b) => b.toJson()).toList(),
      );

      _applyFilter();
      lastSyncTimeNotifier.value = await _cloudSync.getLastSyncTime();
    } catch (e) {
      debugPrint('Fetch from cloud error: $e');
    } finally {
      isSyncingNotifier.value = false;
    }
  }

  // Initialize encryption on first use
  Future<void> _initEncryption() async {
    if (!_encryption.isInitialized) {
      await _encryption.initialize();
    }
  }

  // Save bills with encryption
  Future<void> _saveBillsSecurely() async {
    await _initEncryption();
    final instance = await SharedPreferences.getInstance();

    // Try encrypted save first
    final jsonList = _allBoletos.map((b) => b.toJson()).toList();
    final encrypted = _encryption.encryptList(jsonList);

    if (encrypted != null && encrypted.isNotEmpty) {
      await instance.setStringList('boletos_encrypted', encrypted);
      // Clear old unencrypted data
      await instance.remove('boletos');
    } else {
      // Fallback to unencrypted if encryption fails
      await instance.setStringList('boletos', jsonList);
    }
  }

  // Load bills with decryption
  Future<List<BoletoModel>> _loadBillsSecurely() async {
    await _initEncryption();
    final instance = await SharedPreferences.getInstance();

    // Try encrypted data first
    final encrypted = instance.getStringList('boletos_encrypted');
    if (encrypted != null && encrypted.isNotEmpty) {
      final decrypted = _encryption.decryptList(encrypted);
      if (decrypted != null && decrypted.isNotEmpty) {
        return decrypted
            .map((json) => BoletoModel.fromJson(json))
            .whereType<BoletoModel>()
            .toList();
      }
    }

    // Fallback to unencrypted data (for migration)
    final plain = instance.getStringList('boletos');
    if (plain != null && plain.isNotEmpty) {
      // Migrate to encrypted storage
      final bills = plain
          .map((json) => BoletoModel.fromJson(json))
          .whereType<BoletoModel>()
          .toList();
      _allBoletos = bills;
      await _saveBillsSecurely(); // Encrypt and save
      return bills;
    }

    return [];
  }

  void getBoletos() async {
    try {
      boletos = await _loadBillsSecurely();

      // Load last sync time
      lastSyncTimeNotifier.value = await _cloudSync.getLastSyncTime();
    } catch (e, s) {
      debugPrint('Error when getting boletos ${e.toString()}');
      debugPrint('Stack when getting boletos ${s.toString()}');
    }
  }

  List<String> getCategories() {
    final categories = _allBoletos.map((b) => b.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  void dispose() {
    boletosNotifier.dispose();
    filteredBoletosNotifier.dispose();
    selectedCategoryNotifier.dispose();
    selectedStatusNotifier.dispose();
    searchQueryNotifier.dispose();
    isSyncingNotifier.dispose();
    lastSyncTimeNotifier.dispose();
  }
}
