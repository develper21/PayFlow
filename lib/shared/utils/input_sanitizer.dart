/// Utility class for sanitizing user inputs to prevent injection attacks
/// and ensure data integrity.
class InputSanitizer {
  InputSanitizer._(); // Private constructor

  /// Sanitizes bill name input
  /// - Removes special characters that could cause injection
  /// - Trims whitespace
  /// - Limits length to 100 characters
  static String sanitizeBillName(String name) {
    var sanitized = name.trim();

    // Remove potentially dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>&\"\']'), '');

    // Remove control characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Limit length
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }

    return sanitized;
  }

  /// Sanitizes barcode input
  /// - Only allows alphanumeric characters and hyphens
  /// - Must be exactly 44 or 48 digits for standard Brazilian barcodes
  static String sanitizeBarcode(String barcode) {
    // Remove all non-numeric characters
    var sanitized = barcode.replaceAll(RegExp(r'[^0-9]'), '');

    // Brazilian barcodes are typically 44 or 48 digits
    // Keep only the first 48 characters if longer
    if (sanitized.length > 48) {
      sanitized = sanitized.substring(0, 48);
    }

    return sanitized;
  }

  /// Validates and sanitizes a date string
  /// Expected format: DD/MM/YYYY
  static String? sanitizeDate(String date) {
    // Remove any characters except digits and slashes
    var sanitized = date.replaceAll(RegExp(r'[^0-9/]'), '');

    // Validate format DD/MM/YYYY
    final dateRegex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$');
    if (!dateRegex.hasMatch(sanitized)) {
      return null; // Invalid date format
    }

    // Additional validation: check if date is valid (e.g., not 31/02/2023)
    try {
      final parts = sanitized.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final dateTime = DateTime(year, month, day);

      // Check if the constructed date matches the input (handles invalid dates like 31/02)
      if (dateTime.day != day || dateTime.month != month || dateTime.year != year) {
        return null;
      }

      // Check if date is not in the past (for due dates)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (dateTime.isBefore(today)) {
        // Past dates are technically valid for bills, but you might want to warn
        return sanitized;
      }

      return sanitized;
    } catch (e) {
      return null;
    }
  }

  /// Sanitizes monetary value
  /// - Converts to standard format
  /// - Validates range (0 to 999,999,999.99)
  static String? sanitizeValue(String value) {
    // Remove currency symbols and whitespace
    var sanitized = value.replaceAll(RegExp(r'[R\$\s]'), '');

    // Replace comma with dot for standard decimal format
    sanitized = sanitized.replaceAll(',', '.');

    // Keep only digits, dots, and minus sign
    sanitized = sanitized.replaceAll(RegExp(r'[^0-9.-]'), '');

    // Validate it's a valid number
    final number = double.tryParse(sanitized);
    if (number == null) {
      return null;
    }

    // Validate range
    if (number < 0 || number > 999999999.99) {
      return null;
    }

    // Format to 2 decimal places
    return number.toStringAsFixed(2);
  }

  /// Sanitizes category name
  static String sanitizeCategory(String category) {
    var sanitized = category.trim();

    // Remove special characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>&\"\'\x00-\x1F\x7F]'), '');

    // Limit length
    if (sanitized.length > 50) {
      sanitized = sanitized.substring(0, 50);
    }

    return sanitized;
  }

  /// Validates that input doesn't contain SQL injection patterns
  static bool isSafeInput(String input) {
    final dangerousPatterns = [
      RegExp(r'union\s+select', caseSensitive: false),
      RegExp(r'insert\s+into', caseSensitive: false),
      RegExp(r'delete\s+from', caseSensitive: false),
      RegExp(r'drop\s+table', caseSensitive: false),
      RegExp(r'--'), // SQL comment
      RegExp(r'/\*'), // Block comment start
      RegExp(r';\s*\w+'), // Multiple statements
    ];

    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(input)) {
        return false;
      }
    }

    return true;
  }

  /// Checks if a string is empty or contains only whitespace
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Validates bill name length
  static bool isValidBillName(String name) {
    return name.trim().length >= 2 && name.trim().length <= 100;
  }

  /// Validates barcode format for Brazilian boletos
  static bool isValidBarcode(String barcode) {
    // Remove non-numeric characters
    final cleanBarcode = barcode.replaceAll(RegExp(r'[^0-9]'), '');

    // Brazilian barcodes are 44 or 48 digits
    return cleanBarcode.length == 44 || cleanBarcode.length == 48;
  }
}
