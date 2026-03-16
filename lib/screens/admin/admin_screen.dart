import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'area_configuration_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<String> parkingAreas = ['P1'];

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'MAWQIFI ADMIN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
          ],
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PARKING AREAS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: parkingAreas.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AreaConfigurationScreen(
                              areaName: parkingAreas[index],
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: lightGreenBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              parkingAreas[index],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 4,
                      //   right: 4,
                      //   child: IconButton(
                      //     icon: const Icon(
                      //       Icons.remove_circle,
                      //       color: Colors.red,
                      //     ),
                      //     onPressed: () => _removeArea(index),
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 32,
                ),
                backgroundColor: Colors.red.shade700,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              child: const Text(
                'SIGN OUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _addArea,
      //   backgroundColor: darkGreenBtn,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
    );
  }
}

// Theme constants
const Color primaryGreen = Color(0xFF2D5A47);
const Color secondaryGreen = Color(0xFF8BAA9B);
const Color lightGreenBg = Color(0xFFD1E0D7);
const Color darkGreenBtn = Color(0xFF1E4D3B);
