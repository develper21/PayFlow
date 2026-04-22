import 'package:flutter_test/flutter_test.dart';
import 'package:payflow/shared/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer Tests', () {
    group('sanitizeBillName', () {
      test('should trim whitespace', () {
        expect(InputSanitizer.sanitizeBillName('  Test Bill  '), 'Test Bill');
      });

      test('should remove special characters', () {
        expect(
          InputSanitizer.sanitizeBillName('Test<script>alert(1)</script>'),
          'Testscriptalert(1)/script',
        );
      });

      test('should limit length to 100 characters', () {
        final longName = 'A' * 150;
        final result = InputSanitizer.sanitizeBillName(longName);
        expect(result.length, 100);
      });
    });

    group('sanitizeBarcode', () {
      test('should remove non-numeric characters', () {
        expect(
          InputSanitizer.sanitizeBarcode('123.456.789-00'),
          '12345678900',
        );
      });

      test('should limit to 48 characters', () {
        final longBarcode = '1' * 60;
        final result = InputSanitizer.sanitizeBarcode(longBarcode);
        expect(result.length, 48);
      });
    });

    group('sanitizeDate', () {
      test('should validate correct date format', () {
        expect(InputSanitizer.sanitizeDate('15/12/2024'), '15/12/2024');
      });

      test('should return null for invalid date', () {
        expect(InputSanitizer.sanitizeDate('32/13/2024'), isNull);
      });

      test('should return null for wrong format', () {
        expect(InputSanitizer.sanitizeDate('2024-12-15'), isNull);
      });
    });

    group('isSafeInput', () {
      test('should detect SQL injection patterns', () {
        expect(
          InputSanitizer.isSafeInput('DROP TABLE users;'),
          isFalse,
        );
      });

      test('should allow safe input', () {
        expect(
          InputSanitizer.isSafeInput('Electric Bill January'),
          isTrue,
        );
      });
    });

    group('isNullOrEmpty', () {
      test('should return true for null', () {
        expect(InputSanitizer.isNullOrEmpty(null), isTrue);
      });

      test('should return true for empty string', () {
        expect(InputSanitizer.isNullOrEmpty(''), isTrue);
      });

      test('should return true for whitespace only', () {
        expect(InputSanitizer.isNullOrEmpty('   '), isTrue);
      });

      test('should return false for valid string', () {
        expect(InputSanitizer.isNullOrEmpty('Test'), isFalse);
      });
    });
  });
}
