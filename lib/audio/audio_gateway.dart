enum MusicTrack { none, cultivation, exploration, tournament, war }

enum SoundEffect {
  breakthrough,
  tribulationCleared,
  battleWon,
  forgeStruck,
  eventChime,
  acquisition,
  ledgerClaimed,
}

abstract class AudioGateway {
  bool get isConfigured;
  void play(SoundEffect effect);
  void setMusic(MusicTrack track);
  void dispose();
}

class SilentAudioGateway implements AudioGateway {
  const SilentAudioGateway();

  @override
  bool get isConfigured => false;

  @override
  void play(SoundEffect effect) {}

  @override
  void setMusic(MusicTrack track) {}

  @override
  void dispose() {}
}
