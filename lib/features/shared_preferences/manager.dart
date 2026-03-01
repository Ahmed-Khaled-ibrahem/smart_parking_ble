import 'package:smart_parking_ble/features/shared_preferences/pref_helper.dart';
import 'package:smart_parking_ble/features/shared_preferences/pref_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedPrefsManagerProvider = Provider<SharedPrefsManager>((ref) {
  final prefsHelper = ref.watch(prefsHelperProvider);
  return SharedPrefsManager(prefsHelper);
});

class SharedPrefsManager {
  final PrefsHelper _prefs;

  SharedPrefsManager(this._prefs);

  T? read<T>(PrefKeys key) {
    final k = key.name;

    if (T == bool) {
      return _prefs.getBool(k) as T?;
    } else if (T == int) {
      return _prefs.getInt(k) as T?;
    } else if (T == double) {
      return _prefs.getDouble(k) as T?;
    } else if (T == String) {
      return _prefs.getString(k) as T?;
    } else if (T == List<String>) {
      return _prefs.getStringList(k) as T?;
    } else {
      // to do later
      throw UnsupportedError('Type $T is not supported');
    }
  }

  Future<void> save<T>(PrefKeys key, T value) async {
    final k = key.name;

    if (T == bool) {
      await _prefs.prefs.setBool(k, value as bool);
    } else if (T == int) {
      await _prefs.prefs.setInt(k, value as int);
    } else if (T == double) {
      await _prefs.prefs.setDouble(k, value as double);
    } else if (T == String) {
      await _prefs.prefs.setString(k, value as String);
    } else if (T == List<String>) {
      await _prefs.prefs.setStringList(k, value as List<String>);
    } else {
      throw UnsupportedError('Type $T is not supported');
    }
  }
}
