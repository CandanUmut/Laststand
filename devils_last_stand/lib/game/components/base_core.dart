import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BaseCore extends PositionComponent with CollisionCallbacks {
  BaseCore({
    this.maxHp = 100,
    super.position,
  })  : hp = ValueNotifier<int>(maxHp),
        super(size: Vector2.all(120), anchor: Anchor.center);

  final int maxHp;
  final ValueNotifier<int> hp;
  VoidCallback? onDestroyed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(0.8, parentSize: size));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final radius = size.x / 2;
    final center = Offset(radius, radius);
    canvas.drawCircle(center, radius, Paint()..color = Colors.deepPurpleAccent);
    canvas.drawCircle(center, radius * 0.6, Paint()..color = Colors.black.withOpacity(0.3));
  }

  void takeDamage(int amount) {
    if (hp.value <= 0) {
      return;
    }
    hp.value = math.max(0, hp.value - amount);
    if (hp.value <= 0) {
      onDestroyed?.call();
    }
  }

  void reset() {
    hp.value = maxHp;
  }
}
