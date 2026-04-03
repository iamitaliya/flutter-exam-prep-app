import 'package:hive/hive.dart';
import '../constants/app_constants.dart';

part 'topic_progress_adapter.dart';

enum TopicStrength { untested, weak, average, strong }

class TopicProgress extends HiveObject {
  String topicId;
  int totalAttempted;
  int totalCorrect;
  List<String> failedQuestionIds;
  DateTime lastAttemptedAt;

  TopicProgress({
    required this.topicId,
    this.totalAttempted = 0,
    this.totalCorrect = 0,
    List<String>? failedQuestionIds,
    DateTime? lastAttemptedAt,
  })  : failedQuestionIds = failedQuestionIds ?? [],
        lastAttemptedAt = lastAttemptedAt ?? DateTime.now();

  double get accuracy =>
      totalAttempted == 0 ? 0 : totalCorrect / totalAttempted;

  TopicStrength get strength {
    if (totalAttempted == 0) return TopicStrength.untested;
    if (accuracy >= AppConstants.strongThreshold) return TopicStrength.strong;
    if (accuracy >= AppConstants.averageThreshold) return TopicStrength.average;
    return TopicStrength.weak;
  }

  void recordAnswer({required String questionId, required bool isCorrect}) {
    totalAttempted++;
    if (isCorrect) {
      totalCorrect++;
      failedQuestionIds.remove(questionId);
    } else {
      if (!failedQuestionIds.contains(questionId)) {
        failedQuestionIds.add(questionId);
      }
    }
    lastAttemptedAt = DateTime.now();
  }
}
