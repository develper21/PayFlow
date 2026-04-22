import 'package:flutter/material.dart';

import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/widgets/boleto_list/boleto_list_controller.dart';
import 'package:payflow/shared/widgets/boleto_tile/boleto_tile_widget.dart';

class BoletoListWidget extends StatefulWidget {
  const BoletoListWidget({
    super.key,
    required this.controller,
    this.onEdit,
  });

  final BoletoListController controller;
  final Function(BoletoModel)? onEdit;

  @override
  State<BoletoListWidget> createState() => _BoletoListWidgetState();
}

class _BoletoListWidgetState extends State<BoletoListWidget> {
  void _showOptions(BoletoModel boleto) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(height: 16),

              // Mark as Paid/Pending
              ListTile(
                leading: Icon(
                  boleto.isPaid ? Icons.pending_actions : Icons.check_circle,
                  color: AppColors.primary,
                ),
                title: Text(boleto.isPaid ? 'Mark as Pending' : 'Mark as Paid'),
                onTap: () async {
                  Navigator.pop(context);
                  await widget.controller.togglePaid(boleto);
                },
              ),

              // Edit
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit Bill'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit?.call(boleto);
                },
              ),

              // Delete
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.delete),
                title: const Text('Delete', style: TextStyle(color: AppColors.delete)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Bill?'),
                      content: Text('Are you sure you want to delete "${boleto.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: AppColors.delete)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await widget.controller.deleteBoleto(boleto);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${boleto.name}" deleted'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BoletoModel>>(
      valueListenable: widget.controller.filteredBoletosNotifier,
      builder: (_, boletos, __) {
        if (boletos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No boletos found',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
              ),
            ),
          );
        }
        return Column(
          children: boletos
              .map(
                (boleto) => BoletoTileWidget(
                  data: boleto,
                  onTogglePaid: () => widget.controller.togglePaid(boleto),
                  onLongPress: () => _showOptions(boleto),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
