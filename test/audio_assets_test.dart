import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const musicFiles = [
  'assets/audio/music_cultivation.wav',
  'assets/audio/music_exploration.wav',
  'assets/audio/music_tournament.wav',
  'assets/audio/music_war.wav',
];

const effectFiles = [
  'assets/audio/sfx_breakthrough.wav',
  'assets/audio/sfx_tribulation.wav',
  'assets/audio/sfx_battle.wav',
  'assets/audio/sfx_forge.wav',
  'assets/audio/sfx_event.wav',
  'assets/audio/sfx_acquire.wav',
  'assets/audio/sfx_ledger.wav',
];

void main() {
  test('every music loop exists on disk with real content', () {
    for (final path in musicFiles) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path is missing');
      expect(file.lengthSync(), greaterThan(20000), reason: path);
    }
  });

  test('every sound effect exists on disk with real content', () {
    for (final path in effectFiles) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: '$path is missing');
      expect(file.lengthSync(), greaterThan(5000), reason: path);
    }
  });

  test('every wav ships as a real PCM file with a header', () {
    for (final path in [...musicFiles, ...effectFiles]) {
      final bytes = File(path).readAsBytesSync();
      expect(bytes.length, greaterThan(44), reason: path);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF', reason: path);
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE', reason: path);
    }
  });
}
