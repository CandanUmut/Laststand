import 'package:flutter/material.dart';

import '../game/app_game.dart';

class BuildOverlay extends StatefulWidget {
  const BuildOverlay({super.key, required this.game});

  final AppGame game;

  @override
  State<BuildOverlay> createState() => _BuildOverlayState();
}

class _BuildOverlayState extends State<BuildOverlay> {
  bool buildMode = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.game.isReady) {
      return const SizedBox.shrink();
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() => buildMode = !buildMode);
                widget.game.towerBuilder.toggleBuildMode(buildMode);
              },
              child: Text(buildMode ? 'Exit Build' : 'Build'),
            ),
            const SizedBox(width: 12),
            if (buildMode)
              Wrap(
                spacing: 8,
                children: widget.game.towerDatabase.definitions.values
                    .map(
                      (def) => ElevatedButton(
                        onPressed: () {
                          widget.game.towerBuilder.selectTower(def.id);
                        },
                        child: Text('${def.displayName} (${def.cost})'),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
