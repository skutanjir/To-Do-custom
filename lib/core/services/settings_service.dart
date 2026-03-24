// lib/core/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SettingsService extends ChangeNotifier {
  static const String _keyJarvisVoiceEnabled = 'is_jarvis_voice_enabled';
  static const String _keyJarvisGender = 'jarvis_gender';
  
  final SharedPreferences _prefs;
  
  bool _isJarvisVoiceEnabled;
  bool get isJarvisVoiceEnabled => _isJarvisVoiceEnabled;

  String _jarvisGender;
  String get jarvisGender => _jarvisGender;

  SettingsService(this._prefs) 
    : _isJarvisVoiceEnabled = _prefs.getBool(_keyJarvisVoiceEnabled) ?? true,
      _jarvisGender = _prefs.getString(_keyJarvisGender) ?? 'male' {
    debugPrint('SettingsService: Initialized. VoiceEnabled=$_isJarvisVoiceEnabled, Gender=$_jarvisGender');
  }

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  Future<void> setJarvisVoiceEnabled(bool enabled) async {
    if (_isJarvisVoiceEnabled == enabled) return;
    _isJarvisVoiceEnabled = enabled;
    await _prefs.setBool(_keyJarvisVoiceEnabled, enabled);
    notifyListeners();
  }

  Future<void> setJarvisGender(String gender) async {
    debugPrint('SettingsService.setJarvisGender called: current=$_jarvisGender, new=$gender');
    if (_jarvisGender == gender) {
      debugPrint('SettingsService: Gender unchanged, skipping.');
      return;
    }
    _jarvisGender = gender;
    await _prefs.setString(_keyJarvisGender, gender);
    debugPrint('SettingsService: Gender saved as $gender. Notifying listeners...');
    notifyListeners();
  }
}
