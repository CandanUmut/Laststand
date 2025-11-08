import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/input.dart';
import '../core/rng.dart';
import '../core/save.dart';
import '../data/enemy_defs.dart';
import '../data/tower_defs.dart';
import '../data/upgrade_defs.dart';
import '../ui/build_overlay.dart';
import '../ui/hud.dart';
import '../ui/settings_overlay.dart';
import '../ui/upgrade_overlay.dart';
import 'components/base_core.dart';
import 'components/enemy.dart';
import 'components/pickup.dart';
import 'components/player.dart';
import 'components/projectile.dart';
import 'components/tower.dart';
import 'systems/ring_expansion.dart';
import 'systems/tower_builder.dart';
import 'systems/upgrade_draft.dart';
import 'systems/wave_manager.dart';

class AppGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  AppGame();

  static const hudOverlay = HudOverlay.overlayId;
  static const buildOverlay = BuildOverlay.overlayId;
  static const upgradeOverlay = UpgradeOverlay.overlayId;
  static const settingsOverlay = SettingsOverlay.overlayId;
  static const gameOverOverlay = 'GameOverOverlay';

  final World world = World();

  // Create the camera (no cascades here)
  late final CameraComponent camera = CameraComponent.withFixedResolution(
    world: world,
    width: 960,
    height: 540,
  );

  late final InputController input;
  late final BaseCore baseCore;
  late final Player player;

  late final EnemyDatabase enemyDatabase;
  late final TowerDatabase towerDatabase;
  late final UpgradeDatabase upgradeDatabase;

  late final WaveManager waveManager;
  late final TowerBuilderSystem towerBuilder;
  late final RingExpansionSystem ringExpansion;
  late final UpgradeDraftSystem upgradeDraft;

  final Storage storage = Storage.instance;
  final GameRng rng = GameRng();

  final ValueNotifier<int> coreHp = ValueNotifier<int>(0);
  final ValueNotifier<int> essence = ValueNotifier<int>(0);
  final ValueNotifier<int> crackedSigils = ValueNotifier<int>(0);
  final ValueNotifier<int> waveIndex = ValueNotifier<int>(1);
  final ValueNotifier<int> unlockedRing =
  ValueNotifier<int>(GameConstants.startingRings);
  final ValueNotifier<double> waveCountdown =
  ValueNotifier<double>(GameConstants.timeBetweenWaves);
  final ValueNotifier<bool> gameOver = ValueNotifier<bool>(false);

  bool get isReady => _isReady;
  bool get isGameOver => _isGameOver;

  int get currentWave => waveIndex.value;

  bool _isReady = false;
  bool _isGameOver = false;
  bool _audioUnlocked = false;
  bool _buildMode = false;
  String? _pendingTowerId;

  int _activeEnemies = 0;
  double _waveTimer = GameConstants.timeBetweenWaves;

  final Vector2 _worldSize = GameConstants.worldSize.clone();
  final Map<String, bool> _towerTechFlags = <String, bool>{};

  @override
  Color backgroundColor() => GamePalette.background;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await storage.init();

    enemyDatabase = await EnemyDatabase.load();
    towerDatabase = await TowerDatabase.load();
    upgradeDatabase = await UpgradeDatabase.load();

    addAll([world, camera]);

    // ✅ Set viewfinder properties on the camera here
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 1.05;

    ringExpansion = RingExpansionSystem(
      startingRings: GameConstants.startingRings,
      tileSize: GameConstants.gridSize,
    );
    add(ringExpansion);

    final bool useJoystick = _shouldUseVirtualJoystick();
    input = InputController(enableVirtualJoystick: useJoystick);
    add(input);
    add(_AppGameTapHandler());

    baseCore = BaseCore(maxHp: GameConstants.baseCoreMaxHp)
      ..position = Vector2.zero();
    baseCore.onDestroyed = _handleGameOver;
    await world.add(baseCore);
    coreHp.value = baseCore.hp.value;
    baseCore.hp.addListener(() {
      coreHp.value = baseCore.hp.value;
      if (baseCore.hp.value <= 0) {
        _handleGameOver();
      }
    });

    player = Player(
      input: input,
    )..position = Vector2(0, -GameConstants.gridSize * 2);
    await world.add(player);

    // Follow the player with the camera
    camera.follow(player);

    towerBuilder = TowerBuilderSystem(
      towerDatabase: towerDatabase,
      ringExpansion: ringExpansion,
      essence: essence,
      crackedSigils: crackedSigils,
    );
    await add(towerBuilder);

    upgradeDraft = UpgradeDraftSystem(
      upgradeDatabase: upgradeDatabase,
      rng: rng,
      onUpgradeChosen: _applyUpgrade,
    );

    waveManager = WaveManager(
      enemyDatabase: enemyDatabase,
      waveIndex: waveIndex,
      onWaveCompleted: _onWaveCompleted,
      spawnEnemy: _spawnEnemy,
      onWaveTimerChanged: (value) {
        _waveTimer = value;
        waveCountdown.value = value;
      },
    );
    await add(waveManager);

    essence.value = 0;
    storage.setInt(Storage.keyMetaCurrency, essence.value);
    unlockedRing.value =
        math.max(GameConstants.startingRings, storage.getInt(Storage.keyMetaUnlocks));
    ringExpansion.unlockedRings = unlockedRing.value;

    overlays.add(hudOverlay);
    _isReady = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isReady || _isGameOver) {
      return;
    }

    if (!waveManager.isWaveRunning) {
      _waveTimer = math.max(0, _waveTimer - dt);
      waveCountdown.value = _waveTimer;
      if (_waveTimer <= 0) {
        _startNextWave();
      }
    }
  }

  Future<void> _spawnEnemy(EnemyDefinition definition) async {
    final spawnDistance = _worldSize.x * 0.45;
    final angle = rng.nextDouble() * math.pi * 2;
    final spawnPosition = Vector2(
      math.cos(angle) * spawnDistance,
      math.sin(angle) * spawnDistance,
    );
    final enemy = EnemyComponent(
      definition: definition,
      target: baseCore,
    )..position = spawnPosition;
    enemy.onDeath = (enemy, drops) {
      _activeEnemies = math.max(0, _activeEnemies - 1);
      _handleEnemyDrops(drops, enemy.position, definition.isElite);
      waveManager.onEnemyDefeated();
    };
    enemy.onReachedCore = () {
      baseCore.takeDamage(definition.damage.toInt());
      _activeEnemies = math.max(0, _activeEnemies - 1);
      waveManager.onEnemyDefeated();
    };
    _activeEnemies += 1;
    await world.add(enemy);
  }

  void _handleEnemyDrops(
      Map<String, double> drops, Vector2 position, bool elite) {
    drops.forEach((key, value) {
      final amount = value.round();
      if (amount <= 0) {
        return;
      }
      final pickup = Pickup(
        type: key,
        amount: amount,
      )..position = position.clone();
      pickup.onCollected = () {
        if (key == 'essence') {
          addEssence(amount);
        } else if (key == 'cracked_sigil') {
          crackedSigils.value += amount;
        }
      };
      world.add(pickup);
    });
    if (elite) {
      // Elite enemies guarantee at least 1 essence for now.
      addEssence(1);
    }
  }

  void addEssence(int amount) {
    essence.value += amount;
    storage.setInt(Storage.keyMetaCurrency, essence.value);
  }

  bool spendEssence(int amount) {
    if (essence.value < amount) {
      return false;
    }
    essence.value -= amount;
    storage.setInt(Storage.keyMetaCurrency, essence.value);
    return true;
  }

  bool spendSigil() {
    if (crackedSigils.value <= 0) {
      return false;
    }
    crackedSigils.value -= 1;
    return true;
  }

  void _onWaveCompleted(int clearedWave) {
    if (_isGameOver) {
      return;
    }
    _buildMode = false;
    towerBuilder.clearGhost();
    ringExpansion.unlockNextRing();
    unlockedRing.value = ringExpansion.unlockedRings;
    storage.setInt(Storage.keyMetaUnlocks, unlockedRing.value);
    upgradeDraft.presentChoices();
    showUpgradeOverlay();
  }

  void _startNextWave() {
    waveManager.startNextWave();
    _waveTimer = waveManager.waveDuration;
    waveCountdown.value = _waveTimer;
  }

  void applyTowerTech(String key) {
    _towerTechFlags[key] = true;
    towerBuilder.setTowerTechFlags(_towerTechFlags);
  }

  bool hasTowerTech(String key) => _towerTechFlags[key] ?? false;

  void _applyUpgrade(UpgradeDefinition definition) {
    switch (definition.type) {
      case UpgradeType.playerPerk:
        _applyPlayerPerk(definition);
      case UpgradeType.weaponMod:
        _applyWeaponMod(definition);
      case UpgradeType.towerTech:
        applyTowerTech(definition.id);
    }
  }

  void _applyPlayerPerk(UpgradeDefinition upgrade) {
    switch (upgrade.id) {
      case 'perk_move_1':
        player.moveSpeedMultiplier *= 1.15;
        break;
      case 'perk_dash_1':
        player.maxDashCharges += 1;
        break;
      case 'perk_magnet_1':
        player.magnetRadius += 80;
        break;
      default:
        player.moveSpeedMultiplier *= 1.05;
        break;
    }
  }

  void _applyWeaponMod(UpgradeDefinition upgrade) {
    switch (upgrade.id) {
      case 'mod_rate_1':
        player.fireInterval = math.max(0.1, player.fireInterval * 0.9);
        break;
      case 'mod_speed_1':
        player.projectileSpeed *= 1.15;
        break;
      default:
        player.fireInterval = math.max(0.1, player.fireInterval * 0.95);
        break;
    }
  }

  void finishUpgradeDraft() {
    overlays.remove(upgradeOverlay);
    resumeEngine();
    _waveTimer = 0;
    _startNextWave();
  }

  void showUpgradeOverlay() {
    pauseEngine();
    overlays.add(upgradeOverlay);
  }

  void toggleBuildOverlay() {
    if (overlays.isActive(buildOverlay)) {
      overlays.remove(buildOverlay);
      _buildMode = false;
      towerBuilder.clearGhost();
      _pendingTowerId = null;
    } else {
      overlays.add(buildOverlay);
      _buildMode = true;
    }
  }

  void showSettingsOverlay() {
    pauseEngine();
    overlays.add(settingsOverlay);
  }

  void hideSettingsOverlay() {
    overlays.remove(settingsOverlay);
    resumeEngine();
  }

  void showGameOver() {
    overlays.add(gameOverOverlay);
  }

  void hideGameOver() {
    overlays.remove(gameOverOverlay);
  }

  void selectTowerToBuild(String towerId) {
    _pendingTowerId = towerId;
    towerBuilder.prepareGhost(towerId);
  }

  void handleTap(TapUpEvent event) {
    if (!_audioUnlocked) {
      _audioUnlocked = true;
    }
    if (_buildMode && _pendingTowerId != null) {
      final worldPosition = _screenToWorld(event.canvasPosition);
      final placed = towerBuilder.placeTower(_pendingTowerId!, worldPosition);
      if (placed) {
        _pendingTowerId = null;
      }
    }
  }

  Vector2 _screenToWorld(Vector2 screenPosition) {
    final viewportPoint = camera.viewport.globalToLocal(screenPosition);
    return camera.viewfinder.globalToLocal(viewportPoint);
  }

  void onSettingsChanged({double? volume, bool? reducedMotion}) {
    if (volume != null) {
      storage.setDouble(Storage.keyOptionsVolume, volume);
    }
    if (reducedMotion != null) {
      storage.setBool(Storage.keyOptionsReducedMotion, reducedMotion);
    }
  }

  void _handleGameOver() {
    if (_isGameOver) {
      return;
    }
    _isGameOver = true;
    gameOver.value = true;
    pauseEngine();
    showGameOver();
  }

  void restart() {
    overlays.remove(upgradeOverlay);
    overlays.remove(buildOverlay);
    overlays.remove(settingsOverlay);
    overlays.remove(gameOverOverlay);

    _isGameOver = false;
    gameOver.value = false;
    _waveTimer = GameConstants.timeBetweenWaves;
    waveCountdown.value = _waveTimer;
    waveIndex.value = 1;
    _activeEnemies = 0;

    baseCore.reset();
    coreHp.value = baseCore.hp.value;

    player.resetState(Vector2(0, -GameConstants.gridSize * 2));

    towerBuilder.reset();
    crackedSigils.value = 0;
    essence.value = 0;
    storage.setInt(Storage.keyMetaCurrency, essence.value);
    _pendingTowerId = null;
    ringExpansion.unlockedRings = GameConstants.startingRings;
    unlockedRing.value = ringExpansion.unlockedRings;

    final enemies = world.children.whereType<EnemyComponent>().toList();
    for (final enemy in enemies) {
      enemy.removeFromParent();
    }
    final pickups = world.children.whereType<Pickup>().toList();
    for (final pickup in pickups) {
      pickup.removeFromParent();
    }
    final projectiles = world.children.whereType<Projectile>().toList();
    for (final projectile in projectiles) {
      projectile.removeFromParent();
    }

    resumeEngine();
    overlays.add(hudOverlay);
  }

  bool _shouldUseVirtualJoystick() {
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
}

class _AppGameTapHandler extends Component
    with TapCallbacks, HasGameRef<AppGame> {
  @override
  void onTapUp(TapUpEvent event) {
    gameRef.handleTap(event);
  }
}
