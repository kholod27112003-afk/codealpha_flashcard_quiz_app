import 'package:equatable/equatable.dart';
import '../../domain/entities/flashcard.dart';

abstract class FlashcardState extends Equatable {
  const FlashcardState();

  @override
  List<Object?> get props => [];
}

class FlashcardInitial extends FlashcardState {
  const FlashcardInitial();
}

class FlashcardLoading extends FlashcardState {
  const FlashcardLoading();
}

class FlashcardLoaded extends FlashcardState {
  final List<Flashcard> flashcards;
  final int currentIndex;
  final bool isAnswerVisible;

  const FlashcardLoaded({
    required this.flashcards,
    this.currentIndex = 0,
    this.isAnswerVisible = false,
  });

  Flashcard? get currentCard =>
      flashcards.isNotEmpty ? flashcards[currentIndex] : null;

  bool get hasNext => currentIndex < flashcards.length - 1;
  bool get hasPrevious => currentIndex > 0;

  FlashcardLoaded copyWith({
    List<Flashcard>? flashcards,
    int? currentIndex,
    bool? isAnswerVisible,
  }) {
    return FlashcardLoaded(
      flashcards: flashcards ?? this.flashcards,
      currentIndex: currentIndex ?? this.currentIndex,
      isAnswerVisible: isAnswerVisible ?? this.isAnswerVisible,
    );
  }

  @override
  List<Object?> get props => [flashcards, currentIndex, isAnswerVisible];
}

class FlashcardError extends FlashcardState {
  final String message;

  const FlashcardError(this.message);

  @override
  List<Object?> get props => [message];
}
