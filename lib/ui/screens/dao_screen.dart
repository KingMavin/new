import 'package:flutter/material.dart';

import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/tribulation_screen.dart';

class DaoScreen extends StatelessWidget {
  final GameController controller;

  const DaoScreen({super.key, required this.controller});

  void _openTribulation(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TribulationDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final companion = state.companion;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dao'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.tribulationActive)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: const Icon(Icons.bolt),
                      title: const Text('A tribulation rages!'),
                      subtitle: const Text(
                        'Face the heavenly lightning before cultivating on.',
                      ),
                      trailing: FilledButton(
                        onPressed: () => _openTribulation(context),
                        child: const Text('Face it'),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Cultivation Techniques',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final technique in Technique.catalog)
                  _TechniqueCard(
                    technique: technique,
                    discovered:
                        state.discoveredTechniques.contains(technique.id),
                    equipped: state.techniqueId == technique.id,
                    onEquip: () => controller.equipTechnique(technique.id),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Spirit Companion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (companion == null)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.pets),
                      title: Text('No companion'),
                      subtitle: Text(
                        'Defeat beasts in the wild for a chance to tame one.',
                      ),
                    ),
                  )
                else
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.pets),
                      title: Text('${companion.name} · Lv ${companion.level}'),
                      subtitle: Text(
                        '${companion.bonusLabel}\n'
                        'Feed ${Companion.feedCost} beast cores to grow '
                        'stronger (max Lv ${Companion.maxLevel}).',
                      ),
                      isThreeLine: true,
                      trailing: FilledButton.tonal(
                        onPressed:
                            state.beastCores >= Companion.feedCost &&
                                    companion.level < Companion.maxLevel
                                ? () => controller.feedCompanion()
                                : null,
                        child: const Text('Feed'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final Technique technique;
  final bool discovered;
  final bool equipped;
  final VoidCallback onEquip;

  const _TechniqueCard({
    required this.technique,
    required this.discovered,
    required this.equipped,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          equipped ? Icons.auto_stories : Icons.menu_book_outlined,
          color: equipped ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(discovered ? technique.name : 'Undiscovered Technique'),
        subtitle: Text(discovered ? technique.description : '???'),
        trailing: equipped
            ? const Chip(label: Text('Active'))
            : discovered
                ? FilledButton.tonal(
                    onPressed: onEquip,
                    child: const Text('Equip'),
                  )
                : null,
      ),
    );
  }
}
