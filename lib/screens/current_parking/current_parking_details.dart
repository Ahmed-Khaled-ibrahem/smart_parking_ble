import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_parking_ble/screens/current_parking/timer_widget.dart';
import '../../model/profile.dart';
import '../../providers/profile.dart';

class CurrentParkingScreen extends ConsumerWidget {
  const CurrentParkingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color primaryGreen = Color(0xFF2D5A47);
    const Color lightGreenBg = Color(0xFFD1E0D7);
    const Color darkGreenBtn = Color(0xFF1E4D3B);

    final CurrentParking? currentParking = ref
        .watch(profileProvider)
        ?.currentParking;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Color(0xFFD8EAD3),
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
                    // Logo Icon
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

              const SizedBox(height: 24),
              const Text(
                'CURRENT PARKING',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              // Parking Inf Card
              currentParking == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_parking, size: 200),
                        const Text(
                          'No Current Parking',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Save Parking to see it here',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: lightGreenBg,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                InfoRow(
                                  label: 'SAVED PARKING',
                                  value: currentParking.parkingId,
                                ),
                                SizedBox(height: 8),
                                InfoRow(
                                  label: 'PARKING AREA',
                                  value: currentParking.parkingAreaId,
                                ),
                                SizedBox(height: 8),
                                InfoRow(
                                  label: 'PARKED AT',
                                  value: currentParking.parkedAt
                                      .toString()
                                      .split(' ')[0],
                                ),
                                SizedBox(height: 8),
                                InfoRow(
                                  label: 'Time',
                                  value: currentParking.parkedAt
                                      .toString()
                                      .split(' ')[1]
                                      .split('.')[0],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SessionTimerWidget(),
                        const SizedBox(height: 35),
                        // Guide Me Back Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // navigate to guide me back screen
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/navigate_back');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreenBtn,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'GUIDE ME BACK',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
