import 'package:hive/hive.dart';

part 'exam_session_adapter.dart';

class ExamSession extends HiveObject {
  String id;
  String topicId; // empty string = mixed session
  DateTime startedAt;
  DateTime? completedAt;
  int totalQuestions;
  int answeredCorrectly;
  List<String> failedQuestionIds;
  bool isPassed;

  ExamSession({
    required this.id,
    required this.topicId,
    required this.startedAt,
    this.completedAt,
    required this.totalQuestions,
    this.answeredCorrectly = 0,
    List<String>? failedQuestionIds,
    this.isPassed = false,
  }) : failedQuestionIds = failedQuestionIds ?? [];

  double get score =>
      totalQuestions == 0 ? 0 : answeredCorrectly / totalQuestions;

  int get scorePercent => (score * 100).round();

  bool get isCompleted => completedAt != null;

  int get incorrectCount => totalQuestions - answeredCorrectly;
}
