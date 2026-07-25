import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/models/exam_session.dart';
import '../../../core/models/topic_progress.dart';
import '../../../core/providers/hive_provider.dart';
import '../../../core/providers/question_data_provider.dart';

class DashboardSummary {
  final double overallAccuracy;
  final int totalAttempted;
  final int totalCorrect;
  final int strongCount;
  final int averageCount;
  final int weakCount;
  final int untestedCount;
  final List<ExamSession> recentSessions;

  const DashboardSummary({
    required this.overallAccuracy,
    required this.totalAttempted,
    required this.totalCorrect,
    required this.strongCount,
    required this.averageCount,
    required this.weakCount,
    required this.untestedCount,
    required this.recentSessions,
  });
}

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  final hiveService = ref.watch(hiveServiceProvider);
  final questionData = await ref.watch(questionDataProvider.future);

  final allTopics = questionData.topics;
  final allProgress = hiveService.getAllTopicProgress();

  // Build a map for fast lookup
  final progressMap = {for (final p in allProgress) p.topicId: p};

  int totalAttempted = 0;
  int totalCorrect = 0;
  int strongCount = 0;
  int averageCount = 0;
  int weakCount = 0;
  int untestedCount = 0;

  for (final topic in allTopics) {
    final progress = progressMap[topic.id];
    if (progress == null || progress.totalAttempted == 0) {
      untestedCount++;
    } else {
      totalAttempted += progress.totalAttempted;
      totalCorrect += progress.totalCorrect;
      switch (progress.strength) {
        case TopicStrength.strong:
          strongCount++;
          break;
        case TopicStrength.average:
          averageCount++;
          break;
        case TopicStrength.weak:
          weakCount++;
          break;
        case TopicStrength.untested:
          untestedCount++;
          break;
      }
    }
  }

  final overallAccuracy =
      totalAttempted == 0 ? 0.0 : totalCorrect / totalAttempted;

  final recentSessions = hiveService.getRecentSessions(5);

  return DashboardSummary(
    overallAccuracy: overallAccuracy,
    totalAttempted: totalAttempted,
    totalCorrect: totalCorrect,
    strongCount: strongCount,
    averageCount: averageCount,
    weakCount: weakCount,
    untestedCount: untestedCount,
    recentSessions: recentSessions,
  );
});

final topicProgressMapProvider = Provider<Map<String, TopicProgress>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  final allProgress = hiveService.getAllTopicProgress();
  return {for (final p in allProgress) p.topicId: p};
});
