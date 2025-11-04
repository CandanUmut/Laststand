import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/save.dart';
import '../game/app_game.dart';

class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({super.key, required this.game});

  static const overlayId = 'SettingsOverlay';

  final AppGame game;

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  late double _volume;
  late bool _reducedMotion;

  @override
  void initState() {
    super.initState();
    _volume = widget.game.storage.getDouble(
      Storage.keyOptionsVolume,
      defaultValue: 0.7,
    );
    _reducedMotion = widget.game.storage.getBool(
      Storage.keyOptionsReducedMotion,
      defaultValue: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black54,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: GamePalette.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Master Volume',
                  style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
                ),
                Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: _volume.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => _volume = value);
                    widget.game.onSettingsChanged(volume: value);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _reducedMotion,
                  onChanged: (value) {
                    setState(() => _reducedMotion = value);
                    widget.game.onSettingsChanged(reducedMotion: value);
                  },
                  title: const Text('Reduced motion'),
                  subtitle: const Text('Simplify particles for accessibility.'),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.game.hideSettingsOverlay();
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
