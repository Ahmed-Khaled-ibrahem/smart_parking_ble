import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_parking_ble/app/app.dart';
import 'package:smart_parking_ble/app/config/firebase_config.dart';
import 'package:smart_parking_ble/app/config/hive_config.dart';
import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:smart_parking_ble/app/widgets/error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_parking_ble/screens/deactivate/deactivate_app.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      DateTime now = DateTime.now();
      DateTime date = DateTime(2026, 4, 1);

      if (now.isAfter(date)) {
        runApp(const DeactivateAppScreen());
        return;
      }

      // Initialize Hive
      await hiveConfig();
      // Initialize Firebase
      await firebaseConfig();
      // Initialize Easy Localization
      await EasyLocalization.ensureInitialized();
      // setting orientation
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      // Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        logApp('^^^ Uncaught error: $details');
        FlutterError.dumpErrorToConsole(details);
      };

      ErrorWidget.builder = (FlutterErrorDetails details) {
        return const AppErrorWidget();
      };

      runApp(const ProviderScope(child: App()));
    },

    (error, stack) {
      logApp('@@@ Uncaught async error: $error');
      logApp(stack.toString());
    },
  );
}

// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// // ─── HARDCODED TARGET MAC ADDRESS ─────────────────────────────────────────────
// const String TARGET_MAC = "08:A6:F7:48:49:56"; // <-- Change this
// // 08:A6:F7:48:49:56
// // RSSI to Distance conversion (log-distance path loss model)
// // distance = 10 ^ ((TxPower - RSSI) / (10 * n))
// // TxPower ≈ -59 dBm at 1 meter (typical), n = 2.0 (free space)
// double rssiToDistance(int rssi) {
//   const int txPower = -59;
//   const double n = 2.0;
//   return pow(10, (txPower - rssi) / (10 * n)).toDouble();
// }
//
// void main() {
//   runApp(const BleRadarApp());
// }
//
// class BleRadarApp extends StatelessWidget {
//   const BleRadarApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BLE Radar',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: const Color(0xFF050A14),
//         colorScheme: const ColorScheme.dark(
//           primary: Color(0xFF00FFB2),
//           secondary: Color(0xFF0066FF),
//         ),
//       ),
//       home: const RadarScreen(),
//     );
//   }
// }
//
// class RadarScreen extends StatefulWidget {
//   const RadarScreen({super.key});
//
//   @override
//   State<RadarScreen> createState() => _RadarScreenState();
// }
//
// class _RadarScreenState extends State<RadarScreen>
//     with TickerProviderStateMixin {
//   // Animations
//   late AnimationController _pulseController;
//   late AnimationController _radarSweepController;
//   late AnimationController _distanceRingController;
//
//   // BLE State
//   StreamSubscription<List<ScanResult>>? _scanSubscription;
//   int? _rssi;
//   double? _distance;
//   bool _isScanning = false;
//   String _statusText = "TAP TO SCAN";
//   bool _deviceFound = false;
//
//   // Distance history for Moving Average Filter
//   final List<double> _distanceHistory = [];
//   final int _windowSize = 10; // Smoothing window
//   String _trend = "—";
//   Color _trendColor = Colors.white54;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2000),
//     )..repeat();
//
//     _radarSweepController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3000),
//     )..repeat();
//
//     _distanceRingController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _radarSweepController.dispose();
//     _distanceRingController.dispose();
//     _scanSubscription?.cancel();
//     FlutterBluePlus.stopScan();
//     super.dispose();
//   }
//
//   void _startScan() async {
//     if (_isScanning) {
//       await FlutterBluePlus.stopScan();
//       setState(() {
//         _isScanning = false;
//         _statusText = "TAP TO SCAN";
//       });
//       return;
//     }
//
//     setState(() {
//       _isScanning = true;
//       _statusText = "SCANNING...";
//       _deviceFound = false;
//     });
//
//     // Start continuous scan
//     await FlutterBluePlus.startScan(
//       timeout: const Duration(seconds: 30),
//       continuousUpdates: true,
//     );
//
//     _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         final mac = result.device.remoteId.str.toUpperCase();
//         if (mac == TARGET_MAC.toUpperCase()) {
//           final rssi = result.rssi;
//           final dist = rssiToDistance(rssi);
//
//           setState(() {
//             _rssi = rssi;
//             _deviceFound = true;
//             _statusText = "DEVICE FOUND";
//
//             // Add raw distance to history for Moving Average Filter
//             _distanceHistory.add(dist);
//             if (_distanceHistory.length > _windowSize)
//               _distanceHistory.removeAt(0);
//
//             // Calculate moving average
//             double averageDist =
//                 _distanceHistory.reduce((a, b) => a + b) /
//                 _distanceHistory.length;
//
//             // Update trend based on change in averaged distance
//             if (_distance != null) {
//               final diff = averageDist - _distance!;
//               // Using a small threshold (0.1m) to avoid micro-jitter in trend
//               if (diff < -0.1) {
//                 _trend = "▼ APPROACHING";
//                 _trendColor = const Color(0xFF00FFB2);
//               } else if (diff > 0.1) {
//                 _trend = "▲ MOVING AWAY";
//                 _trendColor = const Color(0xFFFF4444);
//               } else if (diff.abs() < 0.05) {
//                 _trend = "● STEADY";
//                 _trendColor = Colors.white54;
//               }
//             } else {
//               _trend = "● STEADY";
//             }
//
//             _distance = averageDist;
//           });
//         }
//       }
//     });
//
//     // Restart scan when it ends
//     FlutterBluePlus.isScanning.listen((scanning) {
//       if (!scanning && _isScanning) {
//         _startContinuousScan();
//       }
//     });
//   }
//
//   void _startContinuousScan() async {
//     if (!_isScanning) return;
//     await FlutterBluePlus.startScan(
//       timeout: const Duration(seconds: 30),
//       continuousUpdates: true,
//     );
//   }
//
//   Color get _deviceColor {
//     if (!_deviceFound || _distance == null) return const Color(0xFF0066FF);
//     if (_distance! < 2) return const Color(0xFF00FFB2);
//     if (_distance! < 5) return Colors.yellow;
//     if (_distance! < 10) return Colors.orange;
//     return const Color(0xFFFF4444);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final centerSize = size.width * 0.85;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF050A14),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // ─── HEADER ─────────────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "BLE RADAR",
//                         style: TextStyle(
//                           fontFamily: 'monospace',
//                           fontSize: 20,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: 6,
//                           color: _deviceColor,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         TARGET_MAC,
//                         style: TextStyle(
//                           fontFamily: 'monospace',
//                           fontSize: 10,
//                           letterSpacing: 2,
//                           color: Colors.white30,
//                         ),
//                       ),
//                     ],
//                   ),
//                   _ScanningIndicator(
//                     isScanning: _isScanning,
//                     color: _deviceColor,
//                   ),
//                 ],
//               ),
//             ),
//
//             // ─── DISTANCE BUBBLE ─────────────────────────────────────────────
//             const SizedBox(height: 20),
//             AnimatedBuilder(
//               animation: _distanceRingController,
//               builder: (context, child) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 40),
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 16,
//                     horizontal: 24,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: _deviceColor.withOpacity(
//                         0.3 + 0.3 * _distanceRingController.value,
//                       ),
//                       width: 1.5,
//                     ),
//                     gradient: LinearGradient(
//                       colors: [
//                         _deviceColor.withOpacity(0.05),
//                         _deviceColor.withOpacity(0.12),
//                       ],
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _InfoTile(
//                         label: "DISTANCE",
//                         value: _distance != null
//                             ? "${_distance!.toStringAsFixed(1)} m"
//                             : "—",
//                         color: _deviceColor,
//                       ),
//                       Container(width: 1, height: 40, color: Colors.white10),
//                       _InfoTile(
//                         label: "RSSI",
//                         value: _rssi != null ? "$_rssi dBm" : "—",
//                         color: Colors.white70,
//                       ),
//                       Container(width: 1, height: 40, color: Colors.white10),
//                       _InfoTile(
//                         label: "STATUS",
//                         value: 'Ready',
//                         color: _trendColor,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//             // ─── RADAR CANVAS ─────────────────────────────────────────────
//             Expanded(
//               child: Center(
//                 child: GestureDetector(
//                   onTap: _startScan,
//                   child: SizedBox(
//                     width: centerSize,
//                     height: centerSize,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Radar rings
//                         AnimatedBuilder(
//                           animation: _pulseController,
//                           builder: (context, child) {
//                             return CustomPaint(
//                               size: Size(centerSize, centerSize),
//                               painter: _RadarRingPainter(
//                                 progress: _pulseController.value,
//                                 color: _deviceColor,
//                                 distance: _distance,
//                                 isActive: _isScanning,
//                               ),
//                             );
//                           },
//                         ),
//
//                         // Radar sweep
//                         if (_isScanning)
//                           AnimatedBuilder(
//                             animation: _radarSweepController,
//                             builder: (context, child) {
//                               return CustomPaint(
//                                 size: Size(centerSize, centerSize),
//                                 painter: _RadarSweepPainter(
//                                   angle: _radarSweepController.value * 2 * pi,
//                                   color: _deviceColor,
//                                 ),
//                               );
//                             },
//                           ),
//
//                         // Device dot
//                         if (_deviceFound && _distance != null)
//                           _DeviceDot(
//                             distance: _distance!,
//                             maxRadius: centerSize / 2,
//                             color: _deviceColor,
//                             pulseController: _pulseController,
//                           ),
//
//                         // Center "ME" circle
//                         _CenterCircle(
//                           color: _deviceColor,
//                           isScanning: _isScanning,
//                           statusText: _isScanning && !_deviceFound
//                               ? _statusText
//                               : "ME",
//                           pulseController: _pulseController,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             // ─── BOTTOM STATUS ──────────────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.only(bottom: 28),
//               child: Text(
//                 _isScanning
//                     ? "TAP CENTER TO STOP"
//                     : "TAP CENTER TO START SCANNING",
//                 style: const TextStyle(
//                   fontFamily: 'monospace',
//                   fontSize: 11,
//                   letterSpacing: 3,
//                   color: Colors.white30,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── CENTER CIRCLE ─────────────────────────────────────────────────────────────
// class _CenterCircle extends StatelessWidget {
//   final Color color;
//   final bool isScanning;
//   final String statusText;
//   final AnimationController pulseController;
//
//   const _CenterCircle({
//     required this.color,
//     required this.isScanning,
//     required this.statusText,
//     required this.pulseController,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: pulseController,
//       builder: (context, child) {
//         final glow = isScanning
//             ? (0.5 + 0.5 * sin(pulseController.value * 2 * pi))
//             : 0.5;
//         return Container(
//           width: 80,
//           height: 80,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: const Color(0xFF050A14),
//             border: Border.all(color: color, width: 2.5),
//             boxShadow: [
//               BoxShadow(
//                 color: color.withOpacity(0.3 + 0.3 * glow),
//                 blurRadius: 20 + 10 * glow,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Center(
//             child: Text(
//               statusText == "ME" ? "ME" : "●",
//               style: TextStyle(
//                 fontFamily: 'monospace',
//                 fontSize: statusText == "ME" ? 22 : 8,
//                 fontWeight: FontWeight.w900,
//                 color: color,
//                 letterSpacing: statusText == "ME" ? 2 : 0,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ─── DEVICE DOT ───────────────────────────────────────────────────────────────
// class _DeviceDot extends StatelessWidget {
//   final double distance;
//   final double maxRadius;
//   final Color color;
//   final AnimationController pulseController;
//
//   const _DeviceDot({
//     required this.distance,
//     required this.maxRadius,
//     required this.color,
//     required this.pulseController,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Map distance (0–15m) to ring position
//     const maxDist = 15.0;
//     final ratio = (distance / maxDist).clamp(0.0, 0.95);
//     // Place on top of the radar at angle 0 (12 o'clock), then animate angle
//     final radius = ratio * (maxRadius - 40);
//
//     return AnimatedBuilder(
//       animation: pulseController,
//       builder: (context, child) {
//         final glow = 0.5 + 0.5 * sin(pulseController.value * 2 * pi);
//         return Transform.translate(
//           offset: Offset(0, -radius),
//           child: Container(
//             width: 16,
//             height: 16,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: color,
//               boxShadow: [
//                 BoxShadow(
//                   color: color.withOpacity(0.8 * glow),
//                   blurRadius: 12,
//                   spreadRadius: 4,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ─── RADAR RINGS PAINTER ──────────────────────────────────────────────────────
// class _RadarRingPainter extends CustomPainter {
//   final double progress;
//   final Color color;
//   final double? distance;
//   final bool isActive;
//
//   _RadarRingPainter({
//     required this.progress,
//     required this.color,
//     required this.distance,
//     required this.isActive,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final maxRadius = size.width / 2;
//
//     // Draw 4 static rings
//     for (int i = 1; i <= 4; i++) {
//       final r = maxRadius * (i / 4);
//       final paint = Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1
//         ..color = color.withOpacity(0.12 + (i == 4 ? 0.08 : 0));
//       canvas.drawCircle(center, r, paint);
//
//       // Ring labels (distance)
//       const maxDist = 15.0;
//       final distLabel = "${(maxDist * i / 4).toStringAsFixed(0)}m";
//       final tp = TextPainter(
//         text: TextSpan(
//           text: distLabel,
//           style: TextStyle(
//             fontSize: 9,
//             color: color.withOpacity(0.25),
//             fontFamily: 'monospace',
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       )..layout();
//       tp.paint(canvas, Offset(center.dx + r - 20, center.dy + 3));
//     }
//
//     // Cross-hair lines
//     final linePaint = Paint()
//       ..color = color.withOpacity(0.08)
//       ..strokeWidth = 1;
//     canvas.drawLine(
//       Offset(center.dx, 0),
//       Offset(center.dx, size.height),
//       linePaint,
//     );
//     canvas.drawLine(
//       Offset(0, center.dy),
//       Offset(size.width, center.dy),
//       linePaint,
//     );
//
//     // Animated pulse ring expanding outward
//     if (isActive) {
//       final pulseRadius = maxRadius * progress;
//       final pulsePaint = Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 2
//         ..color = color.withOpacity((1 - progress) * 0.6);
//       canvas.drawCircle(center, pulseRadius, pulsePaint);
//     }
//
//     // Highlight ring for current distance
//     if (distance != null) {
//       const maxDist = 15.0;
//       final ratio = (distance! / maxDist).clamp(0.0, 1.0);
//       final distRing = maxRadius * ratio;
//       final dp = Paint()
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.5
//         ..color = color.withOpacity(0.5);
//       canvas.drawCircle(center, distRing, dp);
//     }
//   }
//
//   @override
//   bool shouldRepaint(_RadarRingPainter old) => true;
// }
//
// // ─── RADAR SWEEP PAINTER ──────────────────────────────────────────────────────
// class _RadarSweepPainter extends CustomPainter {
//   final double angle;
//   final Color color;
//
//   _RadarSweepPainter({required this.angle, required this.color});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//
//     // Sweep gradient arc
//     final sweepAngle = pi / 3; // 60 degree sweep
//     final startAngle = angle - sweepAngle - pi / 2;
//
//     final rect = Rect.fromCircle(center: center, radius: radius);
//     final gradient = SweepGradient(
//       startAngle: startAngle,
//       endAngle: startAngle + sweepAngle,
//       colors: [color.withOpacity(0), color.withOpacity(0.25)],
//     );
//
//     final paint = Paint()
//       ..shader = gradient.createShader(rect)
//       ..style = PaintingStyle.fill;
//
//     final path = Path()
//       ..moveTo(center.dx, center.dy)
//       ..arcTo(rect, startAngle, sweepAngle, false)
//       ..close();
//
//     canvas.drawPath(path, paint);
//
//     // Leading edge line
//     final endX = center.dx + radius * cos(angle - pi / 2);
//     final endY = center.dy + radius * sin(angle - pi / 2);
//     canvas.drawLine(
//       center,
//       Offset(endX, endY),
//       Paint()
//         ..color = color.withOpacity(0.6)
//         ..strokeWidth = 1.5,
//     );
//   }
//
//   @override
//   bool shouldRepaint(_RadarSweepPainter old) => true;
// }
//
// // ─── INFO TILE ────────────────────────────────────────────────────────────────
// class _InfoTile extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//
//   const _InfoTile({
//     required this.label,
//     required this.value,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontFamily: 'monospace',
//             fontSize: 9,
//             letterSpacing: 2,
//             color: Colors.white30,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontFamily: 'monospace',
//             fontSize: 13,
//             overflow: TextOverflow.ellipsis,
//             fontWeight: FontWeight.bold,
//             color: color,
//             letterSpacing: 1,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─── SCANNING INDICATOR ──────────────────────────────────────────────────────
// class _ScanningIndicator extends StatefulWidget {
//   final bool isScanning;
//   final Color color;
//
//   const _ScanningIndicator({required this.isScanning, required this.color});
//
//   @override
//   State<_ScanningIndicator> createState() => _ScanningIndicatorState();
// }
//
// class _ScanningIndicatorState extends State<_ScanningIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _ctrl,
//       builder: (context, child) {
//         return Row(
//           children: [
//             Container(
//               width: 8,
//               height: 8,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: widget.isScanning
//                     ? widget.color.withOpacity(0.4 + 0.6 * _ctrl.value)
//                     : Colors.white24,
//                 boxShadow: widget.isScanning
//                     ? [
//                         BoxShadow(
//                           color: widget.color.withOpacity(0.5),
//                           blurRadius: 6,
//                         ),
//                       ]
//                     : null,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Text(
//               widget.isScanning ? "ACTIVE" : "IDLE",
//               style: TextStyle(
//                 fontFamily: 'monospace',
//                 fontSize: 11,
//                 letterSpacing: 2,
//                 color: widget.isScanning ? widget.color : Colors.white30,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
