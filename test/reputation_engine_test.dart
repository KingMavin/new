import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/combat_engine.dart';
import 'package:immortal_path/game/engine/reputation_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';
import 'package:immortal_path/game/models/world_location.dart';

void main() {
  group('ReputationEngine', () {
    test('no race means no reputation and no bonus', () {
      final state = GameState.initial();
      expect(ReputationEngine.ownReputation(state), 0);
      expect(ReputationEngine.standingBonus(state), 0.0);
      expect(ReputationEngine.gain(state, 10), state.reputation);
    });

    test('tiers progress by threshold', () {
      expect(ReputationEngine.tierOf(0), 0);
      expect(ReputationEngine.tierName(0), 'Stranger');
      expect(ReputationEngine.tierOf(99), 0);
      expect(ReputationEngine.tierOf(100), 1);
      expect(ReputationEngine.tierName(100), 'Acknowledged');
      expect(ReputationEngine.tierOf(300), 2);
      expect(ReputationEngine.tierName(300), 'Sworn Ally');
      expect(ReputationEngine.tierOf(700), 3);
      expect(ReputationEngine.tierOf(1500), 4);
      expect(ReputationEngine.tierName(9999), 'Beloved of the Heavens');
    });

    test('next threshold walks to the top then stops', () {
      expect(ReputationEngine.nextThreshold(0), 100);
      expect(ReputationEngine.nextThreshold(150), 300);
      expect(ReputationEngine.nextThreshold(1500), -1);
      expect(ReputationEngine.nextThreshold(9999), -1);
    });

    test('standing bonus is 3% per tier', () {
      expect(
        ReputationEngine.standingBonus(
          GameState.initial().copyWith(
            raceId: 'human',
            reputation: const {'human': 350},
          ),
        ),
        closeTo(0.09, 1e-9),
      );
    });

    test('gains scale with realm and outcome', () {
      final low = GameState.initial().copyWith(raceId: 'human');
      final high = GameState.initial().copyWith(
        raceId: 'human',
        realmIndex: 4,
      );
      expect(ReputationEngine.huntGain(low), 5);
      expect(ReputationEngine.huntGain(high), 17);
      expect(ReputationEngine.tournamentWinGain(low), 20);
      expect(ReputationEngine.tournamentWinGain(high), 60);
      expect(ReputationEngine.warWinGain(low), 60);
      expect(ReputationEngine.warWinGain(high), 140);
      expect(ReputationEngine.tournamentLossGain, 3);
      expect(ReputationEngine.warLossGain, 10);
    });

    test('gain accumulates only for the chosen race', () {
      final state = GameState.initial().copyWith(
        raceId: 'demon',
        reputation: const {'demon': 40},
      );
      final updated = ReputationEngine.gain(state, 12);
      expect(updated['demon'], 52);
      expect(updated.containsKey('human'), isFalse);
    });

    test('faction halls unlock only for the matching race and reputation', () {
      final humanHall = WorldCatalog.factionLocationFor('human')!;
      final demonState = GameState.initial().copyWith(
        raceId: 'demon',
        realmIndex: 5,
        reputation: const {'demon': 1500},
      );
      expect(
        CombatEngine.isLocationUnlocked(demonState, humanHall),
        isFalse,
      );

      final humanState = GameState.initial().copyWith(
        raceId: 'human',
        realmIndex: 5,
        reputation: const {'human': 99},
      );
      expect(
        CombatEngine.isLocationUnlocked(humanState, humanHall),
        isFalse,
      );
      expect(
        CombatEngine.isLocationUnlocked(
          humanState.copyWith(reputation: const {'human': 100}),
          humanHall,
        ),
        isTrue,
      );
      expect(
        CombatEngine.isLocationUnlocked(
          GameState.initial(),
          WorldCatalog.standardLocations().first,
        ),
        isTrue,
      );
    });
  });
}
