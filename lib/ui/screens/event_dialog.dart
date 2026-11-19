import 'package:flutter/material.dart';

import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/game/util/format.dart';
import 'package:immortal_path/state/game_controller.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

class EventDialog extends StatelessWidget {
  final GameController controller;
  final String eventId;

  const EventDialog({
    super.key,
    required this.controller,
    required this.eventId,
  });

  static double stoneCostOf(EventChoice choice, WorldLocation location) {
    return location.spiritStoneReward * choice.stonesCostFactor +
        choice.stonesFlatCost;
  }

  static bool canAfford(
    GameState state,
    EventChoice choice,
    WorldLocation location,
  ) {
    final coresSpent = choice.coreCost + (choice.cores < 0 ? -choice.cores : 0);
    return state.spiritStones >= stoneCostOf(choice, location) &&
        state.spiritHerbs >= choice.herbCost &&
        state.beastCores >= coresSpent;
  }

  static String choiceDetail(
    GameState state,
    EventChoice choice,
    WorldLocation location,
  ) {
    final stoneCost = stoneCostOf(choice, location);
    final parts = <String>[];
    if (stoneCost > 0) {
      parts.add('${formatNumber(stoneCost)} spirit stones');
    }
    if (choice.herbCost > 0) parts.add('${choice.herbCost} herb(s)');
    if (choice.coreCost > 0) parts.add('${choice.coreCost} core(s)');
    if (choice.gamble) parts.add('a 50/50 gamble');
    if (choice.herbs > 0) parts.add('+${choice.herbs} herb(s)');
    if (choice.cores > 0) parts.add('+${choice.cores} core(s)');
    if (choice.qiMinutes > 0) {
      parts.add('+${choice.qiMinutes} min of qi');
    }
    if (choice.qiPills > 0) parts.add('+${choice.qiPills} qi pill(s)');
    if (choice.lifespanYears > 0) {
      parts.add('+${choice.lifespanYears} years of life');
    }
    if (choice.raceChangeTo != null) {
      parts.add('reforges your bloodline');
    }
    if (choice.consequenceId != null &&
        !state.consequences.contains(choice.consequenceId)) {
      parts.add('success marks you forever');
    }
    if (choice.failConsequenceId != null &&
        !state.consequences.contains(choice.failConsequenceId)) {
      parts.add('failure scars you forever');
    }
    if (parts.isEmpty) return 'a freely given kindness';
    return parts.join(' \u00b7 ');
  }

  @override
  Widget build(BuildContext context) {
    final event = EventEngine.byId(eventId);
    if (event == null) return const SizedBox.shrink();
    return Dialog.fullscreen(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final state = controller.state;
          final location = controller.effectiveLocation();
          final anyAffordable = event.choices.any(
            (choice) => canAfford(state, choice, location),
          );
          return Column(
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: BackdropImage(
                      BackdropCatalog.forEvent(event.id),
                      scrim: const [Color(0x22000000), Color(0xAA000000)],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(event.description),
                    const SizedBox(height: 8),
                    Text(
                      'What do you do?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < event.choices.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ChoiceButton(
                          label: event.choices[i].label,
                          detail: choiceDetail(
                            state,
                            event.choices[i],
                            location,
                          ),
                          enabled: !anyAffordable ||
                              canAfford(state, event.choices[i], location),
                          onPressed: () => _choose(context, i),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _choose(BuildContext context, int index) {
    final outcome = controller.resolvePendingEvent(index);
    final message = outcome?.message;
    Navigator.of(context).pop();
    if (message != null && message.isNotEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final String detail;
  final bool enabled;
  final VoidCallback onPressed;

  const _ChoiceButton({
    required this.label,
    required this.detail,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        alignment: Alignment.centerLeft,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 2),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: enabled
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
