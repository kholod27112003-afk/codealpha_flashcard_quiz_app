import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/datasources/flashcard_local_datasource.dart';
import 'data/repositories/flashcard_repository_impl.dart';
import 'domain/repositories/flashcard_repository.dart';
import 'domain/usecases/add_flashcard.dart';
import 'domain/usecases/delete_flashcard.dart';
import 'domain/usecases/get_all_flashcards.dart';
import 'domain/usecases/update_flashcard.dart';
import 'presentation/bloc/flashcard_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoC
  sl.registerFactory(() => FlashcardBloc(
        getAllFlashcards: sl(),
        addFlashcard: sl(),
        updateFlashcard: sl(),
        deleteFlashcard: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetAllFlashcards(sl()));
  sl.registerLazySingleton(() => AddFlashcard(sl()));
  sl.registerLazySingleton(() => UpdateFlashcard(sl()));
  sl.registerLazySingleton(() => DeleteFlashcard(sl()));

  // Repository
  sl.registerLazySingleton<FlashcardRepository>(
    () => FlashcardRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FlashcardLocalDataSource>(
    () => FlashcardLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
