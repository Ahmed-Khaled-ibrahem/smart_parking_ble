import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/profile.dart';

class ParkingHistoryScreen extends ConsumerWidget {
  const ParkingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(profileProvider)?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
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
                color: const Color(0xFF698E78),
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
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('profiles')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                          child: Text('No history available.'),
                        );
                      }

                      final docData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final historyList =
                          (docData['history'] as List<dynamic>? ?? [])
                              .cast<Map<String, dynamic>>();

                      historyList.sort((a, b) {
                        final aTime = (a['startTime'] as Timestamp).toDate();
                        final bTime = (b['startTime'] as Timestamp).toDate();
                        return bTime.compareTo(aTime); // descending
                      });

                      if (historyList.isEmpty) {
                        return const Center(
                          child: Text('No history available.'),
                        );
                      }

                      return ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (context, index) {
                          final item = historyList[index];

                          final startTime = (item['startTime'] as Timestamp)
                              .toDate();
                          final endTime = (item['endTime'] as Timestamp)
                              .toDate();
                          final name = item['name'] ?? '';
                          final id = item['id'] ?? '';

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
            ),
          ],
        ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      startedAt.toString().substring(11, 16),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      endedAt.toString().substring(11, 16),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
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
