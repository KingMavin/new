class ActiveBoost {
  final String id;
  final String kind;
  final double multiplier;
  final DateTime expiresAt;

  const ActiveBoost({
    required this.id,
    required this.kind,
    required this.multiplier,
    required this.expiresAt,
  });

  bool isActive(DateTime now) => now.isBefore(expiresAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'multiplier': multiplier,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory ActiveBoost.fromJson(Map<String, dynamic> json) => ActiveBoost(
        id: json['id'] as String,
        kind: json['kind'] as String,
        multiplier: (json['multiplier'] as num).toDouble(),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );
}

class AdPlacement {
  final String id;
  final String title;
  final String description;
  final String rewardText;
  final String kind;
  final double multiplier;
  final Duration duration;
  final Duration cooldown;

  const AdPlacement({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardText,
    required this.kind,
    required this.multiplier,
    required this.duration,
    required this.cooldown,
  });
}

class StoreProduct {
  final String id;
  final String title;
  final String description;
  final String kind;
  final String priceLabel;
  final String? themeSeed;

  const StoreProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.priceLabel,
    this.themeSeed,
  });
}

class MonetizationCatalog {
  static const List<AdPlacement> adPlacements = [
    AdPlacement(
      id: 'qi_incense',
      title: 'Incense of the Ancestors',
      description:
          'Light a stick of ancestor incense by watching a messenger\u2019s '
          'tale. Your qi circulates twice as fast while it burns.',
      rewardText: '2x qi gain for 8 hours',
      kind: 'qi',
      multiplier: 2.0,
      duration: Duration(hours: 8),
      cooldown: Duration(hours: 6),
    ),
    AdPlacement(
      id: 'stone_favor',
      title: "Fortune Teller's Favor",
      description:
          'A fortune teller reads your ledger \u2014 after you hear her out. '
          'The world leaves more wealth half-buried for a while.',
      rewardText: '+50% spirit stones for 4 hours',
      kind: 'stones',
      multiplier: 1.5,
      duration: Duration(hours: 4),
      cooldown: Duration(hours: 4),
    ),
    AdPlacement(
      id: 'cooldown_pigeon',
      title: 'The Duel Pigeon',
      description:
          'A challenge pigeon arrives early. Read it and the tournament '
          'masters forget when you last fought \u2014 raids may begin at once.',
      rewardText:
          'Tournament and war cooldowns cleared (1h tournament / 4h war)',
      kind: 'cooldown',
      multiplier: 1.0,
      duration: Duration.zero,
      cooldown: Duration(minutes: 20),
    ),
  ];

  static const List<StoreProduct> products = [
    StoreProduct(
      id: 'immortal_patron',
      title: 'Immortal Patron',
      description:
          'Support the temple and carry its golden seal: the Celestial Gold '
          'theme, a Patron mark on your legend, and our thanks. Grants no '
          'power \u2014 the ladder stays honest.',
      kind: 'support',
      priceLabel: '\$4.99',
      themeSeed: '0xFFFFC107',
    ),
    StoreProduct(
      id: 'theme_ember',
      title: 'Theme: Phoenix Ember',
      description: 'A forge-fire palette for your cultivation screen.',
      kind: 'theme',
      priceLabel: '\$1.49',
      themeSeed: '0xFFFF7043',
    ),
    StoreProduct(
      id: 'theme_ashen',
      title: 'Theme: Ashen Clans',
      description: 'Dark iron and old blood, for those who walk the wastes.',
      kind: 'theme',
      priceLabel: '\$1.49',
      themeSeed: '0xFFB71C1C',
    ),
    StoreProduct(
      id: 'theme_moonveil',
      title: 'Theme: Moonveil Glade',
      description: 'Sister-moon silver over twilight violet.',
      kind: 'theme',
      priceLabel: '\$1.49',
      themeSeed: '0xFF7E57C2',
    ),
  ];

  static AdPlacement? placementById(String id) {
    for (final placement in adPlacements) {
      if (placement.id == id) return placement;
    }
    return null;
  }

  static StoreProduct? productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }
}
