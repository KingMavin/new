class Companion {
  final String name;
  final String bonusType;
  final int level;

  const Companion({
    required this.name,
    required this.bonusType,
    required this.level,
  });

  static const int maxLevel = 10;
  static const int feedCost = 2;

  double get qiBonus => bonusType == 'qi' ? 0.04 * level : 0;

  double get attackBonus => bonusType == 'attack' ? 0.05 * level : 0;

  String get bonusLabel => bonusType == 'qi'
      ? '+${(qiBonus * 100).toStringAsFixed(0)}% qi rate'
      : '+${(attackBonus * 100).toStringAsFixed(0)}% attack';

  Map<String, dynamic> toJson() => {
        'name': name,
        'bonusType': bonusType,
        'level': level,
      };

  factory Companion.fromJson(Map<String, dynamic> json) => Companion(
        name: json['name'] as String,
        bonusType: json['bonusType'] as String,
        level: json['level'] as int,
      );
}
