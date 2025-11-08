import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../core/assets.dart';
import '../../core/constants.dart';
import '../../core/input.dart';
import '../app_game.dart';
import 'enemy.dart';
import 'pickup.dart';
import 'projectile.dart';

class Player extends PositionComponent
    with CollisionCallbacks, HasGameRef<AppGame> {
  Player({required this.input})
      : super(size: Vector2.all(48), anchor: Anchor.center);

  final InputController input;

  double moveSpeedMultiplier = 1.0;
  double fireInterval = 0.32;
  double projectileSpeed = GameConstants.playerBaseProjectileSpeed;
  int projectilePierce = 0;
  int maxDashCharges = 1;
  double magnetRadius = GameConstants.playerBaseMagnet;

  double _fireTimer = 0;
  double _dashTimer = 0;
  double _dashRecharge = 0;
  double _invulnerabilityTimer = 0;
  int _availableDashCharges = 1;
  bool _isDashing = false;
  Vector2 _dashDirection = Vector2.zero();
  Vector2 _lastMoveDirection = Vector2(0, 1);
  Sprite? _sprite;

  Rect get _worldBounds {
    final size = gameRef.worldSize;
    return Rect.fromCenter(
      center: Offset.zero,
      width: size.x - this.size.x,
      height: size.y - this.size.y,
    );
  }

  double get _moveSpeed => GameConstants.playerBaseMoveSpeed * moveSpeedMultiplier;

  bool get isInvincible => _invulnerabilityTimer > 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(0.7, parentSize: size));
    try {
      _sprite = await Sprite.load(AppAssets.playerShip);
    } catch (_) {
      _sprite = null;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _fireTimer -= dt;
    if (_invulnerabilityTimer > 0) {
      _invulnerabilityTimer = math.max(0, _invulnerabilityTimer - dt);
    }

    _handleDash(dt);
    _handleMovement(dt);
    _handleAutoFire();
  }

  void _handleMovement(double dt) {
    final desired = input.movement.clone();
    if (_isDashing) {
      position += _dashDirection * GameConstants.dashBurstSpeed * dt;
    } else {
      if (desired.length2 > 1) {
        desired.normalize();
      }
      if (!desired.isZero()) {
        _lastMoveDirection = desired.clone();
      }
      position += desired * _moveSpeed * dt;
    }

    final bounds = _worldBounds;
    final clampedX = position.x.clamp(bounds.left, bounds.right);
    final clampedY = position.y.clamp(bounds.top, bounds.bottom);
    position.setValues(clampedX, clampedY);

    final facing = _isDashing && !_dashDirection.isZero()
        ? _dashDirection
        : _lastMoveDirection;
    angle = math.atan2(facing.y, facing.x) + math.pi / 2;
  }

  void _handleDash(double dt) {
    if (input.consumeDashRequest()) {
      _tryDash();
    }

    if (_isDashing) {
      _dashTimer -= dt;
      if (_dashTimer <= 0) {
        _isDashing = false;
      }
    }

    if (_availableDashCharges < maxDashCharges) {
      _dashRecharge -= dt;
      if (_dashRecharge <= 0) {
        _availableDashCharges += 1;
        _dashRecharge = GameConstants.dashCooldownSeconds;
      }
    }
  }

  void _handleAutoFire() {
    if (_fireTimer > 0 || gameRef.isGameOver) {
      return;
    }
    final target = _nearestEnemy();
    if (target == null) {
      return;
    }
    final direction = (target.position - position);
    if (direction.length2 <= 0) {
      return;
    }
    direction.normalize();
    _fire(direction);
  }

  void _fire(Vector2 direction) {
    _fireTimer = fireInterval;
    final projectile = Projectile.player(
      startPosition: position.clone(),
      direction: direction,
      speed: projectileSpeed,
      damage: 18,
      pierce: projectilePierce,
    );
    gameRef.world.add(projectile);
  }

  EnemyComponent? _nearestEnemy() {
    EnemyComponent? closest;
    var closestDist = double.infinity;
    for (final enemy in gameRef.world.children.whereType<EnemyComponent>()) {
      final dist = enemy.position.distanceToSquared(position);
      if (dist < closestDist) {
        closestDist = dist;
        closest = enemy;
      }
    }
    return closest;
  }

  void _tryDash() {
    if (_availableDashCharges <= 0) {
      return;
    }
    final direction = input.movement.isZero()
        ? _lastMoveDirection.clone()
        : input.movement.clone();
    if (direction.length2 <= 0.0001) {
      return;
    }
    direction.normalize();
    _dashDirection = direction;
    _isDashing = true;
    _dashTimer = 0.22;
    _invulnerabilityTimer =
        GameConstants.dashInvulnerabilityDuration;
    _availableDashCharges -= 1;
    _dashRecharge = GameConstants.dashCooldownSeconds;
  }

  void resetState(Vector2 newPosition) {
    position = newPosition.clone();
    _fireTimer = 0;
    _dashTimer = 0;
    _dashRecharge = 0;
    _availableDashCharges = maxDashCharges;
    _isDashing = false;
    _invulnerabilityTimer = 0;
    _lastMoveDirection = Vector2(0, 1);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Pickup) {
      other.collect();
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final width = size.x;
    final height = size.y;

    if (_sprite != null) {
      _sprite!.renderRect(canvas, Rect.fromLTWH(0, 0, width, height));
    } else {
      final body = Path()
        ..moveTo(width / 2, 0)
        ..lineTo(width, height * 0.72)
        ..lineTo(width * 0.58, height)
        ..lineTo(width * 0.42, height)
        ..lineTo(0, height * 0.72)
        ..close();

      final bodyPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, width, height));

      final canopy = Path()
        ..moveTo(width / 2, height * 0.18)
        ..lineTo(width * 0.66, height * 0.58)
        ..lineTo(width * 0.34, height * 0.58)
        ..close();

      final canopyPaint = Paint()
        ..color = Colors.white.withOpacity(0.65);

      canvas.drawPath(body, bodyPaint);
      canvas.drawPath(canopy, canopyPaint);
    }

    if (isInvincible) {
      final aura = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(width / 2, height / 2),
          width: width * 1.2,
          height: height * 1.2,
        ),
        aura,
      );
    }
  }
}
