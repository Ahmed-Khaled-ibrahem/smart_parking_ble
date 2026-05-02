import 'package:flutter/material.dart';
import 'package:smart_parking_ble/screens/admin/parking_area_selector.dart';

class AreaConfigurationScreen extends StatefulWidget {
  final String areaName;

  const AreaConfigurationScreen({super.key, required this.areaName});

  @override
  State<AreaConfigurationScreen> createState() =>
      _AreaConfigurationScreenState();
}

class _AreaConfigurationScreenState extends State<AreaConfigurationScreen> {
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AREA CONFIGURATION',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: mutedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: g3.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.areaName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: g2,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF40C074),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: g3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // — Instructions —
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: g5.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: g5.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.touch_app_rounded,
                              size: 16,
                              color: g2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap a slot to link it with a parking unit. Tap again to unlink.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: mutedText.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // — Parking Lot —
                  Expanded(
                    child: ParkingScreenAdmin(),
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
