import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/reputation_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/screens/settings_screen.dart';
import 'package:immortal_path/ui/screens/encounter_screen.dart';
import 'package:immortal_path/ui/theme/location_theme.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class WorldScreen extends StatelessWidget {
  final GameController controller;

  const WorldScreen({super.key, required this.controller});

  void _openEncounter(BuildContext context, WorldLocation location) {
    controller.clearEncounter();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EncounterScreen(
          controller: controller,
          location: location,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  String _realmLabel(int realmIndex) {
    if (realmIndex < RealmLadder.realmNames.length) {
      return RealmLadder.realmName(realmIndex);
    }
    return 'the final realm';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state;
        final active = controller.effectiveLocation();
        final theme = themeFor(active);
        final hall = state.raceId == null
            ? null
            : WorldCatalog.factionLocationFor(state.raceId!);
        return BackdropScaffold(
          asset: BackdropCatalog.forScreen('world'),

          appBar: AppBar(
            title: const Text('World Map'),
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
                _ActiveLocationCard(
                  location: active,
                  theme: theme,
                  onExplore: () => _openEncounter(context, active),
                ),
                const SizedBox(height: 16),
                _CombatStatsCard(state: state),
                const SizedBox(height: 16),
                _FactionStandingCard(state: state),
                const SizedBox(height: 16),
                Text(
                  'Known Places',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final location in WorldCatalog.locations)
                  if (!location.isFactionHall) ...[
                    if (WorldCatalog.isKnown(
                      state.discoveredLocations,
                      location,
                    ))
                      _LocationCard(
                        location: location,
                        state: state,
                        active: location.id == active.id,
                        realmLabel: _realmLabel(location.requiredRealm),
                        onTravel: () => controller.selectLocation(location.id),
                        onExplore: () => _openEncounter(context, location),
                      )
                    else if (location.isHidden)
                      _UndiscoveredCard(
                        location: location,
                        realmLabel: _realmLabel(location.requiredRealm),
                      ),
                  ],
                if (hall != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Faction Halls',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _FactionHallCard(
                    state: state,
                    hall: hall,
                    realmLabel: _realmLabel(hall.requiredRealm),
                    onTravel: () => controller.selectLocation(hall.id),
                    onExplore: () => _openEncounter(context, hall),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The other factions keep their own halls, closed to '
                    'outsiders. Deeds for your people raise your standing.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActiveLocationCard extends StatelessWidget {
  final WorldLocation location;
  final LocationTheme theme;
  final VoidCallback onExplore;

  const _ActiveLocationCard({
    required this.location,
    required this.theme,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.gradient,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              theme.icon,
              size: 140,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                    Chip(
                      avatar: Icon(theme.icon, size: 18),
                      label: Text(
                        location.typeLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  location.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white.withOpacity(0.92)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Danger: ${'\u2694' * location.dangerTier}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: onExplore,
                      icon: const Icon(Icons.explore),
                      label: Text(
                        location.isRaid ? 'Begin Raid' : 'Explore',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final WorldLocation location;
  final GameState state;
  final bool active;
  final String realmLabel;
  final VoidCallback onTravel;
  final VoidCallback onExplore;

  const _LocationCard({
    required this.location,
    required this.state,
    required this.active,
    required this.realmLabel,
    required this.onTravel,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = CombatEngine.isLocationUnlocked(state, location);
    return Card(
      child: ListTile(
        leading: Icon(
          themeFor(location).icon,
          color: active ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          location.name,
          style: active
              ? TextStyle(fontWeight: FontWeight.bold)
              : null,
        ),
        subtitle: Text(
          '${location.typeLabel} \u00b7 Danger ${location.dangerTier}/5 \u00b7 '
          '$realmLabel\n'
          '${location.isRaid ? 'A raid against an elite foe. ' : ''}'
          'Rewards up to ${formatNumber(location.spiritStoneReward)} '
          'spirit stones.',
          isThreeLine: true,
        ),
        trailing: !unlocked
            ? const Icon(Icons.lock_outline)
            : active
                ? FilledButton.tonal(
                    onPressed: onExplore,
                    child: const Text('Enter'),
                  )
                : FilledButton.tonal(
                    onPressed: onTravel,
                    child: const Text('Travel'),
                  ),
      ),
    );
  }
}

class _FactionStandingCard extends StatelessWidget {
  final GameState state;

  const _FactionStandingCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final ownRep = ReputationEngine.ownReputation(state);
    final tier = ReputationEngine.tierOf(ownRep);
    final next = ReputationEngine.nextThreshold(ownRep);
    final base = ReputationEngine.tierThresholds[tier];
    final progress =
        next < 0 ? 1.0 : ((ownRep - base) / (next - base)).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faction Standing',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final entry in ReputationEngine.factionNames.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.value,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            fontWeight: entry.key == state.raceId
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: entry.key == state.raceId
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                    ),
                    Text(
                      entry.key == state.raceId
                          ? '${ReputationEngine.standingLabel(ownRep)} \u00b7 '
                              '$ownRep rep'
                          : '${ReputationEngine.standingLabel(
                              ReputationEngine.reputationOf(state, entry.key),
                            )} \u00b7 '
                              '${ReputationEngine.reputationOf(state, entry.key)} rep',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 4),
            Text(
              next < 0
                  ? 'Highest standing reached \u2014 +${(tier * 3)}% qi and '
                      'spirit stones'
                  : '${next - ownRep} reputation to '
                      '${ReputationEngine.tierNames[tier + 1]} \u2014 standing '
                      'grants +${tier * 3}% qi and spirit stones',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _FactionHallCard extends StatelessWidget {
  final GameState state;
  final WorldLocation hall;
  final String realmLabel;
  final VoidCallback onTravel;
  final VoidCallback onExplore;

  const _FactionHallCard({
    required this.state,
    required this.hall,
    required this.realmLabel,
    required this.onTravel,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = CombatEngine.isLocationUnlocked(state, hall);
    final active = state.activeLocationId == hall.id;
    final theme = themeFor(hall);
    final requirement =
        'Requires ${ReputationEngine.tierName(hall.requiredReputation)} '
        'standing (${hall.requiredReputation} reputation) \u2014 you have '
        '${ReputationEngine.ownReputation(state)}.';
    final subtitle = '${hall.typeLabel} \u00b7 '
        'Danger ${hall.dangerTier}/5 \u00b7 $realmLabel\n'
        '${unlocked ? hall.description : '$requirement\n${hall.description}'}';
    return Card(
      child: ListTile(
        leading: Icon(
          theme.icon,
          color: unlocked ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(hall.name),
        subtitle: Text(
          subtitle,
          isThreeLine: true,
        ),
        trailing: !unlocked
            ? const Icon(Icons.lock_outline)
            : active
                ? FilledButton.tonal(
                    onPressed: onExplore,
                    child: const Text('Enter'),
                  )
                : FilledButton.tonal(
                    onPressed: onTravel,
                    child: const Text('Travel'),
                  ),
      ),
    );
  }
}
class _UndiscoveredCard extends StatelessWidget {
  final WorldLocation location;
  final String realmLabel;

  const _UndiscoveredCard({required this.location, required this.realmLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.help_outline),
        title: const Text('???'),
        subtitle: Text(
          '${location.discoveryHint ?? 'A place not yet found.'}\n'
          'Requires $realmLabel or higher to enter.',
          isThreeLine: true,
        ),
      ),
    );
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
              state.weapon == null && state.armor == null && state.amulet == null
                  ? 'No equipment \u2014 defeat beasts to find weapons and armor.'
                  : '${state.weapon?.name ?? "No weapon"} '
                      '(${state.weapon?.gradeName ?? "-"}) \u00b7 '
                      '${state.armor?.name ?? "No armor"} '
                      '(${state.armor?.gradeName ?? "-"}) \u00b7 '
                      '${state.amulet?.name ?? "No amulet"} '
                      '(${state.amulet?.gradeName ?? "-"})',
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
