import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsHelperProvider = Provider<PrefsHelper>((ref) {
  return PrefsHelper();
});

class PrefsHelper {
  late SharedPreferences prefs;
  late Future isInitialized;

  PrefsHelper() {
    isInitialized = init();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> setString({required String key, required String value}) async {
    await isInitialized;
    await prefs.setString(key, value);
  }

  Future<void> setDouble({required String key, required double value}) async {
    await isInitialized;
    await prefs.setDouble(key, value);
  }

  Future<void> setInt({required String key, required int value}) async {
    await isInitialized;
    await prefs.setInt(key, value);
  }

  Future<void> setBool({required String key, required bool value}) async {
    await isInitialized;
    await prefs.setBool(key, value);
  }

  Future<void> setStringList({
    required String key,
    required List<String> value,
  }) async {
    await isInitialized;
    await prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await isInitialized;
    return prefs.getStringList(key);
  }

  Future<String?> getString(String key) async {
    await isInitialized;
    return prefs.getString(key);
  }

  Future<double?> getDouble(String key) async {
    await isInitialized;
    return prefs.getDouble(key);
  }

  Future<int?> getInt(String key) async {
    await isInitialized;
    return prefs.getInt(key);
  }

  Future<bool?> getBool(String key) async {
    await isInitialized;
    return prefs.getBool(key);
  }

  Future<void> removeKey(String key) async {
    await isInitialized;
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    await isInitialized;
    await prefs.clear();
  }
}
