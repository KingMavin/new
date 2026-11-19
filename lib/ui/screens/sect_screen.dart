import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/disciple_engine.dart';
import 'package:immortal_path/game/engine/reputation_engine.dart';
import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/engine/tournament_engine.dart';
import 'package:immortal_path/game/engine/war_engine.dart';
import 'package:immortal_path/game/models/disciple.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/sect.dart';
import 'package:immortal_path/game/models/sect_npc.dart';
import 'package:immortal_path/game/models/sect_task.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/sect_store_screen.dart';
import 'package:immortal_path/ui/screens/settings_screen.dart';
import 'package:immortal_path/ui/screens/encounter_screen.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class SectScreen extends StatelessWidget {
  final GameController controller;

  const SectScreen({super.key, required this.controller});

  void _confirmLeave(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave the sect?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Breaking your oath costs:'),
            SizedBox(height: 8),
            Text(
              '\u2022 All accumulated contribution, your rank and your '
              'standing in the hall.',
            ),
            Text('\u2022 60 reputation with your faction.'),
            Text('\u2022 Sect arts you learned are lost \u2014 their '
                'power leaves with the oath.'),
            Text('\u2022 Their gates will not open for you again this '
                'life.'),
            SizedBox(height: 8),
            Text(
              'The errant road begins in silence \u2014 strength is your '
              'only banner now.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
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
            child: const Text('Break the oath'),
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
        return BackdropScaffold(
          asset: BackdropCatalog.forScreen('sect'),

          appBar: AppBar(
            title: const Text('Sect'),
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
                if (sect == null) ...[
                  _TaskBoardCard(controller: controller),
                  const SizedBox(height: 16),
                  ..._buildJoinSection(context, state),
                ] else ...[
                  _SectHallCard(state: state),
                  const SizedBox(height: 16),
                  _SectStatusCard(state: state, sect: sect),
                  const SizedBox(height: 16),
                  _TaskBoardCard(controller: controller),
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
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.storefront),
                      title: const Text('Sect Armory'),
                      subtitle: const Text(
                        'Sect-forged gear for spirit stones, and ancestral '
                        'offerings for coin.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SectStoreScreen(
                            controller: controller,
                          ),
                        ),
                      ),
                    ),
                  ),
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
    final widgets = <Widget>[];
    if (state.raceId == null) {
      widgets.add(
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Choose your origin first \u2014 each faction keeps its own '
              'halls, and its own gates.',
            ),
          ),
        ),
      );
      return widgets;
    }
    final factionName =
        ReputationEngine.factionNames[state.raceId] ?? 'your faction';
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Halls of the $factionName',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
    widgets.add(const SizedBox(height: 8));
    for (final sect in Sect.forFaction(state.raceId!)) {
      final blocker = SectEngine.joinBlocker(state, sect.id);
      widgets.add(_SectJoinCard(
        state: state,
        sect: sect,
        blocker: blocker,
        onJoin: () => controller.joinSect(sect.id),
      ));
      widgets.add(const SizedBox(height: 8));
    }
    final otherFactions = ReputationEngine.factionNames.keys
        .where((id) => id != state.raceId)
        .toList();
    if (otherFactions.isNotEmpty) {
      widgets.add(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Foreign Halls', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                for (final id in otherFactions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${ReputationEngine.factionNames[id]} \u2014 they take '
                      'only their own people.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    if (state.realmIndex < SectEngine.joinRealmRequirement) {
      widgets.add(const SizedBox(height: 8));
      widgets.add(
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Sects only accept cultivators of Foundation Establishment '
              'realm or higher.',
            ),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _SectJoinCard extends StatelessWidget {
  final GameState state;
  final Sect sect;
  final String? blocker;
  final VoidCallback onJoin;

  const _SectJoinCard({
    required this.state,
    required this.sect,
    required this.blocker,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sect.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              sect.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              sect.hallLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              sect.bonusLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            if (blocker != null)
              Text(
                blocker,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              )
            else
              FilledButton.tonal(
                onPressed: onJoin,
                child: const Text('Swear allegiance'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrantPathCard extends StatelessWidget {
  final GameState state;

  const _ErrantPathCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final rep = ReputationEngine.ownReputation(state);
    final next = ReputationEngine.nextThreshold(rep);
    final gatekeeper =
        SectHallCatalog.gatekeepers[state.raceId] ??
            SectHallCatalog.gatekeepers.values.first;
    final quote = gatekeeper.lineFor(seed: DateTime.now().day + rep);
    final factionName =
        ReputationEngine.factionNames[state.raceId] ?? 'the world';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.explore),
                const SizedBox(width: 8),
                Text('The Errant Path', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'You walk unsworn. Sects sharpen their own \u2014 the roads '
              'answer to strength.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              next < 0
                  ? 'Standing with $factionName: '
                      '${ReputationEngine.standingLabel(rep)} ($rep)'
                  : 'Standing with $factionName: '
                      '${ReputationEngine.standingLabel(rep)} ($rep) \u2014 '
                      '${next - rep} more for the next tier',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: next < 0 ? 1.0 : (rep / next).clamp(0.0, 1.0),
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              'Combat deeds earn +25% reputation \u2014 strength is the '
              'answer.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Hall tasks pay reputation \u00d72.5, but no sect contribution '
              'or ranks.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              '"$quote"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            Text(
              '\u2014 ${gatekeeper.name}, ${gatekeeper.title}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskBoardCard extends StatelessWidget {
  final GameController controller;

  const _TaskBoardCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final sworn = state.sectId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Task Board', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sworn
                      ? 'The sect posts its tasks \u2014 fulfil them for '
                          'contribution, reputation and stones.'
                      : 'The faction halls post tasks for the unsworn \u2014 '
                          'paid in reputation, counted by strength.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < state.sectTasks.length; i++)
                  _TaskCard(
                    state: state,
                    task: state.sectTasks[i],
                    controller: controller,
                    index: i,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final GameState state;
  final ActiveTask task;
  final GameController controller;
  final int index;

  const _TaskCard({
    required this.state,
    required this.task,
    required this.controller,
    required this.index,
  });

  static const Map<String, IconData> taskIcons = {
    'beast_hunt': Icons.travel_explore,
    'war_serve': Icons.shield,
    'tournament_fight': Icons.emoji_events,
    'brew_pills': Icons.science,
    'wander_far': Icons.map,
  };

  @override
  Widget build(BuildContext context) {
    final type = task.type();
    final sworn = state.sectId != null;
    final repGain =
        sworn ? task.reputation : (task.reputation * 2.5).round();
    final reward = sworn
        ? '+${task.contribution} contribution \u00b7 +$repGain reputation '
            '\u00b7 +${formatNumber(task.stones)} spirit stones'
        : '+$repGain reputation \u00b7 +${formatNumber(task.stones)} '
            'spirit stones';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(taskIcons[type.id] ?? Icons.assignment),
              const SizedBox(width: 8),
              Expanded(
                child: Text(type.title, style: Theme.of(context).textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(type.description, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Progress: ${task.progress} / ${task.target}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              FilledButton.tonal(
                onPressed: task.complete
                    ? () {
                        final message = controller.claimSectTask(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              message ?? 'The task is not yet fulfilled.',
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(task.complete ? 'Claim reward' : 'In progress'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: (task.progress / task.target).clamp(0.0, 1.0),
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 4),
          Text(reward, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SectHallCard extends StatelessWidget {
  final GameState state;

  const _SectHallCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final sectId = state.sectId;
    if (sectId == null) return const SizedBox.shrink();
    final sect = Sect.byId(sectId);
    final hall = SectHallCatalog.byId(sectId);
    if (hall.sectId != sectId) return const SizedBox.shrink();
    final seedBase = DateTime.now().day +
        SectEngine.rankOf(state.contribution) +
        state.journal.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The Hall of ${sect.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sect.hallLine,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            const SizedBox(height: 8),
            _NpcRow(
              npc: hall.master,
              icon: Icons.workspace_premium,
              seed: seedBase,
            ),
            _NpcRow(
              npc: hall.steward,
              icon: Icons.assignment,
              seed: seedBase + 1,
            ),
            _NpcRow(
              npc: hall.quartermaster,
              icon: Icons.storefront,
              seed: seedBase + 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _NpcRow extends StatelessWidget {
  final SectNpc npc;
  final IconData icon;
  final int seed;

  const _NpcRow({required this.npc, required this.icon, required this.seed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${npc.name} \u2014 ${npc.title}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '"${npc.lineFor(seed: seed)}"',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
