import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/zone.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';

class AdventureScreen extends StatefulWidget {
  final GameController controller;

  const AdventureScreen({super.key, required this.controller});

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  void _explore() {
    final outcome = widget.controller.explore();
    if (outcome == null || !mounted) return;
    final battle = outcome.battle;
    final loot = battle.loot;
    final lootLines = <String>[
      '+${formatNumber(loot.spiritStones)} spirit stones',
      if (loot.spiritHerbs > 0) '+${loot.spiritHerbs} spirit herb(s)',
      if (loot.beastCores > 0) '+${loot.beastCores} beast core(s)',
      if (loot.equipment != null && outcome.equipped)
        'Equipped ${loot.equipment!.name} (${loot.equipment!.gradeName} '
            '${loot.equipment!.slotLabel})',
      if (loot.equipment != null && !outcome.equipped)
        'Sold ${loot.equipment!.name} for '
            '${formatNumber(outcome.soldFor)} spirit stones',
      if (loot.technique != null)
        'Discovered technique: ${loot.technique!.name}',
      if (loot.tamedCompanion != null)
        'Tamed companion: ${loot.tamedCompanion!.name}',
    ];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(battle.victory ? 'Victory' : 'Retreat'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lootLines.isEmpty ? 'Nothing gained.' : lootLines.join('\n'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  child: Text(
                    battle.log.join('\n'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    ).then((_) => _maybeShowEvent());
  }

  void _maybeShowEvent() {
    final eventId = widget.controller.state.pendingEventId;
    if (eventId == null || !mounted) return;
    final event = EventEngine.byId(eventId);
    if (event == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(event.title),
        content: Text(event.description),
        actions: [
          for (var i = 0; i < event.choices.length; i++)
            TextButton(
              onPressed: () {
                final outcome = widget.controller.resolvePendingEvent(i);
                Navigator.of(dialogContext).pop();
                if (outcome != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(outcome.message),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text(event.choices[i].label),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        final zones = ZoneCatalog.zones;
        final unlockedIndexes = <int>[
          for (var i = 0; i < zones.length; i++)
            if (CombatEngine.isZoneUnlocked(state, zones[i])) i,
        ];
        final effectiveIndex = widget.controller.effectiveZoneIndex();
        final zone = zones[effectiveIndex];
        final firstLocked = zones
            .where((z) => !CombatEngine.isZoneUnlocked(state, z))
            .toList()
            .firstOrNull;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Adventure'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zone',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButton<int>(
                          isExpanded: true,
                          value: effectiveIndex,
                          items: [
                            for (final i in unlockedIndexes)
                              DropdownMenuItem(
                                value: i,
                                child: Text(zones[i].name),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              widget.controller.selectZone(value);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Foes: ${zone.beasts.map((b) => b.name).join(', ')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (firstLocked != null)
                          Text(
                            '${firstLocked.name} unlocks at '
                            '${realmLabel(firstLocked.requiredRealm)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _CombatStatsCard(state: state),
                const SizedBox(height: 16),
                _BattleRecordsCard(state: state),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _explore,
            icon: const Icon(Icons.explore),
            label: const Text('Explore'),
          ),
        );
      },
    );
  }

  String realmLabel(int realmIndex) {
    if (realmIndex < RealmLadder.realmNames.length) {
      return RealmLadder.realmName(realmIndex);
    }
    return 'the final realm';
  }
}

class _CombatStatsCard extends StatelessWidget {
  final GameState state;

  const _CombatStatsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Combat',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _row(
              context,
              'Attack',
              formatNumber(CombatEngine.playerAttack(state)),
            ),
            _row(
              context,
              'Defense',
              formatNumber(CombatEngine.playerDefense(state)),
            ),
            _row(
              context,
              'Health',
              formatNumber(CombatEngine.playerMaxHp(state)),
            ),
            const SizedBox(height: 8),
            Text(
              state.weapon == null && state.armor == null
                  ? 'No equipment — defeat beasts to find weapons and armor.'
                  : '${state.weapon?.name ?? "No weapon"} '
                      '(${state.weapon?.gradeName ?? "-"}) · '
                      '${state.armor?.name ?? "No armor"} '
                      '(${state.armor?.gradeName ?? "-"})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
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

class _BattleRecordsCard extends StatelessWidget {
  final GameState state;

  const _BattleRecordsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battle Records',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _row(context, 'Battles won', '${state.battlesWon}'),
            _row(context, 'Battles lost', '${state.battlesLost}'),
            _row(context, 'Equipment sold', '${state.equipmentSold}'),
            _row(context, 'Spirit herbs', '${state.spiritHerbs}'),
            _row(context, 'Beast cores', '${state.beastCores}'),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
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
