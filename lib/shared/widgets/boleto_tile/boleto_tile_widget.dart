import 'package:flutter/material.dart';

import 'package:animated_card/animated_card.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:payflow/shared/models/boleto_category.dart';
import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/app_text_styles.dart';

class BoletoTileWidget extends StatelessWidget {
  const BoletoTileWidget({
    super.key,
    required this.data,
    this.onTogglePaid,
    this.onTap,
    this.onLongPress,
  });

  final BoletoModel data;
  final VoidCallback? onTogglePaid;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final categoryColor = BoletoCategory.getColor(data.category);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedCard(
      direction: AnimatedCardDirection.top,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: data.isPaid ? 0.7 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkShape : AppColors.shape,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: data.isPaid
                      ? Colors.green.withOpacity(0.3)
                      : (isDark ? AppColors.darkStroke : AppColors.stroke),
                ),
              ),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: data.isPaid
                          ? Colors.green.withOpacity(0.1)
                          : categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      data.isPaid ? Icons.check_circle : BoletoCategory.getIcon(data.category),
                      color: data.isPaid ? Colors.green : categoryColor,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: AppTextStyles.titleListTile.copyWith(
                            decoration: data.isPaid ? TextDecoration.lineThrough : null,
                            decorationColor: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: data.isPaid
                                    ? Colors.green.withOpacity(0.1)
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data.isPaid ? 'PAID' : 'PENDING',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: data.isPaid ? Colors.green : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${data.category} • ${data.dueDate}',
                              style: AppTextStyles.captionBody,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Price & Toggle
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text.rich(TextSpan(
                        text: '\$ ',
                        style: AppTextStyles.trailingRegular,
                        children: [
                          TextSpan(
                            text: data.value.toStringAsFixed(2),
                            style: AppTextStyles.trailingBold.copyWith(
                              decoration: data.isPaid ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.grey,
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onTogglePaid,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: data.isPaid
                                ? Colors.green.withOpacity(0.1)
                                : (isDark ? AppColors.darkStroke : AppColors.stroke),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            data.isPaid ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 20,
                            color: data.isPaid ? Colors.green : AppColors.input,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
