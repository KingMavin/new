class Technique {
  final String id;
  final String name;
  final String description;
  final double qiMultiplier;
  final double breakthroughBonus;
  final double attackMultiplier;
  final double defenseMultiplier;
  final double hpMultiplier;
  final double tribulationHpMultiplier;

  const Technique({
    required this.id,
    required this.name,
    required this.description,
    required this.qiMultiplier,
    required this.breakthroughBonus,
    required this.attackMultiplier,
    required this.defenseMultiplier,
    required this.hpMultiplier,
    required this.tribulationHpMultiplier,
  });

  static const List<Technique> catalog = [
    Technique(
      id: 'basic',
      name: 'Basic Qi Method',
      description: 'The method every cultivator begins with.',
      qiMultiplier: 1,
      breakthroughBonus: 0,
      attackMultiplier: 1,
      defenseMultiplier: 1,
      hpMultiplier: 1,
      tribulationHpMultiplier: 1,
    ),
    Technique(
      id: 'flame',
      name: 'Flame Meridian Art',
      description: '+50% qi rate, -5% breakthrough chance.',
      qiMultiplier: 1.5,
      breakthroughBonus: -0.05,
      attackMultiplier: 1,
      defenseMultiplier: 1,
      hpMultiplier: 1,
      tribulationHpMultiplier: 1,
    ),
    Technique(
      id: 'iron',
      name: 'Iron Body Sutra',
      description:
          '+50% health, +40% defense, +30% tribulation health, -25% qi rate.',
      qiMultiplier: 0.75,
      breakthroughBonus: 0,
      attackMultiplier: 1,
      defenseMultiplier: 1.4,
      hpMultiplier: 1.5,
      tribulationHpMultiplier: 1.3,
    ),
    Technique(
      id: 'sword',
      name: 'Sword Heart Sutra',
      description: '+40% attack, -10% qi rate.',
      qiMultiplier: 0.9,
      breakthroughBonus: 0,
      attackMultiplier: 1.4,
      defenseMultiplier: 1,
      hpMultiplier: 1,
      tribulationHpMultiplier: 1,
    ),
    Technique(
      id: 'formation',
      name: 'Mystic Formation Art',
      description: '+15% breakthrough chance, -15% qi rate.',
      qiMultiplier: 0.85,
      breakthroughBonus: 0.15,
      attackMultiplier: 1,
      defenseMultiplier: 1,
      hpMultiplier: 1,
      tribulationHpMultiplier: 1,
    ),
    Technique(
      id: 'thunder',
      name: 'Thunder Refining Sutra',
      description: '+50% tribulation health, +10% qi rate.',
      qiMultiplier: 1.1,
      breakthroughBonus: 0,
      attackMultiplier: 1,
      defenseMultiplier: 1,
      hpMultiplier: 1,
      tribulationHpMultiplier: 1.5,
    ),
  ];

  static Technique byId(String id) => catalog.firstWhere(
        (technique) => technique.id == id,
        orElse: () => catalog.first,
      );
}
