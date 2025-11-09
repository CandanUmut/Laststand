import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../game/app_game.dart';

class BuildOverlay extends StatelessWidget {
  const BuildOverlay({super.key, required this.game});

  static const overlayId = 'BuildOverlay';

  final AppGame game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
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
                children: [
                  Text(
                    'Select a tower and tap an unlocked tile to place it.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: game.essence,
                    builder: (context, essenceValue, _) {
                      return ValueListenableBuilder<int>(
                        valueListenable: game.crackedSigils,
                        builder: (context, sigils, __) {
                          final towers = game.towerDatabase.definitions.values.toList()
                            ..sort((a, b) => a.cost.compareTo(b.cost));
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: towers.map((definition) {
                              final cost = definition.cost;
                              final hasEssence = essenceValue >= cost;
                              final needsSigil = definition.id == 'redeemer_totem';
                              final hasSigil = sigils > 0;
                              final special = definition.tiers.isNotEmpty
                                  ? definition.tiers.first.special
                                  : '';
                              return ElevatedButton(
                                onPressed: hasEssence && (!needsSigil || hasSigil)
                                    ? () => game.selectTowerToBuild(definition.id)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasEssence
                                      ? GamePalette.accent.withOpacity(0.2)
                                      : Colors.grey.shade700,
                                ),
                                child: SizedBox(
                                  width: 120,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        definition.displayName,
                                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Cost: $cost',
                                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                      ),
                                      if (special.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          special,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.white60,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                      if (needsSigil)
                                        Text(
                                          'Requires Sigil',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: hasSigil ? GamePalette.success : GamePalette.danger,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Available build tiles: ${game.towerBuilder.buildableCellCount}. Arcane Barriers can be dropped directly on paths to open new routes, but at least one path must remain.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: game.toggleBuildOverlay,
                    child: const Text('Close Build'),
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
