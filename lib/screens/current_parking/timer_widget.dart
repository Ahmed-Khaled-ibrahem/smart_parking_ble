import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/config/notifications_config.dart';

const Color lightGreenBg = Color(0xFFE8F5E9);
const Color primaryGreen = Color(0xFF2D5A47);
const Color darkGreenBtn = Color(0xFF1E4D3B);

class SessionTimerWidget extends StatefulWidget {
  const SessionTimerWidget({super.key});

  @override
  State<SessionTimerWidget> createState() => _SessionTimerWidgetState();
}

class _SessionTimerWidgetState extends State<SessionTimerWidget> {
  int _remainingSecs = 0;
  int _remindSecs = 0;
  String _remindLabel = 'Not set';
  bool _running = false;
  bool _started = false;
  Timer? _timer;

  final List<Map<String, dynamic>> _remindOptions = [
    {'label': '10 Sec', 'secs': 10},
    {'label': '15 min', 'secs': 15 * 60},
    {'label': '30 min', 'secs': 30 * 60},
    {'label': '45 min', 'secs': 45 * 60},
    {'label': '1 hour', 'secs': 60 * 60},
    {'label': '1 hr 30 min', 'secs': 90 * 60},
    {'label': '2 hours', 'secs': 120 * 60},
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('timer_started', _started);
    await prefs.setBool('timer_running', _running);
    await prefs.setInt('timer_remindSecs', _remindSecs);
    await prefs.setInt('timer_remainingSecs', _remainingSecs);
    await prefs.setString('timer_remindLabel', _remindLabel);

    if (_running) {
      final endTime = DateTime.now().add(Duration(seconds: _remainingSecs));
      await prefs.setInt('timer_endTime', endTime.millisecondsSinceEpoch);
    } else {
      await prefs.remove('timer_endTime');
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final started = prefs.getBool('timer_started') ?? false;

    if (!started) {
      final remindSecs = prefs.getInt('timer_remindSecs') ?? 0;
      final remainingSecs = prefs.getInt('timer_remainingSecs') ?? 0;
      final remindLabel = prefs.getString('timer_remindLabel') ?? 'Not set';
      setState(() {
        _remindSecs = remindSecs;
        _remainingSecs = remainingSecs;
        _remindLabel = remindLabel;
      });
      return;
    }

    final running = prefs.getBool('timer_running') ?? false;
    final remindSecs = prefs.getInt('timer_remindSecs') ?? 0;
    int remainingSecs = prefs.getInt('timer_remainingSecs') ?? 0;
    final remindLabel = prefs.getString('timer_remindLabel') ?? 'Not set';

    if (running) {
      final endTimeMs = prefs.getInt('timer_endTime');
      if (endTimeMs != null) {
        final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMs);
        final diff = endTime.difference(DateTime.now()).inSeconds;
        remainingSecs = diff > 0 ? diff : 0;
      }
    }

    setState(() {
      _started = started;
      _running = running;
      _remindSecs = remindSecs;
      _remainingSecs = remainingSecs;
      _remindLabel = remindLabel;
    });

    if (_running && _remainingSecs > 0) {
      _startTicking();
    } else if (_running && _remainingSecs <= 0) {
      setState(() {
        _running = false;
        _started = false;
        _remainingSecs = 0;
      });
      _saveState();
    }
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingSecs > 0) {
          _remainingSecs--;
        } else {
          _timer?.cancel();
          _running = false;
          _started = false;
          _saveState();
        }
      });
    });
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return '0:00';
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_remindSecs == 0) return 0;
    return 1.0 - (_remainingSecs / _remindSecs).clamp(0.0, 1.0);
  }

  Future checkPendingNotifications() async {
    final pending = await flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    print('Pending notifications: ${pending.length}');
    for (var notification in pending) {
      print(
        'ID: ${notification.id}, Title: ${notification.title} , Body: ${notification.body}',
      );
    }
  }

  Future requestExactAlarmPermission() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();

  }

  void _startTimer() async {
    await requestExactAlarmPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    checkPendingNotifications();
    if (_remindSecs == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reminder time first')),
      );
      return;
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    setState(() {
      _running = true;
      _started = true;
      if (_remainingSecs <= 0) {
        _remainingSecs = _remindSecs;
      }
    });

    // Cancel existing
    await flutterLocalNotificationsPlugin.cancelAll();

    // Schedule new notification
    if (_remainingSecs > 0) {
      scheduleNotificationSeconds(_remainingSecs);
    }

    _saveState();
    _startTicking();
  }

  void _pauseTimer() async {
    _timer?.cancel();
    await flutterLocalNotificationsPlugin.cancelAll();
    setState(() => _running = false);
    _saveState();
  }

  void _resumeTimer() {
    setState(() => _running = true);

    // Schedule notification for remaining time
    if (_remainingSecs > 0) {
      scheduleNotificationSeconds(_remainingSecs);
    }

    _saveState();
    _startTicking();
  }

  void _stopTimer() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    _timer?.cancel();
    setState(() {
      _remainingSecs = 0;
      _remindSecs = 0;
      _remindLabel = 'Not set';
      _running = false;
      _started = false;
    });
    _saveState();
  }

  void _selectRemind(int secs, String label) {
    setState(() {
      _remindSecs = secs;
      _remainingSecs = secs;
      _remindLabel = label;

      if (_started && _running) {
        _stopTimer();
      } else {
        _saveState();
      }
    });
  }

  void _showRemindMenu(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    showMenu(
      context: context,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 6,
        offset.dx + size.width,
        0,
      ),
      items: _remindOptions
          .map(
            (opt) => PopupMenuItem(
              onTap: () => _selectRemind(opt['secs'], opt['label']),
              child: Text(
                opt['label'],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _remindLabel == opt['label']
                      ? darkGreenBtn
                      : Colors.black87,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timer Card ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

            decoration: BoxDecoration(
              color: lightGreenBg,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TIMER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Color(0xFF1A4D33),
                      ),
                    ),
                    if (_started)
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: _running ? primaryGreen : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _running ? 'RUNNING' : 'PAUSED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: .8,
                              color: _running ? darkGreenBtn : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(_remainingSecs),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A4D33),
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFB8DEC8),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Remind Me + Start/Pause Row ─────────────────────────
          Row(
            children: [
              // Remind me after button
              Expanded(
                flex: 2,
                child: Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => _showRemindMenu(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: lightGreenBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'REMIND ME AFTER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: .8,
                                  color: Color(0xFF1A4D33),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _remindLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: darkGreenBtn,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Start / Pause / Resume button
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (!_started) {
                      _startTimer();
                    } else if (_running) {
                      _pauseTimer();
                    } else {
                      _resumeTimer();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _running ? Colors.white : darkGreenBtn,
                      borderRadius: BorderRadius.circular(20),
                      border: _running
                          ? Border.all(color: const Color(0xFFA8D9BC))
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        !_started
                            ? 'START'
                            : _running
                            ? 'PAUSE'
                            : 'RESUME',
                        style: TextStyle(
                          color: _running
                              ? const Color(0xFF1A4D33)
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Stop Timer button (shown after start) ───────────────
          if (_started) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _stopTimer,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEDED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    'STOP TIMER',
                    style: TextStyle(
                      color: Color(0xFFC0392B),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: .8,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
