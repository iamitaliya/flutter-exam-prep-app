import 'package:hive_flutter/hive_flutter.dart';
import '../models/topic_progress.dart';
import '../models/exam_session.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Box<TopicProgress>? _topicProgressBox;
  static Box<ExamSession>? _examSessionBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TopicProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExamSessionAdapter());
    }
    _topicProgressBox = await Hive.openBox<TopicProgress>(
      AppConstants.topicProgressBox,
    );
    _examSessionBox = await Hive.openBox<ExamSession>(
      AppConstants.examSessionBox,
    );
  }

  static Box<TopicProgress> get topicProgressBox {
    assert(_topicProgressBox != null, 'HiveService not initialized');
    return _topicProgressBox!;
  }

  static Box<ExamSession> get examSessionBox {
    assert(_examSessionBox != null, 'HiveService not initialized');
    return _examSessionBox!;
  }

  // --- Topic Progress ---

  TopicProgress getOrCreateTopicProgress(String topicId) {
    final box = topicProgressBox;
    final existing = box.get(topicId);
    if (existing != null) return existing;

    final newProgress = TopicProgress(topicId: topicId);
    box.put(topicId, newProgress);
    return newProgress;
  }

  Future<void> saveTopicProgress(TopicProgress progress) async {
    await topicProgressBox.put(progress.topicId, progress);
  }

  List<TopicProgress> getAllTopicProgress() {
    return topicProgressBox.values.toList();
  }

  TopicProgress? getTopicProgress(String topicId) {
    return topicProgressBox.get(topicId);
  }

  // --- Exam Sessions ---

  Future<void> saveSession(ExamSession session) async {
    await examSessionBox.put(session.id, session);
  }

  List<ExamSession> getAllSessions() {
    final sessions = examSessionBox.values.toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  List<ExamSession> getRecentSessions(int limit) {
    return getAllSessions().take(limit).toList();
  }

  ExamSession? getSession(String id) {
    return examSessionBox.get(id);
  }

  // --- Reset ---

  Future<void> clearAllProgress() async {
    await topicProgressBox.clear();
    await examSessionBox.clear();
  }

  Future<void> close() async {
    await _topicProgressBox?.close();
    await _examSessionBox?.close();
  }
}
