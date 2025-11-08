import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../app_game.dart';
import 'enemy.dart';
import 'projectile.dart';

class AllyTurret extends PositionComponent with HasGameRef<AppGame> {
  AllyTurret({required this.baseDamage})
      : super(size: Vector2.all(56), anchor: Anchor.center);

  factory AllyTurret.fromEnemy(EnemyComponent enemy) {
    return AllyTurret(baseDamage: enemy.definition.damage * 1.5);
  }

  final double baseDamage;
  double _cooldown = 0;
  Sprite? _sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      _sprite = await Sprite.load(AppAssets.allyTurret);
    } catch (_) {
      _sprite = null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _cooldown -= dt;
    if (_cooldown <= 0) {
      if (_performAttack()) {
        _cooldown = 0.6;
      } else {
        _cooldown = 0.2;
      }
    }
  }

  bool _performAttack() {
    EnemyComponent? closest;
    double closestDist = double.infinity;
    for (final enemy in gameRef.world.children.whereType<EnemyComponent>()) {
      final dist = enemy.position.distanceToSquared(position);
      if (dist < closestDist) {
        closestDist = dist;
        closest = enemy;
      }
    }
    if (closest == null) {
      return false;
    }
    final direction = (closest.position - position).normalized();
    final projectile = Projectile(
      startPosition: position.clone(),
      direction: direction,
      speed: 480,
      damage: baseDamage,
      owner: ProjectileOwner.ally,
    );
    gameRef.world.add(projectile);
    return true;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_sprite != null) {
      _sprite!.renderRect(canvas, Rect.fromLTWH(0, 0, size.x, size.y));
      return;
    }
    final fill = Paint()..color = Colors.greenAccent.withOpacity(0.75);
    final border = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(10),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, border);
  }
}
