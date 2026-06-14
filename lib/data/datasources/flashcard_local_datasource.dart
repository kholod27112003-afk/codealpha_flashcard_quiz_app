import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../models/flashcard_model.dart';

abstract class FlashcardLocalDataSource {
  Future<List<FlashcardModel>> getAllFlashcards();
  Future<FlashcardModel> saveFlashcard(FlashcardModel flashcard);
  Future<FlashcardModel> updateFlashcard(FlashcardModel flashcard);
  Future<String> deleteFlashcard(String id);
}

const _kFlashcardsKey = 'FLASHCARDS_KEY';

class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  final SharedPreferences sharedPreferences;

  FlashcardLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<FlashcardModel>> getAllFlashcards() async {
    final jsonString = sharedPreferences.getString(_kFlashcardsKey);
    if (jsonString == null) return _defaultFlashcards();
    return FlashcardModel.fromJsonList(jsonString);
  }

  @override
  Future<FlashcardModel> saveFlashcard(FlashcardModel flashcard) async {
    final cards = await getAllFlashcards();
    cards.add(flashcard);
    await _persist(cards);
    return flashcard;
  }

  @override
  Future<FlashcardModel> updateFlashcard(FlashcardModel flashcard) async {
    final cards = await getAllFlashcards();
    final idx = cards.indexWhere((c) => c.id == flashcard.id);
    if (idx == -1) throw const CacheFailure('Flashcard not found');
    cards[idx] = flashcard;
    await _persist(cards);
    return flashcard;
  }

  @override
  Future<String> deleteFlashcard(String id) async {
    final cards = await getAllFlashcards();
    cards.removeWhere((c) => c.id == id);
    await _persist(cards);
    return id;
  }

  Future<void> _persist(List<FlashcardModel> cards) async {
    await sharedPreferences.setString(
      _kFlashcardsKey,
      FlashcardModel.toJsonList(cards),
    );
  }

  List<FlashcardModel> _defaultFlashcards() {
    return [
      FlashcardModel(
        id: '1',
        question: 'What is Flutter?',
        answer:
            'Flutter is Google\'s open-source UI toolkit for building natively compiled apps across mobile, web, and desktop from a single codebase.',
        createdAt: DateTime.now(),
      ),
      FlashcardModel(
        id: '2',
        question: 'What is Clean Architecture?',
        answer:
            'Clean Architecture separates code into layers (Presentation, Domain, Data) to enforce separation of concerns, making code testable and maintainable.',
        createdAt: DateTime.now(),
      ),
      FlashcardModel(
        id: '3',
        question: 'What is BLoC pattern?',
        answer:
            'BLoC (Business Logic Component) is a state management pattern that separates business logic from UI using streams of events and states.',
        createdAt: DateTime.now(),
      ),
    ];
  }
}
