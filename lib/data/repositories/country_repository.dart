import '../models/country.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

/// Mediates between the API and local storage.
///
/// Exposes a clean interface so the ViewModel never talks to
/// [ApiService] or [StorageService] directly.
class CountryRepository {
  final ApiService apiService;
  final StorageService storageService;

  CountryRepository({
    required this.apiService,
    required this.storageService,
  });

  /// Fetch all countries from the remote API.
  Future<List<Country>> fetchCountries() => apiService.fetchCountries();

  /// Read the persisted total score.
  Future<int> getTotalScore() => storageService.getTotalScore();

  /// Persist the updated total score.
  Future<void> saveTotalScore(int score) =>
      storageService.saveTotalScore(score);

  /// Read the set of already-solved ISO codes.
  Future<Set<String>> getSolvedFlags() => storageService.getSolvedFlags();

  /// Persist the updated set of solved ISO codes.
  Future<void> saveSolvedFlags(Set<String> flags) =>
      storageService.saveSolvedFlags(flags);
}
