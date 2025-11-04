import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/app_game.dart';
import '../ui/build_overlay.dart';
import '../ui/hud.dart';
import '../ui/upgrade_cards.dart';
import 'game_over_scene.dart';

class PlayScene extends StatefulWidget {
  const PlayScene({super.key, required this.biomeId});

  final String biomeId;

  @override
  State<PlayScene> createState() => _PlaySceneState();
}

class _PlaySceneState extends State<PlayScene> {
  late AppGame game;

  @override
  void initState() {
    super.initState();
    game = AppGame();
    game.gameOver.addListener(_handleGameOver);
  }

  void _handleGameOver() {
    if (game.gameOver.value && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameOverScene(metaCurrencyEarned: 120),
        ),
      );
    }
  }

  @override
  void dispose() {
    game.gameOver.removeListener(_handleGameOver);
    game.onRemove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned.fill(child: HudOverlay(game: game)),
          Positioned.fill(child: BuildOverlay(game: game)),
          Positioned.fill(child: UpgradeCardsOverlay(game: game)),
        ],
      ),
    );
  }
}
