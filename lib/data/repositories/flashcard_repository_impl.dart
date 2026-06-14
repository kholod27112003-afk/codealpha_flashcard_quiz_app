import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_local_datasource.dart';
import '../models/flashcard_model.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardLocalDataSource localDataSource;

  FlashcardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Flashcard>>> getAllFlashcards() async {
    try {
      final cards = await localDataSource.getAllFlashcards();
      return Right(cards);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Flashcard>> addFlashcard(Flashcard flashcard) async {
    try {
      final model = FlashcardModel.fromEntity(flashcard);
      final saved = await localDataSource.saveFlashcard(model);
      return Right(saved);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Flashcard>> updateFlashcard(
      Flashcard flashcard) async {
    try {
      final model = FlashcardModel.fromEntity(flashcard);
      final updated = await localDataSource.updateFlashcard(model);
      return Right(updated);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteFlashcard(String id) async {
    try {
      final deletedId = await localDataSource.deleteFlashcard(id);
      return Right(deletedId);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
