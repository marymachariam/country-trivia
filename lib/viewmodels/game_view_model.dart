import 'dart:math';
import 'package:flutter/foundation.dart';

import '../core/enums/game_status.dart';
import '../data/models/country.dart';
import '../data/repositories/country_repository.dart';
import '../data/services/image_cache_service.dart';

/// ViewModel that drives the trivia game.
///
/// Holds all mutable game state and exposes intent methods
/// (e.g. [submitAnswer], [nextRound]) that the View calls.
class GameViewModel extends ChangeNotifier {
  final CountryRepository repository;
  final ImageCacheService imageCacheService;

  GameViewModel({
    required this.repository,
    required this.imageCacheService,
  });

  // ── Private state ─────────────────────────────────────────────

  List<Country> _allCountries = [];
  Set<String> _solvedIsoCodes = {};
  final Random _random = Random();

  Country? _targetCountry;
  List<String> _answerOptions = [];
  int _attempts = 0;
  int _totalScore = 0;
  GameStatus _status = GameStatus.playing;
  String? _selectedAnswer;
  bool _isLoading = true;
  String? _errorMessage;

  // ── Public getters ────────────────────────────────────────────

  Country? get targetCountry => _targetCountry;
  List<String> get answerOptions => List.unmodifiable(_answerOptions);
  int get attempts => _attempts;
  int get totalScore => _totalScore;
  GameStatus get status => _status;
  String? get selectedAnswer => _selectedAnswer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Points awarded for the current round (0 if failed).
  int get roundPoints {
    if (_status == GameStatus.answered) {
      switch (_attempts) {
        case 1:
          return 10;
        case 2:
          return 8;
        case 3:
          return 5;
      }
    }
    return 0;
  }

  // ── Lifecycle ─────────────────────────────────────────────────

  /// Called once when the app starts. Loads persisted data and
  /// fetches the country list from the API.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _totalScore = await repository.getTotalScore();
      _solvedIsoCodes = await repository.getSolvedFlags();
      _allCountries = await repository.fetchCountries();

      // Filter out already-solved countries so they never reappear.
      final available =
          _allCountries.where((c) => !_solvedIsoCodes.contains(c.isoCode)).toList();

      if (available.isEmpty) {
        _errorMessage = 'You have solved all available countries!';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _startNewRound(available);
    } catch (e) {
      _errorMessage = 'Failed to load game data. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Intents ───────────────────────────────────────────────────

  /// Called when the user taps an answer option.
  void submitAnswer(String answer) {
    if (_status != GameStatus.playing || _targetCountry == null) return;

    _selectedAnswer = answer;
    _attempts++;

    if (answer == _targetCountry!.name) {
      // Correct answer
      _status = GameStatus.answered;
      _totalScore += roundPoints;
      _solvedIsoCodes.add(_targetCountry!.isoCode);

      // Persist updated score and solved flags.
      repository.saveTotalScore(_totalScore);
      repository.saveSolvedFlags(_solvedIsoCodes);
    } else if (_attempts >= 3) {
      // Exhausted all attempts
      _status = GameStatus.failed;
    }

    notifyListeners();
  }

  /// Advances to the next trivia round.
  void nextRound() {
    final available =
        _allCountries.where((c) => !_solvedIsoCodes.contains(c.isoCode)).toList();

    if (available.isEmpty) {
      _errorMessage = 'You have solved all available countries!';
      notifyListeners();
      return;
    }

    _startNewRound(available);
  }

  /// Preloads flag images for the next round into the cache.
  Future<void> preloadNextFlags(List<String> flagUrls) async {
    await imageCacheService.preloadImages(flagUrls);
  }

  /// Clears all cached flag images.
  Future<void> clearImageCache() async {
    await imageCacheService.clearCache();
  }

  // ── Private helpers ────────────────────────────────────────────

  void _startNewRound(List<Country> available) {
    _targetCountry = available[_random.nextInt(available.length)];
    _answerOptions = _generateOptions(_targetCountry!, available);
    _attempts = 0;
    _status = GameStatus.playing;
    _selectedAnswer = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();

    // Preload flags for the next round in the background.
    _preloadUpcomingFlags(available);
  }

  /// Preloads flag images for upcoming rounds.
  void _preloadUpcomingFlags(List<Country> available) {
    final upcoming = available.take(10).map((c) => c.flagUrl).toList();
    preloadNextFlags(upcoming);
  }

  /// Generates 4 answer options: the correct answer + 3 random distractors.
  List<String> _generateOptions(Country target, List<Country> pool) {
    final options = <String>{target.name};

    // Shuffle a copy of the pool and pick distractors.
    final shuffled = List<Country>.from(pool)..shuffle(_random);
    for (final country in shuffled) {
      if (options.length >= 4) break;
      if (country.isoCode != target.isoCode) {
        options.add(country.name);
      }
    }

    final list = options.toList()..shuffle(_random);
    return list;
  }
}
