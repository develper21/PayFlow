import 'package:flutter/material.dart';

import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:payflow/modules/insert_boleto/insert_boleto_controller.dart';
import 'package:payflow/shared/models/boleto_model.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/app_text_styles.dart';
import 'package:payflow/shared/widgets/category_selector/category_selector_widget.dart';
import 'package:payflow/shared/widgets/input_text/input_text_widget.dart';
import 'package:payflow/shared/widgets/set_label_buttons/set_label_buttons.dart';

class InsertBoletoPage extends StatefulWidget {
  const InsertBoletoPage({
    super.key,
    this.barcode,
    this.boleto,
  });

  final String? barcode;
  final BoletoModel? boleto;

  bool get isEditing => boleto != null;

  @override
  State<InsertBoletoPage> createState() => _InsertBoletoPageState();
}

class _InsertBoletoPageState extends State<InsertBoletoPage> {
  final formKey = GlobalKey<FormState>();
  final controller = InsertBoletoController();
  final barcodeInputTextController = TextEditingController();
  final dueDateInputTextController = MaskedTextController(mask: '00/00/0000');
  final nameInputTextController = TextEditingController();

  final moneyInputTextController = MoneyMaskedTextController(
    leftSymbol: '\$',
    initialValue: 0,
    decimalSeparator: ',',
  );

  String selectedCategory = 'Others';

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.isEditing && widget.boleto != null) {
      // Pre-fill form with existing bill data for editing
      final boleto = widget.boleto!;

      setState(() {
        selectedCategory = boleto.category;
      });

      nameInputTextController.text = boleto.name;
      barcodeInputTextController.text = boleto.barcode;
      dueDateInputTextController.text = boleto.dueDate;
      moneyInputTextController.updateValue(boleto.value);

      // Initialize controller with existing data
      controller.onChange(
        name: boleto.name,
        dueDate: boleto.dueDate,
        value: boleto.value,
        barcode: boleto.barcode,
        category: boleto.category,
      );
    } else if (widget.barcode != null && widget.barcode!.isNotEmpty) {
      // New bill with scanned barcode
      barcodeInputTextController.text = widget.barcode!;
      controller.onChange(
        barcode: widget.barcode,
        category: selectedCategory,
      );
    } else {
      // New bill without barcode
      controller.onChange(category: selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: const BackButton(color: AppColors.input),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(93, 24, 93, 24),
                child: Text(
                  widget.isEditing ? 'Edit Bill' : 'Fill in the payment slip data',
                  style: AppTextStyles.titleBoldHeading,
                  textAlign: TextAlign.center,
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    InputTextWidget(
                      controller: nameInputTextController,
                      label: 'Boleto name',
                      icon: Icons.description_outlined,
                      onChanged: (value) => controller.onChange(name: value),
                      validator: controller.validateName,
                      keyboardType: TextInputType.name,
                    ),
                    CategorySelectorWidget(
                      selectedCategory: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                          controller.onChange(category: value);
                        });
                      },
                      validator: controller.validateCategory,
                    ),
                    InputTextWidget(
                      controller: dueDateInputTextController,
                      label: 'Due date',
                      icon: FontAwesomeIcons.circleXmark,
                      onChanged: (value) => controller.onChange(dueDate: value),
                      validator: controller.validateDueDate,
                    ),
                    InputTextWidget(
                      controller: moneyInputTextController,
                      label: 'Price',
                      icon: FontAwesomeIcons.wallet,
                      validator: (_) => controller.validateValue(
                        moneyInputTextController.numberValue,
                      ),
                      onChanged: (value) => controller.onChange(
                        value: moneyInputTextController.numberValue,
                      ),
                    ),
                    InputTextWidget(
                      controller: barcodeInputTextController,
                      label: 'Code',
                      icon: FontAwesomeIcons.barcode,
                      validator: controller.validateCode,
                      onChanged: (value) => controller.onChange(barcode: value),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.stroke,
          ),
          SetLabelButtons(
            enableSecondaryColor: true,
            labelPrimary: 'Cancel',
            onTapPrimary: () {
              Navigator.pop(context);
            },
            labelSecondary: widget.isEditing ? 'Save Changes' : 'Register',
            onTapSecondary: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (widget.isEditing && widget.boleto != null) {
                  // Update existing bill
                  await controller.updateBoleto(widget.boleto!);
                } else {
                  // Create new bill
                  await controller.saveBoleto();
                }
                if (!context.mounted) return;
                Navigator.pop(context);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }
}
