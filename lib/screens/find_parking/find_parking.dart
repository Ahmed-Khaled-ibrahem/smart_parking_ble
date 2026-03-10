import 'package:flutter/material.dart';

enum ParkingStatus { free, occupied }

class ParkingSpot {
  final String id;
  final ParkingStatus status;

  const ParkingSpot({required this.id, required this.status});
}

class AvailableParkingScreen extends StatefulWidget {
  const AvailableParkingScreen({super.key});

  @override
  State<AvailableParkingScreen> createState() => _AvailableParkingScreenState();
}

class _AvailableParkingScreenState extends State<AvailableParkingScreen> {
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color chipGreen = Color(0xFF52796F);

  // Toggle this to simulate empty state
  bool _hasSpots = true;

  final List<ParkingSpot> _spots = const [
    ParkingSpot(id: 'A-01', status: ParkingStatus.free),
    ParkingSpot(id: 'A-02', status: ParkingStatus.free),
    ParkingSpot(id: 'A-03', status: ParkingStatus.occupied),
    ParkingSpot(id: 'A-04', status: ParkingStatus.free),
    ParkingSpot(id: 'A-05', status: ParkingStatus.occupied),
    ParkingSpot(id: 'A-06', status: ParkingStatus.occupied),
    ParkingSpot(id: 'A-07', status: ParkingStatus.free),
  ];

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
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
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
                  const Spacer(),
                  // Dev toggle button
                  TextButton(
                    onPressed: () => setState(() => _hasSpots = !_hasSpots),
                    child: Text(
                      _hasSpots ? 'Show Empty' : 'Show Spots',
                      style: const TextStyle(color: primaryGreen, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────
            Expanded(
              child: _hasSpots
                  ? _SpotsAvailableView(spots: _spots)
                  : const _NoSpotsView(),
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
  final List<ParkingSpot> spots;

  const _SpotsAvailableView({required this.spots});

  static const Color primaryGreen = Color(0xFF2D6A4F);
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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: chipGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SORTED BY: CLOSEST TO ENTRANCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_drop_down, color: primaryGreen, size: 22),
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
  final ParkingSpot spot;

  const _ParkingSpotRow({required this.spot});

  static const Color primaryGreen = Color(0xFF2D6A4F);

  bool get isFree => spot.status == ParkingStatus.free;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isFree) {
          Navigator.pushNamed(context, '/navigate');
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
              spot.id,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            // Status
            if (isFree) ...[
              const Text(
                'FREE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              // Double chevron arrow
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
                  color: Colors.black54,
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
