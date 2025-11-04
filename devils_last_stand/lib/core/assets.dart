/// Central place to track asset paths used throughout the project.
class AppAssets {
  static const dataEnemies = 'assets/data/enemies.json';
  static const dataTowers = 'assets/data/towers.json';
  static const dataWeapons = 'assets/data/weapons.json';
  static const dataUpgrades = 'assets/data/upgrades.json';

  static const sfxShoot = 'assets/sfx/shoot.wav';
  static const sfxHit = 'assets/sfx/hit.wav';
  static const sfxPickup = 'assets/sfx/pickup.wav';

  /// Returns a list of sound effect assets so we can preload them together.
  static const preloadSfx = [sfxShoot, sfxHit, sfxPickup];
}
