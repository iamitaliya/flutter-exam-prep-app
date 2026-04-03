import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/exam_session.dart';
import '../../../core/providers/hive_provider.dart';
import '../../../core/providers/question_data_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_card.dart';

class ResultsScreen extends ConsumerWidget {
  final String sessionId;

  const ResultsScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hive = ref.read(hiveServiceProvider);
    final session = hive.getSession(sessionId);

    if (session == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text('Session not found', style: AppTypography.headlineMedium),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.dashboard),
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    return _ResultsView(session: session);
  }
}

class _ResultsView extends ConsumerWidget {
  final ExamSession session;

  const _ResultsView({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionDataAsync = ref.watch(questionDataProvider);
    final scorePercent = session.scorePercent;
    final isPassed = session.isPassed;
    final scoreColor = isPassed ? AppColors.success : AppColors.error;

    final topicName = questionDataAsync.maybeWhen(
      data: (data) {
        if (session.topicId.isEmpty || session.topicId == 'all') {
          return 'Mixed Session';
        }
        if (session.topicId == 'review') return 'Review Session';
        try {
          return data.topics.firstWhere((t) => t.id == session.topicId).name;
        } catch (_) {
          return 'Practice Session';
        }
      },
      orElse: () => 'Practice Session',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: Text('Results', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary),
            onPressed: () => context.go(RouteNames.dashboard),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Score circle ───────────────────────────────────────────────
            Center(
              child: CircularPercentIndicator(
                radius: 80,
                lineWidth: 10,
                percent: session.score.clamp(0.0, 1.0),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$scorePercent%',
                      style: AppTypography.scoreDisplay
                          .copyWith(color: scoreColor),
                    ),
                    Text(
                      isPassed ? 'Pass' : 'Fail',
                      style: AppTypography.titleMedium
                          .copyWith(color: scoreColor),
                    ),
                  ],
                ),
                progressColor: scoreColor,
                backgroundColor: AppColors.border,
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
                animationDuration: 1200,
              ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Pass / Fail banner ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: scoreColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPassed
                        ? Icons.emoji_events_rounded
                        : Icons.replay_rounded,
                    color: scoreColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isPassed
                        ? 'Congratulations! You passed!'
                        : 'Keep practicing — you\'ll get it!',
                    style: AppTypography.titleMedium
                        .copyWith(color: scoreColor),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: AppSpacing.xxl),

            // ── Stat cards ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total',
                    value: session.totalQuestions.toString(),
                    icon: Icons.quiz_outlined,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Correct',
                    value: session.answeredCorrectly.toString(),
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Wrong',
                    value: (session.totalQuestions -
                            session.answeredCorrectly)
                        .toString(),
                    icon: Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                ),
              ],
            ).animate().slideY(
                  begin: 0.2,
                  delay: 400.ms,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Session info ───────────────────────────────────────────────
            AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.menu_book_outlined,
                    label: 'Topic',
                    value: topicName,
                  ),
                  const Divider(color: AppColors.border, height: 16),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: session.startedAt.formattedDate,
                  ),
                  if (session.completedAt != null) ...[
                    const Divider(color: AppColors.border, height: 16),
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: _formatDuration(
                          session.completedAt!
                              .difference(session.startedAt)),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: AppSpacing.xxl),

            // ── Action buttons ─────────────────────────────────────────────
            if (session.failedQuestionIds.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(
                    RouteNames.review,
                    extra: {'sessionId': session.id},
                  ),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Review Failed Questions'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate back to same topic exam
                  context.pushReplacement(
                    RouteNames.examPath(session.topicId.isEmpty
                        ? 'all'
                        : session.topicId),
                  );
                },
                icon: const Icon(Icons.replay_rounded, size: 20),
                label: Text(
                  'Try Again',
                  style: AppTypography.labelLarge
                      .copyWith(fontSize: 16, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => context.go(RouteNames.dashboard),
                icon: const Icon(Icons.dashboard_outlined),
                label: const Text('Go to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes < 1) return '${d.inSeconds}s';
    if (d.inHours < 1) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(color: color),
          ),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppTypography.bodySmall),
        const Spacer(),
        Text(value, style: AppTypography.titleMedium),
      ],
    );
  }
}
