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
    final center = Offset(size.x / 2, size.y / 2);
    final outerRadius = size.x / 2;
    final innerRadius = outerRadius * 0.6;

    final outerPath = Path();
    final innerPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = math.pi / 2 + i * math.pi / 3;
      final outerPoint = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
      final innerPoint = Offset(
        center.dx + math.cos(angle) * innerRadius,
        center.dy + math.sin(angle) * innerRadius,
      );
      if (i == 0) {
        outerPath.moveTo(outerPoint.dx, outerPoint.dy);
        innerPath.moveTo(innerPoint.dx, innerPoint.dy);
      } else {
        outerPath.lineTo(outerPoint.dx, outerPoint.dy);
        innerPath.lineTo(innerPoint.dx, innerPoint.dy);
      }
    }
    outerPath.close();
    innerPath.close();

    final outerPaint = Paint()
      ..color = Colors.deepPurpleAccent.shade200
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final innerPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    canvas.drawPath(outerPath, outerPaint);
    canvas.drawPath(outerPath, borderPaint);
    canvas.drawPath(innerPath, innerPaint);
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
