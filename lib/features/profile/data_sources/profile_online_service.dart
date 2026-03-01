import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_profile.dart';

final firestoreProfileServiceProvider = Provider<FirestoreProfileService>((
  ref,
) {
  return FirestoreProfileService();
});

class FirestoreProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference _profiles;
  late final CollectionReference _usernames;

  static const String _profilesCollection = 'profiles';
  static const String _usernamesCollection = 'usernames';

  FirestoreProfileService() {
    _profiles = _firestore.collection(_profilesCollection);
    _usernames = _firestore.collection(_usernamesCollection);
  }

  Future<void> createUserProfile(UserProfile profile) async {
    logApp('setting new profile');
    await _profiles
        .doc(profile.id)
        .set(profile.toJson(), SetOptions(merge: false));
    await updateProfileLastUpdated(profile.id, profile.lastUpdated);
  }

  Future<UserProfile?> getUserProfile(
    String userId,
    DateTime? lastUpdated,
  ) async {
    logApp('requesting profile data');
    final doc = await _profiles.doc(userId).get();
    if (!doc.exists) return null;
    final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;
    return UserProfile.fromJson(data).copyWith(lastUpdated: lastUpdated);
  }

  Future<DateTime?> getProfileLastUpdated(String userId) async {
    logApp('requesting profile last updated');
    final doc = await _profiles
        .doc(userId)
        .collection('timestamp')
        .doc('lastUpdated')
        .get();
    if (!doc.exists) return null;
    final Map<String, dynamic>? data = doc.data();
    return (data?['lastUpdated'] as Timestamp?)?.toDate();
  }

  Future<void> updateProfileLastUpdated(
    String userId,
    DateTime? lastUpdated,
  ) async {
    logApp('updating profile last updated');
    await _profiles.doc(userId).collection('timestamp').doc('lastUpdated').set({
      'lastUpdated': lastUpdated,
    });
  }

  // Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map profile,
    DateTime? lastUpdated,
  ) async {
    await _profiles.doc(userId).set(profile, SetOptions(merge: true));
    await updateProfileLastUpdated(userId, lastUpdated);
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    logApp('deleting profile');
    await _profiles.doc(userId).delete();
  }

  Future<bool> isUserNameExists(String username) async {
    final doc = await _usernames.doc(username).get();
    return doc.exists;
  }

  Future<void> createUserName(String username, String uid) async {
    await _usernames.doc(username).set({
      'username': username,
      'uid': uid,
      'createdAt': Timestamp.now(),
    });
  }
}
