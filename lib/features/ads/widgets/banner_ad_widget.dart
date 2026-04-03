import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../settings/providers/settings_provider.dart';

/// Displays a Google AdMob banner ad for free-tier users.
///
/// For Pro users ([UserSettings.isPro] == true) this widget returns an empty
/// [SizedBox] so it takes no space in the layout.
///
/// During development the test ad unit IDs defined in [AppConstants] are used.
/// Replace them with your real ad unit IDs before shipping.
class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = Platform.isAndroid
        ? AppConstants.bannerAdUnitIdAndroid
        : AppConstants.bannerAdUnitIdIos;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If user is Pro, take zero space
    final isPro = ref.watch(userSettingsProvider.select((s) => s.isPro));
    if (isPro) return const SizedBox.shrink();

    // Ad is loading or failed to load – show a reserved space so the layout
    // doesn't shift when the ad appears.
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(height: AppSpacing.bannerAdHeight);
    }

    return SizedBox(
      height: AppSpacing.bannerAdHeight,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Lightweight non-interactive placeholder used during initial loading or
/// when the real [BannerAdWidget] is not yet available. Useful for shimmer
/// or skeleton screens.
class BannerAdPlaceholder extends StatelessWidget {
  const BannerAdPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.bannerAdHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          'Advertisement',
          style:
              AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}
