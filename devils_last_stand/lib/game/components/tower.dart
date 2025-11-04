import 'dart:math';

import 'package:flame/components.dart';

import '../../core/constants.dart';
import '../../data/tower_defs.dart';
import '../app_game.dart';
import 'ally_turret.dart';
import 'enemy.dart';
import 'projectile.dart';

abstract class TowerComponent extends PositionComponent
    with HasGameRef<AppGame> {
  TowerComponent({
    required this.definition,
    required this.gridPosition,
    this.tier = 0,
  }) : super(size: Vector2.all(GameConstants.gridSize * 0.9), anchor: Anchor.center);

  final TowerDefinition definition;
  final Point<int> gridPosition;
  int tier;

  double _cooldown = 0;

  TowerTierStats get stats => definition.tiers[tier.clamp(0, definition.tiers.length - 1)];
  double get range => stats.range;

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0) {
      _cooldown -= dt;
    }
    if (_cooldown <= 0) {
      if (performAttack()) {
        final rate = stats.fireRate <= 0 ? 1 : stats.fireRate;
        _cooldown = 1 / rate;
      } else {
        _cooldown = 0.1;
      }
    }
  }

  bool performAttack();

  void upgrade() {
    if (tier < definition.tiers.length - 1) {
      tier += 1;
    }
  }

  EnemyComponent? closestEnemy(double within, {bool Function(EnemyComponent enemy)? filter}) {
    EnemyComponent? closest;
    double distance = double.infinity;
    for (final enemy in gameRef.world.children.whereType<EnemyComponent>()) {
      if (filter != null && !filter(enemy)) {
        continue;
      }
      final dist = enemy.position.distanceToSquared(position);
      if (dist <= within * within && dist < distance) {
        closest = enemy;
        distance = dist;
      }
    }
    return closest;
  }

  Iterable<EnemyComponent> enemiesInRange(double within) sync* {
    final threshold = within * within;
    for (final enemy in gameRef.world.children.whereType<EnemyComponent>()) {
      if (enemy.position.distanceToSquared(position) <= threshold) {
        yield enemy;
      }
    }
  }
}

class BoltSpireTower extends TowerComponent {
  BoltSpireTower({
    required super.definition,
    required super.gridPosition,
    super.tier,
  });

  double _overcharge = 0;

  @override
  bool performAttack() {
    final enemy = closestEnemy(range);
    if (enemy == null) {
      _overcharge = _overcharge * 0.7;
      return false;
    }
    final direction = (enemy.position - position).normalized();
    var damage = stats.damage;
    if (gameRef.hasTowerTech('tech_bolt_overcharge')) {
      damage += _overcharge;
      _overcharge = (_overcharge + 1.5).clamp(0, 12);
    }
    final projectile = Projectile.tower(
      startPosition: position.clone(),
      direction: direction,
      speed: 560,
      damage: damage,
    );
    gameRef.world.add(projectile);
    if (!gameRef.hasTowerTech('tech_bolt_overcharge')) {
      _overcharge = (_overcharge - 0.5).clamp(0, 10);
    }
    return true;
  }
}

class EmberSprayerTower extends TowerComponent {
  EmberSprayerTower({
    required super.definition,
    required super.gridPosition,
    super.tier,
  });

  @override
  bool performAttack() {
    final targets = enemiesInRange(range).toList();
    if (targets.isEmpty) {
      return false;
    }
    final baseDamage = stats.dot ?? stats.damage;
    for (final enemy in targets) {
      enemy.applyDamage(baseDamage * 0.6);
      if (gameRef.hasTowerTech('tech_ember_burn')) {
        enemy.applyDamage(baseDamage * 0.4);
      }
    }
    return true;
  }
}

class FrostLatticeTower extends TowerComponent {
  FrostLatticeTower({
    required super.definition,
    required super.gridPosition,
    super.tier,
  });

  @override
  bool performAttack() {
    final targets = enemiesInRange(range).toList();
    if (targets.isEmpty) {
      return false;
    }
    final slow = stats.slowPct ?? 0.25;
    for (final enemy in targets) {
      enemy.applySlow(slow, 1.2);
      enemy.applyDamage(stats.damage * 0.4);
      if (gameRef.hasTowerTech('tech_frost_brittle')) {
        enemy.applyDamage(stats.damage * 0.3);
      }
    }
    return true;
  }
}

class RedeemerTotemTower extends TowerComponent {
  RedeemerTotemTower({
    required super.definition,
    required super.gridPosition,
    super.tier,
  });

  bool _converted = false;

  @override
  bool performAttack() {
    if (_converted) {
      return false;
    }
    final elite = closestEnemy(range, filter: (enemy) => enemy.definition.isElite);
    if (elite == null) {
      return false;
    }
    _converted = true;
    final turret = AllyTurret.fromEnemy(elite)
      ..position = elite.position.clone();
    elite.removeFromParent();
    gameRef.world.add(turret);
    gameRef.towerBuilder.registerRedeemerConversion();
    // TODO(nova): floating "Purified!" feedback + SFX.
    return true;
  }
}

TowerComponent createTowerComponent(
  TowerDefinition definition,
  Point<int> gridPosition,
) {
  switch (definition.id) {
    case 'bolt_spire':
      return BoltSpireTower(definition: definition, gridPosition: gridPosition);
    case 'ember_sprayer':
      return EmberSprayerTower(definition: definition, gridPosition: gridPosition);
    case 'frost_lattice':
      return FrostLatticeTower(definition: definition, gridPosition: gridPosition);
    case 'redeemer_totem':
      return RedeemerTotemTower(definition: definition, gridPosition: gridPosition);
    default:
      return BoltSpireTower(definition: definition, gridPosition: gridPosition);
  }
}
