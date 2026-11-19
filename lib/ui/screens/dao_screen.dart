import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/achievements_engine.dart';
import 'package:immortal_path/game/engine/power_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/companion.dart';
import 'package:immortal_path/game/models/power.dart';
import 'package:immortal_path/game/models/sect.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/consequence.dart';
import 'package:immortal_path/game/models/soul_upgrade.dart';
import 'package:immortal_path/game/models/technique.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/voice_line.dart';
import 'package:immortal_path/ui/screens/settings_screen.dart';
import 'package:immortal_path/ui/screens/tribulation_screen.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

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
        return BackdropScaffold(
          asset: BackdropCatalog.forScreen('dao'),

          appBar: AppBar(
            title: const Text('Dao'),
                    actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsScreen(controller: controller),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                VoiceLine.screen('dao'),
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
                    masteryLabel: state.techniqueId == technique.id
                        ? 'Mastery Lv ${controller.techniqueMasteryLevel()}'
                            '/15 \u00b7 attack '
                            '+${controller.techniqueMasteryLevel()}% '
                            '(grows with every victory)'
                        : null,
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
                  'Marks of the Path',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _MarksCard(state: state),
                const SizedBox(height: 16),
                Text(
                  'Codex \u00b7 Beasts Slain',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _CodexCard(state: state),
                const SizedBox(height: 16),
                Text(
                  'Chronicle',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _ChronicleCard(controller: controller, state: state),
                const SizedBox(height: 16),
                Text(
                  'Deeds',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _AchievementsCard(controller: controller, state: state),
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

  final String? masteryLabel;

  const _TechniqueCard({
    required this.technique,
    required this.discovered,
    required this.equipped,
    this.masteryLabel,
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
        subtitle: Text(
          discovered
              ? (masteryLabel == null
                  ? technique.description
                  : '${technique.description}\n$masteryLabel')
              : '???',
        ),
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

class _MarksCard extends StatelessWidget {
  final GameState state;

  const _MarksCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final marks = [
      for (final id in state.consequences) ConsequenceCatalog.byId(id),
    ].whereType<GameConsequence>().toList();
    if (marks.isEmpty) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.fingerprint),
          title: Text('Unmarked'),
          subtitle: Text(
            'The world has not written on you yet. Choices in fights, wars '
            'and roadside events leave lasting marks \u2014 boons and banes '
            'that hold until the wheel washes them away.',
          ),
          isThreeLine: true,
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (final mark in marks)
            ListTile(
              leading: Icon(
                mark.boon ? Icons.auto_awesome : Icons.healing,
                color: mark.boon
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              title: Text('${mark.title} \u00b7 ${mark.boon ? 'boon' : 'bane'}'),
              subtitle: Text(mark.description),
              isThreeLine: true,
            ),
        ],
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

class _ChronicleCard extends StatelessWidget {
  final GameController controller;
  final GameState state;

  const _ChronicleCard({required this.controller, required this.state});

  String _stamp(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _openFullChronicle(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chronicle'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.journal.length,
            itemBuilder: (context, index) {
              final entry = state.journal[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 18),
                title: Text(entry.text),
                subtitle: Text(_stamp(entry.time)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = state.journal.take(8).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entries.isEmpty)
              Text(
                'Your chronicle is unwritten. Hunts, deeds and fortunes '
                'will collect here for this life.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final entry in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(Icons.circle, size: 6),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.text,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _stamp(entry.time),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
            if (entries.isNotEmpty)
              TextButton(
                onPressed: () => _openFullChronicle(context),
                child: const Text('View full chronicle'),
              ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final GameController controller;
  final GameState state;

  const _AchievementsCard({required this.controller, required this.state});

  void _openCodex(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Codex of Deeds'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AchievementsEngine.catalog.length,
            itemBuilder: (context, index) {
              final achievement = AchievementsEngine.catalog[index];
              final earned = state.achievements.contains(achievement.id);
              return ListTile(
                dense: true,
                leading: Icon(
                  earned ? Icons.check_circle : Icons.lock_outline,
                  color: earned
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                  size: 20,
                ),
                title: Text(
                  achievement.title,
                  style: TextStyle(
                    color: earned
                        ? null
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                subtitle: Text(achievement.description),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.military_tech),
        title: Text(
          'Deeds \u00b7 ${state.achievements.length}/'
          '${AchievementsEngine.catalog.length}',
        ),
        subtitle: const Text(
          'Titles collected across every life for milestones of the path.',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openCodex(context),
      ),
    );
  }
}
