import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/race.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/tribulation_screen.dart';

class HomeScreen extends StatefulWidget {
  final GameController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRaceSelectionIfNeeded();
    });
  }

  void _showRaceSelectionIfNeeded() {
    if (widget.controller.state.raceId != null) {
      _showOfflineReportIfNeeded();
      return;
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RaceSelectionDialog(
        controller: widget.controller,
        onDone: _showOfflineReportIfNeeded,
      ),
    );
  }

  void _showOfflineReportIfNeeded() {
    final report = widget.controller.consumePendingOfflineReport();
    if (!mounted || report == null) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('While you were in seclusion'),
        content: Text(
          'You cultivated for ${formatDuration(report.counted)} '
          'and gained ${formatNumber(report.qiGained)} qi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue cultivating'),
          ),
        ],
      ),
    );
  }

  void _attemptBreakthrough() {
    final attempt = widget.controller.attemptBreakthrough();
    if (attempt.tribulationStarted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => TribulationDialog(controller: widget.controller),
      );
      return;
    }
    final result = attempt.result;
    if (result == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final requirement = CultivationEngine.qiToNextStage(state);
        final ready = CultivationEngine.isBreakthroughReady(state);
        final major = CultivationEngine.isMajorBreakthrough(state);
        final chance = CultivationEngine.effectiveBreakthroughChance(state);
        final progress = (state.qi / requirement).clamp(0.0, 1.0).toDouble();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Immortal Path'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RealmCard(state: state),
                const SizedBox(height: 16),
                _QiCard(
                  state: state,
                  requirement: requirement,
                  progress: progress,
                ),
                const SizedBox(height: 16),
                if (!state.ascended && state.tribulationActive)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: ListTile(
                      leading: const Icon(Icons.bolt),
                      title: const Text('A tribulation rages!'),
                      trailing: FilledButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              TribulationDialog(controller: widget.controller),
                        ),
                        child: const Text('Face it'),
                      ),
                    ),
                  ),
                if (!state.ascended)
                  FilledButton.icon(
                    onPressed: ready ? _attemptBreakthrough : null,
                    icon: const Icon(Icons.bolt),
                    label: Text(
                      ready
                          ? major
                              ? 'Face Heavenly Tribulation'
                              : 'Attempt Breakthrough '
                                  '(${(chance * 100).toStringAsFixed(0)}% chance)'
                          : 'Attempt Breakthrough',
                    ),
                  ),
                if (!state.ascended) const SizedBox(height: 8),
                if (!state.ascended)
                  Text(
                    _nextGoalLabel(state),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 16),
                _StatsCard(state: state),
                if (state.ascended) ...[
                  const SizedBox(height: 16),
                  _ReincarnationCard(
                    controller: widget.controller,
                    state: state,
                  ),
                ],
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: widget.controller.circulateQi,
            icon: const Icon(Icons.self_improvement),
            label: const Text('Circulate Qi'),
          ),
        );
      },
    );
  }

  String _nextGoalLabel(GameState state) {
    if (state.stageIndex < RealmLadder.stagesPerRealm - 1) {
      return 'Next: ${RealmLadder.stageName(state.stageIndex + 1)} stage of '
          '${state.realmName}';
    }
    final nextRealm = state.realmIndex + 1;
    if (nextRealm < RealmLadder.realmNames.length) {
      return 'Next: ${RealmLadder.realmName(nextRealm)} — survive the tribulation';
    }
    return 'Next: Ascend beyond the mortal world';
  }
}

class _RaceSelectionDialog extends StatelessWidget {
  final GameController controller;
  final VoidCallback onDone;

  const _RaceSelectionDialog({required this.controller, required this.onDone});

  void _choose(BuildContext context, Race race) {
    controller.chooseRace(race.id);
    Navigator.of(context).pop();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(race.name),
        content: Text(race.intro),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDone();
            },
            child: const Text('Begin the path'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose your origin'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final race in Race.catalog)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        race.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        race.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        race.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        race.bonusLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () => _choose(context, race),
                        child: Text('Begin as ${race.name}'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _RealmCard extends StatelessWidget {
  final GameState state;

  const _RealmCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.realmName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text('${state.stageName} Stage'),
            Text('Lifespan: ${state.lifespanYears} years'),
            if (state.raceId != null) ...[
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.face, size: 18),
                label: Text(Race.byId(state.raceId!).name),
              ),
            ],
            if (state.ascended) ...[
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Ascended Immortal'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QiCard extends StatelessWidget {
  final GameState state;
  final double requirement;
  final double progress;

  const _QiCard({
    required this.state,
    required this.requirement,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final rate = CultivationEngine.qiPerSecond(state);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Qi', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '+${formatNumber(rate)} qi/s',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${formatNumber(state.qi)} / ${formatNumber(requirement)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: state.ascended ? 1.0 : progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReincarnationCard extends StatelessWidget {
  final GameController controller;
  final GameState state;

  const _ReincarnationCard({
    required this.controller,
    required this.state,
  });

  void _confirmReincarnate(BuildContext context) {
    final gain = SoulEngine.soulPowerGain(state);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reincarnate?'),
        content: Text(
          'Your cultivation, treasures, and sect ties will scatter like '
          'morning mist. In return your soul will crystallize into '
          '$gain soul power.\n\n'
          'Kept: half your spirit stones, discovered techniques, your '
          'companion, your codex, and all soul upgrades.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              controller.reincarnate();
            },
            child: const Text('Embrace rebirth'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gain = SoulEngine.soulPowerGain(state);
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reincarnation',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Soul power: ${state.soulPower} \u00b7 '
              'Reincarnations: ${state.reincarnations}\n'
              'Reincarnating now grants $gain soul power.',
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _confirmReincarnate(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Reincarnate'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final GameState state;

  const _StatsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Records',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _statRow(
              context,
              'Total qi cultivated',
              formatNumber(state.totalQiGained),
            ),
            _statRow(
              context,
              'Spirit stones',
              formatNumber(state.spiritStones),
            ),
            _statRow(
              context,
              'Breakthroughs succeeded',
              '${state.breakthroughsSucceeded}',
            ),
            _statRow(
              context,
              'Breakthroughs failed',
              '${state.breakthroughsFailed}',
            ),
            if (state.breakthroughBonus > 0)
              _statRow(
                context,
                'Pill bonus',
                '+${(state.breakthroughBonus * 100).toStringAsFixed(0)}%',
              ),
            _statRow(
              context,
              'Tribulations survived',
              '${state.tribulationsSurvived}',
            ),
            _statRow(
              context,
              'Tribulations failed',
              '${state.tribulationsFailed}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
