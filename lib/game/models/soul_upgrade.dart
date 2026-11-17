class SoulUpgrade {
  final String id;
  final String name;
  final String description;
  final int baseCost;
  final int maxLevel;

  const SoulUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.baseCost,
    required this.maxLevel,
  });

  static const List<SoulUpgrade> catalog = [
    SoulUpgrade(
      id: 'qi_attunement',
      name: 'Qi Attunement',
      description: '+25% qi gain per level',
      baseCost: 50,
      maxLevel: 10,
    ),
    SoulUpgrade(
      id: 'battle_instinct',
      name: 'Battle Instinct',
      description: '+20% attack per level',
      baseCost: 50,
      maxLevel: 10,
    ),
    SoulUpgrade(
      id: 'iron_soul',
      name: 'Iron Soul',
      description: '+20% hp and defense per level',
      baseCost: 50,
      maxLevel: 10,
    ),
    SoulUpgrade(
      id: 'fortunes_favor',
      name: "Fortune's Favor",
      description: '+10% spirit stones per level',
      baseCost: 80,
      maxLevel: 5,
    ),
    SoulUpgrade(
      id: 'heavenly_insight',
      name: 'Heavenly Insight',
      description: '+4% breakthrough chance per level',
      baseCost: 100,
      maxLevel: 5,
    ),
  ];

  static SoulUpgrade byId(String id) => catalog.firstWhere(
        (upgrade) => upgrade.id == id,
        orElse: () => catalog.first,
      );
}
