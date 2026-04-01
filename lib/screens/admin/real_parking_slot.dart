class RealParkingUnit {
  final String mac;
  final String label;
  final String status;
  final String linkedTo;
  final String bookedBy;
  final DateTime bookedAt;

  RealParkingUnit({
    required this.mac,
    required this.label,
    required this.status,
    required this.linkedTo,
    required this.bookedBy,
    required this.bookedAt,
  });

  factory RealParkingUnit.fromJson(String mac, Map data) {
    return RealParkingUnit(
      mac: mac,
      label: data['label'] ?? '',
      status: data['status'] ?? 'unknown',
      linkedTo: data['linkedTo'] ?? '',
      bookedBy: data['bookedBy'] ?? '',
      bookedAt:
          DateTime.tryParse(data['bookedAt'] ?? '') ??
          DateTime.now().subtract(const Duration(days: 1)),
    );
  }
}
