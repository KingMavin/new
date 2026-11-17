enum EquipmentSlot { weapon, armor }

class Equipment {
  final String name;
  final EquipmentSlot slot;
  final int grade;
  final double power;

  const Equipment({
    required this.name,
    required this.slot,
    required this.grade,
    required this.power,
  });

  static const List<String> gradeNames = [
    'Mortal',
    'Spirit',
    'Earth',
    'Heaven',
    'Immortal',
  ];

  static const List<String> weaponNames = [
    'Iron Sword',
    'Spirit Blade',
    'Earth Splitter',
    'Heaven Cleaver',
    'Immortal Fang',
  ];

  static const List<String> armorNames = [
    'Leather Robe',
    'Silk Vestment',
    'Earth Guard',
    'Heaven Aegis',
    'Immortal Carapace',
  ];

  String get gradeName => gradeNames[grade];

  String get slotLabel => slot == EquipmentSlot.weapon ? 'Weapon' : 'Armor';

  factory Equipment.create(EquipmentSlot slot, int grade, double power) {
    final names = slot == EquipmentSlot.weapon ? weaponNames : armorNames;
    return Equipment(
      name: names[grade],
      slot: slot,
      grade: grade,
      power: power,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slot': slot.name,
        'grade': grade,
        'power': power,
      };

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        name: json['name'] as String,
        slot: EquipmentSlot.values.byName(json['slot'] as String),
        grade: json['grade'] as int,
        power: (json['power'] as num).toDouble(),
      );
}
