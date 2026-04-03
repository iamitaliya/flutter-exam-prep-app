import 'package:equatable/equatable.dart';

class AnswerOption extends Equatable {
  final String id;
  final String text;
  final String? imageUrl;

  const AnswerOption({
    required this.id,
    required this.text,
    this.imageUrl,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      id: json['id'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

  AnswerOption copyWith({
    String? id,
    String? text,
    String? imageUrl,
  }) {
    return AnswerOption(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [id, text, imageUrl];
}
