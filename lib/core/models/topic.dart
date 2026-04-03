import 'package:equatable/equatable.dart';

class Topic extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? iconAssetPath;
  final int totalQuestions;
  final int orderIndex;

  const Topic({
    required this.id,
    required this.name,
    required this.description,
    this.iconAssetPath,
    required this.totalQuestions,
    this.orderIndex = 0,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconAssetPath: json['iconAssetPath'] as String?,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        if (iconAssetPath != null) 'iconAssetPath': iconAssetPath,
        'totalQuestions': totalQuestions,
        'orderIndex': orderIndex,
      };

  @override
  List<Object?> get props => [id, name, description, totalQuestions, orderIndex];
}
