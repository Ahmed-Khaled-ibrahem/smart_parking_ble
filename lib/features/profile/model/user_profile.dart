import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
part 'user_profile.g.dart';

@HiveType(typeId: 11)
enum UserRole {
  @HiveField(0)
  admin,

  @HiveField(1)
  engineer,

  @HiveField(2)
  client,
}

@HiveType(typeId: 12)
enum Gender {
  @HiveField(0)
  male,

  @HiveField(1)
  female,
}

@HiveType(typeId: 13)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? username;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? imageProfile;

  @HiveField(5)
  final String? fcmToken;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? dateOfBirth;

  @HiveField(8)
  final UserRole role;

  @HiveField(9)
  final Gender gender;

  @HiveField(10)
  final DateTime lastUpdated;

  UserProfile({
    required this.id,
    this.name,
    this.username,
    required this.email,
    this.imageProfile,
    this.fcmToken,
    required this.createdAt,
    this.dateOfBirth,
    required this.role,
    required this.gender,
    required this.lastUpdated,
  });

  bool get isProfileComplete {
    return name != null && dateOfBirth != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'imageProfile': imageProfile,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      'role': role.name,
      'gender': gender.name,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String,
      imageProfile: json['imageProfile'] as String?,
      fcmToken: json['fcmToken'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      dateOfBirth: (json['dateOfBirth'] as Timestamp?)?.toDate(),
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  UserProfile copyWith({
    String? name,
    String? username,
    String? email,
    String? imageProfile,
    String? fcmToken,
    DateTime? dateOfBirth,
    UserRole? role,
    Gender? gender,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      imageProfile: imageProfile ?? this.imageProfile,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}