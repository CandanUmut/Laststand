import 'package:flutter/material.dart';

import '../game/app_game.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final AppGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: game.waveIndex,
              builder: (context, wave, _) => Text('Wave $wave'),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: game.coreHealth,
              builder: (context, value, _) => LinearProgressIndicator(value: value),
            ),
            const Spacer(),
            ValueListenableBuilder<int>(
              valueListenable: game.essence,
              builder: (context, value, _) => Text('Essence: $value'),
            ),
          ],
        ),
      ),
    );
  }
}
