import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/ending_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  group('EndingEngine', () {
    test('catalog has three main and three hidden endings', () {
      expect(endingIds(false).length, 3);
      expect(endingIds(true).length, 3);
      for (final ending in EndingEngine.endings) {
        expect(ending.epilogue, isNotEmpty, reason: ending.id);
        expect(EndingEngine.byId(ending.id), same(ending));
      }
    });

    test('no ending before ascension', () {
      final state = GameState.initial().copyWith(
        tribulationsFailed: 5,
        storyFlags: const ['gave_everything'],
      );
      expect(EndingEngine.evaluateState(state), isNull);
    });

    test('hidden endings take priority over main endings', () {
      final ninth = GameState.initial().copyWith(
        ascended: true,
        tribulationsFailed: 3,
        pathPoints: const {'sovereignty': 10},
      );
      expect(EndingEngine.evaluateState(ninth), 'hidden_ninth');

      final nameless = GameState.initial().copyWith(
        ascended: true,
        storyFlags: const ['gave_everything'],
        pathPoints: const {'heaven': 10},
      );
      expect(EndingEngine.evaluateState(nameless), 'hidden_nameless');

      final wheel = GameState.initial().copyWith(
        ascended: true,
        reincarnations: 3,
        battlesLost: 0,
        pathPoints: const {'wild': 10},
      );
      expect(EndingEngine.evaluateState(wheel), 'hidden_wheel');
      expect(
        EndingEngine.evaluateState(wheel.copyWith(battlesLost: 1)),
        'main_wild',
      );
    });

    test('main endings follow the dominant path', () {
      expect(
        EndingEngine.evaluateState(
          GameState.initial().copyWith(
            ascended: true,
            pathPoints: const {'heaven': 8, 'wild': 2},
          ),
        ),
        'main_heaven',
      );
      expect(
        EndingEngine.evaluateState(
          GameState.initial().copyWith(
            ascended: true,
            pathPoints: const {'sovereignty': 8},
          ),
        ),
        'main_sovereignty',
      );
      expect(
        EndingEngine.evaluateState(
          GameState.initial().copyWith(
            ascended: true,
            pathPoints: const {'wild': 8},
          ),
        ),
        'main_wild',
      );
      expect(
        EndingEngine.evaluateState(GameState.initial().copyWith(ascended: true)),
        'main_heaven',
      );
    });
  });
}

List<String> endingIds(bool hidden) => EndingEngine.endings
    .where((ending) => ending.hidden == hidden)
    .map((ending) => ending.id)
    .toList();
