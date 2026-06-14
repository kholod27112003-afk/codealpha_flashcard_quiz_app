import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/usecases/add_flashcard.dart';
import '../../domain/usecases/delete_flashcard.dart';
import '../../domain/usecases/get_all_flashcards.dart';
import '../../domain/usecases/update_flashcard.dart';
import 'flashcard_event.dart';
import 'flashcard_state.dart';

class FlashcardBloc extends Bloc<FlashcardEvent, FlashcardState> {
  final GetAllFlashcards getAllFlashcards;
  final AddFlashcard addFlashcard;
  final UpdateFlashcard updateFlashcard;
  final DeleteFlashcard deleteFlashcard;
  final _uuid = const Uuid();

  FlashcardBloc({
    required this.getAllFlashcards,
    required this.addFlashcard,
    required this.updateFlashcard,
    required this.deleteFlashcard,
  }) : super(const FlashcardInitial()) {
    on<LoadFlashcardsEvent>(_onLoad);
    on<AddFlashcardEvent>(_onAdd);
    on<UpdateFlashcardEvent>(_onUpdate);
    on<DeleteFlashcardEvent>(_onDelete);
    on<NextCardEvent>(_onNext);
    on<PreviousCardEvent>(_onPrevious);
    on<ToggleAnswerEvent>(_onToggleAnswer);
  }

  Future<void> _onLoad(
      LoadFlashcardsEvent event, Emitter<FlashcardState> emit) async {
    emit(const FlashcardLoading());
    final result = await getAllFlashcards(NoParams());
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (cards) => emit(FlashcardLoaded(flashcards: cards)),
    );
  }

  Future<void> _onAdd(
      AddFlashcardEvent event, Emitter<FlashcardState> emit) async {
    if (state is! FlashcardLoaded) return;
    final current = state as FlashcardLoaded;

    final newCard = Flashcard(
      id: _uuid.v4(),
      question: event.question,
      answer: event.answer,
      createdAt: DateTime.now(),
    );

    final result = await addFlashcard(AddFlashcardParams(newCard));
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (card) {
        final updated = [...current.flashcards, card];
        emit(current.copyWith(
          flashcards: updated,
          currentIndex: updated.length - 1,
          isAnswerVisible: false,
        ));
      },
    );
  }

  Future<void> _onUpdate(
      UpdateFlashcardEvent event, Emitter<FlashcardState> emit) async {
    if (state is! FlashcardLoaded) return;
    final current = state as FlashcardLoaded;

    final result = await updateFlashcard(UpdateFlashcardParams(event.flashcard));
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (card) {
        final updated = current.flashcards
            .map((c) => c.id == card.id ? card : c)
            .toList();
        emit(current.copyWith(
          flashcards: updated,
          isAnswerVisible: false,
        ));
      },
    );
  }

  Future<void> _onDelete(
      DeleteFlashcardEvent event, Emitter<FlashcardState> emit) async {
    if (state is! FlashcardLoaded) return;
    final current = state as FlashcardLoaded;

    final result = await deleteFlashcard(DeleteFlashcardParams(event.id));
    result.fold(
      (failure) => emit(FlashcardError(failure.message)),
      (id) {
        final updated =
            current.flashcards.where((c) => c.id != id).toList();
        final newIndex =
            current.currentIndex >= updated.length && updated.isNotEmpty
                ? updated.length - 1
                : current.currentIndex;
        emit(current.copyWith(
          flashcards: updated,
          currentIndex: newIndex,
          isAnswerVisible: false,
        ));
      },
    );
  }

  void _onNext(NextCardEvent event, Emitter<FlashcardState> emit) {
    if (state is! FlashcardLoaded) return;
    final current = state as FlashcardLoaded;
    if (current.hasNext) {
      emit(current.copyWith(
        currentIndex: current.currentIndex + 1,
        isAnswerVisible: false,
      ));
    }
  }

  void _onPrevious(PreviousCardEvent event, Emitter<FlashcardState> emit) {
    if (state is! FlashcardLoaded) return;
    final current = state as FlashcardLoaded;
    if (current.hasPrevious) {
      emit(current.copyWith(
        currentIndex: current.currentIndex - 1,
        isAnswerVisible: false,
      ));
    }
  }

  void _onToggleAnswer(ToggleAnswerEvent event, Emitter<FlashcardState> emit) {
    if (state is! FlashcardLoaded) return;
    final current = state as FlashcardLoaded;
    emit(current.copyWith(isAnswerVisible: !current.isAnswerVisible));
  }
}
