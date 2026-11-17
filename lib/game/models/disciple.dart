class Disciple {
  final String name;
  final int level;
  final String? missionType;
  final double? missionHours;
  final DateTime? missionEndsAt;

  const Disciple({
    required this.name,
    required this.level,
    this.missionType,
    this.missionHours,
    this.missionEndsAt,
  });

  bool get onMission =>
      missionType != null && missionHours != null && missionEndsAt != null;

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'missionType': missionType,
        'missionHours': missionHours,
        'missionEndsAt': missionEndsAt?.toIso8601String(),
      };

  factory Disciple.fromJson(Map<String, dynamic> json) => Disciple(
        name: json['name'] as String,
        level: json['level'] as int? ?? 1,
        missionType: json['missionType'] as String?,
        missionHours: (json['missionHours'] as num?)?.toDouble(),
        missionEndsAt: json['missionEndsAt'] == null
            ? null
            : DateTime.parse(json['missionEndsAt'] as String),
      );
}
