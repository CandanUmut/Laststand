import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

import '../../core/constants.dart';
import '../../core/input.dart';
import '../../data/weapon_defs.dart';

class PlayerComponent extends PositionComponent with HasGameRef, CollisionCallbacks {
  PlayerComponent({
    required this.movementInput,
    required this.weaponDatabase,
    super.position,
  }) : super(size: Vector2.all(GameConstants.baseTileSize));

  final MovementInput movementInput;
  final WeaponDatabase weaponDatabase;

  String equippedWeapon = 'arc_coil';
  double fireTimer = 0;
  double dashTimer = 0;
  bool isDashing = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;
    add(CircleHitbox.relative(0.8, parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final move = movementInput.direction.clone();
    position += move * (dt * 220);

    dashTimer -= dt;
    fireTimer -= dt;

    if (fireTimer <= 0) {
      _autoFire();
    }
  }

  void dash() {
    if (dashTimer <= 0) {
      dashTimer = GameConstants.dashCooldown.inSeconds.toDouble();
      isDashing = true;
      // TODO: add actual dash movement + i-frames.
    }
  }

  void _autoFire() {
    final def = weaponDatabase.definitions[equippedWeapon];
    if (def == null) {
      return;
    }
    fireTimer = 1 / def.fireRate;
    // TODO: spawn projectiles that target nearest enemy.
  }
}
