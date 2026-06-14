import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class UpdateFlashcard extends UseCase<Flashcard, UpdateFlashcardParams> {
  final FlashcardRepository repository;

  UpdateFlashcard(this.repository);

  @override
  Future<Either<Failure, Flashcard>> call(UpdateFlashcardParams params) {
    return repository.updateFlashcard(params.flashcard);
  }
}

class UpdateFlashcardParams {
  final Flashcard flashcard;
  UpdateFlashcardParams(this.flashcard);
}
