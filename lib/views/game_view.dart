import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/enums/game_status.dart';
import '../data/services/image_cache_service.dart';
import '../viewmodels/game_view_model.dart';
import 'widgets/answer_button.dart';
import 'widgets/flag_card.dart';

/// The main trivia game screen.
class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Trivia'),
        centerTitle: true,
        actions: [
          // ── Score display ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Consumer<GameViewModel>(
                builder: (context, vm, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${vm.totalScore}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Clear cache button ─────────────────────────────────
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Cache',
            onPressed: () => _showClearCacheDialog(context),
          ),
        ],
      ),
      body: Consumer<GameViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: vm.initialize,
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildGameBody(context, vm);
        },
      ),
    );
  }

  Widget _buildGameBody(BuildContext context, GameViewModel vm) {
    final target = vm.targetCountry;
    if (target == null) return const SizedBox.shrink();

    final cacheService = context.read<ImageCacheService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Attempt indicator ──────────────────────────────────
          _buildAttemptIndicator(vm),

          const SizedBox(height: 16),

          // ── Flag image ─────────────────────────────────────────
          FlagCard(
            flagUrl: target.flagUrl,
            cacheService: cacheService,
          ),

          const SizedBox(height: 24),

          // ── Question ───────────────────────────────────────────
          const Text(
            'Which country does this flag belong to?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 24),

          // ── Answer options ─────────────────────────────────────
          ...vm.answerOptions.map((option) {
            final isCorrect =
                vm.status == GameStatus.answered && option == target.name;
            final isWrong = vm.selectedAnswer == option && !isCorrect;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnswerButton(
                text: option,
                isCorrect: isCorrect,
                isWrong: isWrong,
                isDisabled: vm.status != GameStatus.playing,
                onPressed: () => vm.submitAnswer(option),
              ),
            );
          }),

          // ── Result / Next button ───────────────────────────────
          if (vm.status == GameStatus.answered) ...[
            const SizedBox(height: 8),
            _buildResultBanner(
              context,
              'Correct! +${vm.roundPoints} points',
              Colors.green,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: vm.nextRound,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Country'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          if (vm.status == GameStatus.failed) ...[
            const SizedBox(height: 8),
            _buildResultBanner(
              context,
              'The correct answer was: ${target.name}',
              Colors.red,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: vm.nextRound,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next Country'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttemptIndicator(GameViewModel vm) {
    final dots = List.generate(3, (index) {
      final used = index < vm.attempts;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: used ? Colors.red : Colors.grey.shade300,
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Attempts: ', style: TextStyle(fontSize: 14)),
        ...dots,
      ],
    );
  }

  Widget _buildResultBanner(BuildContext context, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Clear Cache Dialog ─────────────────────────────────────────

  void _showClearCacheDialog(BuildContext context) {
    final vm = context.read<GameViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Cache'),
          content: const Text(
            'This will remove all cached flag images. '
            'They will be re-downloaded when needed. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await vm.clearImageCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
