import 'package:flutter/material.dart';

class ParkingHistoryScreen extends StatelessWidget {
  const ParkingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8EAD3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF2D6A4F),
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
              'PARKING HISTORY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Sorting Dropdown/Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8BAA9B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SORTED BY: RECENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: Colors.green.shade900,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // History List Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1E0D7),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: const [
                      HistoryItem(date: '2 DEC 2025', location: 'BLACK HAT'),
                      HistoryItem(
                        date: '30 NOV 2025',
                        location: 'BOULEVARD WORLD',
                      ),
                      HistoryItem(date: '29 NOV 2025', location: 'RIYADH PARK'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryItem extends StatelessWidget {
  final String date;
  final String location;

  const HistoryItem({super.key, required this.date, required this.location});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              location,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
