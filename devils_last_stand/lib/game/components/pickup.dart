import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../app_game.dart';
import 'player.dart';

class Pickup extends CircleComponent with CollisionCallbacks, HasGameRef<AppGame> {
  Pickup({
    required this.type,
    required this.amount,
  }) : super(radius: 12, anchor: Anchor.center);

  final String type;
  final int amount;

  VoidCallback? onCollected;

  double _age = 0;
  final double _lifetime = 20;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..color = type == 'essence' ? GamePalette.accent : GamePalette.success;
    add(CircleHitbox.relative(0.7, parentSize: size));
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
        final speed = math.max(100, 280 * (1 - distance / player.magnetRadius));
        position += direction.normalized() * speed * dt;
      }
    }
  }

  void collect() {
    onCollected?.call();
    removeFromParent();
    // TODO(nova): play pickup SFX + floating text when audio unlocked.
  }
}
