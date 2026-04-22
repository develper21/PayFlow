import 'package:flutter_test/flutter_test.dart';
import 'package:payflow/shared/models/boleto_model.dart';

void main() {
  group('BoletoModel Tests', () {
    test('should create BoletoModel from empty constructor', () {
      final boleto = BoletoModel.empty();

      expect(boleto.name, '');
      expect(boleto.dueDate, '');
      expect(boleto.value, 0.0);
      expect(boleto.barcode, '');
      expect(boleto.category, 'Others');
      expect(boleto.isPaid, false);
    });

    test('should serialize to JSON correctly', () {
      final boleto = BoletoModel(
        name: 'Electric Bill',
        dueDate: '15/12/2024',
        value: 150.50,
        barcode: '12345678901234567890123456789012345678901234',
        category: 'Utilities',
        isPaid: true,
      );

      final json = boleto.toJson();
      expect(json, contains('"name":"Electric Bill"'));
      expect(json, contains('"category":"Utilities"'));
      expect(json, contains('"isPaid":true'));
    });

    test('should deserialize from JSON correctly', () {
      final json = '{"name":"Water Bill","dueDate":"20/12/2024","value":75.25,"barcode":"98765432109876543210987654321098765432109876","category":"Water","isPaid":false}';

      final boleto = BoletoModel.fromJson(json);

      expect(boleto.name, 'Water Bill');
      expect(boleto.dueDate, '20/12/2024');
      expect(boleto.value, 75.25);
      expect(boleto.barcode, '98765432109876543210987654321098765432109876');
      expect(boleto.category, 'Water');
      expect(boleto.isPaid, false);
    });

    test('should copyWith create a new instance with updated values', () {
      final original = BoletoModel(
        name: 'Rent',
        dueDate: '01/01/2025',
        value: 1000.0,
        barcode: '11111111111111111111111111111111111111111111',
        category: 'Rent',
        isPaid: false,
      );

      final updated = original.copyWith(isPaid: true, value: 1050.0);

      expect(updated.isPaid, true);
      expect(updated.value, 1050.0);
      expect(updated.name, original.name); // Unchanged
      expect(updated.dueDate, original.dueDate); // Unchanged
    });

    test('should calculate dueDateTime correctly', () {
      final boleto = BoletoModel(
        name: 'Test',
        dueDate: '15/12/2024',
        value: 100.0,
        barcode: '12345678901234567890123456789012345678901234',
      );

      final dateTime = boleto.dueDateTime;
      expect(dateTime?.day, 15);
      expect(dateTime?.month, 12);
      expect(dateTime?.year, 2024);
    });

    test('should identify overdue bills correctly', () {
      final pastBoleto = BoletoModel(
        name: 'Past Bill',
        dueDate: '01/01/2020',
        value: 100.0,
        barcode: '12345678901234567890123456789012345678901234',
        isPaid: false,
      );

      expect(pastBoleto.isOverdue, true);

      final futureBoleto = BoletoModel(
        name: 'Future Bill',
        dueDate: '01/01/2030',
        value: 100.0,
        barcode: '12345678901234567890123456789012345678901234',
        isPaid: false,
      );

      expect(futureBoleto.isOverdue, false);
    });
  });
}
