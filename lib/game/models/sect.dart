class Sect {
  final String id;
  final String name;
  final String factionId;
  final String description;
  final String hallLine;
  final String bonusLabel;

  const Sect({
    required this.id,
    required this.name,
    required this.factionId,
    required this.description,
    required this.hallLine,
    required this.bonusLabel,
  });

  static const List<Sect> catalog = [
    Sect(
      id: 'sword_sect',
      name: 'Heavenly Sword Sect',
      factionId: 'human',
      description: 'Blade artists who sharpen their dao through endless battle.',
      hallLine: 'A thousand sword-terraces ring the peak; every stone has '
          'absorbed one duelist\u2019s regret.',
      bonusLabel: 'Attack +12% per sect rank',
    ),
    Sect(
      id: 'formation_hall',
      name: 'Mystic Formation Hall',
      factionId: 'human',
      description: 'Scholars who inscribe arrays to bend fate itself.',
      hallLine: 'Chalk-white courtyards over a buried grand array that '
          'hums underfoot before every tribulation.',
      bonusLabel: 'Breakthrough chance +3% per sect rank',
    ),
    Sect(
      id: 'imperial_herbal_court',
      name: 'Imperial Herbal Court',
      factionId: 'human',
      description: 'Physicians and gardeners of the Verdant Empire\u2019s '
          'seven healing gardens.',
      hallLine: 'Terraced medicine gardens climb the palace hill; the '
          'seventh terrace is guarded and grows things with opinions.',
      bonusLabel: 'Qi gain +10% per sect rank',
    ),
    Sect(
      id: 'blood_furnace_clan',
      name: 'Blood Furnace Clan',
      factionId: 'demon',
      description: 'Old-blood smiths who quench their blades in war and '
          'their pride in fire.',
      hallLine: 'Iron halls built into a dormant volcano; the forge never '
          'fully cools and neither do its disciples.',
      bonusLabel: 'Attack +12% per sect rank',
    ),
    Sect(
      id: 'pill_valley',
      name: 'Myriad Pill Valley',
      factionId: 'demon',
      description: 'Alchemists who refine the qi of heaven and earth.',
      hallLine: 'A valley smoked with a thousand cauldrons, each one held '
          'by a lineage and a temper.',
      bonusLabel: 'Qi gain +10% per sect rank',
    ),
    Sect(
      id: 'nightveil_bureau',
      name: 'Nightveil Bureau',
      factionId: 'demon',
      description: 'Warders and omen-readers who file the quiet paperwork '
          'of fate.',
      hallLine: 'Windowless black archives where ward charts outnumber '
          'swords and silence is a filing system.',
      bonusLabel: 'Breakthrough chance +3% per sect rank',
    ),
    Sect(
      id: 'beast_court',
      name: 'Spirit Beast Court',
      factionId: 'demi_human',
      description: 'Bonded to beast kin; the pack walks with the strong.',
      hallLine: 'Open-air courts of moss and bone where spirit beasts '
          'deliberate beside their bonded drinkers.',
      bonusLabel: 'Attack +12% per sect rank',
    ),
    Sect(
      id: 'verdant_grove',
      name: 'Verdant Whisper Grove',
      factionId: 'demi_human',
      description: 'Root-growers who outpace any furnace \u2014 slowly, '
          'then all at once.',
      hallLine: 'A grove of seedling-souls, each tree a sworn disciple; '
          'the oldest rings remember the first tribes.',
      bonusLabel: 'Qi gain +10% per sect rank',
    ),
    Sect(
      id: 'wind_speaker_circle',
      name: 'Wind-Speaker Circle',
      factionId: 'demi_human',
      description: 'Storm-listeners who read tribulations before they '
          'fall.',
      hallLine: 'Cliffside rings of standing stones that sing when the '
          'weather \u2014 or fate \u2014 turns.',
      bonusLabel: 'Breakthrough chance +3% per sect rank',
    ),
  ];

  static Sect byId(String id) =>
      catalog.firstWhere((sect) => sect.id == id, orElse: () => catalog.first);

  static List<Sect> forFaction(String factionId) =>
      catalog.where((sect) => sect.factionId == factionId).toList();
}
