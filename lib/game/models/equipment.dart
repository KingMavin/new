enum EquipmentSlot { weapon, armor, amulet }

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

  static const List<String> amuletNames = [
    'Bone Charm',
    'Spirit Talisman',
    'Earth Sigil',
    'Heaven Medallion',
    'Immortal Seal',
  ];

  String get gradeName => gradeNames[grade];

  String get slotLabel {
    switch (slot) {
      case EquipmentSlot.weapon:
        return 'Weapon';
      case EquipmentSlot.armor:
        return 'Armor';
      case EquipmentSlot.amulet:
        return 'Amulet';
    }
  }

  factory Equipment.create(EquipmentSlot slot, int grade, double power) {
    final List<String> names;
    switch (slot) {
      case EquipmentSlot.weapon:
        names = weaponNames;
        break;
      case EquipmentSlot.armor:
        names = armorNames;
        break;
      case EquipmentSlot.amulet:
        names = amuletNames;
        break;
    }
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
