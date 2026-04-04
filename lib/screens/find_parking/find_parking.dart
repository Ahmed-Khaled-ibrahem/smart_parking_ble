import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../admin/real_parking_slot.dart';
import 'navigate_to_parking.dart';

enum SortType { entrance, exit, gate1, gate2 }

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
    }
  }
}


class AvailableParkingScreen extends StatefulWidget {
  const AvailableParkingScreen({super.key});

  @override
  State<AvailableParkingScreen> createState() => _AvailableParkingScreenState();
}

class _AvailableParkingScreenState extends State<AvailableParkingScreen> {
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFD8EAD3);

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
      case 'A': blockX = 0; blockY = 0; break;
      case 'B': blockX = 1; blockY = 0; break;
      case 'C': blockX = 0; blockY = 1; break;
      case 'D': blockX = 1; blockY = 1; break;
      default: return const Offset(0, 0);
    }
    
    final colInBlock = i ~/ 5;
    final rowInBlock = i % 5;
    
    final globalCol = blockX * 2 + colInBlock;
    final globalRow = blockY * 5 + rowInBlock;
    
    return Offset(globalCol.toDouble(), globalRow.toDouble());
  }

  double _getDistance(String label, SortType sortType) {
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
    }
    return (pos - target).distance;
  }

  Stream<List<RealParkingUnit>>? _unitsStream;

  @override
  void initState() {
    super.initState();
    _unitsStream = streamUnits();
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: primaryGreen,
                        size: 24,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.transparent,
                    child: Image.asset('assets/images/logo/logo.png'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MAWQIFI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ─────────────────────────────────────────────
            StreamBuilder<List<RealParkingUnit>>(
              stream: _unitsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final spots = snapshot.data!;

                if (spots.isEmpty) {
                  return const _NoSpotsView();
                }

                spots.sort((a, b) {
                  final distA = _getDistance(a.label, _sortType);
                  final distB = _getDistance(b.label, _sortType);
                  return distA.compareTo(distB);
                });

                return Expanded(
                  child: _SpotsAvailableView(
                    spots: spots,
                    sortType: _sortType,
                    onSortChanged: (type) {
                      setState(() {
                        _sortType = type;
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
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
  final ValueChanged<SortType> onSortChanged;

  const _SpotsAvailableView({
    required this.spots,
    required this.sortType,
    required this.onSortChanged,
  });

  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color chipGreen = Color(0xFF52796F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),

          // Title
          const Center(
            child: Text(
              'AVAILABLE PARKING',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sort chip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PopupMenuButton<SortType>(
                initialValue: sortType,
                onSelected: onSortChanged,
                itemBuilder: (context) {
                  return SortType.values.map((type) {
                    return PopupMenuItem<SortType>(
                      value: type,
                      child: Text('CLOSEST TO ${type.displayName}'),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: chipGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SORTED BY: CLOSEST TO ${sortType.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Spots card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: cardGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: spots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final spot = spots[index];
                  return _ParkingSpotRow(spot: spot);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ParkingSpotRow extends StatelessWidget {
  final RealParkingUnit spot;

  const _ParkingSpotRow({required this.spot});

  static const Color primaryGreen = Color(0xFF2D6A4F);

  bool get isFree => spot.status == 'free';

  bool get isBooked =>
      DateTime.now().toUtc().difference(spot.bookedAt).inMinutes <= 10;

  bool get bookedByMe =>
      spot.bookedBy == FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final bool canNavigate = isFree
            ? (isBooked ? (bookedByMe ? (true) : (false)) : (true))
            : (false);
        if (canNavigate) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ParkingNavigationScreen(slotId: spot.label);
              },
            ),
          );
        }
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Spot ID
            Text(
              spot.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            // Status
            if (isBooked) ...[
              const Text(
                'RESERVED',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  letterSpacing: 1,
                ),
              ),
              if (bookedByMe)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.chevron_right, color: primaryGreen, size: 22),
                  ],
                ),
            ] else if (isFree) ...[
              const Text(
                'FREE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.chevron_right, color: primaryGreen, size: 22),
                ],
              ),
            ] else ...[
              const Text(
                'OCCUPIED',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
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

  static const Color primaryGreen = Color(0xFF2D6A4F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),

          // Title
          const Center(
            child: Text(
              'AVAILABLE PARKING',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const Spacer(),

          // Sorry message
          const Text(
            'SORRY,\nTHERE IS NO\nAVAILABLE PARKING\nSPOTS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              height: 1.3,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 40),

          // HOME button
          SizedBox(
            width: 160,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.maybePop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: const Text(
                'HOME',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
