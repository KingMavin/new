import 'package:immortal_path/game/engine/encounter_engine.dart';
import 'package:immortal_path/audio/audio_gateway.dart';

class MusicDirector {
  const MusicDirector._();

  static MusicTrack trackFor({
    required bool encounterActive,
    required EncounterKind? kind,
    required int tabIndex,
  }) {
    if (encounterActive) {
      switch (kind) {
        case EncounterKind.tournament:
          return MusicTrack.tournament;
        case EncounterKind.war:
          return MusicTrack.war;
        case EncounterKind.hunt:
          return MusicTrack.exploration;
        case null:
          break;
      }
    }
    if (tabIndex == 1) return MusicTrack.exploration;
    return MusicTrack.cultivation;
  }
}
