import 'package:equatable/equatable.dart';
import 'answer_option.dart';

enum QuestionType { text, photo, video }

enum AnswerType { multipleChoice, multiSelect, textEntry }

class Question extends Equatable {
  final String id;
  final String topicId;
  final QuestionType questionType;
  final AnswerType answerType;
  final String questionText;
  final String? imageUrl;
  final String? videoUrl;
  final List<AnswerOption> options;
  final List<String> correctOptionIds;
  final String? correctTextAnswer;
  final String explanation;
  final int difficultyLevel;
  final int orderIndex;

  const Question({
    required this.id,
    required this.topicId,
    required this.questionType,
    required this.answerType,
    required this.questionText,
    this.imageUrl,
    this.videoUrl,
    required this.options,
    required this.correctOptionIds,
    this.correctTextAnswer,
    required this.explanation,
    this.difficultyLevel = 1,
    this.orderIndex = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      questionType: QuestionType.values.firstWhere(
        (e) => e.name == (json['questionType'] as String),
        orElse: () => QuestionType.text,
      ),
      answerType: AnswerType.values.firstWhere(
        (e) => e.name == (json['answerType'] as String),
        orElse: () => AnswerType.multipleChoice,
      ),
      questionText: json['questionText'] as String,
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => AnswerOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      correctOptionIds: (json['correctOptionIds'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      correctTextAnswer: json['correctTextAnswer'] as String?,
      explanation: json['explanation'] as String? ?? '',
      difficultyLevel: json['difficultyLevel'] as int? ?? 1,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'topicId': topicId,
        'questionType': questionType.name,
        'answerType': answerType.name,
        'questionText': questionText,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (videoUrl != null) 'videoUrl': videoUrl,
        'options': options.map((o) => o.toJson()).toList(),
        'correctOptionIds': correctOptionIds,
        if (correctTextAnswer != null) 'correctTextAnswer': correctTextAnswer,
        'explanation': explanation,
        'difficultyLevel': difficultyLevel,
        'orderIndex': orderIndex,
      };

  bool isCorrect(List<String> selectedIds, String? textAnswer) {
    switch (answerType) {
      case AnswerType.multipleChoice:
        return selectedIds.length == 1 && correctOptionIds.contains(selectedIds.first);
      case AnswerType.multiSelect:
        if (selectedIds.length != correctOptionIds.length) return false;
        return selectedIds.every((id) => correctOptionIds.contains(id));
      case AnswerType.textEntry:
        if (textAnswer == null) return false;
        return textAnswer.trim().toLowerCase() ==
            (correctTextAnswer ?? '').trim().toLowerCase();
    }
  }

  @override
  List<Object?> get props => [id, topicId, questionType, answerType, questionText];
}
