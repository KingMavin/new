import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/game/models/narration.dart';

const majorScreens = [
  'home',
  'world',
  'alchemy',
  'dao',
  'store',
  'sect_store',
  'tribulation',
  'encounter',
  'settings',
];

void main() {
  group('NarrationCatalog screens', () {
    test('covers every major screen', () {
      for (final screen in majorScreens) {
        expect(NarrationCatalog.hasScreen(screen), isTrue,
            reason: '$screen has no screen voice');
      }
    });

    test('sect has its own voice line', () {
      expect(NarrationCatalog.screens['sect'], isNotNull);
      expect(NarrationCatalog.screens['sect']!, isNotEmpty);
    });

    test('major screens carry at least three lines each', () {
      for (final screen in majorScreens) {
        expect(
          NarrationCatalog.screens[screen]!.length,
          greaterThanOrEqualTo(3),
          reason: '$screen needs more voice lines',
        );
      }
    });

    test('all lines are non-empty and unique within a context', () {
      for (final lines in NarrationCatalog.screens.values) {
        expect(lines, everyElement(isNotEmpty));
        expect(lines.toSet().length, lines.length);
      }
      for (final lines in NarrationCatalog.cases.values) {
        expect(lines, everyElement(isNotEmpty));
        expect(lines.toSet().length, lines.length);
      }
    });

    test('screenLine is deterministic and bounded by context size', () {
      for (final screen in NarrationCatalog.screens.keys) {
        final lines = NarrationCatalog.screens[screen]!;
        for (final seed in [0, 1, 7, 99, 1000003]) {
          final line = NarrationCatalog.screenLine(screen, seed: seed);
          expect(lines.contains(line), isTrue,
              reason: 'seed $seed picked a foreign line for $screen');
          expect(line, isNotEmpty);
        }
        expect(
          NarrationCatalog.screenLine(screen, seed: 5),
          NarrationCatalog.screenLine(screen, seed: 5),
          reason: '$screen is not deterministic',
        );
      }
    });
  });

  group('NarrationCatalog cases', () {
    test('covers every outcome moment', () {
      const expected = [
        'breakthrough_success',
        'breakthrough_failure',
        'tribulation_survived',
        'tribulation_failed',
        'tournament_victory',
        'tournament_defeat',
        'war_victory',
        'war_defeat',
        'hunt_victory',
        'hunt_defeat',
        'forge_success',
        'forge_failure',
        'promotion',
        'reincarnation',
        'ascension',
      ];
      for (final key in expected) {
        expect(NarrationCatalog.hasCase(key), isTrue,
            reason: '$key case line missing');
      }
    });

    test('every case carries at least three lines', () {
      for (final lines in NarrationCatalog.cases.values) {
        expect(lines.length, greaterThanOrEqualTo(3));
      }
    });

    test('caseLine is deterministic and falls back to empty', () {
      expect(
        NarrationCatalog.caseLine('forge_success', seed: 3),
        NarrationCatalog.caseLine('forge_success', seed: 3),
      );
      expect(NarrationCatalog.caseLine('nonexistent_case'), isEmpty);
      expect(NarrationCatalog.hasCase('nonexistent_case'), isFalse);
      expect(NarrationCatalog.screenLine('nonexistent_screen'), isEmpty);
    });
  });
}
