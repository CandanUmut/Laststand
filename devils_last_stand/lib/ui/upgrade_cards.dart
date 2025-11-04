import 'package:flutter/material.dart';

import '../game/app_game.dart';

class UpgradeCardsOverlay extends StatelessWidget {
  const UpgradeCardsOverlay({super.key, required this.game});

  final AppGame game;

  @override
  Widget build(BuildContext context) {
    if (!game.isReady) {
      return const SizedBox.shrink();
    }
    final choices = game.upgradeDraft.currentChoices;
    if (choices.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children: choices
              .map(
                (upgrade) => Card(
                  child: InkWell(
                    onTap: () {
                      game.upgradeDraft.pickUpgrade(upgrade);
                      game.resumeAfterUpgrade();
                    },
                    child: SizedBox(
                      width: 220,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(upgrade.displayName,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(upgrade.description),
                            const SizedBox(height: 12),
                            Text('Type: ${upgrade.type.name}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
