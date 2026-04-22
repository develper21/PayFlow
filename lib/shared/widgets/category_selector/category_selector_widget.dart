import 'package:flutter/material.dart';
import 'package:animated_card/animated_card.dart';
import 'package:payflow/shared/models/boleto_category.dart';
import 'package:payflow/shared/themes/app_colors.dart';

class CategorySelectorWidget extends StatelessWidget {
  const CategorySelectorWidget({
    super.key,
    required this.selectedCategory,
    required onChanged,
    this.validator,
  }) : _onChanged = onChanged;

  final String selectedCategory;
  final Function(String) _onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedCard(
      direction: AnimatedCardDirection.top,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: FormField<String>(
          initialValue: selectedCategory,
          validator: validator,
          builder: (FormFieldState<String> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _showCategoryPicker(context, field),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.darkStroke : AppColors.stroke,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          BoletoCategory.getIcon(selectedCategory),
                          color: BoletoCategory.getColor(selectedCategory),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 1,
                          height: 24,
                          color: isDark ? AppColors.darkStroke : AppColors.stroke,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            selectedCategory,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? AppColors.darkHeading : AppColors.heading,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: isDark ? AppColors.darkInput : AppColors.input,
                        ),
                      ],
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      field.errorText ?? '',
                      style: TextStyle(
                        color: AppColors.delete,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, FormFieldState<String> field) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkStroke : AppColors.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkHeading : AppColors.heading,
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: BoletoCategory.allCategories.length,
                  itemBuilder: (context, index) {
                    final category = BoletoCategory.allCategories[index];
                    final isSelected = category.name == selectedCategory;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          category.icon,
                          color: category.color,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          color: isDark ? AppColors.darkHeading : AppColors.heading,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        _onChanged(category.name);
                        field.didChange(category.name);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
