import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/question.dart';
import '../../../core/providers/hive_provider.dart';
import '../../../core/providers/question_data_provider.dart';
import '../../../core/router/route_names.dart';

class ReviewScreen extends ConsumerWidget {
  final String sessionId;

  const ReviewScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hive = ref.read(hiveServiceProvider);
    final session = hive.getSession(sessionId);

    if (session == null || session.failedQuestionIds.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text('Review Mistakes', style: AppTypography.headlineMedium),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.success, size: 64),
              const SizedBox(height: AppSpacing.md),
              Text('No mistakes to review!',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'You answered everything correctly.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.dashboard),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    final failedIds = session.failedQuestionIds;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Review Mistakes', style: AppTypography.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Text(
                    '${failedIds.length} mistakes',
                    style: AppTypography.labelSmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ref.watch(questionDataProvider).when(
            loading: () => const Center(
              child:
                  CircularProgressIndicator(color: AppColors.accent),
            ),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (data) {
              final failedQuestions = data.questions
                  .where((q) => failedIds.contains(q.id))
                  .toList();

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      itemCount: failedQuestions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return _ReviewQuestionTile(
                            question: failedQuestions[index]);
                      },
                    ),
                  ),
                  // Practice again button
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushReplacement(
                            RouteNames.examPath('review'),
                            extra: {'reviewIds': failedIds},
                          );
                        },
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: Text(
                          'Practice These Again',
                          style: AppTypography.labelLarge.copyWith(
                              fontSize: 16, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _ReviewQuestionTile extends StatelessWidget {
  final Question question;

  const _ReviewQuestionTile({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context)
            .copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            0,
            AppSpacing.cardPadding,
            AppSpacing.cardPadding,
          ),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.close_rounded,
                  color: AppColors.error, size: 16),
            ),
          ),
          title: Text(
            question.questionText,
            style: AppTypography.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _typeLabel(question.answerType),
              style: AppTypography.labelSmall,
            ),
          ),
          iconColor: AppColors.accent,
          collapsedIconColor: AppColors.textMuted,
          children: [
            // Full question text (if truncated above)
            if (question.questionText.length > 80) ...[
              Text(question.questionText,
                  style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.md),
            ],

            // Options list
            if (question.options.isNotEmpty) ...[
              Text('Options',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              ...question.options.map((opt) {
                final isCorrect =
                    question.correctOptionIds.contains(opt.id);
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isCorrect
                            ? AppColors.success
                            : AppColors.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          opt.text,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isCorrect
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: isCorrect
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.md),
            ],

            // Text answer
            if (question.correctTextAnswer != null) ...[
              Text('Correct Answer:',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                question.correctTextAnswer!,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.success),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Explanation
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          color: AppColors.warning, size: 16),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Explanation',
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    question.explanation.isNotEmpty
                        ? question.explanation
                        : 'No explanation provided.',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(AnswerType type) {
    switch (type) {
      case AnswerType.multipleChoice:
        return 'Single choice';
      case AnswerType.multiSelect:
        return 'Multi-select';
      case AnswerType.textEntry:
        return 'Text entry';
    }
  }
}
