// only read&write. 딴거 일체 관여 X
import 'package:shared_preferences/shared_preferences.dart';

class PlaybackConfigRepository {
  static const String _muted = "muted";
  static const String _autoplay = "autoplay";

  final SharedPreferences _preferences;

  PlaybackConfigRepository(this._preferences);

  /* 1. Write(Setting) data (disk에 data저장) */
  Future<void> setMuted(bool value) async {
    _preferences.setBool(_muted, value);
  }

  Future<void> setAutoplay(bool value) async {
    _preferences.setBool(_autoplay, value);
  }

  /* Reading data */
  bool isMuted() {
    return _preferences.getBool(_muted) ?? false;
  }

  bool isAutoplay() {
    return _preferences.getBool(_autoplay) ?? false;
  }
}
