import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/exam_session.dart';
import '../../../core/models/question.dart';
import '../../../core/providers/hive_provider.dart';
import '../../settings/providers/settings_provider.dart';

const _uuid = Uuid();

/// Immutable snapshot of the in-progress exam session.
class ExamState {
  final List<Question> questions;
  final int currentIndex;
  final List<String> selectedOptionIds;
  final String textAnswer;
  final bool isSubmitted;
  final bool isSessionComplete;
  final String topicId;
  final String sessionId;

  const ExamState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedOptionIds = const [],
    this.textAnswer = '',
    this.isSubmitted = false,
    this.isSessionComplete = false,
    this.topicId = '',
    this.sessionId = '',
  });

  Question? get currentQuestion =>
      questions.isEmpty || currentIndex >= questions.length
          ? null
          : questions[currentIndex];

  bool get isLastQuestion =>
      questions.isNotEmpty && currentIndex >= questions.length - 1;

  bool get hasSelection =>
      selectedOptionIds.isNotEmpty || textAnswer.isNotEmpty;

  ExamState copyWith({
    List<Question>? questions,
    int? currentIndex,
    List<String>? selectedOptionIds,
    String? textAnswer,
    bool? isSubmitted,
    bool? isSessionComplete,
    String? topicId,
    String? sessionId,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      textAnswer: textAnswer ?? this.textAnswer,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isSessionComplete: isSessionComplete ?? this.isSessionComplete,
      topicId: topicId ?? this.topicId,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class ExamSessionNotifier extends StateNotifier<ExamState> {
  final Ref _ref;

  ExamSessionNotifier(this._ref) : super(const ExamState());

  /// Whether the most recently submitted answer was correct.
  bool get isAnswerCorrect {
    final q = state.currentQuestion;
    if (q == null || !state.isSubmitted) return false;
    return q.isCorrect(state.selectedOptionIds, state.textAnswer);
  }

  /// Start a new exam session.
  Future<void> startSession({
    required String topicId,
    required List<Question> questions,
    required String sessionId,
  }) async {
    final hive = _ref.read(hiveServiceProvider);

    // Persist a new ExamSession to Hive immediately so it can be updated later.
    final session = ExamSession(
      id: sessionId,
      topicId: topicId,
      startedAt: DateTime.now(),
      totalQuestions: questions.length,
    );
    await hive.saveSession(session);

    state = ExamState(
      questions: questions,
      currentIndex: 0,
      topicId: topicId,
      sessionId: sessionId,
    );
  }

  /// Toggle / replace option selection depending on answer type.
  void selectOption(String optionId) {
    if (state.isSubmitted) return;
    final q = state.currentQuestion;
    if (q == null) return;

    if (q.answerType == AnswerType.multipleChoice) {
      state = state.copyWith(selectedOptionIds: [optionId]);
    } else if (q.answerType == AnswerType.multiSelect) {
      final current = List<String>.from(state.selectedOptionIds);
      if (current.contains(optionId)) {
        current.remove(optionId);
      } else {
        current.add(optionId);
      }
      state = state.copyWith(selectedOptionIds: current);
    }
  }

  void setTextAnswer(String text) {
    if (state.isSubmitted) return;
    state = state.copyWith(textAnswer: text);
  }

  /// Evaluate the answer, persist progress, update the session record.
  Future<void> submitAnswer() async {
    final q = state.currentQuestion;
    if (q == null || state.isSubmitted) return;

    final correct = q.isCorrect(state.selectedOptionIds, state.textAnswer);
    state = state.copyWith(isSubmitted: true);

    final hive = _ref.read(hiveServiceProvider);

    // Update topic progress
    final progress = hive.getOrCreateTopicProgress(q.topicId);
    progress.recordAnswer(questionId: q.id, isCorrect: correct);
    await hive.saveTopicProgress(progress);

    // Update ExamSession in Hive (increment counters)
    final session = hive.getSession(state.sessionId);
    if (session != null) {
      if (correct) {
        session.answeredCorrectly++;
        session.failedQuestionIds.remove(q.id);
      } else {
        if (!session.failedQuestionIds.contains(q.id)) {
          session.failedQuestionIds.add(q.id);
        }
      }
      await hive.saveSession(session);
    }
  }

  /// Move to the next question (or mark session complete on the last one).
  Future<void> nextQuestion() async {
    if (state.isLastQuestion) {
      await _finaliseSession();
      state = state.copyWith(isSessionComplete: true);
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedOptionIds: const [],
      textAnswer: '',
      isSubmitted: false,
    );
  }

  Future<void> _finaliseSession() async {
    final hive = _ref.read(hiveServiceProvider);
    final settings = _ref.read(userSettingsProvider);
    final session = hive.getSession(state.sessionId);
    if (session == null) return;

    session.completedAt = DateTime.now();
    session.isPassed = session.score >= settings.passingThreshold;
    await hive.saveSession(session);
  }

  /// Reset the notifier (called when navigating away from the exam).
  void reset() {
    state = const ExamState();
  }
}

final examSessionProvider =
    StateNotifierProvider<ExamSessionNotifier, ExamState>((ref) {
  return ExamSessionNotifier(ref);
});
