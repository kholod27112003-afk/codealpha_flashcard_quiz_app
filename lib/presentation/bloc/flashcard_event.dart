import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard.dart';

abstract class FlashcardEvent extends Equatable {
  const FlashcardEvent();

  @override
  List<Object?> get props => [];
}

class LoadFlashcardsEvent extends FlashcardEvent {
  const LoadFlashcardsEvent();
}

class AddFlashcardEvent extends FlashcardEvent {
  final String question;
  final String answer;

  const AddFlashcardEvent({required this.question, required this.answer});

  @override
  List<Object?> get props => [question, answer];
}

class UpdateFlashcardEvent extends FlashcardEvent {
  final Flashcard flashcard;

  const UpdateFlashcardEvent(this.flashcard);

  @override
  List<Object?> get props => [flashcard];
}

class DeleteFlashcardEvent extends FlashcardEvent {
  final String id;

  const DeleteFlashcardEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class NextCardEvent extends FlashcardEvent {
  const NextCardEvent();
}

class PreviousCardEvent extends FlashcardEvent {
  const PreviousCardEvent();
}

class ToggleAnswerEvent extends FlashcardEvent {
  const ToggleAnswerEvent();
}
