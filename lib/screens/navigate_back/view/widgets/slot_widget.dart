import 'package:flutter/material.dart';
import '../../../../model/slot.dart';

class ParkingSlotWidget extends StatefulWidget {
  final ParkingSlot slot;
  final bool isSelected;
  final AnimationController pulseAnimation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ParkingSlotWidget({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.pulseAnimation,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<ParkingSlotWidget> createState() => _ParkingSlotWidgetState();
}

class _ParkingSlotWidgetState extends State<ParkingSlotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleCtrl.forward().then((_) => _scaleCtrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isOccupied = widget.slot.status == ParkingStatus.occupied;
    final baseColor = isOccupied
        ? const Color(0xFFB71C1C)
        : const Color(0xFF1B5E20);
    final glowColor = isOccupied
        ? const Color(0xFFFF5252)
        : const Color(0xFF00E676);
    final isBooked = widget.slot.status == ParkingStatus.booked;
    final selectedColor = const Color(0xFF00E5FF);

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleCtrl, widget.pulseAnimation]),
        builder: (context, child) {
          final pulse = isOccupied
              ? 1.0
              : 0.6 + 0.4 * widget.pulseAnimation.value;
          return Transform.scale(
            scale: _scaleAnim.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isBooked ? const Color(0xFF837A0A) : baseColor,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: widget.isSelected ? selectedColor : glowColor,
                  width: widget.isSelected ? 2.5 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? selectedColor.withOpacity(0.5)
                        : glowColor.withOpacity(
                            isOccupied ? 0.2 : pulse * 0.35,
                          ),
                    blurRadius: widget.isSelected ? 14 : 8,
                    spreadRadius: widget.isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Slot marking lines
            Positioned.fill(child: CustomPaint(painter: _SlotMarkingPainter())),
            // ID label
            Positioned(
              top: 2,
              left: 3,
              child: Text(
                widget.slot.id,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            // Car icon with fade animation
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: -10,
              child: AnimatedOpacity(
                opacity: isOccupied ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: AnimatedScale(
                  scale: isOccupied ? 1.0 : 0.3,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  child: RotatedBox(
                    quarterTurns: widget.slot.gridPosition.dx.toInt() % 2 == 0
                        ? 1
                        : 3,
                    child: const _CarIcon(),
                  ),
                ),
              ),
            ),
            // Available check or Accessibility Icon
            Positioned(
              top: 10,
              left: 20,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: widget.slot.type == ParkingType.disablePerson
                    ? 0.35
                    : (isOccupied ? 0.0 : 0.3),
                duration: const Duration(milliseconds: 400),
                child: Icon(
                  widget.slot.type == ParkingType.disablePerson
                      ? Icons.accessible
                      : Icons.check_circle_outline,
                  color: const Color(0xFFFFFFFF),
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotMarkingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1;
    // Top and bottom marking lines for horizontal slots
    canvas.drawLine(
      Offset(size.width * 0.2, 4),
      Offset(size.width * 0.8, 4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height - 4),
      Offset(size.width * 0.8, size.height - 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CarIcon extends StatelessWidget {
  const _CarIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/car.png');
  }
}
