/// Represents the current state of a trivia round.
enum GameStatus {
  /// Waiting for the user to select an answer.
  playing,

  /// The user answered correctly; show the result and a "Next" button.
  answered,

  /// The user exhausted all 3 attempts; the correct answer is revealed.
  failed,
}
