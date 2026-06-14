import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class GetAllFlashcards extends UseCase<List<Flashcard>, NoParams> {
  final FlashcardRepository repository;

  GetAllFlashcards(this.repository);

  @override
  Future<Either<Failure, List<Flashcard>>> call(NoParams params) {
    return repository.getAllFlashcards();
  }
}
