class Beast {
  final String name;
  final double hp;
  final double attack;
  final double defense;

  const Beast({
    required this.name,
    required this.hp,
    required this.attack,
    required this.defense,
  });
}

class Zone {
  final String name;
  final int requiredRealm;
  final List<Beast> beasts;
  final double spiritStoneReward;
  final int maxEquipmentGrade;

  const Zone({
    required this.name,
    required this.requiredRealm,
    required this.beasts,
    required this.spiritStoneReward,
    required this.maxEquipmentGrade,
  });
}

class ZoneCatalog {
  static Beast _beast(String name, double scale) => Beast(
        name: name,
        hp: 40 * scale,
        attack: 8 * scale,
        defense: 3 * scale,
      );

  static final List<Zone> zones = [
    Zone(
      name: 'Verdant Bamboo Forest',
      requiredRealm: 0,
      beasts: [
        _beast('Bamboo Viper', 1),
        _beast('Green Shadow Hare', 0.8),
      ],
      spiritStoneReward: 10,
      maxEquipmentGrade: 1,
    ),
    Zone(
      name: 'Misty Cloud Mountains',
      requiredRealm: 1,
      beasts: [
        _beast('Iron Fang Wolf', 2.2),
        _beast('Mist Roc Chick', 1.9),
      ],
      spiritStoneReward: 25,
      maxEquipmentGrade: 1,
    ),
    Zone(
      name: 'Azure Lotus Lake',
      requiredRealm: 2,
      beasts: [
        _beast('Lotus Python', 4.84),
        _beast('Azure Carp Demon', 4.2),
      ],
      spiritStoneReward: 60,
      maxEquipmentGrade: 2,
    ),
    Zone(
      name: 'Scorched Ember Valley',
      requiredRealm: 3,
      beasts: [
        _beast('Ember Lion', 10.65),
        _beast('Magma Toad', 9.3),
      ],
      spiritStoneReward: 150,
      maxEquipmentGrade: 2,
    ),
    Zone(
      name: 'Frozen Serpent Peak',
      requiredRealm: 4,
      beasts: [
        _beast('Frost Serpent', 23.43),
        _beast('Ice Crow', 20),
      ],
      spiritStoneReward: 380,
      maxEquipmentGrade: 3,
    ),
    Zone(
      name: 'Myriad Beast Wasteland',
      requiredRealm: 5,
      beasts: [
        _beast('Golden Sand Ape', 51.54),
        _beast('Storm Rhino', 45),
      ],
      spiritStoneReward: 900,
      maxEquipmentGrade: 3,
    ),
    Zone(
      name: 'Ancient Sword Tomb',
      requiredRealm: 6,
      beasts: [
        _beast('Sword Wraith', 113.4),
        _beast('Grave Sentinel', 100),
      ],
      spiritStoneReward: 2200,
      maxEquipmentGrade: 4,
    ),
    Zone(
      name: 'Nine Hells Gorge',
      requiredRealm: 7,
      beasts: [
        _beast('Hell Hound', 249.5),
        _beast('Abyss Spider', 220),
      ],
      spiritStoneReward: 5500,
      maxEquipmentGrade: 4,
    ),
    Zone(
      name: 'Heavenly Gate Ruins',
      requiredRealm: 8,
      beasts: [
        _beast('Gate Guardian', 548.8),
        _beast('Thunder Peng', 480),
      ],
      spiritStoneReward: 13000,
      maxEquipmentGrade: 4,
    ),
  ];
}
