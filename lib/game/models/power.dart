class BloodlinePower {
  final String id;
  final String name;
  final String description;
  final String bonusType;
  final double magnitude;
  final String source;
  final String? sectId;
  final int contributionCost;
  final int minSectRank;

  const BloodlinePower({
    required this.id,
    required this.name,
    required this.description,
    required this.bonusType,
    required this.magnitude,
    required this.source,
    this.sectId,
    this.contributionCost = 0,
    this.minSectRank = 0,
  });

  bool get isSectPower => sectId != null;

  String get bonusLabel {
    final percent = (magnitude * 100).toStringAsFixed(0);
    switch (bonusType) {
      case 'qi':
        return '+$percent% qi gain';
      case 'attack':
        return '+$percent% attack';
      case 'defense':
        return '+$percent% defense';
      case 'hp':
        return '+$percent% health';
      case 'stones':
        return '+$percent% spirit stones';
      case 'breakthrough':
        return '+$percent% breakthrough chance';
      default:
        return '+$percent% $bonusType';
    }
  }
}

class PowerCatalog {
  static const List<BloodlinePower> powers = [
    BloodlinePower(
      id: 'phoenix_ember',
      name: 'Ember of the Fallen Phoenix',
      description:
          'A coal that never cools, dug from the heart of the Scorched '
          'Ember Valley. Swallowed whole, it banks phoenix fire in your '
          'meridians that answers when you strike.',
      bonusType: 'attack',
      magnitude: 0.10,
      source: 'found',
    ),
    BloodlinePower(
      id: 'dragon_scale_heart',
      name: 'Dragon-Scale Heart',
      description:
          'A scale grown over a mortal heart, torn from a dragon that '
          'chose to become a mountain. Blows land on it and remember.',
      bonusType: 'defense',
      magnitude: 0.10,
      source: 'found',
    ),
    BloodlinePower(
      id: 'thunder_marrow',
      name: 'Thunder Marrow',
      description:
          'Lightning that outlived the storm, sealed in a beast core from '
          'the Heavenly Gate Ruins. Your bones ring with it when you '
          'bleed.',
      bonusType: 'hp',
      magnitude: 0.10,
      source: 'found',
    ),
    BloodlinePower(
      id: 'void_insight',
      name: 'Void Insight',
      description:
          'A single moment of clarity pulled back from the Void Rift: the '
          'dao is mostly empty space, and empty space is easy to move '
          'through. Qi circulates like it has less world to cross.',
      bonusType: 'qi',
      magnitude: 0.10,
      source: 'found',
    ),
    BloodlinePower(
      id: 'moonveil_blessing',
      name: 'Moonveil Blessing',
      description:
          'Silver hoofprint-light on your shoulder, left by the Moonveil '
          'matriarch. Where you walk, the world tends to leave wealth '
          'half-buried.',
      bonusType: 'stones',
      magnitude: 0.10,
      source: 'found',
    ),
    BloodlinePower(
      id: 'sages_last_word',
      name: 'The Sage\u2019s Last Word',
      description:
          'One syllable, unliterated, from a sage who spent his final '
          'breath on it. Held in the mind it plows bottleneck qi like a '
          'blade through silk.',
      bonusType: 'breakthrough',
      magnitude: 0.03,
      source: 'found',
    ),
    BloodlinePower(
      id: 'sword_intent',
      name: 'Sect Art: Sword Intent',
      description:
          'The Heavenly Sword Sect\u2019s inner teaching: a strike decided '
          'before the blade moves. Granted to Inner Disciples who pay in '
          'deeds.',
      bonusType: 'attack',
      magnitude: 0.08,
      source: 'sect',
      sectId: 'sword_sect',
      contributionCost: 150,
      minSectRank: 1,
    ),
    BloodlinePower(
      id: 'merged_scripture',
      name: 'Sect Art: Merged Pill Scripture',
      description:
          'Myriad Pill Valley\u2019s inner teaching: your dantian as a '
          'cauldron that never fully cools. Granted to Inner Disciples '
          'who pay in deeds.',
      bonusType: 'qi',
      magnitude: 0.08,
      source: 'sect',
      sectId: 'pill_valley',
      contributionCost: 150,
      minSectRank: 1,
    ),
    BloodlinePower(
      id: 'grand_formation',
      name: 'Sect Art: Grand Formation Insight',
      description:
          'Mystic Formation Hall\u2019s inner teaching: see the array '
          'hidden inside every bottleneck and walk through its seam. '
          'Granted to Inner Disciples who pay in deeds.',
      bonusType: 'breakthrough',
      magnitude: 0.02,
      source: 'sect',
      sectId: 'formation_hall',
      contributionCost: 150,
      minSectRank: 1,
    ),
  ];

  static List<BloodlinePower> foundPowers() =>
      powers.where((power) => power.source == 'found').toList();

  static List<BloodlinePower> sectPowers() =>
      powers.where((power) => power.isSectPower).toList();

  static BloodlinePower? byId(String id) {
    for (final power in powers) {
      if (power.id == id) return power;
    }
    return null;
  }
}
