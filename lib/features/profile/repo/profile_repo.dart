import 'package:smart_parking_ble/features/profile/data_sources/profile_cache_service.dart';
import 'package:smart_parking_ble/features/profile/data_sources/profile_online_service.dart';
import 'package:smart_parking_ble/features/profile/model/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/helpers/info/logging.dart';
import '../../../app/helpers/utile/compare_dates.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/model/app_user.dart';
import '../model/user_profile_diff_extention.dart';

final profileRepoProvider = Provider<ProfileRepo>((ref) {
  final hiveService = ref.watch(profileCacheServiceProvider);
  final firestoreService = ref.watch(firestoreProfileServiceProvider);
  final authController = ref.watch(authControllerProvider);
  return ProfileRepo(hiveService, firestoreService, authController);
});

class ProfileRepo {
  final HiveProfileService _hiveService;
  final FirestoreProfileService _firestoreService;
  final AsyncValue _authController;

  ProfileRepo(this._hiveService, this._firestoreService, this._authController);

  Future<UserProfile?> getProfile() async {
    final AppUser? user = _authController.value;
    if (user == null) {
      return null;
    }
    return _hiveService.getProfile(user.uid);
  }

  Future<UserProfile?> readSyncProfile() async {
    final AppUser? user = _authController.value;
    if (user == null) {
      return null;
    }

    final DateTime? dbT = await _firestoreService.getProfileLastUpdated(
      user.uid,
    );
    final DateTime? localT = _hiveService.getLastUpdated(user.uid);
    final Duration diff = DateTime.now().difference(localT ?? DateTime.now());
    final days = diff.inDays;

    if (compareDatesIsEqual(dbT, localT) && localT != null && days < 30) {
      final data = _hiveService.getProfile(user.uid);
      return data;
    }

    final profile = await _firestoreService.getUserProfile(user.uid, dbT);
    if (profile != null) {
      if (dbT == null) {
        await _firestoreService.updateProfileLastUpdated(
          user.uid,
          profile.lastUpdated,
        );
      }
      await _hiveService.saveProfile(profile);
      return profile;
    }
    await _hiveService.clearAll();
    return null;
  }

  Future<void> createNewUserProfile(UserProfile profile) async {
    if (profile.username == null) {
      throw Exception('Username already exists');
    }
    await _firestoreService.createUserProfile(profile);
    await _firestoreService.createUserName(profile.username!, profile.id);
    await _hiveService.saveProfile(profile);
  }

  Future<void> updateProfile(
    UserProfile profile,
    UserProfile? oldProfile,
  ) async {
    if (oldProfile == null) {
      return;
    }
    if (oldProfile.diff(profile).isEmpty) {
      return;
    }
    logApp('updating profile');
    await _firestoreService.updateUserProfile(
      profile.id,
      oldProfile.diff(profile),
      profile.lastUpdated,
    );
    await _hiveService.saveProfile(profile);
  }

  Future<void> deleteProfile(String userId) async {
    await _hiveService.clearAll();
    await _firestoreService.deleteUserProfile(userId);
  }

  Future<UserProfile?> getAnyProfileByUid(String uid) async {
    final profile = _hiveService.getProfile(uid);
    if (profile != null) {
      return profile;
    }
    logApp('profile not found in hive cache , trying firebase');
    final onlineProfile = await _firestoreService.getUserProfile(uid, null);
    if (onlineProfile != null) {
      await _hiveService.saveProfile(onlineProfile);
      return onlineProfile;
    }
    return null;
  }

  Future<bool> isUserNameExists(String username) async {
    return await _firestoreService.isUserNameExists(username);
  }


}
