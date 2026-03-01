import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final int version;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    this.version = 1,
  });

  bool isSameUser(AppUser? other) {
    return uid == other?.uid &&
        email == other?.email &&
        displayName == other?.displayName &&
        photoURL == other?.photoURL &&
        emailVerified == other?.emailVerified &&
        version == other?.version;
  }

  AppUser copyWith({
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    int? version,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      version: version ?? this.version,
    );
  }
}

extension FirebaseUserMapper on User {
  AppUser toAppUser() {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      emailVerified: emailVerified,
      version: 1,
    );
  }
}