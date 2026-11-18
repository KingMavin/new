import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/ending_engine.dart';
import 'package:immortal_path/game/engine/soul_engine.dart';
import 'package:immortal_path/game/engine/story_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/race.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/story.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/settings_screen.dart';
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

  void _showEndingIfNeeded() {
    final endingId = widget.controller.state.pendingEndingId;
    if (!mounted || endingId == null) {
      _showLegendIfNeeded();
      return;
    }
    final ending = EndingEngine.byId(endingId);
    if (ending == null) {
      _showLegendIfNeeded();
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(ending.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ending.hidden)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Chip(
                    avatar: const Icon(Icons.star, size: 18),
                    label: const Text('Hidden ending discovered'),
                  ),
                ),
              Text(ending.epilogue),
              const SizedBox(height: 8),
              Text(
                'This ending is recorded in your legend and will persist '
                'through every reincarnation.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.acknowledgeEnding();
              _showLegendIfNeeded();
            },
            child: const Text('Continue the legend'),
          ),
        ],
      ),
    );
  }

  void _showLegendIfNeeded() {
    final state = widget.controller.state;
    if (!mounted || !state.immortalized || state.legendSeen) return;
    final name = state.legacyName ?? 'The Nameless One';
    final raceName =
        state.raceId == null ? '' : Race.byId(state.raceId!).name;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('The World Remembers'),
        content: Text(
          'Statues rise in three kingdoms. Sect registries and demon clan '
          'fires alike speak of $name, the immortalized of the $raceName '
          'people.\n\n'
          'From now on, your name echoes through tournaments and wars '
          '\u2014 and it will survive every reincarnation.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.controller.acknowledgeLegend();
            },
            child: const Text('Carry it'),
          ),
        ],
      ),
    );
  }

  void _showOfflineReportIfNeeded() {
    final report = widget.controller.consumePendingOfflineReport();
    if (!mounted || report == null) {
      _showEndingIfNeeded();
      return;
    }
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
            onPressed: () {
              Navigator.of(context).pop();
              _showEndingIfNeeded();
            },
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
                    actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SettingsScreen(controller: widget.controller),
                  ),
                ),
              ),
            ],
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
                _StoryCard(controller: widget.controller, state: state),
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

class _StoryCard extends StatelessWidget {
  final GameController controller;
  final GameState state;

  const _StoryCard({required this.controller, required this.state});

  void _openStoryDialog(BuildContext context, StoryChapter chapter) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StoryDialog(controller: controller, chapter: chapter),
    );
  }

  String _nextGateLabel() {
    if (state.raceId == null) return 'Choose your origin to begin your legend.';
    if (state.storyChapter >= StoryEngine.realmGates.length) {
      return 'Your tale for this life is fully told.';
    }
    final gate = StoryEngine.realmGates[state.storyChapter];
    return 'The next chapter awaits at '
        '${RealmLadder.realmName(gate)} realm.';
  }

  @override
  Widget build(BuildContext context) {
    final chapter = controller.currentStoryChapter();
    final hasPoints = state.pathPoints.values.any((value) => value > 0);
    final dominant = StoryEngine.dominantPath(state);
    final pathInfo = StoryPathInfo.byId(dominant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Path',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (state.immortalized)
                  Chip(
                    avatar: const Icon(Icons.star, size: 18),
                    label: Text(
                      state.legacyName ?? 'Immortalized',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasPoints)
              Text(
                '${pathInfo.name} \u00b7 ${pathInfo.bonusLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            if (chapter != null) ...[
              const SizedBox(height: 8),
              Text(
                'Chapter ${state.storyChapter + 1}: ${chapter.title}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                chapter.narration,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _openStoryDialog(context, chapter),
                icon: const Icon(Icons.auto_stories),
                label: const Text('Continue the story'),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                _nextGateLabel(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (state.achievedEndings.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: [
                  for (final id in state.achievedEndings)
                    Chip(
                      avatar: const Icon(Icons.military_tech, size: 18),
                      label: Text(
                        EndingEngine.byId(id)?.title ?? id,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoryDialog extends StatefulWidget {
  final GameController controller;
  final StoryChapter chapter;

  const _StoryDialog({required this.controller, required this.chapter});

  @override
  State<_StoryDialog> createState() => _StoryDialogState();
}

class _StoryDialogState extends State<_StoryDialog> {
  String? _outcome;

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    return AlertDialog(
      title: Text(chapter.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(chapter.narration),
            const SizedBox(height: 12),
            if (_outcome == null)
              for (var i = 0; i < chapter.choices.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: OutlinedButton(
                    onPressed: () {
                      final outcome = widget.controller.advanceStory(i);
                      if (!mounted) return;
                      setState(() {
                        _outcome = outcome?.choice.narration ??
                            'The moment passes without consequence.';
                      });
                    },
                    child: Text(chapter.choices[i].label),
                  ),
                )
            else ...[
              Text(_outcome!),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('The path continues'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class _RaceSelectionDialog extends StatefulWidget {
  final GameController controller;
  final VoidCallback onDone;

  const _RaceSelectionDialog({required this.controller, required this.onDone});

  @override
  State<_RaceSelectionDialog> createState() => _RaceSelectionDialogState();
}

class _RaceSelectionDialogState extends State<_RaceSelectionDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _choose(BuildContext context, Race race) {
    widget.controller.chooseRace(race.id, name: _nameController.text);
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
              widget.onDone();
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
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: _nameController,
                maxLength: 20,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  hintText: 'The name the world will remember',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ),
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
