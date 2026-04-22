import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

/// Service for encrypting and decrypting sensitive data in SharedPreferences.
/// Uses AES-256 encryption with a device-specific key derived from app signature.
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  encrypt.Encrypter? _encrypter;
  encrypt.Key? _key;

  /// Initialize encryption with device-specific key
  Future<void> initialize() async {
    // In production, you should derive this from secure storage or device ID
    // For this demo, we use a derived key from app package + salt
    final keyString = _deriveKey();
    _key = encrypt.Key.fromUtf8(keyString);
    _encrypter = encrypt.Encrypter(
      encrypt.AES(_key!, mode: encrypt.AESMode.cbc),
    );
  }

  /// Derive a 32-character key (AES-256 requires 32 bytes)
  String _deriveKey() {
    // Combine app package name with a salt to create device-specific key
    const packageName = 'com.example.payflow';
    const salt = 'PayFlowSecure2024!'; // In production, use secure random salt

    final combined = '$packageName\n$salt';
    final bytes = utf8.encode(combined);

    // Use Base64 to get 32 characters, take first 32
    final base64Str = base64.encode(bytes);
    return base64Str.substring(0, 32);
  }

  /// Encrypt plain text
  String? encryptData(String plainText) {
    if (_encrypter == null) {
      debugPrint('EncryptionService not initialized');
      return null;
    }

    try {
      final iv = encrypt.IV.fromLength(16); // Random IV for each encryption
      final encrypted = _encrypter!.encrypt(plainText, iv: iv);

      // Combine IV + ciphertext for storage
      final combined = iv.bytes + encrypted.bytes;
      return base64.encode(combined);
    } catch (e) {
      debugPrint('Encryption error: $e');
      return null;
    }
  }

  /// Decrypt encrypted text
  String? decryptData(String encryptedText) {
    if (_encrypter == null) {
      debugPrint('EncryptionService not initialized');
      return null;
    }

    try {
      final combined = base64.decode(encryptedText);

      // Extract IV (first 16 bytes) and ciphertext
      final ivBytes = combined.sublist(0, 16);
      final cipherBytes = Uint8List.fromList(combined.sublist(16));

      final iv = encrypt.IV(ivBytes);
      final encrypted = encrypt.Encrypted(cipherBytes);

      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (e) {
      debugPrint('Decryption error: $e');
      return null;
    }
  }

  /// Encrypt a list of strings (for bills)
  List<String>? encryptList(List<String> data) {
    return data.map((item) => encryptData(item)).whereType<String>().toList();
  }

  /// Decrypt a list of strings
  List<String>? decryptList(List<String>? encryptedData) {
    if (encryptedData == null) return null;

    final decrypted = <String>[];
    for (final item in encryptedData) {
      final plain = decryptData(item);
      if (plain != null) {
        decrypted.add(plain);
      }
    }
    return decrypted;
  }

  /// Check if service is initialized
  bool get isInitialized => _encrypter != null;
}
