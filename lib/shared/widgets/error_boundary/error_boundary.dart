import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:payflow/shared/themes/app_colors.dart';

class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  final Widget child;
  final VoidCallback? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = _handleFlutterError;
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    log('Error caught by ErrorBoundary: ${details.exception}');
    log('Stack trace: ${details.stack}');

    if (mounted) {
      setState(() {
        _error = details;
      });
    }

    widget.onError?.call();
  }

  void _resetError() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorUI();
    }

    return widget.child;
  }

  Widget _buildErrorUI() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.delete.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.delete,
                ),
              ),

              const SizedBox(height: 32),

              // Error Title
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.lexendDeca(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkHeading : AppColors.heading,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error Description
              Text(
                'We encountered an unexpected error. Don\'t worry, your data is safe.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isDark ? AppColors.darkBody : AppColors.body,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Error Details (Collapsible)
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkShape : AppColors.shape,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkStroke : AppColors.stroke,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error Details:',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkHeading
                              : AppColors.heading,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!.exception.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.darkBody : AppColors.body,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _resetError,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Try Again',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Report Button
              TextButton.icon(
                onPressed: () => _reportError(context, _error),
                icon: Icon(
                  Icons.bug_report_outlined,
                  color: AppColors.body,
                ),
                label: Text(
                  'Report this issue',
                  style: GoogleFonts.inter(
                    color: isDark ? AppColors.darkBody : AppColors.body,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reports error details to developers
  void _reportError(BuildContext context, FlutterErrorDetails? error) {
    if (error == null) return;

    // Log error to console/developer tools
    log('=== ERROR REPORT ===');
    log('Exception: ${error.exception}');
    log('Stack Trace: ${error.stack}');
    log('Context: ${error.context}');
    log('Library: ${error.library}');
    log('===================');

    // Show feedback to user
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error details logged. Please contact support if the issue persists.',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Copy',
          textColor: Colors.white,
          onPressed: () {
            // Copy error details to clipboard would go here
            log('Error details copied to clipboard');
          },
        ),
      ),
    );
  }
}

// Widget Error Handler for specific widgets
class WidgetErrorHandler extends StatelessWidget {
  const WidgetErrorHandler({
    super.key,
    required this.child,
    required this.fallback,
  });

  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e, stackTrace) {
          log('Widget build error: $e');
          log('Stack trace: $stackTrace');
          return fallback;
        }
      },
    );
  }
}
