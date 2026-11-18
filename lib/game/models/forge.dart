import 'equipment.dart';

class ForgeRecipe {
  final String id;
  final EquipmentSlot slot;
  final int grade;
  final double stonesBase;
  final int herbCost;
  final int coreCost;
  final double successChance;

  const ForgeRecipe({
    required this.id,
    required this.slot,
    required this.grade,
    required this.stonesBase,
    required this.herbCost,
    required this.coreCost,
    required this.successChance,
  });

  double powerFor(int realmIndex) =>
      (grade + 1) * 10.0 * pow1_8(realmIndex) * 1.08;

  int stoneCostFor(int realmIndex) =>
      (stonesBase * pow1_8(realmIndex)).round();
}

class ForgeCatalog {
  static const List<ForgeRecipe> recipes = [
    ForgeRecipe(
      id: 'forge_earth_weapon',
      slot: EquipmentSlot.weapon,
      grade: 2,
      stonesBase: 260,
      herbCost: 2,
      coreCost: 1,
      successChance: 0.60,
    ),
    ForgeRecipe(
      id: 'forge_earth_armor',
      slot: EquipmentSlot.armor,
      grade: 2,
      stonesBase: 260,
      herbCost: 2,
      coreCost: 1,
      successChance: 0.60,
    ),
    ForgeRecipe(
      id: 'forge_earth_amulet',
      slot: EquipmentSlot.amulet,
      grade: 2,
      stonesBase: 300,
      herbCost: 2,
      coreCost: 1,
      successChance: 0.60,
    ),
    ForgeRecipe(
      id: 'forge_heaven_weapon',
      slot: EquipmentSlot.weapon,
      grade: 3,
      stonesBase: 480,
      herbCost: 3,
      coreCost: 2,
      successChance: 0.35,
    ),
    ForgeRecipe(
      id: 'forge_heaven_armor',
      slot: EquipmentSlot.armor,
      grade: 3,
      stonesBase: 480,
      herbCost: 3,
      coreCost: 2,
      successChance: 0.35,
    ),
    ForgeRecipe(
      id: 'forge_heaven_amulet',
      slot: EquipmentSlot.amulet,
      grade: 3,
      stonesBase: 540,
      herbCost: 3,
      coreCost: 2,
      successChance: 0.35,
    ),
    ForgeRecipe(
      id: 'forge_immortal_weapon',
      slot: EquipmentSlot.weapon,
      grade: 4,
      stonesBase: 900,
      herbCost: 4,
      coreCost: 3,
      successChance: 0.15,
    ),
    ForgeRecipe(
      id: 'forge_immortal_armor',
      slot: EquipmentSlot.armor,
      grade: 4,
      stonesBase: 900,
      herbCost: 4,
      coreCost: 3,
      successChance: 0.15,
    ),
    ForgeRecipe(
      id: 'forge_immortal_amulet',
      slot: EquipmentSlot.amulet,
      grade: 4,
      stonesBase: 1000,
      herbCost: 4,
      coreCost: 3,
      successChance: 0.15,
    ),
  ];

  static ForgeRecipe? recipeById(String id) {
    for (final recipe in recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }
}

double pow1_8(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 1.8;
  }
  return result;
}
