import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../data/upgrade_defs.dart';
import '../game/app_game.dart';

class UpgradeOverlay extends StatelessWidget {
  const UpgradeOverlay({super.key, required this.game});

  static const String overlayId = 'UpgradeOverlay';

  final AppGame game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black54,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: GamePalette.panel,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose an upgrade',
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<UpgradeDefinition>>(
                    valueListenable: game.upgradeDraft.choices,
                    builder: (context, choices, _) {
                      if (choices.isEmpty) {
                        return const Text(
                          'Loading upgrades...',
                          style: TextStyle(color: Colors.white70),
                        );
                      }
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: choices
                            .map(
                              (upgrade) => _UpgradeCard(
                                upgrade: upgrade,
                                onTap: () {
                                  game.upgradeDraft.pickUpgrade(upgrade);
                                  game.finishUpgradeDraft();
                                },
                              ),
                            )
                            .toList(),
                      );
                    },
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

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.upgrade, required this.onTap});

  final UpgradeDefinition upgrade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              upgrade.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              upgrade.description,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              upgrade.type.name,
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
