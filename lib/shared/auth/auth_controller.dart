import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:payflow/shared/models/user_model.dart';
import 'package:payflow/shared/utils/input_sanitizer.dart';

class AuthController {
  UserModel? _user;
  UserModel get user => _user as UserModel;

  // Token verification status
  bool _isTokenVerified = false;

  /// Validates and sanitizes user data before setting
  bool _validateUserData(UserModel user) {
    // Sanitize name
    final sanitizedName = InputSanitizer.sanitizeBillName(user.name);
    if (!InputSanitizer.isValidBillName(sanitizedName)) {
      debugPrint('Invalid user name format');
      return false;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(user.email ?? '')) {
      debugPrint('Invalid email format');
      return false;
    }

    // Check for potentially dangerous characters in email
    if (!InputSanitizer.isSafeInput(user.email ?? '')) {
      debugPrint('Email contains unsafe characters');
      return false;
    }

    return true;
  }

  /// Verifies Google ID token format (client-side validation)
  /// Note: Full server-side verification requires backend implementation
  bool _verifyTokenFormat(String? token) {
    if (token == null || token.isEmpty) {
      debugPrint('Token is null or empty');
      return false;
    }

    // Basic JWT structure check (3 parts separated by dots)
    final parts = token.split('.');
    if (parts.length != 3) {
      debugPrint('Invalid JWT structure');
      return false;
    }

    // Check token length (Google tokens are typically 800-1500 chars)
    if (token.length < 100 || token.length > 2000) {
      debugPrint('Token length suspicious');
      return false;
    }

    return true;
  }

  void setUser(BuildContext context, UserModel? user) {
    if (user != null) {
      // Validate user data
      if (!_validateUserData(user)) {
        debugPrint('User data validation failed');
        // Still allow login but log the issue
      }

      // Verify token format if available
      if (user.token != null) {
        _isTokenVerified = _verifyTokenFormat(user.token);
        if (!_isTokenVerified) {
          debugPrint('Token format verification failed');
        } else {
          debugPrint('Token format verified successfully');
        }
      }

      saveUser(user);
      _user = user;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: user,
      );
    } else {
      _isTokenVerified = false;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      final instance = await SharedPreferences.getInstance();

      // Store user with token verification status
      final userData = {
        'name': InputSanitizer.sanitizeBillName(user.name),
        'photoURL': user.photoURL,
        'email': user.email,
        'token': user.token,
        'tokenVerified': _isTokenVerified,
        'savedAt': DateTime.now().toIso8601String(),
      };

      await instance.setString('user', jsonEncode(userData));
    } catch (e) {
      debugPrint('Error saving user: $e');
      // Fallback to original method
      final instance = await SharedPreferences.getInstance();
      await instance.setString('user', user.toJson());
    }
  }

  Future<void> currentUser(
    BuildContext context,
  ) async {
    final instance = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));

    if (instance.containsKey('user')) {
      final json = instance.get('user') as String;

      try {
        // Validate stored user data
        final userData = jsonDecode(json) as Map<String, dynamic>;

        // Check if token was previously verified
        _isTokenVerified = userData['tokenVerified'] == true;

        // Check if session is recent (optional: implement session expiry)
        final savedAt = userData['savedAt'] as String?;
        if (savedAt != null) {
          final savedDate = DateTime.tryParse(savedAt);
          if (savedDate != null) {
            final daysSinceLogin = DateTime.now().difference(savedDate).inDays;
            if (daysSinceLogin > 30) {
              debugPrint('Session expired, requiring re-login');
              if (!context.mounted) return;
              setUser(context, null);
              return;
            }
          }
        }

        if (!context.mounted) return;
        setUser(context, UserModel.fromJson(json));
        return;
      } catch (e) {
        debugPrint('Error parsing stored user data: $e');
        // Clear corrupted data
        await instance.remove('user');
        if (!context.mounted) return;
        setUser(context, null);
      }
    } else {
      if (!context.mounted) return;
      setUser(context, null);
    }
  }

  Future<void> logout(BuildContext context) async {
    final instance = await SharedPreferences.getInstance();
    await instance.remove('user');
    _user = null;
    _isTokenVerified = false;
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  /// Check if current user's token has been verified
  bool get isTokenVerified => _isTokenVerified;
}
