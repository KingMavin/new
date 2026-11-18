import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/forge_engine.dart';
import 'package:immortal_path/game/models/equipment.dart';
import 'package:immortal_path/game/models/forge.dart';
import 'package:immortal_path/game/models/game_state.dart';

GameState stateAt({
  int realmIndex = 0,
  double spiritStones = 0,
  int spiritHerbs = 0,
  int beastCores = 0,
}) {
  return GameState.initial().copyWith(
    realmIndex: realmIndex,
    spiritStones: spiritStones,
    spiritHerbs: spiritHerbs,
    beastCores: beastCores,
  );
}

void main() {
  final earthWeapon = ForgeCatalog.recipeById('forge_earth_weapon')!;

  group('ForgeEngine.blocker', () {
    test('demands stones, herbs, and cores', () {
      final state = stateAt(spiritStones: 0, spiritHerbs: 5, beastCores: 5);
      expect(ForgeEngine.blocker(state, earthWeapon), isNotNull);
      final almost = stateAt(spiritStones: 100, spiritHerbs: 1, beastCores: 5);
      expect(ForgeEngine.blocker(almost, earthWeapon), isNotNull);
      final full = stateAt(spiritStones: 500, spiritHerbs: 5, beastCores: 5);
      expect(ForgeEngine.blocker(full, earthWeapon), isNull);
    });
  });

  group('ForgeEngine.attempt', () {
    test('a successful forge consumes everything and equips', () {
      final state =
          stateAt(spiritStones: 1000, spiritHerbs: 5, beastCores: 5);
      final outcome = ForgeEngine.attempt(state, earthWeapon, roll: 0.1);
      expect(outcome.success, isTrue);
      expect(
        outcome.state.spiritStones,
        1000 - earthWeapon.stoneCostFor(0),
      );
      expect(outcome.state.spiritHerbs, 3);
      expect(outcome.state.beastCores, 4);
      expect(outcome.state.weapon, isNotNull);
      expect(outcome.state.weapon!.grade, 2);
      expect(
        outcome.state.weapon!.power,
        closeTo(earthWeapon.powerFor(0), 0.001),
      );
    });

    test('a failed forge salvages only part of the stones', () {
      final state =
          stateAt(spiritStones: 1000, spiritHerbs: 5, beastCores: 5);
      final outcome = ForgeEngine.attempt(state, earthWeapon, roll: 0.9);
      expect(outcome.success, isFalse);
      final lost = (state.spiritStones - outcome.state.spiritStones).round();
      expect(lost, closeTo(earthWeapon.stoneCostFor(0) * 0.6, 0.5));
      expect(outcome.state.spiritHerbs, 3);
      expect(outcome.state.beastCores, 4);
      expect(outcome.state.weapon, isNull);
    });

    test('success chance is honored across many rolls', () {
      final recipe = ForgeCatalog.recipeById('forge_heaven_weapon')!;
      var wins = 0;
      for (var i = 0; i < 1000; i++) {
        final state = stateAt(
          spiritStones: 999999,
          spiritHerbs: 99,
          beastCores: 99,
        );
        final outcome = ForgeEngine.attempt(
          state,
          recipe,
          roll: i / 1000,
        );
        if (outcome.success) wins++;
      }
      expect(wins, inInclusiveRange(280, 420));
    });

    test('a forged weapon never replaces stronger gear', () {
      final state = stateAt(
        spiritStones: 1000,
        spiritHerbs: 5,
        beastCores: 5,
      ).copyWith(
        weapon: const Equipment(
          name: 'Immortal Fang',
          slot: EquipmentSlot.weapon,
          grade: 4,
          power: 1000000,
        ),
      );
      final outcome = ForgeEngine.attempt(state, earthWeapon, roll: 0.1);
      expect(outcome.success, isTrue);
      expect(outcome.state.weapon!.grade, 4);
      expect(outcome.state.weapon!.name, 'Immortal Fang');
    });
  });

  group('ForgeCatalog', () {
    test('covers three slots at three grades', () {
      expect(ForgeCatalog.recipes.length, 9);
      expect(
        ForgeCatalog.recipes.map((r) => r.slot).toSet().length,
        3,
      );
      expect(
        ForgeCatalog.recipes.map((r) => r.grade).toSet(),
        {2, 3, 4},
      );
      for (final recipe in ForgeCatalog.recipes) {
        expect(ForgeCatalog.recipeById(recipe.id), same(recipe));
        expect(recipe.successChance, inInclusiveRange(0.05, 0.8));
      }
    });
  });
}
