import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BoletoCategory {
  const BoletoCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;

  static const List<BoletoCategory> allCategories = [
    BoletoCategory(
      name: 'Utilities',
      icon: FontAwesomeIcons.bolt,
      color: Color(0xFFFF941A),
    ),
    BoletoCategory(
      name: 'Water',
      icon: FontAwesomeIcons.water,
      color: Color(0xFF2196F3),
    ),
    BoletoCategory(
      name: 'Internet',
      icon: FontAwesomeIcons.wifi,
      color: Color(0xFF9C27B0),
    ),
    BoletoCategory(
      name: 'Phone',
      icon: FontAwesomeIcons.phone,
      color: Color(0xFF4CAF50),
    ),
    BoletoCategory(
      name: 'Rent',
      icon: FontAwesomeIcons.house,
      color: Color(0xFF795548),
    ),
    BoletoCategory(
      name: 'Credit Card',
      icon: FontAwesomeIcons.creditCard,
      color: Color(0xFFE91E63),
    ),
    BoletoCategory(
      name: 'Insurance',
      icon: FontAwesomeIcons.shield,
      color: Color(0xFF607D8B),
    ),
    BoletoCategory(
      name: 'Taxes',
      icon: FontAwesomeIcons.fileInvoiceDollar,
      color: Color(0xFFF44336),
    ),
    BoletoCategory(
      name: 'Education',
      icon: FontAwesomeIcons.graduationCap,
      color: Color(0xFF3F51B5),
    ),
    BoletoCategory(
      name: 'Health',
      icon: FontAwesomeIcons.heartPulse,
      color: Color(0xFFE91E63),
    ),
    BoletoCategory(
      name: 'Others',
      icon: FontAwesomeIcons.fileLines,
      color: Color(0xFF9E9E9E),
    ),
  ];

  static BoletoCategory getCategory(String name) {
    return allCategories.firstWhere(
      (category) => category.name == name,
      orElse: () => allCategories.last,
    );
  }

  static IconData getIcon(String name) {
    return getCategory(name).icon;
  }

  static Color getColor(String name) {
    return getCategory(name).color;
  }

  static List<String> get categoryNames {
    return allCategories.map((c) => c.name).toList();
  }
}
