import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';

class BaseCoreComponent extends PositionComponent with HasGameRef {
  BaseCoreComponent({super.position})
      : super(size: Vector2.all(GameConstants.baseTileSize * 2));

  double health = 1.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
    add(RectangleHitbox());
  }

  void applyDamage(double normalized) {
    health = normalized.clamp(0, 1);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [GamePalette.coreGlow, Colors.transparent],
      ).createShader(size.toRect());
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
  }
}
