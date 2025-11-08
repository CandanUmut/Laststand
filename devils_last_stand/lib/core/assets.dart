/// Central place to track asset paths used throughout the project.
class AppAssets {
  static const dataEnemies = 'assets/data/enemies.json';
  static const dataTowers = 'assets/data/towers.json';
  static const dataWeapons = 'assets/data/weapons.json';
  static const dataUpgrades = 'assets/data/upgrades.json';

  static const sfxShoot = 'assets/sfx/shoot.wav';
  static const sfxHit = 'assets/sfx/hit.wav';
  static const sfxPickup = 'assets/sfx/pickup.wav';

  static const _images = 'assets/images';
  static const playerShip = '$_images/player_ship.png';
  static const baseCore = '$_images/base_core.png';
  static const allyTurret = '$_images/ally_turret.png';

  static const Map<String, String> enemySprites = {
    'skitterling': '$_images/enemy_skitterling.png',
    'brute': '$_images/enemy_brute.png',
    'imp_bomber': '$_images/enemy_imp_bomber.png',
  };

  static const Map<String, String> towerSprites = {
    'bolt_spire': '$_images/tower_bolt_spire.png',
    'ember_sprayer': '$_images/tower_ember_sprayer.png',
    'frost_lattice': '$_images/tower_frost_lattice.png',
    'redeemer_totem': '$_images/tower_redeemer_totem.png',
  };

  static const Map<String, String> pickupSprites = {
    'essence': '$_images/pickup_essence.png',
    'cracked_sigil': '$_images/pickup_sigil.png',
  };

  /// Returns a list of sound effect assets so we can preload them together.
  static const preloadSfx = [sfxShoot, sfxHit, sfxPickup];

  static const preloadImages = [
    playerShip,
    baseCore,
    allyTurret,
    ...enemySprites.values,
    ...towerSprites.values,
    ...pickupSprites.values,
  ];
}
