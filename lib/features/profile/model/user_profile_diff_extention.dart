import 'package:smart_parking_ble/features/profile/model/user_profile.dart';

extension UserProfileDiff on UserProfile {
  Map<String, dynamic> diff(UserProfile? other) {
    final Map<String, dynamic> changes = {};

    if (name != other?.name) {
      changes['name'] = other?.name;
    }

    if (username != other?.username) {
      changes['username'] = other?.username;
    }

    if (email != other?.email) {
      changes['email'] = other?.email;
    }

    if (imageProfile != other?.imageProfile) {
      changes['imageProfile'] = other?.imageProfile;
    }

    if (role != other?.role) {
      changes['role'] = other?.role.name;
    }

    if (gender != other?.gender) {
      changes['gender'] = other?.gender.name;
    }

    if(fcmToken != other?.fcmToken){
      changes['fcmToken'] = other?.fcmToken;
    }

    // createdAt is immutable → ignore
    // id is immutable → ignore

    return changes;
  }
}
