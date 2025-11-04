import 'package:flame/components.dart';

import '../../data/tower_defs.dart';

class TowerComponent extends PositionComponent with HasGameRef {
  TowerComponent({
    required this.definition,
    required this.tier,
    super.position,
  }) : super(size: Vector2.all(48)) {
    anchor = Anchor.center;
  }

  final TowerDefinition definition;
  int tier;
  double fireTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);
    fireTimer -= dt;
    if (fireTimer <= 0) {
      _fire();
    }
  }

  void _fire() {
    fireTimer = 1 / definition.tiers[tier].fireRate;
    // TODO: acquire target + spawn projectile.
  }

  void upgrade() {
    if (tier < definition.tiers.length - 1) {
      tier++;
    }
  }
}
