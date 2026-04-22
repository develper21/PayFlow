import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:payflow/shared/auth/auth_controller.dart';
import 'package:payflow/shared/models/user_model.dart';
import 'package:payflow/shared/themes/app_colors.dart';
import 'package:payflow/shared/themes/theme_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.user,
    required this.themeController,
  });

  final UserModel user;
  final ThemeController themeController;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedUser = UserModel(
        name: _nameController.text.trim(),
        photoURL: widget.user.photoURL,
      );

      await _authController.saveUser(updatedUser);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated successfully!',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.lexendDeca(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.body),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(color: AppColors.delete),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await _authController.logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.lexendDeca(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Picture
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkShape : AppColors.shape,
                  border: Border.all(
                    color: isDark ? AppColors.darkStroke : AppColors.stroke,
                    width: 3,
                  ),
                  image: widget.user.photoURL != null
                      ? DecorationImage(
                          image: NetworkImage(widget.user.photoURL!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.user.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: isDark ? AppColors.darkInput : AppColors.input,
                      )
                    : null,
              ),

              const SizedBox(height: 24),

              // User Email/Info
              Text(
                widget.user.name,
                style: GoogleFonts.lexendDeca(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkHeading : AppColors.heading,
                ),
              ),

              const SizedBox(height: 40),

              // Edit Name Field
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isDark ? AppColors.darkHeading : AppColors.heading,
                ),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: GoogleFonts.inter(
                    color: isDark ? AppColors.darkInput : AppColors.input,
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: isDark ? AppColors.darkInput : AppColors.input,
                  ),
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
                  filled: true,
                  fillColor: isDark ? AppColors.darkShape : AppColors.shape,
                ),
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return 'Please enter your name';
                  }
                  if (value!.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Theme Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkShape : AppColors.shape,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkStroke : AppColors.stroke,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkPrimary.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkHeading
                                  : AppColors.heading,
                            ),
                          ),
                          Text(
                            isDark ? 'Dark Mode' : 'Light Mode',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkBody
                                  : AppColors.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (_) => widget.themeController.toggleTheme(),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // App Version
              Text(
                'PayFlow v2.0.1',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppColors.darkInput : AppColors.input,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
