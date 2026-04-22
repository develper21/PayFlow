import 'package:flutter/material.dart';

import 'package:animated_card/animated_card.dart';

import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/app_text_styles.dart';
import 'package:payflow/shared/widgets/boleto_info/boleto_info_widget.dart';
import 'package:payflow/shared/widgets/boleto_list/boleto_list_controller.dart';
import 'package:payflow/shared/widgets/boleto_list/boleto_list_widget.dart';
import 'package:payflow/shared/widgets/export_button/export_button_widget.dart';

class MyBoletosPage extends StatefulWidget {
  const MyBoletosPage({super.key});

  @override
  State<MyBoletosPage> createState() => _MyBoletosPageState();
}

class _MyBoletosPageState extends State<MyBoletosPage> {
  final controller = BoletoListController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Stack(
              children: [
                Container(
                  height: 40,
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ValueListenableBuilder<List<BoletoModel>>(
                    valueListenable: controller.filteredBoletosNotifier,
                    builder: (_, boletos, __) => AnimatedCard(
                      direction: AnimatedCardDirection.top,
                      child: BoletoInfoWidget(
                        size: boletos.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My tickets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkHeading : AppColors.heading,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sync Button
                    ValueListenableBuilder<bool>(
                      valueListenable: controller.isSyncingNotifier,
                      builder: (_, isSyncing, __) {
                        return ValueListenableBuilder<DateTime?>(
                          valueListenable: controller.lastSyncTimeNotifier,
                          builder: (_, lastSync, __) {
                            return IconButton(
                              onPressed: isSyncing
                                  ? null
                                  : () async {
                                      await controller.syncWithCloud();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(lastSync != null
                                                ? 'Synced! Last sync: ${_formatSyncTime(lastSync)}'
                                                : 'Synced to cloud!'),
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                              icon: isSyncing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.sync),
                              tooltip: lastSync != null
                                  ? 'Last sync: ${_formatSyncTime(lastSync)}'
                                  : 'Sync with cloud',
                              color: Colors.white,
                            );
                          },
                        );
                      },
                    ),
                    // Export Button
                    ValueListenableBuilder<List<BoletoModel>>(
                      valueListenable: controller.filteredBoletosNotifier,
                      builder: (_, boletos, __) => ExportButtonWidget(
                        boletos: boletos,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: ValueListenableBuilder<String>(
              valueListenable: controller.searchQueryNotifier,
              builder: (_, searchQuery, __) {
                return TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    controller.searchQuery = value;
                  },
                  style: TextStyle(
                    color: isDark ? AppColors.darkHeading : AppColors.heading,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, category, barcode...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkInput : AppColors.input,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? AppColors.darkInput : AppColors.input,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              controller.searchQuery = '';
                            },
                            icon: Icon(
                              Icons.clear,
                              color: isDark
                                  ? AppColors.darkInput
                                  : AppColors.input,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.darkShape : AppColors.shape,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkStroke : AppColors.stroke,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkStroke : AppColors.stroke,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              color: AppColors.stroke,
            ),
          ),
          // Category Filter Chips
          ValueListenableBuilder<String>(
            valueListenable: controller.selectedCategoryNotifier,
            builder: (_, selectedCategory, __) {
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    'All',
                    'Utilities',
                    'Water',
                    'Internet',
                    'Phone',
                    'Rent',
                    'Credit Card',
                    'Insurance',
                    'Taxes',
                    'Education',
                    'Health',
                    'Others',
                  ].map((category) {
                    final isSelected = selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              controller.selectedCategory = category;
                            });
                          }
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark
                            ? AppColors.darkShape
                            : AppColors.shape,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkHeading
                                  : AppColors.heading),
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkStroke
                                : AppColors.stroke,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Status Filter Chips
          ValueListenableBuilder<String>(
            valueListenable: controller.selectedStatusNotifier,
            builder: (_, selectedStatus, __) {
              return Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    'All',
                    'Paid',
                    'Pending',
                  ].map((status) {
                    final isSelected = selectedStatus == status;
                    Color chipColor;
                    if (status == 'Paid') {
                      chipColor = Colors.green;
                    } else if (status == 'Pending') {
                      chipColor = AppColors.primary;
                    } else {
                      chipColor = AppColors.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              controller.selectedStatus = status;
                            });
                          }
                        },
                        selectedColor: chipColor,
                        backgroundColor: isDark
                            ? AppColors.darkShape
                            : AppColors.shape,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? AppColors.darkHeading
                                  : AppColors.heading),
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkStroke
                                : AppColors.stroke,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BoletoListWidget(
              controller: controller,
              onEdit: (boleto) {
                // Navigate to edit page with full BoletoModel
                Navigator.pushNamed(
                  context,
                  '/insert_boleto',
                  arguments: boleto,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  String _formatSyncTime(DateTime syncTime) {
    final now = DateTime.now();
    final diff = now.difference(syncTime);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else {
      return '${syncTime.day}/${syncTime.month}/${syncTime.year}';
    }
  }
}
