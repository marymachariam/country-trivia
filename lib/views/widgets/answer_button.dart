import 'package:flutter/material.dart';

/// A single multiple-choice answer button.
///
/// Visual states:
/// - [isCorrect]  → green background
/// - [isWrong]    → red background
/// - default      → neutral background
class AnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isCorrect;
  final bool isWrong;
  final bool isDisabled;

  const AnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isCorrect = false,
    this.isWrong = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    if (isCorrect) {
      backgroundColor = Colors.green;
    } else if (isWrong) {
      backgroundColor = Colors.red;
    } else {
      backgroundColor = Theme.of(context).colorScheme.primary;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
