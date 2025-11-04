import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../core/assets.dart';
import '../core/constants.dart';
import '../core/input.dart';
import '../core/rng.dart';
import '../data/enemy_defs.dart';
import '../data/tower_defs.dart';
import '../data/upgrade_defs.dart';
import '../data/weapon_defs.dart';
import 'components/base_core.dart';
import 'components/player.dart';
import 'systems/ring_expansion.dart';
import 'systems/tower_builder.dart';
import 'systems/upgrade_draft.dart';
import 'systems/wave_manager.dart';

/// Central FlameGame that owns the simulation and overlays.
class AppGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents, TapCallbacks {
  AppGame({int? seed}) : rng = GameRng(seed);

  final GameRng rng;
  late final MovementInput movementInput;
  late final EnemyDatabase enemyDatabase;
  late final TowerDatabase towerDatabase;
  late final WeaponDatabase weaponDatabase;
  late final UpgradeDatabase upgradeDatabase;

  final ValueNotifier<int> waveIndex = ValueNotifier<int>(1);
  final ValueNotifier<double> coreHealth = ValueNotifier<double>(1.0);
  final ValueNotifier<int> essence = ValueNotifier<int>(0);
  final ValueNotifier<bool> gameOver = ValueNotifier<bool>(false);

  late final WaveManager waveManager;
  late final RingExpansionSystem ringExpansion;
  late final TowerBuilderSystem towerBuilder;
  late final UpgradeDraftSystem upgradeDraft;

  bool isPausedForUpgrade = false;
  bool _contentReady = false;

  bool get isReady => _contentReady;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadDatabases();
    await _preloadAudio();

    camera.viewport = FixedResolutionViewport(Vector2(1280, 720));

    movementInput = MovementInput();
    add(movementInput);

    ringExpansion = RingExpansionSystem();
    add(ringExpansion);

    final joystick = JoystickComponent(
      knob: CircleComponent(radius: 24, paint: Paint()..color = Colors.white70),
      background: CircleComponent(radius: 48, paint: Paint()..color = Colors.white24),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );
    movementInput.joystick = joystick;
    add(joystick);

    final core = BaseCoreComponent(position: size / 2);
    add(core);

    final player = PlayerComponent(
      movementInput: movementInput,
      weaponDatabase: weaponDatabase,
      position: size / 2 + Vector2(0, -GameConstants.baseTileSize * 2),
    );
    add(player);

    towerBuilder = TowerBuilderSystem(
      towerDatabase: towerDatabase,
      ringExpansion: ringExpansion,
      essence: essence,
    )..priority = 10;
    add(towerBuilder);

    upgradeDraft = UpgradeDraftSystem(
      upgradeDatabase: upgradeDatabase,
      weaponDatabase: weaponDatabase,
      essence: essence,
      rng: rng,
      onUpgradeChosen: _handleUpgradeChoice,
    );
    add(upgradeDraft);

    waveManager = WaveManager(
      enemyDatabase: enemyDatabase,
      waveIndex: waveIndex,
      ringExpansion: ringExpansion,
      onWaveCompleted: _handleWaveComplete,
      onCoreDamaged: _handleCoreDamage,
    );
    add(waveManager);
    waveManager.spawnWave();

    add(ScreenHitbox());

    _contentReady = true;
  }

  Future<void> _loadDatabases() async {
    enemyDatabase = await EnemyDatabase.load();
    towerDatabase = await TowerDatabase.load();
    weaponDatabase = await WeaponDatabase.load();
    upgradeDatabase = await UpgradeDatabase.load();
  }

  Future<void> _preloadAudio() async {
    // TODO: hook up flame_audio caching when assets are available.
  }

  void _handleUpgradeChoice(UpgradeDefinition upgrade) {
    // TODO: apply upgrade effects to player/towers.
  }

  void _handleWaveComplete() {
    essence.value += 25;
    ringExpansion.unlockNextRing();
    upgradeDraft.presentChoices();
    isPausedForUpgrade = true;
    pauseEngine();
  }

  void _handleCoreDamage(double normalizedHealth) {
    coreHealth.value = normalizedHealth;
    if (normalizedHealth <= 0) {
      gameOver.value = true;
    }
  }

  void resumeAfterUpgrade() {
    isPausedForUpgrade = false;
    resumeEngine();
  }

  @override
  void onRemove() {
    waveIndex.dispose();
    coreHealth.dispose();
    essence.dispose();
    gameOver.dispose();
    super.onRemove();
  }
}
