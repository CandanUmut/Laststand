import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_game.dart';
import 'enemy.dart';

class Player extends PositionComponent
    with
        CollisionCallbacks,
        KeyboardHandler,
        TapCallbacks,
        HasGameRef<AppGame> {
  Player({
    this.joystick,
  }) : super(size: Vector2.all(48), anchor: Anchor.center);

  final JoystickComponent? joystick;

  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};
  final double _moveSpeed = 220;
  final double _dashDistance = 200;
  final double _dashCooldownDuration = 1.0;
  final double _invincibilityDuration = 0.25;

  late final Timer _fireTimer;
  Vector2 _aimDirection = Vector2(1, 0);
  Vector2 _lastMoveDirection = Vector2.zero();
  double _dashCooldown = 0;
  double _invincibilityTimer = 0;

  bool get isInvincible => _invincibilityTimer > 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(0.7, parentSize: size));
    _fireTimer = Timer(0.3, onTick: _fireBullet, repeat: true)..start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _fireTimer.update(dt);

    if (_dashCooldown > 0) {
      _dashCooldown = math.max(0, _dashCooldown - dt);
    }
    if (_invincibilityTimer > 0) {
      _invincibilityTimer = math.max(0, _invincibilityTimer - dt);
    }

    _updateMovement(dt);
    _updateAimDirection();
  }

  void _updateMovement(double dt) {
    final Vector2 direction = Vector2.zero();
    if (joystick != null) {
      final joystickDelta = joystick!.relativeDelta.clone();
      if (joystickDelta.length2 > 0.01) {
        direction.add(joystickDelta);
      }
    }

    if (_keysPressed.contains(LogicalKeyboardKey.keyW) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      direction.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyS) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      direction.y += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      direction.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      direction.x += 1;
    }

    if (!direction.isZero()) {
      direction.normalize();
      position += direction * _moveSpeed * dt;
      _lastMoveDirection = direction.clone();
    }
  }

  void _updateAimDirection() {
    EnemyComponent? closestEnemy;
    var closestDistance = double.infinity;

    for (final enemy in gameRef.enemies) {
      final distance = enemy.position.distanceTo(position);
      if (distance < closestDistance) {
        closestDistance = distance;
        closestEnemy = enemy;
      }
    }

    if (closestEnemy != null) {
      final direction = (closestEnemy.position - position);
      if (!direction.isZero()) {
        _aimDirection = direction.normalized();
      }
    } else if (!_lastMoveDirection.isZero()) {
      _aimDirection = _lastMoveDirection.normalized();
    }
  }

  void _fireBullet() {
    if (gameRef.isGameOver) {
      return;
    }
    if (_aimDirection.length2 < 0.01) {
      return;
    }
    final bullet = PlayerBullet(
      startPosition: position.clone(),
      direction: _aimDirection.normalized(),
    );
    gameRef.addToWorld(bullet);
  }

  void dash() {
    if (_dashCooldown > 0) {
      return;
    }
    final Vector2 dashDirection;
    if (!_lastMoveDirection.isZero()) {
      dashDirection = _lastMoveDirection.normalized();
    } else if (_aimDirection.length2 > 0.01) {
      dashDirection = _aimDirection.normalized();
    } else {
      return;
    }

    position += dashDirection * _dashDistance;
    _dashCooldown = _dashCooldownDuration;
    _invincibilityTimer = _invincibilityDuration;
  }

  void resetState(Vector2 newPosition) {
    position = newPosition.clone();
    _dashCooldown = 0;
    _invincibilityTimer = 0;
    _lastMoveDirection = Vector2.zero();
    _aimDirection = Vector2(1, 0);
    _keysPressed.clear();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      _keysPressed.add(event.logicalKey);
      if (event.logicalKey == LogicalKeyboardKey.space) {
        dash();
      }
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }
    return true;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    dash();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final radius = size.x / 2;
    final center = Offset(radius, radius);
    canvas.drawCircle(center, radius, Paint()..color = Colors.lightBlueAccent);
    if (isInvincible) {
      canvas.drawCircle(center, radius, Paint()..color = Colors.white.withOpacity(0.4));
    }
  }
}

class PlayerBullet extends CircleComponent with CollisionCallbacks {
  PlayerBullet({
    required Vector2 startPosition,
    required Vector2 direction,
    this.speed = 420,
    this.lifetime = 1.5,
  })  : velocity = direction.normalized() * speed,
        super(
          radius: 6,
          position: startPosition,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.orangeAccent,
        );

  final double speed;
  final double lifetime;
  final Vector2 velocity;
  double _time = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox.relative(1, parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    _time += dt;
    if (_time >= lifetime) {
      removeFromParent();
    }
  }
}
