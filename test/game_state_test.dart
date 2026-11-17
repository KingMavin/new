import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/realm_ladder.dart';

void main() {
  group('RealmLadder', () {
    test('has nine realms', () {
      expect(RealmLadder.realmNames.length, 9);
    });

    test('has four stages per realm', () {
      expect(RealmLadder.stagesPerRealm, 4);
      expect(RealmLadder.totalStages, 36);
    });

    test('lifespan increases with realm', () {
      for (var i = 1; i < RealmLadder.realmNames.length; i++) {
        expect(
          RealmLadder.lifespanYears(i),
          greaterThan(RealmLadder.lifespanYears(i - 1)),
        );
      }
    });
  });

  group('GameState', () {
    test('json roundtrip preserves all fields', () {
      final state = GameState.initial().copyWith(
        realmIndex: 2,
        stageIndex: 1,
        qi: 123.45,
        totalQiGained: 9876.5,
        breakthroughsSucceeded: 3,
        breakthroughsFailed: 1,
        lastSaved: DateTime.utc(2024, 5, 5, 12, 30),
      );
      final parsed = GameState.fromJson(state.toJson());
      expect(parsed.realmIndex, state.realmIndex);
      expect(parsed.stageIndex, state.stageIndex);
      expect(parsed.qi, closeTo(state.qi, 1e-9));
      expect(parsed.totalQiGained, closeTo(state.totalQiGained, 1e-9));
      expect(parsed.breakthroughsSucceeded, state.breakthroughsSucceeded);
      expect(parsed.breakthroughsFailed, state.breakthroughsFailed);
      expect(parsed.ascended, state.ascended);
      expect(parsed.lastSaved, state.lastSaved);
    });

    test('globalStageIndex combines realm and stage', () {
      final state = GameState.initial().copyWith(
        realmIndex: 2,
        stageIndex: 3,
      );
      expect(state.globalStageIndex, 11);
    });

    test('missing optional json fields fall back to defaults', () {
      final minimal = GameState.initial().toJson()..remove('ascended');
      final parsed = GameState.fromJson(minimal);
      expect(parsed.ascended, isFalse);
    });
  });
}
