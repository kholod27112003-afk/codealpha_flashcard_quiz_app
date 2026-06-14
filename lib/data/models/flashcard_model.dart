import 'dart:convert';
import '../../domain/entities/flashcard.dart';

class FlashcardModel extends Flashcard {
  const FlashcardModel({
    required super.id,
    required super.question,
    required super.answer,
    required super.createdAt,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FlashcardModel.fromEntity(Flashcard flashcard) {
    return FlashcardModel(
      id: flashcard.id,
      question: flashcard.question,
      answer: flashcard.answer,
      createdAt: flashcard.createdAt,
    );
  }

  static List<FlashcardModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String toJsonList(List<FlashcardModel> models) {
    final List<Map<String, dynamic>> jsonList =
        models.map((e) => e.toJson()).toList();
    return json.encode(jsonList);
  }
}
