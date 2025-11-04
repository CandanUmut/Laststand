# Devil's Last Stand MVP

This repository contains a Flame-powered survivor-meets-tower-defense prototype targeting Android, iOS, and Web. The game is fully data driven so designers can iterate on JSON without rebuilding the binary.

## Running the Game

1. Install the latest [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. From the `devils_last_stand` directory run `flutter pub get` to download dependencies.
3. Launch on your preferred target:
   * Web (CanvasKit): `flutter run -d chrome --web-renderer canvaskit`
   * Web (HTML fallback): `flutter run -d chrome --web-renderer html`
   * Android/iOS: `flutter run`

> **First tap unlocks audio on the web.** Avoid playing SFX until the player interacts once to satisfy browser autoplay policies.

## Project Layout

```
lib/
  core/        // constants, RNG helpers, shared input + save utilities
  data/        // JSON-backed definition loading
  game/        // Flame game, components, and gameplay systems
  scenes/      // placeholder scene stubs for future menus
  ui/          // Flutter overlays (HUD, build, upgrades, settings)
assets/
  data/        // Tunable enemy, tower, weapon, and upgrade stats
  sfx/         // Placeholder audio hooks
```

## Tuning & Data

* Core numbers live in `lib/core/constants.dart`.
* Gameplay stats are defined in `assets/data/*.json` and hot-reloaded by Flutter; no code rebuild required.
* Save data (volume, reduced motion, meta currency/unlocks) is persisted via `SharedPreferences` in `lib/core/save.dart` and works across web/mobile.

## Known Limitations

* Placeholder art/audio and extremely light feedback for the Redeemer conversion.
* No networked leaderboard or deterministic seeding yet.
* Particle heavy effects are still enabled even when reduced motion is toggled; future work can add alternate visuals.
