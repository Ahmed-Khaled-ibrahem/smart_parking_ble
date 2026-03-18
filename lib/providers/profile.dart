import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/profile.dart';

class ProfileNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => null;

  void setProfile(Profile profile) {
    state = profile;
  }

  void removeParking() {
    final current = state;
    if (current == null) return;
    state = Profile(
      uid: current.uid,
      name: current.name,
      email: current.email,
      role: current.role,
      parkingHistory: current.parkingHistory,
      createdAt: current.createdAt,
      currentParking: null,
    );
  }

  void update({
    String? name,
    String? email,
    UserRole? role,
    List<ParkingHistory>? parkingHistory,
    DateTime? createdAt,
    CurrentParking? currentParking,
  }) {
    final current = state;
    if (current == null) return;

    state = Profile(
      uid: current.uid,
      name: name ?? current.name,
      email: email ?? current.email,
      role: role ?? current.role,
      parkingHistory: parkingHistory ?? current.parkingHistory,
      createdAt: current.createdAt,
      currentParking: currentParking ?? current.currentParking,
    );
  }

  void clear() => state = null;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final profileProvider = NotifierProvider<ProfileNotifier, Profile?>(
  ProfileNotifier.new,
);

final profileRoleProvider = Provider<UserRole?>(
  (ref) => ref.watch(profileProvider)?.role,
);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(profileProvider) != null,
);
