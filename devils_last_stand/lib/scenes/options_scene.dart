import 'package:flutter/material.dart';

import '../core/save.dart';

class OptionsScene extends StatefulWidget {
  const OptionsScene({super.key});

  @override
  State<OptionsScene> createState() => _OptionsSceneState();
}

class _OptionsSceneState extends State<OptionsScene> {
  final Storage storage = Storage.instance;
  double audioVolume = 0.7;
  bool reducedMotion = false;
  String colorBlindMode = 'none';

  @override
  void initState() {
    super.initState();
    storage.init().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        audioVolume =
            storage.getDouble(Storage.keyOptionsVolume, defaultValue: 0.7);
        reducedMotion = storage.getBool(Storage.keyOptionsReducedMotion);
        colorBlindMode = storage.getString(
          Storage.keyOptionsColorBlindMode,
          defaultValue: 'none',
        );
      });
    });
  }

  Future<void> _save() async {
    await storage.init();
    await Future.wait([
      storage.setDouble(Storage.keyOptionsVolume, audioVolume),
      storage.setBool(Storage.keyOptionsReducedMotion, reducedMotion),
      storage.setString(Storage.keyOptionsColorBlindMode, colorBlindMode),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Options')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Audio Volume'),
            subtitle: Slider(
              value: audioVolume,
              onChanged: (value) => setState(() => audioVolume = value),
            ),
          ),
          SwitchListTile(
            title: const Text('Reduced Motion'),
            value: reducedMotion,
            onChanged: (value) => setState(() => reducedMotion = value),
          ),
          DropdownButtonFormField<String>(
            value: colorBlindMode,
            decoration: const InputDecoration(labelText: 'Color Blind Mode'),
            items: const [
              DropdownMenuItem(value: 'none', child: Text('None')),
              DropdownMenuItem(value: 'protanopia', child: Text('Protanopia')),
              DropdownMenuItem(value: 'deuteranopia', child: Text('Deuteranopia')),
            ],
            onChanged: (value) => setState(() => colorBlindMode = value ?? 'none'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _save();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
