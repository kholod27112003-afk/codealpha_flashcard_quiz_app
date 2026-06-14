import 'package:equatable/equatable.dart';

class Flashcard extends Equatable {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;

  const Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, question, answer, createdAt];
}
