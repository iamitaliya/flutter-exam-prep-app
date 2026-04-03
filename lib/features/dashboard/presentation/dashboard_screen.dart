import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/exam_session.dart';
import '../../../core/models/topic_progress.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/topic_strength_badge.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final settings = ref.watch(userSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Dashboard', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.examPath('all')),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text('Quick Exam', style: AppTypography.labelLarge.copyWith(color: Colors.black)),
      ),
      body: dashboardAsync.when(
        loading: () => _DashboardShimmer(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text('Failed to load dashboard',
                    style: AppTypography.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(error.toString(),
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => ref.refresh(dashboardProvider),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (summary) {
          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () async {
              ref.refresh(dashboardProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.xxxl + AppSpacing.bannerAdHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Overall Progress header ----
                  _SectionHeader(title: 'Overall Progress'),
                  const SizedBox(height: AppSpacing.md),

                  // ---- Stats card ----
                  _OverallStatsCard(summary: summary),
                  const SizedBox(height: AppSpacing.xxl),

                  // ---- Topics at a Glance header ----
                  _SectionHeader(
                    title: 'Topics at a Glance',
                    action: TextButton(
                      onPressed: () => context.go(RouteNames.topics),
                      child: Text(
                        'See All',
                        style: AppTypography.labelLarge
                            .copyWith(color: AppColors.accent),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ---- Topics grid ----
                  _TopicsGlanceGrid(summary: summary),
                  const SizedBox(height: AppSpacing.xxl),

                  // ---- Recent Sessions header ----
                  _SectionHeader(title: 'Recent Sessions'),
                  const SizedBox(height: AppSpacing.md),

                  // ---- Session list ----
                  if (summary.recentSessions.isEmpty)
                    _EmptyState(
                      icon: Icons.history_rounded,
                      message: 'No sessions yet. Start a Quick Exam!',
                    )
                  else
                    ...summary.recentSessions
                        .map((session) => _SessionCard(session: session))
                        .toList(),

                  // ---- Banner ad placeholder ----
                  if (!settings.isPro) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _BannerAdPlaceholder(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overall Stats Card
// ---------------------------------------------------------------------------

class _OverallStatsCard extends StatelessWidget {
  final DashboardSummary summary;

  const _OverallStatsCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          // Accuracy display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                summary.overallAccuracy.percentStr,
                style: AppTypography.scoreDisplay,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  ' accuracy',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Stat chips row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(
                label: 'Correct',
                value: summary.totalCorrect.toString(),
                color: AppColors.success,
                icon: Icons.check_circle_outline_rounded,
              ),
              _StatChip(
                label: 'Attempted',
                value: summary.totalAttempted.toString(),
                color: AppColors.accent,
                icon: Icons.quiz_outlined,
              ),
              _StatChip(
                label: 'Strong',
                value: summary.strongCount.toString(),
                color: AppColors.strengthStrong,
                icon: Icons.trending_up_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Strength breakdown row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStrengthChip(
                  count: summary.strongCount,
                  label: 'Strong',
                  color: AppColors.strengthStrong),
              _MiniStrengthChip(
                  count: summary.averageCount,
                  label: 'Average',
                  color: AppColors.strengthAverage),
              _MiniStrengthChip(
                  count: summary.weakCount,
                  label: 'Weak',
                  color: AppColors.strengthWeak),
              _MiniStrengthChip(
                  count: summary.untestedCount,
                  label: 'Untested',
                  color: AppColors.strengthUntested),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style:
                  AppTypography.titleLarge.copyWith(color: color)),
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MiniStrengthChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _MiniStrengthChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: AppTypography.titleMedium.copyWith(color: color),
        ),
        Text(
          label,
          style:
              AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Topics Glance Grid
// ---------------------------------------------------------------------------

class _TopicsGlanceGrid extends ConsumerWidget {
  final DashboardSummary summary;

  const _TopicsGlanceGrid({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionDataAsync = ref.watch(questionDataProvider);
    final progressMap = ref.watch(topicProgressMapProvider);

    return questionDataAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final topics = data.topics;
        if (topics.isEmpty) {
          return _EmptyState(
            icon: Icons.menu_book_outlined,
            message: 'No topics available.',
          );
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.95,
          ),
          itemCount: topics.length,
          itemBuilder: (context, index) {
            final topic = topics[index];
            final progress = progressMap[topic.id];
            return _TopicGlanceCard(
              topicName: topic.name,
              accuracy: progress?.accuracy ?? 0.0,
              strength: progress?.strength ?? TopicStrength.untested,
              totalAttempted: progress?.totalAttempted ?? 0,
            );
          },
        );
      },
    );
  }
}

class _TopicGlanceCard extends StatelessWidget {
  final String topicName;
  final double accuracy;
  final TopicStrength strength;
  final int totalAttempted;

  const _TopicGlanceCard({
    required this.topicName,
    required this.accuracy,
    required this.strength,
    required this.totalAttempted,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Topic name
          Text(
            topicName,
            style: AppTypography.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          // Circular progress
          CircularPercentIndicator(
            radius: 32,
            lineWidth: 5,
            percent: accuracy.clamp(0.0, 1.0),
            center: Text(
              accuracy.percentStr,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.accent, fontWeight: FontWeight.w700),
            ),
            progressColor: AppColors.accent,
            backgroundColor: AppColors.border,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Strength badge
          TopicStrengthBadge(strength: strength),
          const SizedBox(height: AppSpacing.xs),
          // Questions attempted
          Text(
            '$totalAttempted attempted',
            style: AppTypography.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent Session Card
// ---------------------------------------------------------------------------

class _SessionCard extends ConsumerWidget {
  final ExamSession session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionDataAsync = ref.watch(questionDataProvider);

    final topicName = questionDataAsync.maybeWhen(
      data: (data) {
        if (session.topicId.isEmpty || session.topicId == 'all') {
          return 'Mixed';
        }
        try {
          return data.topics
              .firstWhere((t) => t.id == session.topicId)
              .name;
        } catch (_) {
          return 'Unknown Topic';
        }
      },
      orElse: () => session.topicId.isEmpty ? 'Mixed' : session.topicId,
    );

    final scoreColor = session.isPassed ? AppColors.success : AppColors.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Row(
          children: [
            // Score circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withOpacity(0.15),
                border: Border.all(color: scoreColor, width: 2),
              ),
              child: Center(
                child: Text(
                  '${session.scorePercent}%',
                  style: AppTypography.labelLarge.copyWith(color: scoreColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Topic + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topicName, style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    session.startedAt.relativeTime,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            // Pass / Fail chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scoreColor),
              ),
              child: Text(
                session.isPassed ? 'Pass' : 'Fail',
                style: AppTypography.labelSmall
                    .copyWith(color: scoreColor, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Banner Ad Placeholder
// ---------------------------------------------------------------------------

class _BannerAdPlaceholder extends StatelessWidget {
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
          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.headlineSmall),
        if (action != null) action!,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textMuted, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading Shimmer
// ---------------------------------------------------------------------------

class _DashboardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 160, height: 22, radius: 6),
            const SizedBox(height: AppSpacing.md),
            _ShimmerBox(
                width: double.infinity, height: 160, radius: AppSpacing.cardRadius),
            const SizedBox(height: AppSpacing.xxl),
            _ShimmerBox(width: 200, height: 22, radius: 6),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.95,
              children: List.generate(
                4,
                (_) => _ShimmerBox(
                    width: double.infinity,
                    height: double.infinity,
                    radius: AppSpacing.cardRadius),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _ShimmerBox(width: 160, height: 22, radius: 6),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ShimmerBox(
                    width: double.infinity,
                    height: 72,
                    radius: AppSpacing.cardRadius),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox(
      {required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
