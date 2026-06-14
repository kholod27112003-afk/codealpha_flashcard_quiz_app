import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/flashcard_repository.dart';

class DeleteFlashcard extends UseCase<String, DeleteFlashcardParams> {
  final FlashcardRepository repository;

  DeleteFlashcard(this.repository);

  @override
  Future<Either<Failure, String>> call(DeleteFlashcardParams params) {
    return repository.deleteFlashcard(params.id);
  }
}

class DeleteFlashcardParams {
  final String id;
  DeleteFlashcardParams(this.id);
}
