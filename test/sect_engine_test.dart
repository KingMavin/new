import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/sect.dart';

GameState stateAt({int realmIndex = 0, String? sectId, int contribution = 0}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    stageIndex: 0,
    sectId: sectId,
    contribution: contribution,
  );
}

void main() {
  group('joining', () {
    test('requires Foundation Establishment realm or higher', () {
      expect(SectEngine.canJoin(stateAt(realmIndex: 0)), isFalse);
      expect(SectEngine.canJoin(stateAt(realmIndex: 1)), isTrue);
    });

    test('cannot join while already in a sect', () {
      final state = stateAt(realmIndex: 3, sectId: 'sword_sect');
      expect(SectEngine.canJoin(state), isFalse);
    });

    test('join sets the sect and resets contribution', () {
      final state = stateAt(realmIndex: 2, contribution: 500);
      final joined = SectEngine.join(state, 'pill_valley');
      expect(joined.sectId, 'pill_valley');
      expect(joined.contribution, 0);
    });
  });

  group('ranks', () {
    test('thresholds map to rank names', () {
      expect(SectEngine.rankOf(0), 0);
      expect(SectEngine.rankOf(99), 0);
      expect(SectEngine.rankOf(100), 1);
      expect(SectEngine.rankOf(300), 2);
      expect(SectEngine.rankOf(800), 3);
      expect(SectEngine.rankName(850), 'Elder');
    });

    test('nextRankThreshold returns -1 at max rank', () {
      expect(SectEngine.nextRankThreshold(100), 300);
      expect(SectEngine.nextRankThreshold(800), -1);
    });
  });

  group('sect bonuses', () {
    test('sword sect boosts attack only', () {
      final state = stateAt(sectId: 'sword_sect', contribution: 300);
      expect(SectEngine.attackMultiplier(state), closeTo(1.36, 1e-9));
      expect(SectEngine.qiMultiplier(state), 1.0);
      expect(SectEngine.breakthroughBonus(state), 0.0);
    });

    test('pill valley boosts qi only', () {
      final state = stateAt(sectId: 'pill_valley', contribution: 100);
      expect(SectEngine.qiMultiplier(state), closeTo(1.20, 1e-9));
      expect(SectEngine.attackMultiplier(state), 1.0);
    });

    test('formation hall boosts breakthrough only', () {
      final state = stateAt(sectId: 'formation_hall', contribution: 0);
      expect(SectEngine.breakthroughBonus(state), closeTo(0.03, 1e-9));
      expect(SectEngine.qiMultiplier(state), 1.0);
    });

    test('no sect means no bonus', () {
      final state = stateAt();
      expect(SectEngine.attackMultiplier(state), 1.0);
      expect(SectEngine.qiMultiplier(state), 1.0);
      expect(SectEngine.breakthroughBonus(state), 0.0);
    });
  });

  group('join blockers', () {
    test('wrong faction halls take only their own people', () {
      final state = GameState.initial().copyWith(
        raceId: 'human',
        realmIndex: 3,
      );
      expect(
        SectEngine.joinBlocker(state, 'pill_valley'),
        'They take only their own people.',
      );
      expect(SectEngine.canJoinSpecific(state, 'pill_valley'), isFalse);
      expect(SectEngine.canJoinSpecific(state, 'sword_sect'), isTrue);
    });

    test('realm gate blocks mortals', () {
      final state = GameState.initial().copyWith(
        raceId: 'human',
        realmIndex: 0,
      );
      expect(
        SectEngine.joinBlocker(state, 'sword_sect'),
        'Requires realm 2 or beyond.',
      );
      expect(SectEngine.canJoinSpecific(state, 'sword_sect'), isFalse);
    });

    test('oathbreakers are locked out of their old sect this life', () {
      final state = GameState.initial().copyWith(
        raceId: 'human',
        realmIndex: 3,
        sectBetrayed: const ['sword_sect'],
      );
      expect(
        SectEngine.joinBlocker(state, 'sword_sect'),
        'Their gates will not open for you again this life.',
      );
      expect(SectEngine.canJoinSpecific(state, 'sword_sect'), isFalse);
      expect(SectEngine.canJoinSpecific(state, 'formation_hall'), isTrue);
    });

    test('already-sworn cultivators cannot swear again', () {
      final state = GameState.initial().copyWith(
        raceId: 'human',
        realmIndex: 3,
        sectId: 'formation_hall',
      );
      expect(
        SectEngine.joinBlocker(state, 'sword_sect'),
        'You are already sworn to Mystic Formation Hall.',
      );
      expect(SectEngine.canJoinSpecific(state, 'sword_sect'), isFalse);
    });

    test('nine sects cover three factions with three halls each', () {
      expect(Sect.catalog.length, 9);
      for (final faction in ['human', 'demon', 'demi_human']) {
        expect(Sect.forFaction(faction).length, 3);
      }
      expect(Sect.catalog.map((s) => s.id).toSet().length, 9);
      for (final sect in Sect.catalog) {
        expect(sect.hallLine, isNotEmpty);
        expect(sect.bonusLabel, isNotEmpty);
      }
    });
  });
}