import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile.dart';

class ParkingHistoryScreen extends ConsumerWidget {
  const ParkingHistoryScreen({super.key});

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
    final uid = ref.watch(profileProvider)?.uid;
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
              bottom: false,
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
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Text(
                      'PARKING HISTORY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: mutedText,
                      ),
                    ),
                  ),

                  // — Sorting Badge —
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: g3.withOpacity(0.12),
                        border: Border.all(
                          color: g3.withOpacity(0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 14,
                            color: g2,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'SORTED BY: RECENT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: g2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // — History List —
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: lightGreen,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('profiles')
                            .doc(uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: g2,
                              ),
                            );
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return _buildEmptyState();
                          }

                          final docData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final historyList =
                              (docData['history'] as List<dynamic>? ?? [])
                                  .cast<Map<String, dynamic>>();

                          historyList.sort((a, b) {
                            final aTime =
                                (a['startTime'] as Timestamp).toDate();
                            final bTime =
                                (b['startTime'] as Timestamp).toDate();
                            return bTime.compareTo(aTime); // descending
                          });

                          if (historyList.isEmpty) {
                            return _buildEmptyState();
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 20),
                            itemCount: historyList.length,
                            itemBuilder: (context, index) {
                              final item = historyList[index];

                              final startTime =
                                  (item['startTime'] as Timestamp).toDate();
                              final endTime =
                                  (item['endTime'] as Timestamp).toDate();
                              final name = item['name'] ?? '';

                              final dateString =
                                  '${startTime.day.toString().padLeft(2, '0')} '
                                  '${_monthString(startTime.month)} '
                                  '${startTime.year}';

                              return HistoryItem(
                                date: dateString,
                                location: name,
                                endedAt: endTime,
                                startedAt: startTime,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_outlined,
              size: 48,
              color: g2.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No History Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your parking sessions will appear here',
            style: TextStyle(
              fontSize: 12,
              color: mutedText.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _monthString(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }
}

class HistoryItem extends StatelessWidget {
  final String date;
  final String location;
  final DateTime endedAt;
  final DateTime startedAt;

  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  const HistoryItem({
    super.key,
    required this.date,
    required this.location,
    required this.endedAt,
    required this.startedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: g3.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: g2.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date column
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: g5.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: g5.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.split(' ')[0], // Day
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: g2,
                      height: 1,
                    ),
                  ),
                  Text(
                    date.split(' ')[1], // Month
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: mutedText.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${startedAt.toString().substring(11, 16)} - ${endedAt.toString().substring(11, 16)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: mutedText.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: g5,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(endedAt.difference(startedAt)),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: g3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cardGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: g2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
