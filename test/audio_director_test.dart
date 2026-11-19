import 'package:flutter_test/flutter_test.dart';

import 'package:immortal_path/audio/music_director.dart';
import 'package:immortal_path/game/engine/encounter_engine.dart';

void main() {
  test('hunt encounters play the exploration track', () {
    expect(
      MusicDirector.trackFor(
        encounterActive: true,
        kind: EncounterKind.hunt,
        tabIndex: 1,
      ),
      MusicTrack.exploration,
    );
  });

  test('tournament encounters play the tournament track', () {
    expect(
      MusicDirector.trackFor(
        encounterActive: true,
        kind: EncounterKind.tournament,
        tabIndex: 0,
      ),
      MusicTrack.tournament,
    );
  });

  test('war encounters play the war track', () {
    expect(
      MusicDirector.trackFor(
        encounterActive: true,
        kind: EncounterKind.war,
        tabIndex: 0,
      ),
      MusicTrack.war,
    );
  });

  test('the world tab plays the exploration track outside combat', () {
    expect(
      MusicDirector.trackFor(
        encounterActive: false,
        kind: EncounterKind.hunt,
        tabIndex: 1,
      ),
      MusicTrack.exploration,
    );
  });

  test('idle tabs default to the cultivation track', () {
    for (final tabIndex in [0, 2, 3, 4]) {
      expect(
        MusicDirector.trackFor(
          encounterActive: false,
          kind: null,
          tabIndex: tabIndex,
        ),
        MusicTrack.cultivation,
      );
    }
  });
}
