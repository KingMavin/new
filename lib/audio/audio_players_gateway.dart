import 'package:audioplayers/audioplayers.dart';

import 'package:immortal_path/audio/audio_gateway.dart';

class AudioPlayersGateway implements AudioGateway {
  AudioPlayersGateway();

  static const Map<MusicTrack, String> _musicAssets = {
    MusicTrack.cultivation: 'audio/music_cultivation.wav',
    MusicTrack.exploration: 'audio/music_exploration.wav',
    MusicTrack.tournament: 'audio/music_tournament.wav',
    MusicTrack.war: 'audio/music_war.wav',
  };

  static const Map<SoundEffect, String> _effectAssets = {
    SoundEffect.breakthrough: 'audio/sfx_breakthrough.wav',
    SoundEffect.tribulationCleared: 'audio/sfx_tribulation.wav',
    SoundEffect.battleWon: 'audio/sfx_battle.wav',
    SoundEffect.forgeStruck: 'audio/sfx_forge.wav',
    SoundEffect.eventChime: 'audio/sfx_event.wav',
    SoundEffect.acquisition: 'audio/sfx_acquire.wav',
    SoundEffect.ledgerClaimed: 'audio/sfx_ledger.wav',
  };

  late final AudioPlayer _music = AudioPlayer();
  late final AudioPlayer _effects = AudioPlayer();
  MusicTrack _current = MusicTrack.none;
  bool _failed = false;

  @override
  bool get isConfigured => true;

  void _safe(Future<void> Function() action) {
    if (_failed) return;
    action().then(
      (_) {},
      onError: (Object error) {
        _failed = true;
      },
    );
  }

  @override
  void setMusic(MusicTrack track) {
    if (track == _current) return;
    final asset = _musicAssets[track];
    _current = track;
    if (asset == null) {
      _safe(() => _music.stop());
      return;
    }
    _safe(() async {
      await _music.stop();
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setSource(AssetSource(asset));
      await _music.resume();
    });
  }

  @override
  void play(SoundEffect effect) {
    final asset = _effectAssets[effect];
    if (asset == null) return;
    _safe(() async {
      await _effects.stop();
      await _effects.play(AssetSource(asset));
    });
  }

  @override
  void dispose() {
    _safe(() async {
      await _music.dispose();
      await _effects.dispose();
    });
  }
}
