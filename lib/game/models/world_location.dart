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

class WorldLocation {
  final String id;
  final String name;
  final String type;
  final String description;
  final String? discoveryHint;
  final int requiredRealm;
  final int requiredReputation;
  final String? raceId;
  final int dangerTier;
  final double spiritStoneReward;
  final int maxEquipmentGrade;
  final List<Beast> beasts;

  const WorldLocation({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.requiredRealm,
    this.requiredReputation = 0,
    this.raceId,
    required this.dangerTier,
    required this.spiritStoneReward,
    required this.maxEquipmentGrade,
    required this.beasts,
    this.discoveryHint,
  });

  bool get isHidden => type == 'hidden';
  bool get isFactionHall => type == 'faction';
  bool get isForbidden => type == 'forbidden';
  bool get isFallenCity => type == 'fallenCity';
  bool get isRaid => isForbidden || isFallenCity;

  String get typeLabel {
    switch (type) {
      case 'hidden':
        return 'Hidden Realm';
      case 'forbidden':
        return 'Forbidden Ground';
      case 'fallenCity':
        return 'Fallen City';
      case 'faction':
        return 'Faction Hall';
      default:
        return 'Wilderness';
    }
  }
}

class WorldCatalog {
  static Beast _beast(String name, double scale, String bonusType) => Beast(
        name: name,
        hp: 40 * scale,
        attack: 8 * scale,
        defense: 3 * scale,
        bonusType: bonusType,
      );

  static Beast _elite(String name, double scale, String bonusType) => Beast(
        name: name,
        hp: 40 * scale * 2.5,
        attack: 8 * scale * 1.3,
        defense: 3 * scale * 1.5,
        bonusType: bonusType,
      );

  static const String typeRegion = 'region';
  static const String typeHidden = 'hidden';
  static const String typeForbidden = 'forbidden';
  static const String typeFallenCity = 'fallenCity';
  static const String typeFaction = 'faction';

  static final List<WorldLocation> locations = [
    WorldLocation(
      id: 'bamboo_forest',
      name: 'Verdant Bamboo Forest',
      type: typeRegion,
      description:
          'A sea of jade stalks whispering in the wind. Spirit qi pools '
          'gently here, and mortal cultivators hunt small game among the '
          'shadows.',
      requiredRealm: 0,
      dangerTier: 1,
      spiritStoneReward: 10,
      maxEquipmentGrade: 1,
      beasts: [
        _beast('Bamboo Viper', 1, 'attack'),
        _beast('Green Shadow Hare', 0.8, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'misty_mountains',
      name: 'Misty Cloud Mountains',
      type: typeRegion,
      description:
          'Clouds crawl between jagged peaks where wolf packs howl at the '
          'moon. Old mountain shrines hint at cultivators who came before.',
      requiredRealm: 1,
      dangerTier: 1,
      spiritStoneReward: 25,
      maxEquipmentGrade: 1,
      beasts: [
        _beast('Iron Fang Wolf', 2.2, 'attack'),
        _beast('Mist Roc Chick', 1.9, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'lotus_lake',
      name: 'Azure Lotus Lake',
      type: typeRegion,
      description:
          'Ten thousand lotus blossoms drift on water so still it mirrors '
          'the heavens. Something vast circles beneath the surface.',
      requiredRealm: 2,
      dangerTier: 2,
      spiritStoneReward: 60,
      maxEquipmentGrade: 2,
      beasts: [
        _beast('Lotus Python', 4.84, 'attack'),
        _beast('Azure Carp Demon', 4.2, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'ember_valley',
      name: 'Scorched Ember Valley',
      type: typeRegion,
      description:
          'The ground glows dull red and the air tastes of cinder. Fire qi '
          'here is thick enough to refine a body \u2014 or cook one.',
      requiredRealm: 3,
      dangerTier: 2,
      spiritStoneReward: 150,
      maxEquipmentGrade: 2,
      beasts: [
        _beast('Ember Lion', 10.65, 'attack'),
        _beast('Magma Toad', 9.3, 'attack'),
      ],
    ),
    WorldLocation(
      id: 'serpent_peak',
      name: 'Frozen Serpent Peak',
      type: typeRegion,
      description:
          'A needle of black ice piercing the clouds. Serpents older than '
          'empires sleep coiled in its glaciers.',
      requiredRealm: 4,
      dangerTier: 3,
      spiritStoneReward: 380,
      maxEquipmentGrade: 3,
      beasts: [
        _beast('Frost Serpent', 23.43, 'attack'),
        _beast('Ice Crow', 20, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'beast_wasteland',
      name: 'Myriad Beast Wasteland',
      type: typeRegion,
      description:
          'An endless savanna ruled by beasts that treat human sects as '
          'snacks. Only the strong walk out with their bones unbroken.',
      requiredRealm: 5,
      dangerTier: 3,
      spiritStoneReward: 900,
      maxEquipmentGrade: 3,
      beasts: [
        _beast('Golden Sand Ape', 51.54, 'attack'),
        _beast('Storm Rhino', 45, 'attack'),
      ],
    ),
    WorldLocation(
      id: 'sword_tomb',
      name: 'Ancient Sword Tomb',
      type: typeRegion,
      description:
          'A million broken blades stand planted in a hillside like a '
          'forest of steel. Wraiths of dead swordsmen still duel at dusk.',
      requiredRealm: 6,
      dangerTier: 4,
      spiritStoneReward: 2200,
      maxEquipmentGrade: 4,
      beasts: [
        _beast('Sword Wraith', 113.4, 'attack'),
        _beast('Grave Sentinel', 100, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'hells_gorge',
      name: 'Nine Hells Gorge',
      type: typeRegion,
      description:
          'A canyon that descends past bedrock into firelit darkness. The '
          'deeper you climb down, the less the world above resembles home.',
      requiredRealm: 7,
      dangerTier: 4,
      spiritStoneReward: 5500,
      maxEquipmentGrade: 4,
      beasts: [
        _beast('Hell Hound', 249.5, 'attack'),
        _beast('Abyss Spider', 220, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'heavenly_gate',
      name: 'Heavenly Gate Ruins',
      type: typeRegion,
      description:
          'The shattered threshold between mortality and the heavens. '
          'Lightning never stops falling here, and guardians never stop '
          'walking.',
      requiredRealm: 8,
      dangerTier: 5,
      spiritStoneReward: 13000,
      maxEquipmentGrade: 4,
      beasts: [
        _beast('Gate Guardian', 548.8, 'attack'),
        _beast('Thunder Peng', 480, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'verdant_palace',
      name: 'Verdant Palace of the Empire',
      type: typeFaction,
      raceId: 'human',
      requiredReputation: 100,
      description:
          'The empire\u2019s inner sanctum, open only to those its people '
          'trust. Jade halls hum with formation arrays, and the imperial '
          'armory stands open to honored guests.',
      requiredRealm: 1,
      dangerTier: 3,
      spiritStoneReward: 80,
      maxEquipmentGrade: 2,
      beasts: [
        _elite('Jade Sentinel Construct', 2.2, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'ash_sanctum',
      name: 'Ash Sanctum of the Clans',
      type: typeFaction,
      raceId: 'demon',
      requiredReputation: 300,
      description:
          'A temple of black iron built on a vein of dragonfire, where the '
          'old blood gathers. Only demons who have proven their strength '
          'may walk its ember-lit corridors.',
      requiredRealm: 2,
      dangerTier: 4,
      spiritStoneReward: 200,
      maxEquipmentGrade: 3,
      beasts: [
        _elite('Sanctum Flame Warden', 4.84, 'attack'),
      ],
    ),
    WorldLocation(
      id: 'moonveil_glade',
      name: 'Moonveil Glade',
      type: typeFaction,
      raceId: 'demi_human',
      requiredReputation: 700,
      description:
          'A hidden glade deep in the border forests where beast-blooded '
          'tribes gather under a permanent silver moon. The forest itself '
          'bars the path of strangers.',
      requiredRealm: 3,
      dangerTier: 4,
      spiritStoneReward: 600,
      maxEquipmentGrade: 3,
      beasts: [
        _elite('Moonveil Stag Sovereign', 10.65, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'fallen_zhao',
      name: 'Sunken City of Zhao',
      type: typeFallenCity,
      description:
          'A dynasty\u2019s capital, swallowed by the earth in a single '
          'night. Its pagoda tips jut from the marsh like ribs, and '
          'something regal still patrols the flooded streets.',
      requiredRealm: 2,
      dangerTier: 3,
      spiritStoneReward: 120,
      maxEquipmentGrade: 2,
      beasts: [
        _elite('Crown Prince Wraith', 4.84, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'bone_pits',
      name: 'The Bone Pits',
      type: typeForbidden,
      description:
          'Forbidden ground. A crater where an ancient sect ground ten '
          'thousand disciples into powder. The bones do not rest, and the '
          'qi here curdles the soul.',
      requiredRealm: 3,
      dangerTier: 5,
      spiritStoneReward: 400,
      maxEquipmentGrade: 3,
      beasts: [
        _elite('Ossuary Sovereign', 10.65, 'attack'),
      ],
    ),
    WorldLocation(
      id: 'sword_vault',
      name: 'Hidden Sword Vault',
      type: typeHidden,
      description:
          'A sealed vault behind a waterfall, holding the armory of a '
          'sword sect that ascended ten thousand years ago. The blades '
          'hum when you approach.',
      discoveryHint:
          'Rumor: swordsman wraiths of the Ancient Sword Tomb guard the '
          'way to a sealed vault.',
      requiredRealm: 4,
      dangerTier: 4,
      spiritStoneReward: 1000,
      maxEquipmentGrade: 4,
      beasts: [
        _elite('Vault Sword Spirit', 23.43, 'attack'),
      ],
    ),
    WorldLocation(
      id: 'fallen_yan',
      name: 'Fallen Capital of Yan',
      type: typeFallenCity,
      description:
          'A raid on a dead empire. Yan\u2019s capital burned when its '
          'last emperor tried to defy heaven; now ash storms sweep '
          'boulevards lined with petrified nobles.',
      requiredRealm: 5,
      dangerTier: 4,
      spiritStoneReward: 2500,
      maxEquipmentGrade: 4,
      beasts: [
        _elite('Ashen Emperor', 51.54, 'qi'),
      ],
    ),
    WorldLocation(
      id: 'void_rift',
      name: 'The Void Rift',
      type: typeForbidden,
      description:
          'Forbidden beyond forbidden. A tear in the world where '
          'space itself bleeds. Cultivators enter seeking dao insight; '
          'the rift keeps what it catches.',
      requiredRealm: 6,
      dangerTier: 5,
      spiritStoneReward: 6000,
      maxEquipmentGrade: 4,
      beasts: [
        _elite('Rift Stalker', 113.4, 'attack'),
      ],
    ),
    WorldLocation(
      id: 'immortal_grotto',
      name: 'Hidden Immortal Grotto',
      type: typeHidden,
      description:
          'A pocket paradise folded inside a mountain: peach blossoms in '
          'eternal spring, a pond of liquid qi, and a hermit\u2019s cave '
          'stocked for an ascension that never happened.',
      discoveryHint:
          'Rumor: beasts of the Nine Hells Gorge whisper of a gate that '
          'opens only to the worthy.',
      requiredRealm: 6,
      dangerTier: 4,
      spiritStoneReward: 8000,
      maxEquipmentGrade: 4,
      beasts: [
        _elite('Grotto Guardian Ape', 113.4, 'attack'),
      ],
    ),
  ];

  static WorldLocation? factionLocationFor(String raceId) =>
      locations
          .where((location) =>
              location.isFactionHall && location.raceId == raceId)
          .firstOrNull;

  static WorldLocation byId(String id) => locations.firstWhere(
        (location) => location.id == id,
        orElse: () => locations.first,
      );

  static List<WorldLocation> standardLocations() =>
      locations.where((location) => location.type == typeRegion).toList();

  static bool isKnown(List<String> discoveredLocations, WorldLocation location) =>
      !location.isHidden || discoveredLocations.contains(location.id);

  static String? hiddenToDiscover(int realmIndex, List<String> discovered) {
    for (final location in locations) {
      if (location.isHidden &&
          !discovered.contains(location.id) &&
          location.requiredRealm <= realmIndex + 1) {
        return location.id;
      }
    }
    return null;
  }
}
