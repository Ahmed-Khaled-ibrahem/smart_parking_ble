import 'package:flutter/material.dart';
import 'navigate_to_parking_screen.dart';

class ParkingNavigationScreen extends StatelessWidget {
  const ParkingNavigationScreen({super.key, required this.slotId});

  final String slotId;
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFD8EAD3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
            Expanded(child: NavigateToParkingScreen(slotId: slotId)),
          ],
        ),
      ),
    );
  }
}
