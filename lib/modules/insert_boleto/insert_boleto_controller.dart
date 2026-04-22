import 'package:shared_preferences/shared_preferences.dart';

import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/services/cloud_sync_service.dart';
import 'package:payflow/shared/services/encryption_service.dart';
import 'package:payflow/shared/services/notification_service.dart';
import 'package:payflow/shared/utils/input_sanitizer.dart';

class InsertBoletoController {
  BoletoModel model = BoletoModel.empty();
  final EncryptionService _encryption = EncryptionService();

  // Enhanced validators with input sanitization
  String? validateName(String? value) {
    if (InputSanitizer.isNullOrEmpty(value)) {
      return 'The name cannot be empty';
    }

    final sanitized = InputSanitizer.sanitizeBillName(value!);

    if (!InputSanitizer.isValidBillName(sanitized)) {
      return 'Name must be 2-100 characters';
    }

    if (!InputSanitizer.isSafeInput(sanitized)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  String? validateDueDate(String? value) {
    if (InputSanitizer.isNullOrEmpty(value)) {
      return 'The due date cannot be empty';
    }

    final sanitized = InputSanitizer.sanitizeDate(value!);
    if (sanitized == null) {
      return 'Invalid date format (DD/MM/YYYY)';
    }

    return null;
  }

  String? validateValue(double value) {
    if (value <= 0) {
      return 'Enter an amount greater than \$0.00';
    }
    if (value > 999999999.99) {
      return 'Amount is too large';
    }
    return null;
  }

  String? validateCode(String? value) {
    if (InputSanitizer.isNullOrEmpty(value)) {
      return 'Boleto code cannot be empty';
    }

    final sanitized = InputSanitizer.sanitizeBarcode(value!);

    if (!InputSanitizer.isValidBarcode(sanitized)) {
      return 'Barcode must be 44 or 48 digits';
    }

    return null;

  // Sanitize and update model
  void onChange({
    String? name,
    String? dueDate,
    double? value,
    String? barcode,
    String? category,
  }) {
    // Sanitize inputs before storing in model
    final sanitizedName = name != null ? InputSanitizer.sanitizeBillName(name) : null;
    final sanitizedBarcode = barcode != null ? InputSanitizer.sanitizeBarcode(barcode) : null;
    final sanitizedDate = dueDate != null ? InputSanitizer.sanitizeDate(dueDate) ?? dueDate : null;
    final sanitizedCategory = category != null ? InputSanitizer.sanitizeCategory(category) : null;

    model = model.copyWith(
      name: sanitizedName ?? name,
      dueDate: sanitizedDate ?? dueDate,
      value: value,
      barcode: sanitizedBarcode ?? barcode,
      category: sanitizedCategory ?? category,
    );
  }

  String? validateCategory(String? value) {
    if (InputSanitizer.isNullOrEmpty(value)) {
      return 'Please select a category';
    }

    final sanitized = InputSanitizer.sanitizeCategory(value!);

    if (!InputSanitizer.isSafeInput(sanitized)) {
      return 'Category contains invalid characters';
    }

    return null;

  Future<void> saveBoleto() async {
    try {
      // Validate all fields before saving
      final nameError = validateName(model.name);
      if (nameError != null) throw Exception(nameError);

      final dateError = validateDueDate(model.dueDate);
      if (dateError != null) throw Exception(dateError);

      final valueError = validateValue(model.value);
      if (valueError != null) throw Exception(valueError);

      final codeError = validateCode(model.barcode);
      if (codeError != null) throw Exception(codeError);

      final catError = validateCategory(model.category);
      if (catError != null) throw Exception(catError);

      // Initialize encryption
      await _encryption.initialize();

      final instance = await SharedPreferences.getInstance();

      // Load existing bills (encrypted or plain)
      final encryptedList = instance.getStringList('boletos_encrypted');
      List<String> boletos = [];

      if (encryptedList != null && encryptedList.isNotEmpty) {
        final decrypted = _encryption.decryptList(encryptedList);
        if (decrypted != null) {
          boletos = decrypted;
        }
      } else {
        boletos = instance.getStringList('boletos') ?? <String>[];
      }

      // Add new bill
      boletos.add(model.toJson());

      // Encrypt and save
      final encrypted = _encryption.encryptList(boletos);
      if (encrypted != null && encrypted.isNotEmpty) {
        await instance.setStringList('boletos_encrypted', encrypted);
        await instance.remove('boletos'); // Remove old unencrypted data
      } else {
        await instance.setStringList('boletos', boletos);
      }

      // Schedule reminder notification
      await NotificationService().scheduleBillReminder(model);

      // Sync to cloud
      await CloudSyncService().saveBillToCloud(model);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing boleto
  Future<void> updateBoleto(BoletoModel oldBoleto) async {
    try {
      // Validate all fields before updating
      final nameError = validateName(model.name);
      if (nameError != null) throw Exception(nameError);

      final dateError = validateDueDate(model.dueDate);
      if (dateError != null) throw Exception(dateError);

      final valueError = validateValue(model.value);
      if (valueError != null) throw Exception(valueError);

      final codeError = validateCode(model.barcode);
      if (codeError != null) throw Exception(codeError);

      final catError = validateCategory(model.category);
      if (catError != null) throw Exception(catError);

      // Initialize encryption
      await _encryption.initialize();

      final instance = await SharedPreferences.getInstance();

      // Load existing bills (encrypted or plain)
      final encryptedList = instance.getStringList('boletos_encrypted');
      List<String> boletos = [];

      if (encryptedList != null && encryptedList.isNotEmpty) {
        final decrypted = _encryption.decryptList(encryptedList);
        if (decrypted != null) {
          boletos = decrypted;
        }
      } else {
        boletos = instance.getStringList('boletos') ?? <String>[];
      }

      // Find and update the existing bill
      final index = boletos.indexWhere((json) {
        final b = BoletoModel.fromJson(json);
        return b.name == oldBoleto.name &&
            b.dueDate == oldBoleto.dueDate &&
            b.barcode == oldBoleto.barcode;
      });

      if (index != -1) {
        // Remove old bill and add updated one
        boletos.removeAt(index);
        boletos.add(model.toJson());
      } else {
        throw Exception('Bill not found for update');
      }

      // Encrypt and save
      final encrypted = _encryption.encryptList(boletos);
      if (encrypted != null && encrypted.isNotEmpty) {
        await instance.setStringList('boletos_encrypted', encrypted);
        await instance.remove('boletos');
      } else {
        await instance.setStringList('boletos', boletos);
      }

      // Update notification
      await NotificationService().scheduleBillReminder(model);

      // Sync to cloud
      await CloudSyncService().saveBillToCloud(model);
    } catch (e) {
      rethrow;
    }
  }
}
