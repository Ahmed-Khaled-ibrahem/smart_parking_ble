import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_profile.dart';
import '../repo/profile_repo.dart';

final anyProfileProvider = FutureProvider.family<UserProfile?, String>((
  ref,
  uid,
) async {
  final repo = ref.read(profileRepoProvider);
  return repo.getAnyProfileByUid(uid);
});
