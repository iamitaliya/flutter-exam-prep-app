import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/models/question.dart';
import '../../../core/providers/question_data_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../core/services/question_loader_service.dart';
import '../../ads/widgets/banner_ad_widget.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/exam_provider.dart';

const _uuid = Uuid();

class QuestionScreen extends ConsumerStatefulWidget {
  final String topicId;
  final List<String>? reviewIds;

  const QuestionScreen({
    super.key,
    required this.topicId,
    this.reviewIds,
  });

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  bool _initialized = false;
  String _sessionId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  Future<void> _initSession() async {
    final questionData = await ref.read(questionDataProvider.future);
    final settings = ref.read(userSettingsProvider);

    final sampled = QuestionLoaderService.getSampledQuestions(
      questionData.questions,
      topicId:
          (widget.topicId == 'all' || widget.topicId == 'review')
              ? null
              : widget.topicId,
      limit: settings.questionsPerSession,
      onlyIds: widget.reviewIds,
    );

    if (sampled.isEmpty) {
      if (mounted) context.go(RouteNames.dashboard);
      return;
    }

    _sessionId = _uuid.v4();
    await ref.read(examSessionProvider.notifier).startSession(
          topicId: widget.topicId,
          questions: sampled,
          sessionId: _sessionId,
        );

    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examSessionProvider);

    // Navigate to results when session is complete
    ref.listen<ExamState>(examSessionProvider, (prev, next) {
      if (!prev!.isSessionComplete && next.isSessionComplete) {
        context.pushReplacement(
          RouteNames.results,
          extra: {'sessionId': _sessionId},
        );
      }
    });

    if (!_initialized || examState.currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return _QuestionView(
      examState: examState,
      topicId: widget.topicId,
    );
  }
}

class _QuestionView extends ConsumerWidget {
  final ExamState examState;
  final String topicId;

  const _QuestionView({required this.examState, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = examState.currentQuestion!;
    final notifier = ref.read(examSessionProvider.notifier);
    final isCorrect = notifier.isAnswerCorrect;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress header ──────────────────────────────────────────
            _ProgressHeader(examState: examState, topicId: topicId),

            // ── Scrollable question + answer area ────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question content
                    _QuestionContent(question: question),
                    const SizedBox(height: AppSpacing.xxl),

                    // Answer section
                    _AnswerSection(examState: examState, question: question),

                    // Explanation card (shown after wrong answer)
                    if (examState.isSubmitted && !isCorrect) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _ExplanationCard(explanation: question.explanation)
                          .animate()
                          .slideY(
                            begin: 0.3,
                            duration: 350.ms,
                            curve: Curves.easeOut,
                          )
                          .fadeIn(duration: 350.ms),
                    ],
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),

            // ── Bottom actions ───────────────────────────────────────────
            _BottomActions(examState: examState),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Progress Header
// ────────────────────────────────────────────────────────────────────────────

class _ProgressHeader extends ConsumerWidget {
  final ExamState examState;
  final String topicId;

  const _ProgressHeader({required this.examState, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = examState.questions.length;
    final current = examState.currentIndex + 1;
    final progress = total == 0 ? 0.0 : current / total;

    final questionDataAsync = ref.watch(questionDataProvider);
    final topicName = questionDataAsync.maybeWhen(
      data: (data) {
        if (topicId == 'all') return 'Mixed Topics';
        if (topicId == 'review') return 'Review Session';
        try {
          return data.topics.firstWhere((t) => t.id == topicId).name;
        } catch (_) {
          return 'Practice';
        }
      },
      orElse: () => 'Practice',
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _showExitDialog(context),
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textSecondary),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topicName,
                        style: AppTypography.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      'Question $current of $total',
                      style: AppTypography.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text(
            'Your progress for this session will be saved, but the current question will not be counted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(RouteNames.dashboard);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Question Content
// ────────────────────────────────────────────────────────────────────────────

class _QuestionContent extends StatelessWidget {
  final Question question;

  const _QuestionContent({required this.question});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Difficulty badge
        Row(
          children: [
            _DifficultyBadge(level: question.difficultyLevel),
            const SizedBox(width: AppSpacing.sm),
            _AnswerTypeBadge(answerType: question.answerType),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Question text
        Text(question.questionText, style: AppTypography.bodyLarge),

        // Image (if photo question)
        if (question.questionType == QuestionType.photo &&
            question.imageUrl != null) ...[
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            child: question.imageUrl!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: question.imageUrl!,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: AppColors.surface,
                      child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent)),
                    ),
                    errorWidget: (_, __, ___) => _ImagePlaceholder(),
                  )
                : _ImagePlaceholder(),
          ),
        ],

        // Video placeholder (if video question)
        if (question.questionType == QuestionType.video) ...[
          const SizedBox(height: AppSpacing.lg),
          _VideoPlaceholder(),
        ],
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: AppColors.textMuted, size: 40),
          SizedBox(height: AppSpacing.sm),
          Text('Image question',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_outline_rounded,
              color: AppColors.accent, size: 56),
          SizedBox(height: AppSpacing.sm),
          Text('Video question',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final int level;
  const _DifficultyBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final labels = ['', 'Easy', 'Medium', 'Hard'];
    final colors = [
      AppColors.textMuted,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];
    final safeLevel = level.clamp(1, 3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors[safeLevel].withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors[safeLevel].withOpacity(0.4)),
      ),
      child: Text(
        labels[safeLevel],
        style: AppTypography.labelSmall
            .copyWith(color: colors[safeLevel], fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AnswerTypeBadge extends StatelessWidget {
  final AnswerType answerType;
  const _AnswerTypeBadge({required this.answerType});

  @override
  Widget build(BuildContext context) {
    String label;
    switch (answerType) {
      case AnswerType.multipleChoice:
        label = 'Single choice';
        break;
      case AnswerType.multiSelect:
        label = 'Multi-select';
        break;
      case AnswerType.textEntry:
        label = 'Text entry';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall
            .copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Answer Section
// ────────────────────────────────────────────────────────────────────────────

class _AnswerSection extends ConsumerWidget {
  final ExamState examState;
  final Question question;

  const _AnswerSection(
      {required this.examState, required this.question});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (question.answerType) {
      case AnswerType.multipleChoice:
        return _ChoiceOptions(
          question: question,
          examState: examState,
          multiSelect: false,
        );
      case AnswerType.multiSelect:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select all that apply',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: AppSpacing.md),
            _ChoiceOptions(
              question: question,
              examState: examState,
              multiSelect: true,
            ),
          ],
        );
      case AnswerType.textEntry:
        return _TextEntryAnswer(examState: examState, question: question);
    }
  }
}

class _ChoiceOptions extends ConsumerWidget {
  final Question question;
  final ExamState examState;
  final bool multiSelect;

  const _ChoiceOptions({
    required this.question,
    required this.examState,
    required this.multiSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(examSessionProvider.notifier);

    return Column(
      children: question.options.map((option) {
        final isSelected =
            examState.selectedOptionIds.contains(option.id);
        final isCorrectOption =
            question.correctOptionIds.contains(option.id);

        // Determine visual state after submission
        Color bgColor = AppColors.answerDefault;
        Color borderColor = AppColors.border;
        Color textColor = AppColors.textPrimary;
        Widget? trailingIcon;

        if (examState.isSubmitted) {
          if (isSelected && isCorrectOption) {
            bgColor = AppColors.answerCorrect;
            borderColor = AppColors.success;
            textColor = AppColors.successLight;
            trailingIcon = const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20);
          } else if (isSelected && !isCorrectOption) {
            bgColor = AppColors.answerWrong;
            borderColor = AppColors.error;
            textColor = AppColors.errorLight;
            trailingIcon = const Icon(Icons.cancel_rounded,
                color: AppColors.error, size: 20);
          } else if (!isSelected && isCorrectOption) {
            // Missed correct answer
            bgColor = AppColors.answerMissed;
            borderColor = AppColors.success;
            textColor = AppColors.success;
            trailingIcon = const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 20);
          }
        } else if (isSelected) {
          bgColor = AppColors.answerSelected;
          borderColor = AppColors.accent;
          textColor = AppColors.accentLight;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: GestureDetector(
            onTap: examState.isSubmitted
                ? null
                : () => notifier.selectOption(option.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius:
                    BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  // Leading indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: multiSelect
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      borderRadius: multiSelect
                          ? BorderRadius.circular(6)
                          : null,
                      border: Border.all(
                        color: isSelected
                            ? borderColor
                            : AppColors.borderLight,
                        width: 2,
                      ),
                      color: isSelected
                          ? borderColor.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? Icon(
                            multiSelect ? Icons.check : Icons.circle,
                            size: multiSelect ? 14 : 10,
                            color: borderColor,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Option text
                  Expanded(
                    child: Text(
                      option.text,
                      style: AppTypography.bodyMedium
                          .copyWith(color: textColor),
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    trailingIcon,
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TextEntryAnswer extends ConsumerStatefulWidget {
  final ExamState examState;
  final Question question;

  const _TextEntryAnswer(
      {required this.examState, required this.question});

  @override
  ConsumerState<_TextEntryAnswer> createState() =>
      _TextEntryAnswerState();
}

class _TextEntryAnswerState extends ConsumerState<_TextEntryAnswer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(examSessionProvider.notifier);
    final isSubmitted = widget.examState.isSubmitted;
    final isCorrect = notifier.isAnswerCorrect;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: !isSubmitted,
          style: AppTypography.bodyLarge,
          onChanged: notifier.setTextAnswer,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Type your answer here…',
            suffixIcon: isSubmitted
                ? Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color:
                        isCorrect ? AppColors.success : AppColors.error,
                  )
                : null,
          ),
        ),
        if (isSubmitted && !isCorrect) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Correct answer: ${widget.question.correctTextAnswer ?? ''}',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Explanation Card
// ────────────────────────────────────────────────────────────────────────────

class _ExplanationCard extends StatelessWidget {
  final String explanation;

  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border:
            Border.all(color: AppColors.warning.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Explanation',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            explanation.isNotEmpty ? explanation : 'No explanation provided.',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Bottom Actions
// ────────────────────────────────────────────────────────────────────────────

class _BottomActions extends ConsumerWidget {
  final ExamState examState;

  const _BottomActions({required this.examState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(examSessionProvider.notifier);

    Widget button;

    if (!examState.isSubmitted) {
      button = SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: examState.hasSelection
              ? () => notifier.submitAnswer()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.border,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Confirm Answer',
            style: AppTypography.labelLarge
                .copyWith(fontSize: 16, color: examState.hasSelection ? Colors.black : AppColors.textMuted),
          ),
        ),
      );
    } else if (examState.isLastQuestion) {
      button = SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => notifier.nextQuestion(),
          icon: const Icon(Icons.bar_chart_rounded, size: 20),
          label: Text(
            'View Results',
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
      );
    } else {
      button = SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => notifier.nextQuestion(),
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          label: Text(
            'Next Question',
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
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
