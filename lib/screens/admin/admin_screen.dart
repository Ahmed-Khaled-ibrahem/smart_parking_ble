import 'package:flutter/material.dart';

// Theme constants
const Color primaryGreen = Color(0xFF2D5A47);
const Color secondaryGreen = Color(0xFF8BAA9B);
const Color lightGreenBg = Color(0xFFD1E0D7);
const Color darkGreenBtn = Color(0xFF1E4D3B);

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<String> parkingAreas = ['P1'];

  void _addArea() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Parking Area'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter area name (e.g., P2)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => parkingAreas.add(controller.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: darkGreenBtn),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeArea(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Removal'),
        content: Text('Are you sure you want to remove ${parkingAreas[index]}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => parkingAreas.removeAt(index));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: secondaryGreen,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.location_on, size: 20, color: Colors.green),
            ),
            const SizedBox(width: 8),
            const Text(
              'MAWQIFI ADMIN',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
                            builder: (context) => AreaConfigurationScreen(areaName: parkingAreas[index]),
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
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryGreen),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeArea(index),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addArea,
        backgroundColor: darkGreenBtn,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AreaConfigurationScreen extends StatefulWidget {
  final String areaName;
  const AreaConfigurationScreen({super.key, required this.areaName});

  @override
  State<AreaConfigurationScreen> createState() => _AreaConfigurationScreenState();
}

class _AreaConfigurationScreenState extends State<AreaConfigurationScreen> {
  final List<String> slots = ['A1', 'A2', 'A3', 'A4'];

  void _addSlot() {
    setState(() => slots.add('A${slots.length + 1}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: secondaryGreen,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'CONFIG: ${widget.areaName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'PARKING SLOTS',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: primaryGreen),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            slots[index],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: _addSlot,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('ADD NEW SLOT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreenBtn,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
