class Race {
  final String id;
  final String name;
  final String title;
  final String description;
  final String intro;
  final String bonusLabel;

  const Race({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.intro,
    required this.bonusLabel,
  });

  static const List<Race> catalog = [
    Race(
      id: 'human',
      name: 'Human',
      title: 'Child of the Verdant Empire',
      description:
          'Fragile but endlessly adaptable. Humans lack the claws of '
          'demons and the senses of demi-humans, yet no race refines qi '
          'faster \u2014 and no race has ever produced more immortals.',
      intro:
          'You are born a mortal in a farming village of the Verdant '
          'Empire. Humans rule this world \u2014 for now \u2014 and their '
          'sects open their gates to any child who can walk the stairs.',
      bonusLabel: '+10% qi gain',
    ),
    Race(
      id: 'demon',
      name: 'Demon',
      title: 'Scion of the Ash Wastes',
      description:
          'Born of the old blood. Demons cultivate the body before the '
          'dao: denser bones, hotter blood, a temper the heavens learned '
          'to fear. Sects watch them carefully.',
      intro:
          'You are born among the ash-stone camps beyond the empire\u2019s '
          'border, where demon clans keep to the old ways. The mortal '
          'world calls your kind monsters. You will make it call you '
          'something else.',
      bonusLabel: '+15% attack, +10% health',
    ),
    Race(
      id: 'demi_human',
      name: 'Demi-human',
      title: 'Wanderer of the Border Forests',
      description:
          'Part spirit, part beast-blood. Demi-humans carry beast blood '
          'in their veins \u2014 hides like bark, eyes like hawks \u2014 '
          'and an instinct for survival and fortune that pure humans '
          'never match.',
      intro:
          'You are born in a border village where the empire\u2019s law '
          'ends and the beast forests begin. Demi-humans are tolerated '
          'there, rarely more \u2014 but the wilds themselves seem to '
          'watch over you.',
      bonusLabel: '+15% defense, +10% spirit stones',
    ),
  ];

  static Race byId(String id) =>
      catalog.firstWhere((race) => race.id == id, orElse: () => catalog.first);
}
