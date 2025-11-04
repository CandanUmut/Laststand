import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/app_game.dart';
import 'ui/build_overlay.dart';
import 'ui/game_over_overlay.dart';
import 'ui/hud.dart';
import 'ui/settings_overlay.dart';
import 'ui/upgrade_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final game = AppGame();

  runApp(
    GameWidget(
      game: game,
      overlayBuilderMap: {
        HudOverlay.overlayId: (context, game) => HudOverlay(game: game as AppGame),
        BuildOverlay.overlayId: (context, game) => BuildOverlay(game: game as AppGame),
        UpgradeOverlay.overlayId: (context, game) => UpgradeOverlay(game: game as AppGame),
        SettingsOverlay.overlayId: (context, game) => SettingsOverlay(game: game as AppGame),
        GameOverOverlay.overlayId: (context, game) => GameOverOverlay(game: game as AppGame),
      },
      initialActiveOverlays: const [HudOverlay.overlayId],
    ),
  );
}
