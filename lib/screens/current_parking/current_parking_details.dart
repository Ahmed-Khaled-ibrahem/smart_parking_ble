import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_parking_ble/screens/current_parking/timer_widget.dart';
import '../../model/profile.dart';
import '../../providers/profile.dart';

class CurrentParkingScreen extends ConsumerWidget {
  const CurrentParkingScreen({super.key});


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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CurrentParking? currentParking = ref
        .watch(profileProvider)
        ?.currentParking;

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
              child: SingleChildScrollView(
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
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                          // Logo Icon
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

                    // — Page Title —
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Text(
                        'CURRENT PARKING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: mutedText,
                        ),
                      ),
                    ),

                    // — Parking Content —
                    currentParking == null
                        ? _buildEmptyState()
                        : _buildParkingDetails(context, currentParking),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_parking_outlined,
                size: 60,
                color: g2.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Parking',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save a parking spot to see it here',
              style: TextStyle(
                fontSize: 12,
                color: mutedText.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingDetails(BuildContext context, CurrentParking currentParking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // — Parking Info Card —
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardGreen,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: g3.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  // Decorative circle
                  Positioned(
                    right: -30,
                    bottom: -40,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: g2.withOpacity(0.05),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: g2.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: g2.withOpacity(0.18),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.local_parking_rounded,
                                size: 20,
                                color: g2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ACTIVE SESSION',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                      color: mutedText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentParking.parkingId,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: darkText,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Status dot
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF40C074),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Info rows
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'PARKING AREA',
                          value: currentParking.parkingAreaId,
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'PARKED AT',
                          value: currentParking.parkedAt.toString().split(' ')[0],
                        ),
                        _InfoRow(
                          icon: Icons.access_time_outlined,
                          label: 'TIME',
                          value: currentParking.parkedAt
                              .toString()
                              .split(' ')[1]
                              .split('.')[0],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // — Timer Widget —
        const SessionTimerWidget(),

        const SizedBox(height: 24),

        // — Guide Me Back Button —
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/navigate_back');
            },
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
                  Icon(
                    Icons.navigation_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'GUIDE ME BACK',
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
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  static const Color g2 = Color(0xFF2D6A4F);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: g2.withOpacity(0.07),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: g2.withOpacity(0.08),
            ),
            child: Icon(
              icon,
              size: 14,
              color: g2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: mutedText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
