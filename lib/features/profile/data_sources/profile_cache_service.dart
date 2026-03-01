import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../app/const/hive_box_names.dart';
import '../model/user_profile.dart';

final profileCacheServiceProvider = Provider<HiveProfileService>((ref) {
  return HiveProfileService();
});

class HiveProfileService {
  static const String _boxName = HiveBoxNames.profile;
  late final Box<UserProfile> _box;

  Future<void> init() async {
    try {
      _box = await Hive.openBox<UserProfile>(_boxName);
    } catch (e) {
      await Hive.deleteBoxFromDisk(_boxName);
      _box = await Hive.openBox<UserProfile>(_boxName);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    final hiveProfile = profile;
    await _box.put(profile.id, hiveProfile);
  }

  UserProfile? getProfile(String uid)  {
    final hiveProfile = _box.get(uid);
    return hiveProfile;
  }

  DateTime? getLastUpdated(String uid)  {
    return _box.get(uid)?.lastUpdated;
  }

  Future<void> clearProfile(String uid) async {
    await _box.delete(uid);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
