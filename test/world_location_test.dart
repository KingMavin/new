import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/models/world_location.dart';

void main() {
  test('catalog has unique ids', () {
    final ids = WorldCatalog.locations.map((l) => l.id).toSet();
    expect(ids.length, WorldCatalog.locations.length);
  });

  test('nine standard regions map to the nine realms in order', () {
    final regions = WorldCatalog.standardLocations();
    expect(regions.length, 9);
    for (var i = 0; i < regions.length; i++) {
      expect(regions[i].requiredRealm, i);
    }
  });

  test('every location has beasts, description, and sane danger', () {
    for (final location in WorldCatalog.locations) {
      expect(location.beasts, isNotEmpty, reason: location.id);
      expect(location.description, isNotEmpty, reason: location.id);
      expect(location.dangerTier, inInclusiveRange(1, 5), reason: location.id);
      expect(
        location.spiritStoneReward,
        greaterThan(0),
        reason: location.id,
      );
    }
  });

  test('hidden locations carry discovery hints and are not raids', () {
    final hidden = WorldCatalog.locations
        .where((location) => location.isHidden)
        .toList();
    expect(hidden.length, 2);
    for (final location in hidden) {
      expect(location.discoveryHint, isNotNull, reason: location.id);
      expect(location.isRaid, isFalse, reason: location.id);
    }
  });

  test('forbidden grounds and fallen cities are raids with elite foes', () {
    final raids = WorldCatalog.locations
        .where((location) => location.isRaid)
        .toList();
    expect(raids.length, 4);
    for (final location in raids) {
      expect(location.beasts.length, 1, reason: location.id);
      final foe = location.beasts.first;
      final comparable = WorldCatalog.standardLocations()
          .firstWhere((region) => region.requiredRealm == location.requiredRealm)
          .beasts
          .first;
      expect(foe.hp, greaterThan(comparable.hp), reason: location.id);
    }
  });

  test('each race has one reputation-gated faction hall', () {
    final halls = WorldCatalog.locations
        .where((location) => location.isFactionHall)
        .toList();
    expect(halls.length, 3);
    expect(
      halls.map((location) => location.raceId).toSet(),
      {'human', 'demon', 'demi_human'},
    );
    for (final hall in halls) {
      expect(hall.requiredReputation, greaterThan(0), reason: hall.id);
      expect(hall.isRaid, isFalse, reason: hall.id);
      expect(hall.beasts.length, 1, reason: hall.id);
      expect(hall.beasts.first.hp, greaterThan(0), reason: hall.id);
      expect(
        WorldCatalog.factionLocationFor(hall.raceId!)!.id,
        hall.id,
        reason: hall.id,
      );
    }
    expect(WorldCatalog.factionLocationFor('unknown_race'), isNull);
  });

  test('faction halls are excluded from standard regions', () {
    final regions = WorldCatalog.standardLocations();
    expect(regions.length, 9);
    expect(regions.any((location) => location.isFactionHall), isFalse);
  });

  test('hiddenToDiscover respects realm gating and discovery', () {
    expect(WorldCatalog.hiddenToDiscover(0, const []), isNull);
    expect(WorldCatalog.hiddenToDiscover(3, const []), 'sword_vault');
    expect(
      WorldCatalog.hiddenToDiscover(3, const ['sword_vault']),
      isNull,
    );
    expect(
      WorldCatalog.hiddenToDiscover(5, const ['sword_vault']),
      'immortal_grotto',
    );
  });
}
