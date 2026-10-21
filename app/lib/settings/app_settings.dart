import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English'),
  ukrainian('uk', 'Українська');

  const AppLanguage(this.code, this.endonym);

  final String code;
  final String endonym;

  static AppLanguage fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return english;
  }
}

class AppSettings {
  const AppSettings({required this.sound, required this.language});

  final bool sound;
  final AppLanguage language;

  static const defaults = AppSettings(sound: true, language: AppLanguage.english);

  @override
  bool operator ==(Object other) {
    return other is AppSettings && other.sound == sound && other.language == language;
  }

  @override
  int get hashCode => Object.hash(sound, language);
}

abstract class SettingsStore {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([this._settings = AppSettings.defaults]);

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}

/// Sound and language kept on the device.
class SharedPrefsSettingsStore implements SettingsStore {
  static const soundKey = 'sound';
  static const languageKey = 'language';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      sound: prefs.getBool(soundKey) ?? true,
      language: AppLanguage.fromCode(prefs.getString(languageKey)),
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundKey, settings.sound);
    await prefs.setString(languageKey, settings.language.code);
  }
}
