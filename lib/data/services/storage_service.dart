import 'package:shared_preferences/shared_preferences.dart';

/// Wraps [SharedPreferences] to persist the user's score and solved flags.
class StorageService {
  static const String _totalScoreKey = 'total_score';
  static const String _solvedFlagsKey = 'solved_flags';

  // ── Total Score ───────────────────────────────────────────────

  Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalScoreKey) ?? 0;
  }

  Future<void> saveTotalScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalScoreKey, score);
  }

  // ── Solved Flags ──────────────────────────────────────────────

  Future<Set<String>> getSolvedFlags() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_solvedFlagsKey) ?? <String>[];
    return list.toSet();
  }

  Future<void> saveSolvedFlags(Set<String> flags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_solvedFlagsKey, flags.toList());
  }
}
