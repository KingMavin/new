import 'dart:math';

import 'equipment.dart';

class SectStoreItem {
  final String id;
  final String name;
  final String description;
  final EquipmentSlot slot;
  final int grade;
  final double basePower;
  final double baseStoneCost;
  final int minRank;

  const SectStoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.slot,
    required this.grade,
    required this.basePower,
    required this.baseStoneCost,
    this.minRank = 1,
  });

  double powerFor(int realmIndex) => basePower * pow(1.8, realmIndex);

  int stoneCostFor(int realmIndex) =>
      (baseStoneCost * pow(1.8, realmIndex)).round();
}

class SectStoreCatalog {
  static const List<SectStoreItem> items = [
    SectStoreItem(
      id: 'forged_blade',
      name: 'Sect-Forged Spirit Blade',
      description: 'Quenched in the same spring as the training swords.',
      slot: EquipmentSlot.weapon,
      grade: 1,
      basePower: 20.0,
      baseStoneCost: 400,
    ),
    SectStoreItem(
      id: 'forged_vestment',
      name: 'Sect-Forged Spirit Vestment',
      description: 'Robes stitched by the formation hall apprentices.',
      slot: EquipmentSlot.armor,
      grade: 1,
      basePower: 20.0,
      baseStoneCost: 400,
    ),
    SectStoreItem(
      id: 'sigil_talisman',
      name: 'Sect Talisman',
      description:
          'Blessed at the offering altar; lends strength to blade and ward '
          'both.',
      slot: EquipmentSlot.amulet,
      grade: 1,
      basePower: 20.0,
      baseStoneCost: 450,
    ),
    SectStoreItem(
      id: 'earth_blade',
      name: 'Sect-Forged Earth Splitter',
      description: 'A sect elder works the forge for three days and nights.',
      slot: EquipmentSlot.weapon,
      grade: 2,
      basePower: 30.0,
      baseStoneCost: 1500,
      minRank: 2,
    ),
    SectStoreItem(
      id: 'earth_guard',
      name: 'Sect-Forged Earth Guard',
      description: 'Armor heavy as the sect mountain, fitted to your frame.',
      slot: EquipmentSlot.armor,
      grade: 2,
      basePower: 30.0,
      baseStoneCost: 1500,
      minRank: 2,
    ),
    SectStoreItem(
      id: 'earth_sigil',
      name: 'Earth Sigil Charm',
      description: 'The seal of an elder, worn at the chest.',
      slot: EquipmentSlot.amulet,
      grade: 2,
      basePower: 30.0,
      baseStoneCost: 1700,
      minRank: 2,
    ),
  ];

  static SectStoreItem? itemById(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
