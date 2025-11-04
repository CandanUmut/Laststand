import 'package:flutter/material.dart';

import 'play_scene.dart';

class LevelSelectScene extends StatelessWidget {
  const LevelSelectScene({super.key});

  @override
  Widget build(BuildContext context) {
    final biomes = [
      'Ashen Docks',
      'Bone Orchard',
      'Sulfur Wastes',
      'Crimson City',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Biome')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: biomes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final enabled = index == 0;
          return ListTile(
            title: Text(biomes[index]),
            subtitle: Text(index == 0
                ? 'Starter biome with open lanes and oil slick hazards.'
                : 'Locked for MVP'),
            trailing: ElevatedButton(
              onPressed: enabled
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PlayScene(biomeId: 'ashen_docks'),
                        ),
                      );
                    }
                  : null,
              child: const Text('Deploy'),
            ),
          );
        },
      ),
    );
  }
}
