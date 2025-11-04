import 'package:flutter/material.dart';

import '../game/app_game.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  static const String overlayId = 'HudOverlay';

  final AppGame game;

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      ignoring: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: game.coreHp,
                        builder: (context, hp, _) {
                          return Text(
                            'Core HP: $hp / ${game.coreMaxHp}',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: game.waveTimeRemaining,
                        builder: (context, seconds, _) {
                          return Text(
                            'Next Wave In: ${_formatTime(seconds)}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<int>(
                        valueListenable: game.resources,
                        builder: (context, resources, _) {
                          return Text(
                            'Resources: $resources',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Controls: WASD / Joystick • Dash: Space or Tap',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
