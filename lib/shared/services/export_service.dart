import 'dart:io';
import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import 'package:payflow/shared/models/boleto_model.dart';

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  Future<String?> exportToCSV(List<BoletoModel> boletos) async {
    try {
      // Create CSV data
      final rows = <List<String>>[
        // Header
        ['Name', 'Category', 'Due Date', 'Value', 'Barcode'],
        // Data rows
        ...boletos.map((b) => [
              b.name,
              b.category,
              b.dueDate,
              b.value.toStringAsFixed(2),
              b.barcode,
            ]),
      ];

      final csvData = const ListToCsvConverter().convert(rows);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'payflow_bills_${_getTimestamp()}.csv';
      final filePath = '${tempDir.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsString(csvData);

      log('CSV exported to: $filePath');

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'My PayFlow Bills (CSV)',
        text: 'Here are my bills from PayFlow app',
      );

      return filePath;
    } catch (e, stackTrace) {
      log('Error exporting CSV: $e');
      log('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> exportToPDF(List<BoletoModel> boletos) async {
    try {
      // Load font
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ttf = pw.Font.ttf(fontData);

      // Create PDF
      final pdf = pw.Document();

      // Calculate total
      final total = boletos.fold<double>(0, (sum, b) => sum + b.value);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'PayFlow - Bill Summary',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Generated on: ${_getFormattedDate()}',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                color: PdfColors.grey,
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Total Bills: ${boletos.length}',
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                  pw.Text(
                    'Total Amount: \$${total.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Bills Table
            pw.Text(
              'Bill Details',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: ['Name', 'Category', 'Due Date', 'Amount'],
              data: boletos
                  .map((b) => [
                        b.name,
                        b.category,
                        b.dueDate,
                        '\$${b.value.toStringAsFixed(2)}',
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue,
              ),
              cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Text(
              'PayFlow - Your Bill Manager',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ],
        ),
      );

      // Save PDF
      final tempDir = await getTemporaryDirectory();
      final fileName = 'payflow_bills_${_getTimestamp()}.pdf';
      final filePath = '${tempDir.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      log('PDF exported to: $filePath');

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'My PayFlow Bills (PDF)',
        text: 'Here are my bills from PayFlow app',
      );

      return filePath;
    } catch (e, stackTrace) {
      log('Error exporting PDF: $e');
      log('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> shareBills(List<BoletoModel> boletos) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('🧾 My PayFlow Bills\n');
      buffer.writeln('Generated: ${_getFormattedDate()}\n');

      double total = 0;
      for (final boleto in boletos) {
        total += boleto.value;
        buffer.writeln('📄 ${boleto.name}');
        buffer.writeln('   Category: ${boleto.category}');
        buffer.writeln('   Due: ${boleto.dueDate}');
        buffer.writeln('   Amount: \$${boleto.value.toStringAsFixed(2)}');
        buffer.writeln('   Barcode: ${boleto.barcode}\n');
      }

      buffer.writeln('━' * 30);
      buffer.writeln('Total Bills: ${boletos.length}');
      buffer.writeln('Total Amount: \$${total.toStringAsFixed(2)}');

      await Share.share(
        buffer.toString(),
        subject: 'My PayFlow Bills',
      );

      log('Shared ${boletos.length} bills');
    } catch (e, stackTrace) {
      log('Error sharing bills: $e');
      log('Stack trace: $stackTrace');
    }
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }
}
