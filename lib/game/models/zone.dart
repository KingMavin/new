class Beast {
  final String name;
  final double hp;
  final double attack;
  final double defense;
  final String bonusType;

  const Beast({
    required this.name,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.bonusType,
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
  static Beast _beast(String name, double scale, String bonusType) => Beast(
        name: name,
        hp: 40 * scale,
        attack: 8 * scale,
        defense: 3 * scale,
        bonusType: bonusType,
      );

  static final List<Zone> zones = [
    Zone(
      name: 'Verdant Bamboo Forest',
      requiredRealm: 0,
      beasts: [
        _beast('Bamboo Viper', 1, 'attack'),
        _beast('Green Shadow Hare', 0.8, 'qi'),
      ],
      spiritStoneReward: 10,
      maxEquipmentGrade: 1,
    ),
    Zone(
      name: 'Misty Cloud Mountains',
      requiredRealm: 1,
      beasts: [
        _beast('Iron Fang Wolf', 2.2, 'attack'),
        _beast('Mist Roc Chick', 1.9, 'qi'),
      ],
      spiritStoneReward: 25,
      maxEquipmentGrade: 1,
    ),
    Zone(
      name: 'Azure Lotus Lake',
      requiredRealm: 2,
      beasts: [
        _beast('Lotus Python', 4.84, 'attack'),
        _beast('Azure Carp Demon', 4.2, 'qi'),
      ],
      spiritStoneReward: 60,
      maxEquipmentGrade: 2,
    ),
    Zone(
      name: 'Scorched Ember Valley',
      requiredRealm: 3,
      beasts: [
        _beast('Ember Lion', 10.65, 'attack'),
        _beast('Magma Toad', 9.3, 'attack'),
      ],
      spiritStoneReward: 150,
      maxEquipmentGrade: 2,
    ),
    Zone(
      name: 'Frozen Serpent Peak',
      requiredRealm: 4,
      beasts: [
        _beast('Frost Serpent', 23.43, 'attack'),
        _beast('Ice Crow', 20, 'qi'),
      ],
      spiritStoneReward: 380,
      maxEquipmentGrade: 3,
    ),
    Zone(
      name: 'Myriad Beast Wasteland',
      requiredRealm: 5,
      beasts: [
        _beast('Golden Sand Ape', 51.54, 'attack'),
        _beast('Storm Rhino', 45, 'attack'),
      ],
      spiritStoneReward: 900,
      maxEquipmentGrade: 3,
    ),
    Zone(
      name: 'Ancient Sword Tomb',
      requiredRealm: 6,
      beasts: [
        _beast('Sword Wraith', 113.4, 'attack'),
        _beast('Grave Sentinel', 100, 'qi'),
      ],
      spiritStoneReward: 2200,
      maxEquipmentGrade: 4,
    ),
    Zone(
      name: 'Nine Hells Gorge',
      requiredRealm: 7,
      beasts: [
        _beast('Hell Hound', 249.5, 'attack'),
        _beast('Abyss Spider', 220, 'qi'),
      ],
      spiritStoneReward: 5500,
      maxEquipmentGrade: 4,
    ),
    Zone(
      name: 'Heavenly Gate Ruins',
      requiredRealm: 8,
      beasts: [
        _beast('Gate Guardian', 548.8, 'attack'),
        _beast('Thunder Peng', 480, 'qi'),
      ],
      spiritStoneReward: 13000,
      maxEquipmentGrade: 4,
    ),
  ];
}
