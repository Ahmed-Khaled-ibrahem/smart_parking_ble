import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'area_configuration_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<String> parkingAreas = ['P1'];

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

  // void _addArea() {
  //   final TextEditingController controller = TextEditingController();
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Add New Parking Area'),
  //       content: TextField(
  //         controller: controller,
  //         decoration: const InputDecoration(
  //           hintText: 'Enter area name (e.g., P2)',
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             if (controller.text.isNotEmpty) {
  //               setState(() => parkingAreas.add(controller.text));
  //               Navigator.pop(context);
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: darkGreenBtn),
  //           child: const Text('Add', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // void _removeArea(int index) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Confirm Removal'),
  //       content: Text(
  //         'Are you sure you want to remove ${parkingAreas[index]}?',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             setState(() => parkingAreas.removeAt(index));
  //             Navigator.pop(context);
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red.shade700,
  //           ),
  //           child: const Text('Remove', style: TextStyle(color: Colors.white)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Align(
            alignment: AlignmentGeometry.center,
            child: Column(
              children: [
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo/logo.png',
                        width: 36,
                        height: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MAWQIFI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: darkText,
                          ),
                        ),
                        Text(
                          'ADMIN PANEL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: mutedText.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              // — Gradient top strip —
              Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [g5, g2, g1]),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // lottie
                    const SizedBox(height: 10),
                    Lottie.asset(
                      'assets/lottie/admin.json',
                      width: double.infinity,
                      // height: 200,
                    ),
                    // — Top bar —
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              // — Section label —
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 16),
                                child: Text(
                                  'PARKING AREAS',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    color: mutedText,
                                  ),
                                ),
                              ),
                              // — Stats row —
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 20,
                                ),
                                child: Row(
                                  children: [
                                    _StatBadge(
                                      icon: Icons.local_parking_rounded,
                                      label: '${parkingAreas.length} Areas',
                                      color: g2,
                                    ),
                                    const SizedBox(width: 10),
                                    _StatBadge(
                                      icon: Icons.check_circle_rounded,
                                      label: 'Active',
                                      color: const Color(0xFF40C074),
                                    ),
                                  ],
                                ),
                              ),
                              // — Grid —
                              SizedBox(
                                width: double.infinity,
                                height: 200,
                                child: GridView.builder(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1.1,
                                      ),
                                  itemCount: parkingAreas.length,
                                  itemBuilder: (context, index) {
                                    return _ParkingAreaCard(
                                      areaName: parkingAreas[index],
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AreaConfigurationScreen(
                                                areaName: parkingAreas[index],
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // — Sign Out Button —
                              GestureDetector(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/',
                                    );
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFDC3232,
                                    ).withOpacity(0.08),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFDC3232,
                                      ).withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        size: 18,
                                        color: Color(0xFFc0392b),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'SIGN OUT',
                                        style: TextStyle(
                                          color: Color(0xFFc0392b),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParkingAreaCard extends StatelessWidget {
  final String areaName;
  final VoidCallback onTap;

  // — Color palette —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  const _ParkingAreaCard({required this.areaName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cardGreen, lightGreen],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: g3.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: g2.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: g5.withOpacity(0.15),
                  ),
                ),
              ),
              Positioned(
                left: -10,
                bottom: -30,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: g2.withOpacity(0.05),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [g2, g3],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: g2.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_parking_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),

                    // Area name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AREA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: mutedText.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          areaName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow indicator
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: g2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
