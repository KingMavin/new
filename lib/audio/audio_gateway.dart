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
}

class SilentAudioGateway implements AudioGateway {
  const SilentAudioGateway();

  @override
  bool get isConfigured => false;

  @override
  void play(SoundEffect effect) {}
}
