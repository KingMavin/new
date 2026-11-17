import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';

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
      _showOfflineReportIfNeeded();
    });
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
    final result = widget.controller.attemptBreakthrough();
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
        final chance = CultivationEngine.breakthroughChance(state);
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
                if (!state.ascended)
                  FilledButton.icon(
                    onPressed: ready ? _attemptBreakthrough : null,
                    icon: const Icon(Icons.bolt),
                    label: Text(
                      ready
                          ? 'Attempt Breakthrough '
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
              'Breakthroughs succeeded',
              '${state.breakthroughsSucceeded}',
            ),
            _statRow(
              context,
              'Breakthroughs failed',
              '${state.breakthroughsFailed}',
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
