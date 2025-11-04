# Devil's Last Stand MVP Skeleton

This repository contains a Flutter + Flame scaffolding for the **Devil's Last Stand** prototype. It targets Android, iOS, and Web with an asset-light presentation.

## Getting Started

1. Install the latest [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Run `flutter pub get` to install dependencies.
3. Launch on web with `flutter run -d chrome --web-renderer canvaskit` or on a connected device with `flutter run`.

> **Note:** The container environment used to generate this scaffold did not include the Flutter SDK, so commands such as `flutter create` were not executed. After cloning, ensure Flutter is installed locally before running the project.

## Project Structure

The important directories are:

```
lib/
  core/        // Shared constants, asset keys, input helpers, saving utilities
  data/        // Data models and JSON loading logic
  game/        // Flame game, components, and systems
  scenes/      // Flutter UI scenes for menus, play, and summaries
  ui/          // Flutter overlays used during gameplay
assets/
  data/        // JSON stats for enemies, towers, weapons, upgrades
  sfx/         // Placeholder audio assets
```

## Next Steps

* Flesh out game systems (combat, wave spawning, purify mechanic).
* Replace placeholder art and audio with final assets.
* Implement deterministic seeding, additional biomes, and meta progression.
