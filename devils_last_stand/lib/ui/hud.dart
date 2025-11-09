import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../game/app_game.dart';

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  static const String overlayId = 'HudOverlay';

  final AppGame game;

  String _formatTime(double seconds) {
    final clamped = seconds.clamp(0, 9999);
    final intTotal = clamped.floor();
    final minutes = intTotal ~/ 60;
    final secs = intTotal % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: GamePalette.panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<int>(
                            valueListenable: game.waveIndex,
                            builder: (context, wave, _) {
                              return Text(
                                'Wave $wave',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        ValueListenableBuilder<double>(
                          valueListenable: game.waveCountdown,
                          builder: (context, seconds, _) {
                            return Text(
                              game.waveManager.isWaveRunning
                                  ? 'Wave ends in ${_formatTime(seconds)}'
                                  : 'Next wave in ${_formatTime(seconds)}',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: game.coreHp,
                      builder: (context, hp, _) {
                        return LinearProgressIndicator(
                          value: hp / GameConstants.baseCoreMaxHp,
                          minHeight: 10,
                          backgroundColor: Colors.black26,
                          color: GamePalette.coreGlow,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: game.essence,
                          builder: (context, value, _) {
                            return _HudTag(label: 'Essence', value: value.toString());
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: game.crackedSigils,
                          builder: (context, value, _) {
                            return _HudTag(label: 'Sigils', value: value.toString());
                          },
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: game.unlockedRing,
                          builder: (context, value, _) {
                            return _HudTag(label: 'Rings', value: value.toString());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: game.toggleBuildOverlay,
                          child: const Text('Build'),
                        ),
                        ElevatedButton(
                          onPressed: game.showSettingsOverlay,
                          child: const Text('Settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
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
    );
  }
}

class _HudTag extends StatelessWidget {
  const _HudTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
