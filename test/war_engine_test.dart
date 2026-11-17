import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/war_engine.dart';
import 'package:immortal_path/game/models/disciple.dart';
import 'package:immortal_path/game/models/game_state.dart';

void main() {
  group('WarEngine', () {
    GameState stateAt({
      int realmIndex = 3,
      String? sectId,
      int contribution = 0,
      List<Disciple> disciples = const [],
    }) =>
        GameState.initial().copyWith(
          realmIndex: realmIndex,
          sectId: sectId,
          contribution: contribution,
          disciples: disciples,
        );

    test('side strength includes disciples and sect rank', () {
      final bare = WarEngine.playerSideStrength(stateAt());
      final withDisciples = WarEngine.playerSideStrength(
        stateAt(
          disciples: const [
            Disciple(name: 'A', level: 4),
            Disciple(name: 'B', level: 2),
          ],
        ),
      );
      expect(withDisciples, closeTo(bare + 30, 1e-9));

      final withSect = WarEngine.playerSideStrength(
        stateAt(sectId: 'sword_sect', contribution: 300),
      );
      expect(withSect, greaterThan(bare));
    });

    test('enemy strength stays within 0.7x to 1.3x of side strength', () {
      final state = stateAt(sectId: 'sword_sect');
      final side = WarEngine.playerSideStrength(state);
      final rng = Random(5);
      for (var i = 0; i < 50; i++) {
        final enemy = WarEngine.enemyStrength(state, rng: rng);
        expect(enemy, greaterThanOrEqualTo(side * 0.7 - 1e-9));
        expect(enemy, lessThan(side * 1.3));
      }
    });

    test('champion scales from enemy strength deterministically', () {
      final state = stateAt(sectId: 'sword_sect');
      final a = WarEngine.champion(state, rng: Random(9));
      final b = WarEngine.champion(state, rng: Random(9));
      expect(a.name, b.name);
      expect(a.hp, b.hp);
      expect(a.attack, b.attack);
      expect(a.defense, b.defense);

      final strength = WarEngine.enemyStrength(state, rng: Random(9));
      expect(a.hp, closeTo(strength * 1.5, 1e-9));
      expect(a.attack, closeTo(strength * 0.3, 1e-9));
      expect(a.defense, closeTo(strength * 0.1, 1e-9));
    });

    test('front description narrates both sides', () {
      final description = WarEngine.frontDescription(
        stateAt(sectId: 'sword_sect'),
      );
      expect(description, contains('strength'));
      expect(description, contains('Enemy strength'));
    });

    test('prizes scale with realm', () {
      GameState stateAtRealm(int realmIndex) =>
          GameState.initial().copyWith(realmIndex: realmIndex);
      expect(WarEngine.prizeStones(stateAtRealm(0)), 200.0);
      expect(WarEngine.prizeStones(stateAtRealm(3)), 1600.0);
      expect(WarEngine.prizeContribution(stateAtRealm(0)), 100);
      expect(WarEngine.prizeContribution(stateAtRealm(3)), 175);
    });

    test('cooldown and realm gate', () {
      expect(WarEngine.cooldown, const Duration(hours: 4));
      expect(WarEngine.requiredRealm, 2);
    });
  });
}
