class Sect {
  final String id;
  final String name;
  final String description;
  final String bonusLabel;

  const Sect({
    required this.id,
    required this.name,
    required this.description,
    required this.bonusLabel,
  });

  static const List<Sect> catalog = [
    Sect(
      id: 'sword_sect',
      name: 'Heavenly Sword Sect',
      description: 'Blade artists who sharpen their dao through endless battle.',
      bonusLabel: 'Attack +12% per sect rank',
    ),
    Sect(
      id: 'pill_valley',
      name: 'Myriad Pill Valley',
      description: 'Alchemists who refine the qi of heaven and earth.',
      bonusLabel: 'Qi gain +10% per sect rank',
    ),
    Sect(
      id: 'formation_hall',
      name: 'Mystic Formation Hall',
      description: 'Scholars who inscribe arrays to bend fate itself.',
      bonusLabel: 'Breakthrough chance +3% per sect rank',
    ),
  ];

  static Sect byId(String id) =>
      catalog.firstWhere((sect) => sect.id == id, orElse: () => catalog.first);
}
