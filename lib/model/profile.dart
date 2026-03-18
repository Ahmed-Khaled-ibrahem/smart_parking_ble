import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, user }

class ParkingHistory {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final double? lat;
  final double? lng;

  ParkingHistory({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'lat': lat,
      'lng': lng,
    };
  }

  factory ParkingHistory.fromJson(Map<String, dynamic> json) {
    return ParkingHistory(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: json['startTime'].toDate(),
      endTime: json['endTime'].toDate(),
      lat: json['lat'] as double,
      lng: json['lng'] as double,
    );
  }
}

class CurrentParking {
  final DateTime parkedAt;
  final String parkingId;
  final String parkingAreaId;

  CurrentParking({
    required this.parkedAt,
    required this.parkingId,
    required this.parkingAreaId,
  });

  Map<String, dynamic> toJson() {
    return {
      'parkedAt': Timestamp.fromDate(parkedAt),
      'parkingId': parkingId,
      'parkingAreaId': parkingAreaId,
    };
  }

  factory CurrentParking.fromJson(Map<String, dynamic> json) {
    return CurrentParking(
      parkedAt: json['parkedAt'].toDate(),
      parkingId: json['parkingId'] as String,
      parkingAreaId: json['parkingAreaId'] as String,
    );
  }
}

class Profile {
  final String? uid;
  final String? email;
  final String? name;
  final DateTime? createdAt;
  final UserRole? role;
  final List<ParkingHistory> parkingHistory;
  final CurrentParking? currentParking;

  Profile({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
    required this.role,
    required this.parkingHistory,
    required this.currentParking,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt!),
      'role': role!.name,
      'parkingHistory': parkingHistory.map((e) => e.toJson()).toList(),
      'currentParking': currentParking?.toJson(),
    };
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      parkingHistory: (json['parkingHistory'] as List)
          .map((e) => ParkingHistory.fromJson(e))
          .toList(),
      currentParking: json['current_parking'] == null
          ? null
          : CurrentParking.fromJson(json['current_parking']),
    );
  }
}
