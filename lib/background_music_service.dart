import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicService {
  BackgroundMusicService._internal();
  static final BackgroundMusicService instance = BackgroundMusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.3);
  }

  Future<void> play() async {
    if (!_isEnabled) return;
    await init();
    await _player.play(AssetSource('audio/background_music.mp3'));
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    if (_isEnabled) {
      await play();
    } else {
      await stop();
    }
  }
}
