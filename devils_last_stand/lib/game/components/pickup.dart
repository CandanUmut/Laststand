import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/constants.dart';
import '../app_game.dart';
import 'player.dart';

class Pickup extends PositionComponent
    with CollisionCallbacks, HasGameRef<AppGame> {
  Pickup({
    required this.type,
    required this.amount,
  }) : super(size: Vector2.all(28), anchor: Anchor.center);

  final String type;
  final int amount;

  VoidCallback? onCollected;

  double _age = 0;
  final double _lifetime = 20;
  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(0.7, parentSize: size));
    final asset = AppAssets.pickupSprites[type];
    if (asset != null) {
      try {
        _sprite = await Sprite.load(asset);
      } catch (_) {
        _sprite = null;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _lifetime) {
      removeFromParent();
      return;
    }

    final player = gameRef.player;
    final distance = position.distanceTo(player.position);
    if (distance < player.magnetRadius) {
      final direction = (player.position - position);
      if (!direction.isZero()) {
        final rawSpeed = 280 * (1 - distance / player.magnetRadius);
        final speed = math.max(100, rawSpeed).toDouble();
        position += direction.normalized() * speed * dt;
      }
    }
  }

  void collect() {
    onCollected?.call();
    removeFromParent();
    // TODO(nova): play pickup SFX + floating text when audio unlocked.
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final w = size.x;
    final h = size.y;
    if (_sprite != null) {
      _sprite!.renderRect(canvas, Rect.fromLTWH(0, 0, w, h));
      return;
    }

    final shape = Path();
    if (type == 'essence') {
      shape
        ..moveTo(w / 2, 0)
        ..lineTo(w, h / 2)
        ..lineTo(w / 2, h)
        ..lineTo(0, h / 2)
        ..close();
    } else {
      shape
        ..moveTo(w * 0.2, 0)
        ..lineTo(w, h * 0.2)
        ..lineTo(w * 0.8, h)
        ..lineTo(0, h * 0.8)
        ..close();
    }

    final fill = Paint()
      ..shader = LinearGradient(
        colors: [
          type == 'essence' ? GamePalette.accent : GamePalette.success,
          (type == 'essence' ? GamePalette.accent : GamePalette.success)
              .withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    final border = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(shape, fill);
    canvas.drawPath(shape, border);
  }
}
