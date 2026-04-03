import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../settings/providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Load settings while the splash is visible
    await ref.read(userSettingsProvider.notifier).load();

    // Wait for the 2-second splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final settings = ref.read(userSettingsProvider);
    if (settings.onboardingComplete) {
      context.go('/dashboard');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 80,
              color: AppColors.accent,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 24),
            Text(
              'ExamPrep',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.accent,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.0, 1.0),
                  delay: 200.ms,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 12),
            Text(
              'Ace Your Exams',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms, curve: Curves.easeOut)
                .slideY(
                  begin: 0.3,
                  end: 0.0,
                  delay: 400.ms,
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
