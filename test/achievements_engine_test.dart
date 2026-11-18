import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/achievements_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  group('AchievementsEngine', () {
    test('evaluate grants every matching milestone in one pass', () {
      final state = GameState.initial().copyWith(
        battlesWon: 60,
        realmIndex: 5,
        tribulationsSurvived: 3,
        reincarnations: 1,
      );
      final evaluated = AchievementsEngine.evaluate(state);
      expect(evaluated.achievements, containsAll([
        'first_blood',
        'hunter',
        'realm_elite',
        'storm_rider',
        'reincarnator',
      ]));
      expect(evaluated.achievements, isNot(contains('slayer')));
      expect(evaluated.achievements, isNot(contains('eternal_wheel')));
    });

    test('re-evaluating never duplicates', () {
      final state = GameState.initial().copyWith(battlesWon: 300);
      final once = AchievementsEngine.evaluate(state);
      final twice = AchievementsEngine.evaluate(once);
      expect(twice.achievements.length, once.achievements.length);
      expect(twice.achievements.toSet(), once.achievements.toSet());
    });

    test('hunter respects the 50-battle boundary', () {
      final below = AchievementsEngine.evaluate(
        GameState.initial().copyWith(battlesWon: 49),
      );
      final at = AchievementsEngine.evaluate(
        GameState.initial().copyWith(battlesWon: 50),
      );
      expect(below.achievements, isNot(contains('hunter')));
      expect(at.achievements, contains('hunter'));
    });

    test('catalog ids are unique and byId resolves', () {
      final ids = AchievementsEngine.catalog.map((a) => a.id).toSet();
      expect(ids.length, AchievementsEngine.catalog.length);
      expect(AchievementsEngine.byId('first_blood')?.title, 'First Blood');
      expect(AchievementsEngine.byId('no_such_deed'), isNull);
    });

    test('an empty state earns nothing', () {
      final evaluated = AchievementsEngine.evaluate(GameState.initial());
      expect(evaluated.achievements, isEmpty);
    });
  });
}
