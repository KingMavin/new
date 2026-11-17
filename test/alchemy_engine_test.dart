import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/alchemy_engine.dart';
import 'package:immortal_path/game/models/game_state.dart';

GameState stateWith({
  double stones = 100,
  int herbs = 10,
  int cores = 10,
}) {
  return GameState.initial().copyWith(
    spiritStones: stones,
    spiritHerbs: herbs,
    beastCores: cores,
  );
}

void main() {
  group('canCraft', () {
    test('true when all materials are available', () {
      final recipe = AlchemyEngine.recipeById('breakthrough_pill')!;
      expect(AlchemyEngine.canCraft(stateWith(), recipe), isTrue);
    });

    test('false when herbs are lacking', () {
      final recipe = AlchemyEngine.recipeById('breakthrough_pill')!;
      expect(
        AlchemyEngine.canCraft(stateWith(herbs: 2), recipe),
        isFalse,
      );
    });

    test('false when stones are lacking', () {
      final recipe = AlchemyEngine.recipeById('lifespan_pill')!;
      expect(
        AlchemyEngine.canCraft(stateWith(stones: 10), recipe),
        isFalse,
      );
    });
  });

  group('craft', () {
    test('brewing a qi pill consumes materials and adds a pill', () {
      final recipe = AlchemyEngine.recipeById('qi_pill')!;
      final result = AlchemyEngine.craft(stateWith(), recipe)!;
      expect(result.spiritHerbs, 8);
      expect(result.spiritStones, 90);
      expect(result.qiPills, 1);
    });

    test('brewing a foundation pill consumes a beast core', () {
      final recipe = AlchemyEngine.recipeById('breakthrough_pill')!;
      final result = AlchemyEngine.craft(stateWith(), recipe)!;
      expect(result.spiritHerbs, 7);
      expect(result.beastCores, 9);
      expect(result.spiritStones, 75);
      expect(result.breakthroughPills, 1);
    });

    test('brewing a longevity pill consumes cores and stones', () {
      final recipe = AlchemyEngine.recipeById('lifespan_pill')!;
      final result = AlchemyEngine.craft(stateWith(), recipe)!;
      expect(result.beastCores, 8);
      expect(result.spiritStones, 60);
      expect(result.lifespanPills, 1);
    });

    test('returns null when materials are insufficient', () {
      final recipe = AlchemyEngine.recipeById('qi_pill')!;
      expect(AlchemyEngine.craft(stateWith(herbs: 1), recipe), isNull);
    });

    test('recipeById returns null for unknown ids', () {
      expect(AlchemyEngine.recipeById('nope'), isNull);
    });
  });
}
