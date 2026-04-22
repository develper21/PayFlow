import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:payflow/shared/services/connectivity_service.dart';
import 'package:payflow/shared/themes/app_colors.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();

    return AnimatedBuilder(
      animation: connectivityService,
      builder: (context, _) {
        final isOffline = !connectivityService.isConnected;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isOffline ? 32 : 0,
              color: AppColors.delete,
              child: isOffline
                  ? Row(
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
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class ConnectivityWrapper extends StatefulWidget {
  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final _connectivityService = ConnectivityService();

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _connectivityService,
      builder: (context, _) {
        final isOffline = !_connectivityService.isConnected;

        return Scaffold(
          body: Column(
            children: [
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
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}
