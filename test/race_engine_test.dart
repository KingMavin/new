import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/cultivation_engine.dart';
import 'package:immortal_path/game/engine/race_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/race.dart';

void main() {
  group('RaceEngine', () {
    test('no race chosen keeps every multiplier neutral', () {
      final state = GameState.initial();
      expect(RaceEngine.raceOf(state), isNull);
      expect(RaceEngine.qiMultiplier(state), 1.0);
      expect(RaceEngine.attackMultiplier(state), 1.0);
      expect(RaceEngine.hpMultiplier(state), 1.0);
      expect(RaceEngine.defenseMultiplier(state), 1.0);
      expect(RaceEngine.stoneMultiplier(state), 1.0);
    });

    test('human boosts qi gain only', () {
      final state = GameState.initial().copyWith(raceId: 'human');
      expect(RaceEngine.qiMultiplier(state), 1.10);
      expect(RaceEngine.attackMultiplier(state), 1.0);
      expect(RaceEngine.hpMultiplier(state), 1.0);
      expect(RaceEngine.defenseMultiplier(state), 1.0);
      expect(RaceEngine.stoneMultiplier(state), 1.0);
    });

    test('demon boosts attack and health only', () {
      final state = GameState.initial().copyWith(raceId: 'demon');
      expect(RaceEngine.qiMultiplier(state), 1.0);
      expect(RaceEngine.attackMultiplier(state), 1.15);
      expect(RaceEngine.hpMultiplier(state), 1.10);
      expect(RaceEngine.defenseMultiplier(state), 1.0);
      expect(RaceEngine.stoneMultiplier(state), 1.0);
    });

    test('demi-human boosts defense and stones only', () {
      final state = GameState.initial().copyWith(raceId: 'demi_human');
      expect(RaceEngine.qiMultiplier(state), 1.0);
      expect(RaceEngine.attackMultiplier(state), 1.0);
      expect(RaceEngine.hpMultiplier(state), 1.0);
      expect(RaceEngine.defenseMultiplier(state), 1.15);
      expect(RaceEngine.stoneMultiplier(state), 1.10);
    });

    test('race multipliers flow into combat stats', () {
      final plain = GameState.initial();
      final demon = GameState.initial().copyWith(raceId: 'demon');
      final demi = GameState.initial().copyWith(raceId: 'demi_human');
      expect(
        CombatEngine.playerAttack(demon),
        closeTo(CombatEngine.playerAttack(plain) * 1.15, 1e-9),
      );
      expect(
        CombatEngine.playerMaxHp(demon),
        closeTo(CombatEngine.playerMaxHp(plain) * 1.10, 1e-9),
      );
      expect(
        CombatEngine.playerDefense(demi),
        closeTo(CombatEngine.playerDefense(plain) * 1.15, 1e-9),
      );
    });

    test('human qi multiplier flows into qiPerSecond', () {
      final plain = GameState.initial();
      final human = GameState.initial().copyWith(raceId: 'human');
      expect(
        CultivationEngine.qiPerSecond(human),
        closeTo(CultivationEngine.qiPerSecond(plain) * 1.10, 1e-9),
      );
    });

    test('race catalog has the three factions', () {
      expect(Race.catalog.map((race) => race.id).toList(),
          ['human', 'demon', 'demi_human']);
      for (final race in Race.catalog) {
        expect(race.name, isNotEmpty);
        expect(race.title, isNotEmpty);
        expect(race.description, isNotEmpty);
        expect(race.intro, isNotEmpty);
        expect(race.bonusLabel, isNotEmpty);
      }
    });
  });
}
