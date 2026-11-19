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

  test('the beggar event grants the gave_everything flag', () {
    final state = stateAt(spiritStones: 500).copyWith(raceId: 'human');
    final outcome = EventEngine.resolve(
      state,
      'the_beggar',
      0,
      location,
    )!;
    expect(outcome.state.storyFlags, contains('gave_everything'));
    expect(outcome.state.spiritStones, 0);

    final kept = EventEngine.resolve(
      state,
      'the_beggar',
      1,
      location,
    )!;
    expect(kept.state.storyFlags, isNot(contains('gave_everything')));
    expect(kept.state.spiritStones, 500);
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

  group('The Faceless Messenger', () {
    final location = WorldCatalog.standardLocations().first;

    GameState messengerState({double stones = 0, String raceId = 'human'}) {
      return GameState.initial().copyWith(
        raceId: raceId,
        spiritStones: stones,
        reputation: {'human': 340, 'demon': 0, 'demi_human': 0},
        storyChapter: 2,
      );
    }

    test('reforging costs 5000 stones and changes race', () {
      final state = messengerState(stones: 5000);
      final outcome = EventEngine.resolve(
        state,
        'faceless_messenger',
        1,
        location,
      );
      expect(outcome, isNotNull);
      expect(outcome!.state.raceId, 'demon');
      expect(outcome.state.spiritStones, 0);
      expect(outcome.state.reputation['human'], -200);
      expect(outcome.state.storyChapter, 0);
      expect(outcome.message, contains('reforged'));
      expect(outcome.message, contains('Demon'));
    });

    test('old faction keeps other reputation untouched', () {
      final state = messengerState(stones: 9000);
      final outcome = EventEngine.resolve(
        state,
        'faceless_messenger',
        0,
        location,
      );
      expect(outcome!.state.raceId, 'human');
      expect(outcome.state.spiritStones, 4000);
      expect(outcome.state.reputation['demon'], 0);
    });

    test('reforging into your own race is a plain payment', () {
      final state = messengerState(stones: 5000);
      final outcome = EventEngine.resolve(
        state,
        'faceless_messenger',
        0,
        location,
      );
      expect(outcome!.state.raceId, 'human');
      expect(outcome.state.reputation['human'], 340);
      expect(outcome.state.storyChapter, 2);
      expect(outcome.message, isNot(contains('reforged')));
    });

    test('insufficient stones leaves race and reputation untouched', () {
      final state = messengerState(stones: 4999);
      final outcome = EventEngine.resolve(
        state,
        'faceless_messenger',
        2,
        location,
      );
      expect(outcome, isNotNull);
      expect(outcome!.state.raceId, 'human');
      expect(outcome.state.reputation['human'], 340);
      expect(outcome.state.storyChapter, 2);
      expect(outcome.message, contains('lack'));
    });

    test('refusing the messenger changes nothing', () {
      final state = messengerState(stones: 9000, raceId: 'demi_human');
      final outcome = EventEngine.resolve(
        state,
        'faceless_messenger',
        3,
        location,
      );
      expect(outcome!.state.raceId, 'demi_human');
      expect(outcome.state.spiritStones, 9000);
      expect(outcome.state.storyChapter, 2);
    });
  });

  group('herb netting (regression)', () {
    test('no catalog choice both costs and grants herbs', () {
      for (final event in EventEngine.catalog) {
        for (final choice in event.choices) {
          expect(
            choice.herbCost > 0 && choice.herbs > 0,
            isFalse,
            reason: '${event.id}/${choice.label} mixes herb cost and grant',
          );
        }
      }
    });

    test('gamble costs are paid even when the roll fails', () {
      final state = stateAt(beastCores: 2, spiritStones: 1000);
      final outcome = EventEngine.resolve(
        state,
        'thunder_cave',
        1,
        location,
        roll: 0.99,
      )!;
      expect(outcome.state.spiritStones, 1000);
    });

    test('dragon bones scale grant only on a winning gamble', () {
      final state = stateAt(beastCores: 0);
      final lost = EventEngine.resolve(
        state,
        'dragon_bones',
        1,
        location,
        roll: 0.99,
      )!;
      expect(lost.state.beastCores, 0);
      final won = EventEngine.resolve(
        state,
        'dragon_bones',
        1,
        location,
        roll: 0.01,
      )!;
      expect(won.state.beastCores, 2);
    });

    test('old monk provisions cost exactly one herb', () {
      final rich = stateAt(spiritHerbs: 5);
      final outcome = EventEngine.resolve(rich, 'old_monk', 1, location)!;
      expect(outcome.state.spiritHerbs, 4);

      final poor = stateAt(spiritHerbs: 0);
      final blocked = EventEngine.resolve(poor, 'old_monk', 1, location);
      expect(blocked!.state.spiritHerbs, 0);
      expect(blocked.message, contains('lack'));
    });

    test('every event keeps at least one free choice', () {
      for (final event in EventEngine.catalog) {
        final hasFree = event.choices.any(
          (c) =>
              c.stonesCostFactor == 0 &&
              c.stonesFlatCost == 0 &&
              c.herbCost == 0 &&
              c.coreCost == 0 &&
              c.cores >= 0,
        );
        expect(hasFree, isTrue, reason: '${event.id} dead-ends the dialog');
      }
    });

    test('wild garden harvest grants exactly three herbs', () {
      final state = stateAt(spiritHerbs: 1);
      final outcome = EventEngine.resolve(state, 'wild_garden', 0, location)!;
      expect(outcome.state.spiritHerbs, 4);
    });

    test('reforging while sworn expels you from your old sect', () {
      final state = stateAt(spiritStones: 9000).copyWith(
        raceId: 'human',
        sectId: 'sword_sect',
        contribution: 340,
        sectRankAchieved: 2,
        sectTasks: const [],
      );
      final outcome = EventEngine.resolve(
        state,
        'faceless_messenger',
        1,
        location,
      )!;
      expect(outcome.state.raceId, 'demon');
      expect(outcome.state.sectId, isNull);
      expect(outcome.state.contribution, 0);
      expect(outcome.state.sectRankAchieved, 0);
      expect(outcome.state.sectBetrayed, contains('sword_sect'));
      expect(outcome.message, contains('strike your name'));
    });

    test('reforging keeps a sect of the new faction relationship intact', () {
      final state = stateAt(spiritStones: 9000).copyWith(
        raceId: 'demon',
        sectId: 'blood_furnace_clan',
        contribution: 120,
      );
      final outcome = EventEngine.resolve(
        state,
        'faceless_messenger',
        1,
        location,
      )!;
      expect(outcome.state.raceId, 'demon');
      expect(outcome.state.sectId, 'blood_furnace_clan');
      expect(outcome.state.contribution, 120);
    });
  });
}
