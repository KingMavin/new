import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/sect_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

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
}
