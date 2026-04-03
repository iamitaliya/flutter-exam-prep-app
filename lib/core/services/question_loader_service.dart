import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/topic.dart';
import '../constants/app_constants.dart';

class QuestionData {
  final List<Topic> topics;
  final List<Question> questions;

  const QuestionData({required this.topics, required this.questions});
}

class QuestionLoaderService {
  static QuestionData? _cache;

  static Future<QuestionData> load() async {
    if (_cache != null) return _cache!;

    final jsonStr = await rootBundle.loadString(AppConstants.questionsDataPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;

    final topics = (json['topics'] as List<dynamic>)
        .map((t) => Topic.fromJson(t as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final questions = (json['questions'] as List<dynamic>)
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    _cache = QuestionData(topics: topics, questions: questions);
    return _cache!;
  }

  static List<Question> getQuestionsForTopic(
    List<Question> all,
    String topicId,
  ) {
    return all.where((q) => q.topicId == topicId).toList();
  }

  static List<Question> getQuestionsById(
    List<Question> all,
    List<String> ids,
  ) {
    final idSet = ids.toSet();
    return all.where((q) => idSet.contains(q.id)).toList();
  }

  static List<Question> getSampledQuestions(
    List<Question> all, {
    String? topicId,
    int limit = 20,
    List<String>? onlyIds,
  }) {
    List<Question> pool;

    if (onlyIds != null) {
      pool = getQuestionsById(all, onlyIds);
    } else if (topicId != null && topicId.isNotEmpty) {
      pool = getQuestionsForTopic(all, topicId);
    } else {
      pool = List.from(all);
    }

    pool.shuffle();
    return pool.take(limit).toList();
  }
}
