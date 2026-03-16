class RealParkingUnit {
  final String mac;
  final String label;
  final String status;
  final String linkedTo;

  RealParkingUnit({
    required this.mac,
    required this.label,
    required this.status,
    required this.linkedTo,
  });

  factory RealParkingUnit.fromJson(String mac, Map data) {
    return RealParkingUnit(
      mac: mac,
      label: data['label'] ?? '',
      status: data['status'] ?? 'unknown',
      linkedTo: data['linkedTo'] ?? '',
    );
  }
}
