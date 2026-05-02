import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../admin/real_parking_slot.dart';
import 'navigate_to_parking.dart';

enum SortType { entrance, exit, gate1, gate2, myLocation }

extension SortTypeExtension on SortType {
  String get displayName {
    switch (this) {
      case SortType.entrance:
        return 'ENTRANCE';
      case SortType.exit:
        return 'EXIT';
      case SortType.gate1:
        return 'GATE 1';
      case SortType.gate2:
        return 'GATE 2';
      case SortType.myLocation:
        return 'MY LOCATION';
    }
  }
}

class AvailableParkingScreen extends StatefulWidget {
  const AvailableParkingScreen({super.key});

  @override
  State<AvailableParkingScreen> createState() => _AvailableParkingScreenState();
}

class _AvailableParkingScreenState extends State<AvailableParkingScreen> {
  // — Color palette (matching home screen) —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  SortType _sortType = SortType.entrance;

  Offset _getSlotPosition(String label) {
    if (label.isEmpty) return const Offset(0, 0);
    final block = label[0].toUpperCase();
    final indexStr = label.substring(1);
    final index = int.tryParse(indexStr) ?? 1;
    final i = (index - 1).clamp(0, 9);

    int blockX = 0;
    int blockY = 0;
    switch (block) {
      case 'A':
        blockX = 0;
        blockY = 0;
        break;
      case 'B':
        blockX = 1;
        blockY = 0;
        break;
      case 'C':
        blockX = 0;
        blockY = 1;
        break;
      case 'D':
        blockX = 1;
        blockY = 1;
        break;
      default:
        return const Offset(0, 0);
    }

    final colInBlock = i ~/ 5;
    final rowInBlock = i % 5;

    final globalCol = blockX * 2 + colInBlock;
    final globalRow = blockY * 5 + rowInBlock;

    return Offset(globalCol.toDouble(), globalRow.toDouble());
  }

  double _getDistance(String label, SortType sortType) {
    if (sortType == SortType.myLocation) return 0; // Handled separately
    final pos = _getSlotPosition(label);
    Offset target;
    switch (sortType) {
      case SortType.entrance:
        target = const Offset(1.5, -1);
        break;
      case SortType.exit:
        target = const Offset(1.5, 10);
        break;
      case SortType.gate1:
        target = const Offset(4, 4.5);
        break;
      case SortType.gate2:
        target = const Offset(-1, 4.5);
        break;
      default:
        target = const Offset(1.5, -1);
    }
    return (pos - target).distance;
  }

  Stream<List<RealParkingUnit>>? _unitsStream;
  Map<String, double> _rssiMap = {};
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool _isScanning = false;

  void _startBleScanning() async {
    if (_isScanning) return;
    try {
      await FlutterBluePlus.adapterState.first;
      if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) return;
      setState(() => _isScanning = true);
      await FlutterBluePlus.startScan(
        timeout: null,
        continuousUpdates: true,
        androidUsesFineLocation: true,
      );
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        final now = DateTime.now();
        bool changed = false;

        for (final r in results) {
          if (now.difference(r.timeStamp).inSeconds > 4) continue;

          final deviceName = r.device.platformName.isNotEmpty
              ? r.device.platformName
              : r.advertisementData.advName;
          if (deviceName.isEmpty) continue;

          final rssi = r.rssi.toDouble();

          if (_rssiMap[deviceName] != rssi) {
            _rssiMap[deviceName] = rssi;
            changed = true;
          }
        }

        if (changed && mounted && _sortType == SortType.myLocation) {
          setState(() {});
        }
      });
    } catch (_) {}
  }

  void _stopBleScanning() {
    _scanSub?.cancel();
    _scanSub = null;
    FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  @override
  void initState() {
    super.initState();
    _unitsStream = streamUnits();
  }

  @override
  void dispose() {
    _stopBleScanning();
    super.dispose();
  }

  Stream<List<RealParkingUnit>> streamUnits() {
    final ref = FirebaseDatabase.instance.ref('units');

    return ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) return [];

      return data.entries.map((e) {
        final mac = e.key.toString();
        final unit = Map<String, dynamic>.from(e.value);

        return RealParkingUnit(
          mac: mac,
          label: unit['label'] ?? '',
          status: unit['status'] ?? '',
          linkedTo: unit['linkedTo'] ?? '',
          bookedBy: unit['bookedBy'] ?? '',
          bookedAt:
              DateTime.tryParse(unit['bookedAt'] ?? '') ??
              DateTime.now().subtract(const Duration(days: 1)),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // — Gradient top strip —
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [g5, g2, g1]),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // — Top bar —
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: lightGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: g3.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: g2,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Center(
                          child: Image.asset(
                            'assets/images/logo/logo.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'MAWQIFI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // — Body —
                  Expanded(
                    child: StreamBuilder<List<RealParkingUnit>>(
                      stream: _unitsStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final spots = snapshot.data!;

                        if (spots.isEmpty) {
                          return const _NoSpotsView();
                        }

                        spots.sort((a, b) {
                          if (_sortType == SortType.myLocation) {
                            final rssiA = _rssiMap[a.mac] ?? -999.0;
                            final rssiB = _rssiMap[b.mac] ?? -999.0;
                            // Larger RSSI means closer
                            return rssiB.compareTo(rssiA);
                          } else {
                            final distA = _getDistance(a.label, _sortType);
                            final distB = _getDistance(b.label, _sortType);
                            return distA.compareTo(distB);
                          }
                        });

                        return _SpotsAvailableView(
                          spots: spots,
                          sortType: _sortType,
                          rssiMap: _rssiMap,
                          onSortChanged: (type) {
                            setState(() {
                              _sortType = type;
                            });
                            if (type == SortType.myLocation) {
                              _startBleScanning();
                            } else {
                              _stopBleScanning();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// State 1: Spots available
// ─────────────────────────────────────────────────────────────
class _SpotsAvailableView extends StatelessWidget {
  final List<RealParkingUnit> spots;
  final SortType sortType;
  final Map<String, double> rssiMap;
  final ValueChanged<SortType> onSortChanged;

  const _SpotsAvailableView({
    required this.spots,
    required this.sortType,
    required this.rssiMap,
    required this.onSortChanged,
  });

  // — Color palette —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  @override
  Widget build(BuildContext context) {
    // Filter available spots (free or reserved by me)
    final availableSpots = spots.where((spot) {
      final isFree = spot.status == 'free';
      final isBooked =
          DateTime.now().toUtc().difference(spot.bookedAt).inMinutes <= 10;
      final bookedByMe =
          spot.bookedBy == FirebaseAuth.instance.currentUser?.uid;
      return isFree || (isBooked && bookedByMe);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'AVAILABLE PARKING',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: mutedText,
              ),
            ),
          ),

          // Sort chip
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: PopupMenuButton<SortType>(
              initialValue: sortType,
              onSelected: onSortChanged,
              itemBuilder: (context) {
                return SortType.values.map((type) {
                  return PopupMenuItem<SortType>(
                    value: type,
                    child: Text(
                      'CLOSEST TO ${type.displayName}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),
                  );
                }).toList();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: g3.withOpacity(0.12),
                  border: Border.all(color: g3.withOpacity(0.2), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort_rounded, size: 14, color: g2),
                    const SizedBox(width: 6),
                    Text(
                      'SORTED BY: ${sortType.displayName}',
                      style: const TextStyle(
                        color: g2,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: g2, size: 16),
                  ],
                ),
              ),
            ),
          ),

          // Spots list
          Expanded(
            child: availableSpots.isEmpty
                ? _buildNoAvailableSpots()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 20),
                    itemCount: availableSpots.length,
                    itemBuilder: (context, index) {
                      final spot = availableSpots[index];
                      final rssi = rssiMap[spot.mac];
                      return _ParkingSpotCard(spot: spot, rssi: rssi);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAvailableSpots() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_parking_outlined,
              size: 48,
              color: g2.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Spots Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All parking spots are currently occupied',
            style: TextStyle(fontSize: 12, color: mutedText.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _ParkingSpotCard extends StatelessWidget {
  final RealParkingUnit spot;
  final double? rssi;

  const _ParkingSpotCard({required this.spot, this.rssi});

  // — Color palette —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  bool get isFree => spot.status == 'free';

  bool get isBooked =>
      DateTime.now().toUtc().difference(spot.bookedAt).inMinutes <= 10;

  bool get bookedByMe =>
      spot.bookedBy == FirebaseAuth.instance.currentUser?.uid;

  String get _blockLetter =>
      spot.label.isNotEmpty ? spot.label[0].toUpperCase() : '';

  Color get _blockColor {
    switch (_blockLetter) {
      case 'A':
        return const Color(0xFF40916C);
      case 'B':
        return const Color(0xFF2D6A4F);
      case 'C':
        return const Color(0xFF74C69D);
      case 'D':
        return const Color(0xFF1B4332);
      default:
        return g2;
    }
  }

  String _getProximityText() {
    if (rssi == null) return '';
    if (rssi! > -50) return 'Very Close';
    if (rssi! > -65) return 'Nearby';
    if (rssi! > -80) return 'Moderate';
    return 'Far';
  }

  @override
  Widget build(BuildContext context) {
    final bool canNavigate = isFree
        ? (isBooked ? (bookedByMe ? true : false) : true)
        : false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: canNavigate
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ParkingNavigationScreen(slotId: spot.label);
                    },
                  ),
                );
              }
            : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: canNavigate
                  ? g3.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: g2.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Spot avatar with block color
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_blockColor, _blockColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _blockColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _blockLetter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      Text(
                        'BLK',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Spot label
                      Row(
                        children: [
                          Text(
                            'Spot ${spot.label}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (bookedByMe)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: g5.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: g3,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Status badge
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? bookedByMe
                                        ? g5
                                        : const Color(0xFFFFA000)
                                  : const Color(0xFF40C074),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isBooked
                                ? bookedByMe
                                      ? 'Reserved by you'
                                      : 'Reserved'
                                : 'Available',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isBooked
                                  ? bookedByMe
                                        ? g3
                                        : const Color(0xFFFFA000)
                                  : g2,
                            ),
                          ),
                          if (rssi != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: mutedText.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.bluetooth_rounded,
                              size: 10,
                              color: mutedText.withOpacity(0.6),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _getProximityText(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: mutedText.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow or lock
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: canNavigate
                        ? cardGreen
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    canNavigate
                        ? Icons.arrow_forward_rounded
                        : Icons.lock_outline,
                    size: 14,
                    color: canNavigate ? g2 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// State 2: No spots available
// ─────────────────────────────────────────────────────────────
class _NoSpotsView extends StatelessWidget {
  const _NoSpotsView();

  // — Color palette —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'AVAILABLE PARKING',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: mutedText,
              ),
            ),
          ),

          const Spacer(),

          // Empty state illustration
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_parking_outlined,
                size: 70,
                color: g2.withOpacity(0.5),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Message
          const Center(
            child: Text(
              'No Available Spots',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: darkText,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              'All parking spots are currently occupied.\nPlease check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: mutedText.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // HOME button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [g1, g2],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: g2.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'BACK TO HOME',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
