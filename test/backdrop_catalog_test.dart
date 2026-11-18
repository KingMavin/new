import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/engine/event_engine.dart';
import 'package:immortal_path/game/models/world_location.dart';
import 'package:immortal_path/ui/theme/backdrops.dart';

void main() {
  group('BackdropCatalog', () {
    test('every random event has artwork', () {
      for (final event in EventEngine.catalog) {
        expect(
          BackdropCatalog.hasEvent(event.id),
          isTrue,
          reason: 'no event image for ${event.id}',
        );
      }
    });

    test('every world location has artwork', () {
      for (final location in WorldCatalog.locations) {
        final asset = BackdropCatalog.forLocation(location.id);
        expect(
          asset.endsWith('loc_${location.id}.png'),
          isTrue,
          reason: 'no location image for ${location.id}',
        );
      }
    });

    test('core screens have artwork', () {
      for (final key in [
        'home',
        'world',
        'alchemy',
        'sect',
        'dao',
        'store',
        'settings',
        'tribulation',
        'encounter',
      ]) {
        final asset = BackdropCatalog.forScreen(key);
        expect(asset, contains('screen_$key'));
      }
    });

    test('every catalogued asset exists on disk', () {
      final eventIds = EventEngine.catalog.map((e) => e.id).toList();
      final locationIds = WorldCatalog.locations.map((l) => l.id).toList();
      final checks = <String>[
        ...eventIds,
        ...locationIds,
        ...['human', 'demon', 'demi_human'],
        ...[
          'home',
          'world',
          'alchemy',
          'sect',
          'dao',
          'store',
          'settings',
          'tribulation',
          'encounter',
        ],
      ];
      for (final id in checks) {
        final asset = BackdropCatalog.hasEvent(id) || eventIds.contains(id)
            ? BackdropCatalog.forEvent(id)
            : locationIds.contains(id)
                ? BackdropCatalog.forLocation(id)
                : ['human', 'demon', 'demi_human'].contains(id)
                    ? BackdropCatalog.forStory(id)
                    : _screensContains(id)
                        ? BackdropCatalog.forScreen(id)
                        : null;
        if (asset == null) continue;
        expect(
          File(asset).existsSync(),
          isTrue,
          reason: 'missing asset file $asset',
        );
      }
    });
  });
}

bool _screensContains(String id) {
  for (final key in [
    'home',
    'world',
    'alchemy',
    'sect',
    'dao',
    'store',
    'settings',
    'tribulation',
    'encounter',
  ]) {
    if (key == id) return true;
  }
  return false;
}
