import 'package:shared_preferences/shared_preferences.dart';

abstract class PersistJson {
  Future<void> saveJson(String key, String json);
  Future<String> loadJson(String key, String defaultJson);
  Future<bool> removeJson(String key);
}

class PersistJsonWithSharedPref {
  factory PersistJsonWithSharedPref() => _instance;
  PersistJsonWithSharedPref._();
  static final PersistJsonWithSharedPref _instance =
      PersistJsonWithSharedPref._();

  Future<void> saveJson(String key, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json);
  }

  Future<String> loadJson(String key, String defaultJson) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(key);

    return json ?? defaultJson;
  }

  Future<bool> removeJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
