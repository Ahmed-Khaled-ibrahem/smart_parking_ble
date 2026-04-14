import 'dart:ui';

enum ParkingStatus { available, occupied , booked }

enum ParkingType { normal, disablePerson }

enum NavigationMode { fromEntrance, fromCurrent }

class ParkingSlot {
  final String id;
  ParkingStatus status;
  final Offset gridPosition;
  ParkingType type = ParkingType.normal;
  String? linkedToDevice;

  ParkingSlot({
    required this.id,
    required this.status,
    required this.gridPosition,
    this.type = ParkingType.normal,
    this.linkedToDevice,
  });
}

// ─────────────────────────────────────────────
//  EXTENSION HELPERS
// ─────────────────────────────────────────────
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
