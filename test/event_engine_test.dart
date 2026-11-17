import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

GameState stateAt({
  double spiritStones = 0,
  int spiritHerbs = 0,
  int beastCores = 0,
  String? pendingEventId,
}) {
  return GameState.initial().copyWith(
    spiritStones: spiritStones,
    spiritHerbs: spiritHerbs,
    beastCores: beastCores,
    pendingEventId: pendingEventId,
  );
}

void main() {
  final location = WorldCatalog.locations.first;

  test('catalog events have choices and unique ids', () {
    final ids = EventEngine.catalog.map((e) => e.id).toSet();
    expect(ids.length, EventEngine.catalog.length);
    for (final event in EventEngine.catalog) {
      expect(event.choices, isNotEmpty);
      expect(EventEngine.byId(event.id), same(event));
    }
    expect(EventEngine.byId('missing'), isNull);
  });

  group('maybeTrigger', () {
    test('never triggers while another event is pending', () {
      final state = stateAt(pendingEventId: 'ancient_tomb');
      for (var i = 0; i < 50; i++) {
        expect(EventEngine.maybeTrigger(state, rng: Random(i)), isNull);
      }
    });

    test('triggers at 15% chance', () {
      var triggered = 0;
      for (var i = 0; i < 1000; i++) {
        final id = EventEngine.maybeTrigger(
          stateAt(),
          rng: Random(i),
        );
        if (id != null) triggered++;
      }
      expect(triggered, inInclusiveRange(80, 220));
    });
  });

  group('resolve', () => [
        test('applies rewards on a safe choice', () {
          final state = stateAt(spiritStones: 0);
          final outcome = EventEngine.resolve(
            state,
            'spirit_spring',
            1,
            location,
            roll: 0.1,
          );
          expect(outcome, isNotNull);
          expect(outcome!.state.spiritHerbs, 2);
        }),

        test('gamble success pays out', () {
          final state = stateAt(spiritStones: 0);
          final outcome = EventEngine.resolve(
            state,
            'ancient_tomb',
            0,
            location,
            roll: 0.1,
          );
          expect(outcome!.state.spiritStones, closeTo(location.spiritStoneReward * 3, 1e-9));
        }),

        test('gamble failure only loses the stake', () {
          final state = stateAt(spiritStones: 1000);
          final outcome = EventEngine.resolve(
            state,
            'bandit_ambush',
            1,
            location,
            roll: 0.9,
          );
          expect(outcome!.state.spiritStones, closeTo(1000 - location.spiritStoneReward, 1e-9));
        }),

        test('refuses choices the player cannot afford', () {
          final state = stateAt(spiritStones: 0);
          final outcome = EventEngine.resolve(
            state,
            'wandering_merchant',
            0,
            location,
          );
          expect(outcome, isNotNull);
          expect(outcome!.state.spiritHerbs, 0);
          expect(outcome.message, contains('lack'));
        }),

        test('unknown event or choice returns null', () {
          expect(
            EventEngine.resolve(stateAt(), 'nope', 0, location),
            isNull,
          );
          expect(
            EventEngine.resolve(stateAt(), 'ancient_tomb', 9, location),
            isNull,
          );
        }),
      ]);

  test('qi events convert minutes at the current rate', () {
    final state = stateAt();
    final outcome = EventEngine.resolve(
      state,
      'spirit_spring',
      0,
      location,
      roll: 0.5,
    );
    expect(outcome!.state.qi, greaterThan(0));
    expect(
      outcome.state.totalQiGained,
      closeTo(outcome.state.qi, 1e-9),
    );
  });
}
