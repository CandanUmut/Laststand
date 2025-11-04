import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'components/base_core.dart';
import 'components/enemy.dart';
import 'components/player.dart';

class AppGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents, HasTappablesComponents, TapDetector {
  AppGame();

  static const String hudOverlay = 'HudOverlay';
  static const String upgradeOverlay = 'UpgradeOverlay';
  static const String gameOverOverlay = 'GameOverOverlay';

  late final World _world;
  late final CameraComponent _camera;
  late final Player _player;
  late final BaseCore _baseCore;
  JoystickComponent? _joystick;

  final ValueNotifier<int> coreHp = ValueNotifier<int>(0);
  int coreMaxHp = 0;
  final ValueNotifier<int> waveTimeRemaining = ValueNotifier<int>(0);
  final ValueNotifier<int> resources = ValueNotifier<int>(0);

  final Vector2 _playerSpawn = Vector2(0, -180);

  double _waveTimer = 60;
  bool _isGameOver = false;
  VoidCallback? _coreHpListener;

  bool get isGameOver => _isGameOver;

  Iterable<EnemyComponent> get enemies => _world.children.whereType<EnemyComponent>();

  bool get _isTouchDevice {
    if (kIsWeb) {
      return false;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  @override
  Color backgroundColor() => const Color(0xFF10141C);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _world = World();
    _camera = CameraComponent.withFixedResolution(world: _world, width: 800, height: 600)
      ..viewfinder.anchor = Anchor.center;
    addAll([_world, _camera]);

    if (_isTouchDevice) {
      _joystick = JoystickComponent(
        knob: CircleComponent(radius: 25, paint: Paint()..color = Colors.white.withOpacity(0.8)),
        background:
            CircleComponent(radius: 50, paint: Paint()..color = Colors.white.withOpacity(0.25)),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      )
        ..priority = 100
        ..positionType = PositionType.viewport;
      add(_joystick!);
    }

    _baseCore = BaseCore()
      ..position = Vector2.zero();
    _baseCore.onDestroyed = handleGameOver;
    await _world.add(_baseCore);

    coreMaxHp = _baseCore.maxHp;
    coreHp.value = _baseCore.hp.value;
    _coreHpListener = () {
      coreHp.value = _baseCore.hp.value;
      if (_baseCore.hp.value <= 0) {
        handleGameOver();
      }
    };
    _baseCore.hp.addListener(_coreHpListener!);

    _player = Player(
      joystick: _joystick,
    )
      ..position = _playerSpawn.clone();
    await _world.add(_player);
    _camera.follow(_player);

    waveTimeRemaining.value = _waveTimer.ceil();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isGameOver) {
      return;
    }

    _waveTimer = math.max(0, _waveTimer - dt);
    waveTimeRemaining.value = _waveTimer.ceil();
  }

  void showUpgradeOverlay() {
    if (_isGameOver || overlays.isActive(upgradeOverlay)) {
      return;
    }
    pauseEngine();
    overlays.add(upgradeOverlay);
  }

  void hideUpgradeOverlay() {
    overlays.remove(upgradeOverlay);
    if (!_isGameOver) {
      resumeEngine();
    }
  }

  void handleGameOver() {
    if (_isGameOver) {
      return;
    }
    _isGameOver = true;
    pauseEngine();
    overlays.add(gameOverOverlay);
  }

  void restart() {
    overlays.remove(gameOverOverlay);
    overlays.remove(upgradeOverlay);

    _isGameOver = false;
    _waveTimer = 60;
    waveTimeRemaining.value = _waveTimer.ceil();

    _baseCore.reset();
    coreHp.value = _baseCore.hp.value;

    resources.value = 0;

    _player.resetState(_playerSpawn);

    final bullets = _world.children.whereType<PlayerBullet>().toList();
    for (final bullet in bullets) {
      bullet.removeFromParent();
    }

    resumeEngine();
  }

  Future<void> addToWorld(PositionComponent component) {
    return _world.add(component);
  }

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);
    if (_isTouchDevice) {
      _player.dash();
    }
  }

  @override
  void onRemove() {
    if (_coreHpListener != null) {
      _baseCore.hp.removeListener(_coreHpListener!);
      _coreHpListener = null;
    }
    super.onRemove();
  }
}
