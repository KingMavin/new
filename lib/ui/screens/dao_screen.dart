import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/power.dart';
import 'package:immortal_path/game/models/sect.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/soul_upgrade.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/game/models/world_location.dart';
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
                  'Soul',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _SoulCard(controller: controller, state: state),
                const SizedBox(height: 8),
                for (final upgrade in SoulUpgrade.catalog)
                  _SoulUpgradeCard(
                    controller: controller,
                    state: state,
                    upgrade: upgrade,
                  ),
                const SizedBox(height: 16),
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
                  'Special Powers',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Powers found in the wilds root themselves in your blood '
                  'and follow you even through reincarnation. Sect arts are '
                  'taught only to those who serve.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                for (final power in PowerCatalog.powers)
                  _PowerCard(
                    controller: controller,
                    state: state,
                    power: power,
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
                      title: Text('${companion.name} \u00b7 Lv ${companion.level}'),
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
                const SizedBox(height: 16),
                Text(
                  'Codex \u00b7 Beasts Slain',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _CodexCard(state: state),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SoulCard extends StatelessWidget {
  final GameController controller;
  final GameState state;

  const _SoulCard({required this.controller, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soul Power: ${state.soulPower}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              state.reincarnations == 0
                  ? 'Ascend and reincarnate to awaken your soul.'
                  : 'Reincarnations: ${state.reincarnations}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SoulUpgradeCard extends StatelessWidget {
  final GameController controller;
  final GameState state;
  final SoulUpgrade upgrade;

  const _SoulUpgradeCard({
    required this.controller,
    required this.state,
    required this.upgrade,
  });

  @override
  Widget build(BuildContext context) {
    final level = SoulEngine.upgradeLevel(state, upgrade.id);
    final maxed = level >= upgrade.maxLevel;
    final cost = SoulEngine.upgradeCost(upgrade, level);
    final affordable = state.soulPower >= cost;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.auto_awesome),
        title: Text('${upgrade.name} \u00b7 Lv $level/${upgrade.maxLevel}'),
        subtitle: Text(upgrade.description),
        trailing: maxed
            ? const Chip(label: Text('Max'))
            : FilledButton.tonal(
                onPressed: affordable
                    ? () => controller.buySoulUpgrade(upgrade.id)
                    : null,
                child: Text('$cost SP'),
              ),
      ),
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

class _PowerCard extends StatelessWidget {
  final GameController controller;
  final GameState state;
  final BloodlinePower power;

  const _PowerCard({
    required this.controller,
    required this.state,
    required this.power,
  });

  @override
  Widget build(BuildContext context) {
    final discovered = PowerEngine.isDiscovered(state, power.id);
    if (power.isSectPower) {
      final sect = Sect.byId(power.sectId!);
      final rank = SectEngine.rankOf(state.contribution);
      final eligible = state.sectId == power.sectId &&
          rank >= power.minSectRank &&
          state.contribution >= power.contributionCost;
      return Card(
        child: ListTile(
          leading: const Icon(Icons.workspace_premium),
          title: Text(power.name),
          subtitle: Text(
            discovered
                ? '${power.bonusLabel}\n${power.description}'
                : '${power.bonusLabel} \u00b7 taught only by the ${sect.name}. '
                    'Requires ${SectEngine.rankNames[power.minSectRank]} rank '
                    'and ${power.contributionCost} contribution.',
          ),
          isThreeLine: true,
          trailing: discovered
              ? const Chip(label: Text('Learned'))
              : FilledButton.tonal(
                  onPressed: eligible
                      ? () => controller.buySectPower(power.id)
                      : null,
                  child: Text('${power.contributionCost} pts'),
                ),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: Icon(
          discovered ? Icons.flash_on : Icons.help_outline,
          color: discovered ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(discovered ? power.name : 'Unfound Power'),
        subtitle: Text(
          discovered
              ? '${power.bonusLabel}\n${power.description}'
              : 'A legend of the wilds \u2014 some say it lies where the '
                  'strongest beasts make their dens.',
        ),
        isThreeLine: true,
        trailing: discovered ? const Chip(label: Text('Ingrained')) : null,
      ),
    );
  }
}

class _CodexCard extends StatelessWidget {
  final GameState state;

  const _CodexCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final entries = <Widget>[];
    for (final zone in WorldCatalog.locations) {
      for (final beast in zone.beasts) {
        final known = state.bestiary.contains(beast.name);
        entries.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  known ? beast.name : '???',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  known
                      ? 'HP ${beast.hp.toStringAsFixed(0)} \u00b7 '
                          'ATK ${beast.attack.toStringAsFixed(0)} \u00b7 '
                          '${zone.name}'
                      : 'Undiscovered',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${state.bestiary.length} of '
              '${WorldCatalog.locations.fold<int>(0, (sum, z) => sum + z.beasts.length)} '
              'beasts recorded',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            ...entries,
          ],
        ),
      ),
    );
  }
}
