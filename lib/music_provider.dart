import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_music_service.dart';

final musicProvider = StateNotifierProvider<MusicNotifier, bool>((ref) {
  return MusicNotifier();
});

class MusicNotifier extends StateNotifier<bool> {
  MusicNotifier() : super(true) {
    _loadMusicPreference();
  }

  static const String _musicKey = 'music_enabled';

  Future<void> _loadMusicPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_musicKey) ?? true;
    state = enabled;
    await BackgroundMusicService.instance.setEnabled(enabled);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_musicKey, enabled);
    await BackgroundMusicService.instance.setEnabled(enabled);
  }

  Future<void> toggle() async {
    await setEnabled(!state);
  }
}
