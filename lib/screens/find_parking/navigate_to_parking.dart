import 'package:flutter/material.dart';

class ParkingNavigationScreen extends StatelessWidget {
  const ParkingNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF8BAA9B),
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF004D40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'MAWQIFI',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004D40),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 36), // To balance the back button
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'NAVIGATION TO SELECTED PARKING',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Map Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      // Parking Grid Background
                      _buildParkingGrid(),

                      // Navigation Path (Arrows and Line)
                      _buildNavigationPath(),

                      // Entrance/Exit Indicators
                      Positioned(
                        left: 10,
                        top: 240,
                        child: _buildGateIndicator(Icons.arrow_back),
                      ),
                      Positioned(
                        right: 10,
                        top: 240,
                        child: _buildGateIndicator(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'SAVE MY PARKING',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGateIndicator(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Icon(icon, size: 24, color: Colors.black),
    );
  }

  Widget _buildParkingGrid() {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Top row of blocks
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildParkingBlock(hasSelected: false),
            _buildParkingBlock(hasSelected: false),
          ],
        ),
        const Spacer(),
        // Bottom row of blocks
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildParkingBlock(hasSelected: true),
            _buildParkingBlock(hasSelected: false),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildParkingBlock({bool hasSelected = false}) {
    return Container(
      width: 120,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        children: List.generate(4, (index) {
          bool isSelectedSpot = hasSelected && index == 0;
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < 3 ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: isSelectedSpot
                        ? _buildSelectedSpot()
                        : _buildOccupiedSpot(index % 2 == 0),
                  ),
                  Container(width: 1, color: Colors.grey.shade300),
                  Expanded(
                    child: _buildOccupiedSpot(index % 3 == 0),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOccupiedSpot(bool occupied) {
    if (!occupied) return const SizedBox();
    return Center(
      child: Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Icon(Icons.accessible, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildSelectedSpot() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Icon(Icons.accessible, size: 14, color: Colors.white),
        ),
        Positioned(
          top: 0,
          child: Column(
            children: [
              const Text(
                'SELECTED\nPARKING',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationPath() {
    return Stack(
      children: [
        // "YOU ARE HERE" indicator
        Positioned(
          top: 60,
          right: 40,
          child: Row(
            children: [
              const Text(
                'YOU ARE HERE',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        // Path Line (Simplified)
        Positioned(
          top: 70,
          right: 45,
          child: CustomPaint(
            size: const Size(150, 200),
            painter: PathPainter(),
          ),
        ),
      ],
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Start from "You are here"
    path.moveTo(0, 0);
    // Horizontal line to the left
    path.lineTo(-80, 0);
    // Turn down
    path.lineTo(-80, 200);
    // Final turn to spot
    path.lineTo(-110, 200);

    canvas.drawPath(path, paint);

    // Draw arrows along the horizontal line
    final arrowPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double i = -20; i > -80; i -= 20) {
      _drawArrow(canvas, Offset(i, 0), arrowPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset position, Paint paint) {
    final path = Path();
    path.moveTo(position.dx + 5, position.dy - 5);
    path.lineTo(position.dx, position.dy);
    path.lineTo(position.dx + 5, position.dy + 5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
