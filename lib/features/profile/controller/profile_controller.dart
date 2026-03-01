import 'package:smart_parking_ble/app/helpers/errors/error_mapper.dart';
import 'package:smart_parking_ble/app/helpers/toast/app_toast.dart';
import 'package:smart_parking_ble/features/profile/model/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repo/profile_repo.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile?>(
      ProfileController.new,
    );

class ProfileController extends AsyncNotifier<UserProfile?> {
  UserProfile? get profile => state.value;

  ProfileRepo get _profileRepo => ref.read(profileRepoProvider);

  @override
  Future<UserProfile?> build() async {
    ref.watch(profileRepoProvider);
    try {
      return await _profileRepo.getProfile();
    } catch (e, s) {
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
      state = AsyncValue.error(e, s);
      return null;
    }
  }

  Future<void> refreshProfileLocal(String uid) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _profileRepo.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<UserProfile?> readSyncProfile(String uid) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _profileRepo.readSyncProfile();
      state = AsyncValue.data(profile);
      return profile;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
      return null;
    }
  }

  Future<void> createNewUserProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      await _profileRepo.createNewUserProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    final UserProfile? oldProfile = state.value;

    state = const AsyncValue.loading();
    try {
      await _profileRepo.updateProfile(profile, oldProfile);
      state = AsyncValue.data(profile);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<void> deleteProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _profileRepo.deleteProfile(userId);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      AppToast.error(ErrorMapper.instance.getErrorMessage(e, s));
    }
  }

  Future<UserProfile?> getAnyProfileByUid(String uid) async {
    return _profileRepo.getAnyProfileByUid(uid);
  }

  Future<bool> isUserNameExists(String username) async {
    return _profileRepo.isUserNameExists(username);
  }
}
