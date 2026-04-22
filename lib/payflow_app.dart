import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:payflow/modules/barcode_scanner/barcode_scanner_page.dart';
import 'package:payflow/modules/home/home_page.dart';
import 'package:payflow/modules/insert_boleto/insert_boleto_page.dart';
import 'package:payflow/modules/login/login_page.dart';
import 'package:payflow/modules/profile/profile_page.dart';
import 'package:payflow/modules/splash/splash_page.dart';
import 'package:payflow/shared/models/user_model.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/app_theme.dart';
import 'package:payflow/shared/themes/theme_controller.dart';

class PayFlowApp extends StatefulWidget {
  const PayFlowApp({super.key});

  @override
  State<PayFlowApp> createState() => _PayFlowAppState();
}

class _PayFlowAppState extends State<PayFlowApp> {
  final themeController = ThemeController();

  @override
  void dispose() {
    themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, child) {
        final isDark = themeController.isDarkMode;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: isDark ? AppColors.darkPrimary : AppColors.primary,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: isDark ? AppColors.darkBackground : AppColors.background,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'PayFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashPage(),
            '/home': (context) => HomePage(
                  user: ModalRoute.of(context)?.settings.arguments as UserModel,
                  themeController: themeController,
                ),
            '/login': (context) => const LoginPage(),
            '/barcode_scanner': (context) => const BarcodeScannerPage(),
            '/insert_boleto': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              // Check if argument is BoletoModel (for editing) or String (barcode for new)
              if (args is BoletoModel) {
                return InsertBoletoPage(boleto: args);
              } else if (args is String) {
                return InsertBoletoPage(barcode: args);
              } else {
                return const InsertBoletoPage();
              }
            },
            '/profile': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              return ProfilePage(
                user: args?['user'] as UserModel,
                themeController: args?['themeController'] as ThemeController,
              );
            },
          },
        );
      },
    );
  }
}
