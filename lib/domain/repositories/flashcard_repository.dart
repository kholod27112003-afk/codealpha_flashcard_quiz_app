import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/flashcard.dart';

abstract class FlashcardRepository {
  Future<Either<Failure, List<Flashcard>>> getAllFlashcards();
  Future<Either<Failure, Flashcard>> addFlashcard(Flashcard flashcard);
  Future<Either<Failure, Flashcard>> updateFlashcard(Flashcard flashcard);
  Future<Either<Failure, String>> deleteFlashcard(String id);
}
