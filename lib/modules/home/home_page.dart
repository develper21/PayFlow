import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:payflow/modules/extract/extract_page.dart';

import 'package:payflow/modules/home/home_controller.dart';
import 'package:payflow/modules/my_boletos/my_boletos_page.dart';
import 'package:payflow/shared/models/user_model.dart';
import 'package:payflow/shared/services/connectivity_service.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/app_images.dart';
import 'package:payflow/shared/themes/theme_controller.dart';
import 'package:payflow/shared/widgets/connectivity_banner/connectivity_banner.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.user,
    required this.themeController,
  });

  final UserModel user;
  final ThemeController themeController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _connectivityService = ConnectivityService();

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = HomeController();
    final isDark = widget.themeController.isDarkMode;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _connectivityService,
      builder: (context, _) {
        final isOffline = !_connectivityService.isConnected;
        return Scaffold(
          body: Column(
            children: [
              // Offline Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isOffline ? 36 : 0,
                color: AppColors.delete,
                child: isOffline
                    ? SafeArea(
                        bottom: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wifi_off,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No internet connection',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
              Expanded(
                child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(152),
        child: Container(
          height: 152,
          padding: const EdgeInsets.only(top: 40),
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
          child: Center(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text.rich(
                TextSpan(
                  text: 'Hello, ',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: widget.user.name.split(' ').first,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              subtitle: Text(
                'Keep your accounts up to date',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => widget.themeController.toggleTheme(),
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: {
                          'user': widget.user,
                          'themeController': widget.themeController,
                        },
                      );
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(5),
                        image: DecorationImage(
                          image: NetworkImage(
                            widget.user.photoURL ?? AppImages.logomini,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: controller.currentPage,
        builder: (_, value, __) {
          return PageView(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              MyBoletosPage(),
              ExtractPage(),
            ],
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  controller.setPage(0);
                });
              },
              icon: Icon(
                Icons.home,
                color: isDark ? AppColors.darkBody : AppColors.body,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  '/barcode_scanner',
                );
                setState(() {});
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.add_box_outlined,
                  color: isDark ? AppColors.darkBackground : AppColors.background,
                ),
              ),
            ),
            IconButton(
              onPressed: () async {
                setState(() {
                  controller.setPage(1);
                });
              },
              icon: Icon(
                Icons.description_outlined,
                color: isDark ? AppColors.darkBody : AppColors.body,
              ),
            ),
          ],
        ),
      ),
    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
