import 'dart:math';

import 'equipment.dart';

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

  static const Set<String> kinds = {
    'support',
    'theme',
    'offline',
    'gear',
    'bundle',
  };
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
      id: 'immortal_pack',
      title: 'The Immortal Pack',
      description:
          'The full inheritance: Patron seal, every theme (Celestial Gold '
          'included), 24 hours of offline stillness, and the complete '
          'Ancestral Heirloom set \u2014 weapon, armor, and seal.',
      kind: 'bundle',
      priceLabel: '\$24.99',
      themeSeed: '0xFFFFD54F',
    ),
    StoreProduct(
      id: 'offline_12h',
      title: 'Hours of Stillness II',
      description:
          'Your cultivation keeps flowing while you sleep \u2014 offline '
          'progress caps rise from 8 to 12 hours. Forever.',
      kind: 'offline',
      priceLabel: '\$2.99',
    ),
    StoreProduct(
      id: 'offline_24h',
      title: 'Hours of Stillness III',
      description:
          'Offline progress caps rise to 24 hours. Forever '
          '(includes the 12-hour band).',
      kind: 'offline',
      priceLabel: '\$4.99',
    ),
    StoreProduct(
      id: 'heirloom_weapon',
      title: 'Heirloom: Ancestral Fang',
      description:
          'A blade passed down your bloodline, forged for the strength you '
          'carry right now. Later realms outgrow it \u2014 heirlooms never '
          'outgrow the climb.',
      kind: 'gear',
      priceLabel: '\$3.99',
    ),
    StoreProduct(
      id: 'heirloom_armor',
      title: 'Heirloom: Ancestral Mantle',
      description:
          'Woven wards of your lineage, fitted to the moment you receive '
          'them.',
      kind: 'gear',
      priceLabel: '\$3.99',
    ),
    StoreProduct(
      id: 'heirloom_amulet',
      title: 'Heirloom: Ancestral Seal',
      description:
          'A seal of the first ancestor of your line \u2014 it lends its '
          'strength to both blade and ward.',
      kind: 'gear',
      priceLabel: '\$3.99',
    ),
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

  static const Duration baseOfflineCap = Duration(hours: 8);

  static Duration offlineCapFor(List<String> ownedStoreItems) {
    if (ownedStoreItems.contains('offline_24h') ||
        ownedStoreItems.contains('immortal_pack')) {
      return const Duration(hours: 24);
    }
    if (ownedStoreItems.contains('offline_12h')) {
      return const Duration(hours: 12);
    }
    return baseOfflineCap;
  }

  static const double heirloomPowerBase = 55.0;

  static double heirloomPower(int realmIndex) =>
      heirloomPowerBase * pow(1.8, realmIndex);

  static const List<String> heirloomProductIds = [
    'heirloom_weapon',
    'heirloom_armor',
    'heirloom_amulet',
  ];

  static const List<String> themeProductIds = [
    'theme_celestial_gold',
    'theme_ember',
    'theme_ashen',
    'theme_moonveil',
  ];

  static Equipment? mintedGearFor(String productId, int realmIndex) {
    final power = heirloomPower(realmIndex);
    switch (productId) {
      case 'heirloom_weapon':
        return Equipment(
          name: 'Ancestral Fang',
          slot: EquipmentSlot.weapon,
          grade: 4,
          power: power,
        );
      case 'heirloom_armor':
        return Equipment(
          name: 'Ancestral Mantle',
          slot: EquipmentSlot.armor,
          grade: 4,
          power: power,
        );
      case 'heirloom_amulet':
        return Equipment(
          name: 'Ancestral Seal',
          slot: EquipmentSlot.amulet,
          grade: 4,
          power: power,
        );
      default:
        return null;
    }
  }

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
