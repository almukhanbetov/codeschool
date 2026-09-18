import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Branded launch/boot screen shown while [ApiClient.restoreSession] runs.
/// Real screen (not a placeholder) — every production app needs one while
/// the session-restore async gap resolves.
class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.gradientDark : AppColors.gradientLight;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'CodeSchool.kz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
