import 'package:immortal_path/game/models/game_state.dart';

class AlchemyRecipe {
  final String id;
  final String name;
  final String description;
  final int herbCost;
  final int coreCost;
  final double stoneCost;

  const AlchemyRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.herbCost,
    required this.coreCost,
    required this.stoneCost,
  });
}

class AlchemyEngine {
  static const List<AlchemyRecipe> recipes = [
    AlchemyRecipe(
      id: 'qi_pill',
      name: 'Qi Gathering Pill',
      description: 'Instantly gain 2 minutes of cultivation.',
      herbCost: 2,
      coreCost: 0,
      stoneCost: 10,
    ),
    AlchemyRecipe(
      id: 'breakthrough_pill',
      name: 'Foundation Pill',
      description: '+20% chance on your next breakthrough (max +50%).',
      herbCost: 3,
      coreCost: 1,
      stoneCost: 25,
    ),
    AlchemyRecipe(
      id: 'lifespan_pill',
      name: 'Longevity Pill',
      description: 'Permanently gain 25 years of lifespan.',
      herbCost: 0,
      coreCost: 2,
      stoneCost: 40,
    ),
  ];

  static AlchemyRecipe? recipeById(String id) {
    for (final recipe in recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  static bool canCraft(GameState state, AlchemyRecipe recipe) =>
      state.spiritHerbs >= recipe.herbCost &&
      state.beastCores >= recipe.coreCost &&
      state.spiritStones >= recipe.stoneCost;

  static GameState? craft(GameState state, AlchemyRecipe recipe) {
    if (!canCraft(state, recipe)) return null;
    switch (recipe.id) {
      case 'qi_pill':
        return state.copyWith(
          spiritHerbs: state.spiritHerbs - recipe.herbCost,
          spiritStones: state.spiritStones - recipe.stoneCost,
          qiPills: state.qiPills + 1,
        );
      case 'breakthrough_pill':
        return state.copyWith(
          spiritHerbs: state.spiritHerbs - recipe.herbCost,
          beastCores: state.beastCores - recipe.coreCost,
          spiritStones: state.spiritStones - recipe.stoneCost,
          breakthroughPills: state.breakthroughPills + 1,
        );
      case 'lifespan_pill':
        return state.copyWith(
          beastCores: state.beastCores - recipe.coreCost,
          spiritStones: state.spiritStones - recipe.stoneCost,
          lifespanPills: state.lifespanPills + 1,
        );
    }
    return null;
  }
}
