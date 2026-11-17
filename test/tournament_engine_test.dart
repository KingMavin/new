import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/tournament_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  group('TournamentEngine', () {
    GameState stateAt({int realmIndex = 0}) =>
        GameState.initial().copyWith(realmIndex: realmIndex);

    test('opponent power stays within 0.75x to 1.25x of player power', () {
      final state = stateAt(realmIndex: 3);
      final playerPower = TournamentEngine.playerTournamentPower(state);
      final rng = Random(7);
      for (var i = 0; i < 50; i++) {
        final foe = TournamentEngine.opponent(state, rng: rng);
        final foePower = foe.hp / 1.2;
        expect(foePower, greaterThanOrEqualTo(playerPower * 0.75 - 1e-9));
        expect(foePower, lessThan(playerPower * 1.25));
      }
    });

    test('opponent is deterministic for a seeded rng', () {
      final state = stateAt(realmIndex: 2);
      final a = TournamentEngine.opponent(state, rng: Random(11));
      final b = TournamentEngine.opponent(state, rng: Random(11));
      expect(a.name, b.name);
      expect(a.hp, b.hp);
      expect(a.attack, b.attack);
      expect(a.defense, b.defense);
    });

    test('opponents scale with realm', () {
      final low = TournamentEngine.opponent(
        stateAt(realmIndex: 1),
        rng: Random(3),
      );
      final high = TournamentEngine.opponent(
        stateAt(realmIndex: 5),
        rng: Random(3),
      );
      expect(high.hp, greaterThan(low.hp));
      expect(high.attack, greaterThan(low.attack));
    });

    test('prizes scale with realm', () {
      expect(TournamentEngine.prizeStones(stateAt(realmIndex: 0)), 50.0);
      expect(TournamentEngine.prizeStones(stateAt(realmIndex: 3)), 400.0);
      expect(TournamentEngine.prizeContribution(stateAt(realmIndex: 0)), 30);
      expect(TournamentEngine.prizeContribution(stateAt(realmIndex: 3)), 60);
    });

    test('cooldown is one hour', () {
      expect(TournamentEngine.cooldown, const Duration(hours: 1));
    });
  });
}
