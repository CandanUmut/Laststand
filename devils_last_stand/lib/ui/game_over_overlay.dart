import 'package:flutter/material.dart';

import '../game/app_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  static const String overlayId = 'GameOverOverlay';

  final AppGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87.withOpacity(0.8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Core Destroyed',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.redAccent),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The demonic horde overwhelmed your defenses. Try again! ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: game.restart,
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
