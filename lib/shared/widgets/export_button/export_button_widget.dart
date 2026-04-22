import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/services/export_service.dart';
import 'package:payflow/shared/themes/app_colors.dart';

class ExportButtonWidget extends StatelessWidget {
  const ExportButtonWidget({
    super.key,
    required this.boletos,
  });

  final List<BoletoModel> boletos;

  void _showExportOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkStroke : AppColors.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Export Bills',
                style: GoogleFonts.lexendDeca(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkHeading : AppColors.heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${boletos.length} bills ready to export',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.darkBody : AppColors.body,
                ),
              ),
              const SizedBox(height: 24),

              // PDF Export
              _ExportOptionTile(
                icon: Icons.picture_as_pdf,
                title: 'Export as PDF',
                subtitle: 'Professional formatted document',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  final path = await ExportService().exportToPDF(boletos);
                  if (path == null && context.mounted) {
                    _showError(context, 'Failed to export PDF');
                  }
                },
              ),

              const SizedBox(height: 12),

              // CSV Export
              _ExportOptionTile(
                icon: Icons.table_chart,
                title: 'Export as CSV',
                subtitle: 'Spreadsheet format for Excel',
                color: Colors.green,
                onTap: () async {
                  Navigator.pop(context);
                  final path = await ExportService().exportToCSV(boletos);
                  if (path == null && context.mounted) {
                    _showError(context, 'Failed to export CSV');
                  }
                },
              ),

              const SizedBox(height: 12),

              // Share Text
              _ExportOptionTile(
                icon: Icons.share,
                title: 'Share as Text',
                subtitle: 'Simple text format',
                color: Colors.blue,
                onTap: () async {
                  Navigator.pop(context);
                  await ExportService().shareBills(boletos);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.delete,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: boletos.isEmpty ? null : () => _showExportOptions(context),
      icon: Icon(
        Icons.download,
        color: boletos.isEmpty
            ? (isDark ? AppColors.darkInput : AppColors.input)
            : Colors.white,
      ),
      tooltip: 'Export bills',
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkShape : AppColors.shape,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkStroke : AppColors.stroke,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkHeading : AppColors.heading,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkBody : AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkInput : AppColors.input,
            ),
          ],
        ),
      ),
    );
  }
}
