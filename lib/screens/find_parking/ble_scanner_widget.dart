import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleProximityWidget extends StatefulWidget {
  final String targetDeviceName;
  final void Function(double? distanceInMeters) onDistanceUpdate;

  const BleProximityWidget({
    super.key,
    required this.targetDeviceName,
    required this.onDistanceUpdate,
  });

  @override
  State<BleProximityWidget> createState() => _BleProximityWidgetState();
}

// ─── Configuration ──────────────────────────
class _BleConfig {
  // Adjust txPower to match your actual BLE beacon/device (common values: -59, -65, -70)
  static const double txPower = -40;

  // Path-loss exponent (2.0 = free space, 2.7–4.0 = indoor obstacles)
  static const double pathLossExponent = 2.5;

  // Number of RSSI readings to average (higher = smoother but slower)
  static const int averagingWindowSize = 8;

  // BLE scan interval in milliseconds
  static const int scanIntervalMs = 2500;
}

// ─── Distance calculator ─────────────────────
double _rssiToDistance(double avgRssi) {
  if (avgRssi == 0) return -1;
  final ratio = avgRssi / _BleConfig.txPower;
  if (ratio < 1.0) {
    return pow(ratio, 10).toDouble();
  }
  print(avgRssi);
  return pow(
    10,
    (avgRssi - _BleConfig.txPower) / (-10 * _BleConfig.pathLossExponent),
  ).toDouble();
}

// ─── Widget State ────────────────────────────
class _BleProximityWidgetState extends State<BleProximityWidget>
    with SingleTickerProviderStateMixin {
  StreamSubscription<List<ScanResult>>? _scanSub;
  final List<double> _rssiWindow = [];
  final List<double> _reportDistanceBuffer = [];
  Timer? _expiryTimer;
  Timer? _reportTimer;
  DateTime? _lastSeen;

  double? _smoothedRssi;
  double? _distance;
  bool _deviceFound = false;
  bool _isScanning = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startScanning();
    _startExpiryTimer();
    _startReporting();
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_lastSeen != null &&
          DateTime.now().difference(_lastSeen!).inSeconds > 4) {
        if (_deviceFound) {
          setState(() {
            _deviceFound = false;
            _smoothedRssi = null;
            _distance = null;
            _rssiWindow.clear();
            _lastSeen = null;
          });
        }
      }
    });
  }

  void _startReporting() {
    _reportTimer?.cancel();
    _reportTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      if (_deviceFound) {
        if (_reportDistanceBuffer.isNotEmpty) {
          final avg =
              _reportDistanceBuffer.reduce((a, b) => a + b) /
              _reportDistanceBuffer.length;
          widget.onDistanceUpdate(avg);
          _reportDistanceBuffer.clear();
        } else if (_distance != null) {
          widget.onDistanceUpdate(_distance);
        }
      } else {
        widget.onDistanceUpdate(null);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expiryTimer?.cancel();
    _reportTimer?.cancel();
    _stopScanning();
    super.dispose();
  }

  // ─── BLE Scanning ──────────────────────────
  void _startScanning() async {
    if (_isScanning) return;
    await FlutterBluePlus.adapterState.first;
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) return;
    if (mounted) setState(() => _isScanning = true);
    try {
      await FlutterBluePlus.startScan(
        timeout: null,
        continuousUpdates: true,
        androidUsesFineLocation: true,
      );
    } catch (_) {}

    _scanSub = FlutterBluePlus.scanResults.listen(_onScanResults);
  }

  void _stopScanning() {
    _scanSub?.cancel();
    _scanSub = null;
    FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  void _onScanResults(List<ScanResult> results) {
    final now = DateTime.now();
    final match = results.where(
      (r) =>
          (r.device.platformName == widget.targetDeviceName ||
              r.advertisementData.advName == widget.targetDeviceName) &&
          now.difference(r.timeStamp).inSeconds < 4,
    );
    if (match.isEmpty) return;
    _lastSeen = now;
    final rssi = match.first.rssi.toDouble();
    print(rssi);
    _addRssiReading(rssi);
  }

  void _addRssiReading(double rssi) {
    _rssiWindow.add(rssi);
    if (_rssiWindow.length > _BleConfig.averagingWindowSize) {
      _rssiWindow.removeAt(0);
    }
    final avg = _rssiWindow.reduce((a, b) => a + b) / _rssiWindow.length;
    final dist = _rssiToDistance(avg);

    if (mounted) {
      setState(() {
        _deviceFound = true;
        _smoothedRssi = avg;
        _distance = dist;
      });
    }
    _reportDistanceBuffer.add(dist);
  }

  // ─── UI Helpers ────────────────────────────
  String get _distanceLabel {
    if (_distance == null) return '—';
    if (_distance! < 1) return '< 1 m';
    return '${_distance!.toStringAsFixed(1)} m';
  }

  String get _proximityLabel {
    if (_distance == null) return 'Out of Range';
    if (_distance! < 2) return 'Very Close';
    if (_distance! < 5) return 'Near';
    if (_distance! < 10) return 'Nearby';
    return 'Far';
  }

  Color get _statusColor {
    if (!_deviceFound) return _AppTheme.colorOutOfRange;
    if (_distance! < 2) return _AppTheme.colorVeryClose;
    if (_distance! < 5) return _AppTheme.colorNear;
    if (_distance! < 10) return _AppTheme.colorNearby;
    return _AppTheme.colorFar;
  }

  // ─── Build ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120, // Compact height
      child: FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on
          ? _buildTurnOff()
          : _deviceFound
          ? _buildFound()
          : _buildNotFound(),
    );
  }

  Widget _buildFound() {
    return Container(
      decoration: BoxDecoration(
        color: _AppTheme.cardBg,
        borderRadius: BorderRadius.circular(_AppTheme.radius),
        boxShadow: _AppTheme.cardShadow,
      ),
      margin: EdgeInsets.all(5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _PulsingDot(
                color: _statusColor,
                controller: _pulseController,
                anim: _pulseAnim,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Parking Unit Navigation',
                  style: _AppTheme.deviceNameStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _SignalBars(
                rssi: _smoothedRssi ?? -100,
                activeColor: _statusColor,
              ),
            ],
          ),

          const Spacer(),

          // Main distance display
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _distanceLabel,
                style: _AppTheme.distanceStyle.copyWith(
                  fontSize: 32, // Reduced from 52
                  color: _statusColor,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _proximityLabel,
                    style: _AppTheme.proximityLabelStyle.copyWith(
                      fontSize: 13,
                      color: _statusColor.withOpacity(0.8),
                    ),
                  ),
                  // Text(
                  //   'RSSI: ${_smoothedRssi?.toInt() ?? '—'} dBm',
                  //   style: _AppTheme.chipLabelStyle,
                  // ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Distance bar (compact)
          _DistanceBar(
            distance: _distance ?? 0,
            maxDistance: 20,
            color: _statusColor,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Container(
      decoration: BoxDecoration(
        color: _AppTheme.cardBg,
        borderRadius: BorderRadius.circular(_AppTheme.radius),
        boxShadow: _AppTheme.cardShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Out of Range', style: _AppTheme.outOfRangeTitle),
            const SizedBox(height: 6),
            _ScanningIndicator(deviceName: widget.targetDeviceName),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnOff() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _AppTheme.cardBg,
          borderRadius: BorderRadius.circular(_AppTheme.radius),
          boxShadow: _AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bluetooth_disabled,
                  color: _AppTheme.colorOutOfRange,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text('Bluetooth is off', style: _AppTheme.deviceNameStyle),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FlutterBluePlus.turnOn();
                  } catch (_) {}
                  if (mounted) setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Turn on Bluetooth',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Sub-components
// ─────────────────────────────────────────────

class _PulsingDot extends StatelessWidget {
  final Color color;
  final AnimationController controller;
  final Animation<double> anim;

  const _PulsingDot({
    required this.color,
    required this.controller,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final double rssi;
  final Color activeColor;

  const _SignalBars({required this.rssi, required this.activeColor});

  int get _activeBars {
    if (rssi >= -60) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    if (rssi >= -90) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final isActive = i < _activeBars;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          width: 6,
          height: 6.0 + (i * 5),
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: isActive ? activeColor : _AppTheme.barInactive,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _DistanceBar extends StatelessWidget {
  final double distance;
  final double maxDistance;
  final Color color;
  final bool compact;

  const _DistanceBar({
    required this.distance,
    required this.maxDistance,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (distance / maxDistance).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 m', style: _AppTheme.barLabelStyle),
              Text('${maxDistance.toInt()} m', style: _AppTheme.barLabelStyle),
            ],
          ),
        if (!compact) const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(compact ? 2 : 6),
          child: SizedBox(
            height: compact ? 4 : 8,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                return Stack(
                  children: [
                    Container(color: _AppTheme.barTrack),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      width: constraints.maxWidth * fraction,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.6), color],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanningIndicator extends StatelessWidget {
  final String deviceName;

  const _ScanningIndicator({required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _AppTheme.colorOutOfRange.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 10),
        Text('Scanning for "$deviceName"…', style: _AppTheme.scanningStyle),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Theme — edit all colors & styles here
// ─────────────────────────────────────────────
abstract class _AppTheme {
  // ── Card
  static const Color cardBg = Color(0xFFFFFFFF);
  static const double radius = 20.0;
  static final List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x12000000), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  // ── Status colors  ← easy to change
  static const Color colorVeryClose = Color(0xFF2ECC71); // green
  static const Color colorNear = Color(0xFF27AE60); // darker green
  static const Color colorNearby = Color(0xFFF39C12); // amber
  static const Color colorFar = Color(0xFFE74C3C); // red
  static const Color colorOutOfRange = Color(0xFFBDC3C7); // grey

  // ── Bar & chip
  static const Color barInactive = Color(0xFFECF0F1);
  static const Color barTrack = Color(0xFFF5F6FA);

  // ── Text styles
  static const TextStyle deviceNameStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2C3E50),
    letterSpacing: 0.3,
  );

  static const TextStyle distanceStyle = TextStyle(
    fontSize: 52,
    fontWeight: FontWeight.w700,
    color: Color(0xFF2C3E50),
    height: 1,
  );

  static const TextStyle proximityLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFF7F8C8D),
  );

  static const TextStyle chipLabelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: Color(0xFF95A5A6),
  );

  static const TextStyle barLabelStyle = TextStyle(
    fontSize: 10,
    color: Color(0xFFBDC3C7),
  );

  static const TextStyle outOfRangeTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xFF2C3E50),
  );

  static const TextStyle scanningStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFFBDC3C7),
  );
}
