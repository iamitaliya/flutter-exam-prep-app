import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/hive_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final notifier = ref.read(userSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Settings', style: AppTypography.headlineMedium),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          // ── ACCOUNT ──────────────────────────────────────────────────────
          _SectionHeader('Account'),
          SwitchListTile(
            value: settings.isPro,
            onChanged: (v) => notifier.setIsPro(v),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.accent, size: 20),
            ),
            title: Text('Pro Mode', style: AppTypography.titleMedium),
            subtitle: Text(
              'Testing only · Remove ads and unlock Pro features',
              style: AppTypography.bodySmall,
            ),
          ),
          _Divider(),

          // ── EXAM CONFIGURATION ────────────────────────────────────────────
          _SectionHeader('Exam Configuration'),
          ListTile(
            leading: _LeadingIcon(Icons.format_list_numbered_rounded,
                AppColors.accentLight),
            title: Text('Questions per Session',
                style: AppTypography.titleMedium),
            subtitle: Text('${settings.questionsPerSession} questions',
                style: AppTypography.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
            onTap: () => _showQuestionsDialog(context, ref, settings),
          ),
          _SettingsTile(
            icon: Icons.percent_rounded,
            iconColor: AppColors.success,
            title: 'Passing Score',
            subtitle: '${(settings.passingThreshold * 100).round()}% required to pass',
            bottom: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Slider(
                    value: settings.passingThreshold,
                    min: 0.5,
                    max: 0.9,
                    divisions: 8,
                    label:
                        '${(settings.passingThreshold * 100).round()}%',
                    onChanged: (v) => notifier.setPassingThreshold(v),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('50%', style: AppTypography.labelSmall),
                        Text('90%', style: AppTypography.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Divider(),

          // ── APPEARANCE ────────────────────────────────────────────────────
          _SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    for (final mode in ['system', 'light', 'dark'])
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: mode != 'dark' ? AppSpacing.sm : 0),
                          child: _ThemeChoice(
                            label: mode[0].toUpperCase() + mode.substring(1),
                            isSelected: settings.themeMode == mode,
                            onTap: () => notifier.setThemeMode(mode),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _Divider(),

          // ── DATA ─────────────────────────────────────────────────────────
          _SectionHeader('Data'),
          ListTile(
            leading: _LeadingIcon(
                Icons.delete_sweep_rounded, AppColors.error),
            title: Text('Reset All Progress',
                style:
                    AppTypography.titleMedium.copyWith(color: AppColors.error)),
            subtitle: Text('This cannot be undone',
                style: AppTypography.bodySmall),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
            onTap: () => _showResetDialog(context, ref),
          ),
          _Divider(),

          // ── ABOUT ─────────────────────────────────────────────────────────
          _SectionHeader('About'),
          ListTile(
            leading:
                _LeadingIcon(Icons.info_outline_rounded, AppColors.textMuted),
            title: Text('Version', style: AppTypography.titleMedium),
            subtitle:
                Text('ExamPrep v1.0.0', style: AppTypography.bodySmall),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
            child: Text(
              'Pro features (ad removal, unlimited sessions) coming soon via in-app purchase.',
              style:
                  AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionsDialog(
      BuildContext context, WidgetRef ref, UserSettings settings) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Questions per Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [10, 20, 30, 50].map((count) {
              final selected = settings.questionsPerSession == count;
              return RadioListTile<int>(
                value: count,
                groupValue: settings.questionsPerSession,
                activeColor: AppColors.accent,
                title: Text('$count questions',
                    style: AppTypography.bodyLarge.copyWith(
                      color: selected
                          ? AppColors.accent
                          : AppColors.textPrimary,
                    )),
                onChanged: (v) {
                  if (v != null) {
                    ref
                        .read(userSettingsProvider.notifier)
                        .setQuestionsPerSession(v);
                  }
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reset All Progress?'),
          content: const Text(
            'All your topic progress, session history, and failed question lists will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final hive = ref.read(hiveServiceProvider);
                await hive.clearAllProgress();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All progress has been reset.'),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}

// ── Private helper widgets ────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.accent,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
        color: AppColors.border, height: 1, indent: AppSpacing.lg);
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _LeadingIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? bottom;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: _LeadingIcon(icon, iconColor),
          title: Text(title, style: AppTypography.titleMedium),
          subtitle: Text(subtitle, style: AppTypography.bodySmall),
        ),
        if (bottom != null) bottom!,
      ],
    );
  }
}
