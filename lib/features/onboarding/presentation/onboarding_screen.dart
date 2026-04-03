import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../settings/providers/settings_provider.dart';

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });
}

const _pages = [
  _OnboardingPage(
    icon: Icons.quiz_rounded,
    title: 'Master Any Exam',
    body:
        'Practice with thousands of questions across multiple topics and formats.',
  ),
  _OnboardingPage(
    icon: Icons.analytics_rounded,
    title: 'Track Your Progress',
    body:
        'See exactly which topics need more work with detailed analytics and strength indicators.',
  ),
  _OnboardingPage(
    icon: Icons.workspace_premium_rounded,
    title: 'Free & Pro Tiers',
    body:
        'Use the app for free with ads, or upgrade to Pro for an ad-free premium experience.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isLoading = true);
      await ref.read(userSettingsProvider.notifier).completeOnboarding();
      if (mounted) {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _OnboardingPageView(
                    page: _pages[index],
                    isActive: index == _currentPage,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.lg,
                AppSpacing.screenPadding,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Next / Get Started button
                  PrimaryButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    isLoading: _isLoading,
                    onPressed: _handleNext,
                    icon: _currentPage == _pages.length - 1
                        ? Icons.arrow_forward_rounded
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  final bool isActive;

  const _OnboardingPageView({
    required this.page,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 100,
            color: AppColors.accent,
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(duration: 500.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.7, 0.7),
                end: const Offset(1.0, 1.0),
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            page.title,
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 100.ms, duration: 500.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.25,
                end: 0.0,
                delay: 100.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.body,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0)
              .fadeIn(delay: 200.ms, duration: 500.ms, curve: Curves.easeOut)
              .slideY(
                begin: 0.25,
                end: 0.0,
                delay: 200.ms,
                duration: 500.ms,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }
}
