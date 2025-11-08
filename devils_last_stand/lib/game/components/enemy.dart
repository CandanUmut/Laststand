import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../data/enemy_defs.dart';
import '../systems/pathfinding.dart';
import 'base_core.dart';

class EnemyComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef {
  EnemyComponent({
    required this.definition,
    required this.target,
    PathNavigator? navigator,
  })  : _navigator = navigator,
        super(size: Vector2.all(48), anchor: Anchor.center) {
    _health = definition.health;
  }

  final EnemyDefinition definition;
  final BaseCore target;
  final PathNavigator? _navigator;

  late double _health;
  final double _speedEpsilon = 0.0001;
  double _speedMultiplier = 1;
  double _slowTimer = 0;
  Sprite? _sprite;

  void Function(EnemyComponent enemy, Map<String, double> drops)? onDeath;
  VoidCallback? onReachedCore;

  Vector2 get _toCore => (target.position - position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(0.75, parentSize: size));
    final asset = AppAssets.enemySprites[definition.id];
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
    if (_slowTimer > 0) {
      _slowTimer = math.max(0, _slowTimer - dt);
      if (_slowTimer == 0) {
        _speedMultiplier = 1;
      }
    }
    if (_navigator != null) {
      final step = _navigator!.stepTowards(position);
      if (!step.isZero()) {
        position += step * (definition.speed * _speedMultiplier) * dt;
      } else {
        _moveDirectlyToCore(dt);
      }
    } else {
      _moveDirectlyToCore(dt);
    }

    if (position.distanceTo(target.position) <=
        (target.size.x + size.x) * 0.35) {
      onReachedCore?.call();
      removeFromParent();
    }
  }

  void _moveDirectlyToCore(double dt) {
    final dir = _toCore;
    if (dir.length2 > _speedEpsilon) {
      dir.normalize();
      position += dir * (definition.speed * _speedMultiplier) * dt;
    }
  }

  void applyDamage(double amount) {
    _health -= amount;
    if (_health <= 0) {
      onDeath?.call(this, definition.dropTable);
      removeFromParent();
    }
  }

  void applySlow(double amount, double duration) {
    _speedMultiplier = (1 - amount).clamp(0.2, 1.0);
    _slowTimer = math.max(_slowTimer, duration);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = _colorForEnemy();
    final shape = _shapeForEnemy();
    if (_sprite != null) {
      _sprite!.renderRect(canvas, Rect.fromLTWH(0, 0, size.x, size.y));
    } else {
      canvas.drawPath(shape, paint);
    }

    if (definition.isElite) {
      final border = Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawPath(shape, border);
    }
  }

  Color _colorForEnemy() {
    switch (definition.id) {
      case 'brute':
        return Colors.deepOrangeAccent;
      case 'imp_bomber':
        return Colors.amberAccent.shade400;
      default:
        return Colors.pinkAccent.shade200;
    }
  }

  Path _shapeForEnemy() {
    final w = size.x;
    final h = size.y;
    switch (definition.id) {
      case 'brute':
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, w, h),
            const Radius.circular(10),
          ));
      case 'imp_bomber':
        final path = Path();
        final center = Offset(w / 2, h / 2);
        final radius = w / 2;
        for (var i = 0; i < 6; i++) {
          final angle = math.pi / 6 + i * math.pi / 3;
          final point = Offset(
            center.dx + math.cos(angle) * radius,
            center.dy + math.sin(angle) * radius,
          );
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        return path;
      default:
        return Path()
          ..moveTo(w / 2, 0)
          ..lineTo(w, h / 2)
          ..lineTo(w / 2, h)
          ..lineTo(0, h / 2)
          ..close();
    }
  }
}
