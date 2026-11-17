import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/disciple_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/tournament_engine.dart';
import 'package:immortal_path/game/engine/war_engine.dart';
import 'package:immortal_path/game/models/disciple.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/sect.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/encounter_screen.dart';

class SectScreen extends StatelessWidget {
  final GameController controller;

  const SectScreen({super.key, required this.controller});

  void _confirmLeave(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave the sect?'),
        content: const Text(
          'You will lose your rank and contribution. Your disciples '
          'will go their own way.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.leaveSect();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _openDispatchSheet(BuildContext context, int discipleIndex) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dispatch ${controller.state.disciples[discipleIndex].name}',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final mission in DiscipleEngine.missionTypes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission.name,
                          style: Theme.of(sheetContext).textTheme.bodyMedium,
                        ),
                      ),
                      for (final hours in DiscipleEngine.missionDurations)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              controller.dispatchDisciple(
                                discipleIndex,
                                mission.id,
                                hours,
                              );
                            },
                            child: Text(
                              hours < 1
                                  ? '${(hours * 60).round()}m'
                                  : '${hours.toStringAsFixed(0)}h',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final sect = SectEngine.sectOf(state);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sect'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (sect == null)
                  ..._buildJoinSection(context, state)
                else ...[
                  _SectStatusCard(state: state, sect: sect),
                  const SizedBox(height: 16),
                  _EventsSection(controller: controller, state: state),
                  const SizedBox(height: 16),
                  _DisciplesSection(
                    controller: controller,
                    state: state,
                    onDispatch: (index) =>
                        _openDispatchSheet(context, index),
                  ),
                  const SizedBox(height: 16),
                  _MissionLogCard(state: state),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _confirmLeave(context),
                    child: const Text('Leave the sect'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildJoinSection(BuildContext context, GameState state) {
    final canJoin = SectEngine.canJoin(state);
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            state.realmIndex >= SectEngine.joinRealmRequirement
                ? 'Sects of the cultivation world open their gates to you. '
                    'Swear allegiance to one to gain its teachings.'
                : 'Sects only accept cultivators of Foundation Establishment '
                    'realm or higher.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      const SizedBox(height: 8),
      for (final sect in Sect.catalog)
        Card(
          child: ListTile(
            leading: const Icon(Icons.groups),
            title: Text(sect.name),
            subtitle: Text(
              '${sect.description}\n${sect.bonusLabel}',
              isThreeLine: true,
            ),
            trailing: FilledButton.tonal(
              onPressed: canJoin ? () => controller.joinSect(sect.id) : null,
              child: const Text('Join'),
            ),
          ),
        ),
    ];
  }
}

class _EventsSection extends StatelessWidget {
  final GameController controller;
  final GameState state;

  const _EventsSection({required this.controller, required this.state});

  void _enterTournament(BuildContext context) {
    controller.startTournament();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EncounterScreen(controller: controller, location: null),
        fullscreenDialog: true,
      ),
    );
  }

  void _enterWar(BuildContext context) {
    controller.startWar();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EncounterScreen(controller: controller, location: null),
        fullscreenDialog: true,
      ),
    );
  }

  String _tournamentLabel() {
    if (state.raceId == null) return 'Choose a race first';
    if (state.sectId == null) return 'Join a sect first';
    final remaining = controller.tournamentCooldownRemaining();
    if (remaining > Duration.zero) {
      return 'Next bout in ${formatDuration(remaining)}';
    }
    return 'Enter the tournament';
  }

  String _warLabel() {
    if (state.raceId == null) return 'Choose a race first';
    if (state.sectId == null) return 'Join a sect first';
    if (state.realmIndex < WarEngine.requiredRealm) {
      return 'Requires ${RealmLadder.realmName(WarEngine.requiredRealm)} realm';
    }
    final remaining = controller.warCooldownRemaining();
    if (remaining > Duration.zero) {
      return 'Next war in ${formatDuration(remaining)}';
    }
    return 'March to war';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sect Events', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events),
                    const SizedBox(width: 8),
                    Text(
                      'Sect Tournament',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Duel a ranked disciple of your sect on the platform. '
                  'Victory earns '
                  '${formatNumber(TournamentEngine.prizeStones(state))} '
                  'spirit stones and '
                  '${TournamentEngine.prizeContribution(state)} contribution.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: controller.canStartTournament()
                      ? () => _enterTournament(context)
                      : null,
                  icon: const Icon(Icons.sports_kabaddi),
                  label: Text(_tournamentLabel()),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield),
                    const SizedBox(width: 8),
                    Text(
                      'Faction War',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Lead your sect onto a war front. Your side\u2019s strength '
                  '\u2014 your combat power, your disciples, your sect rank '
                  '\u2014 is weighed against the enemy\u2019s before the '
                  'champions meet. Victory earns '
                  '${formatNumber(WarEngine.prizeStones(state))} spirit stones '
                  'and ${WarEngine.prizeContribution(state)} contribution.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: controller.canStartWar()
                      ? () => _enterWar(context)
                      : null,
                  icon: const Icon(Icons.local_fire_department),
                  label: Text(_warLabel()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
class _SectStatusCard extends StatelessWidget {
  final GameState state;
  final Sect sect;

  const _SectStatusCard({required this.state, required this.sect});

  @override
  Widget build(BuildContext context) {
    final rank = SectEngine.rankOf(state.contribution);
    final nextThreshold = SectEngine.nextRankThreshold(state.contribution);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sect.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${SectEngine.rankNames[rank]} \u00b7 ${sect.bonusLabel}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              nextThreshold < 0
                  ? 'Contribution: ${state.contribution} (highest rank)'
                  : 'Contribution: ${state.contribution} \u2014 '
                      '${nextThreshold - state.contribution} more for the next rank',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            LinearProgressIndicator(
              value: nextThreshold < 0
                  ? 1.0
                  : (state.contribution / nextThreshold).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisciplesSection extends StatelessWidget {
  final GameController controller;
  final GameState state;
  final void Function(int index) onDispatch;

  const _DisciplesSection({
    required this.controller,
    required this.state,
    required this.onDispatch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Disciples', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (state.disciples.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.person_add_alt),
              title: Text('No disciples yet'),
              subtitle: Text('Recruit wandering talents to run missions.'),
            ),
          ),
        for (var i = 0; i < state.disciples.length; i++)
          _DiscipleCard(
            disciple: state.disciples[i],
            onDispatch: () => onDispatch(i),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed:
              DiscipleEngine.canRecruit(state) ? controller.recruitDisciple : null,
          icon: const Icon(Icons.person_add_alt),
          label: Text(
            'Recruit Disciple '
            '(${formatNumber(DiscipleEngine.recruitCost)} stones, '
            '${state.disciples.length}/${DiscipleEngine.maxDisciples})',
          ),
        ),
      ],
    );
  }
}

class _DiscipleCard extends StatelessWidget {
  final Disciple disciple;
  final VoidCallback onDispatch;

  const _DiscipleCard({required this.disciple, required this.onDispatch});

  @override
  Widget build(BuildContext context) {
    final mission = disciple.onMission
        ? DiscipleEngine.missionById(disciple.missionType!)
        : null;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.face),
        title: Text('${disciple.name} \u00b7 Lv ${disciple.level}'),
        subtitle: Text(
          disciple.onMission
              ? 'On mission: ${mission!.name} \u2014 '
                  'back at ${disciple.missionEndsAt!.toLocal()}'
              : 'Idle \u2014 ready for a mission.',
        ),
        isThreeLine: disciple.onMission,
        trailing: disciple.onMission
            ? const Chip(label: Text('Away'))
            : FilledButton.tonal(
                onPressed: onDispatch,
                child: const Text('Dispatch'),
              ),
      ),
    );
  }
}

class _MissionLogCard extends StatelessWidget {
  final GameState state;

  const _MissionLogCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mission Log',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.missionLog.isEmpty)
              Text(
                'No missions completed yet.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final entry in state.missionLog)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    entry,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
