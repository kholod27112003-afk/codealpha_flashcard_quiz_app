import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class AddFlashcard extends UseCase<Flashcard, AddFlashcardParams> {
  final FlashcardRepository repository;

  AddFlashcard(this.repository);

  @override
  Future<Either<Failure, Flashcard>> call(AddFlashcardParams params) {
    return repository.addFlashcard(params.flashcard);
  }
}

class AddFlashcardParams {
  final Flashcard flashcard;
  AddFlashcardParams(this.flashcard);
}
