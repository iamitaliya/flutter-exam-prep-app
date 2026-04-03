import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/models/topic.dart';
import '../../../core/models/topic_progress.dart';
import '../../../core/providers/hive_provider.dart';
import '../../../core/providers/question_data_provider.dart';

class TopicWithProgress {
  final Topic topic;
  final TopicProgress? progress;

  const TopicWithProgress({
    required this.topic,
    required this.progress,
  });

  /// Convenience accessor: returns progress.strength or untested when absent.
  TopicStrength get strength => progress?.strength ?? TopicStrength.untested;

  /// Convenience accessor: returns progress.accuracy or 0.0 when absent.
  double get accuracy => progress?.accuracy ?? 0.0;
}

/// Returns a flat list of [TopicWithProgress] combining every known topic with
/// whatever progress data exists for it in Hive.
///
/// The provider is synchronous (plain [Provider]) so the UI can derive a
/// filtered/sorted list without any async gap – the heavy lifting is already
/// done by [questionDataProvider] (a [FutureProvider]).
final topicsWithProgressProvider = Provider<List<TopicWithProgress>>((ref) {
  final questionDataAsync = ref.watch(questionDataProvider);
  final hiveService = ref.watch(hiveServiceProvider);

  return questionDataAsync.when(
    data: (data) {
      final progressMap = {
        for (final p in hiveService.getAllTopicProgress()) p.topicId: p,
      };

      return data.topics.map((topic) {
        return TopicWithProgress(
          topic: topic,
          progress: progressMap[topic.id],
        );
      }).toList();
    },
    loading: () => const [],
    error: (_, __) => const [],
  );
});
