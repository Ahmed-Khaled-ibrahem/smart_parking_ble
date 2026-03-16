import 'package:flutter/material.dart';
import 'package:smart_parking_ble/screens/admin/parking_area_selector.dart';
import 'admin_screen.dart';

class AreaConfigurationScreen extends StatefulWidget {
  final String areaName;

  const AreaConfigurationScreen({super.key, required this.areaName});

  @override
  State<AreaConfigurationScreen> createState() =>
      _AreaConfigurationScreenState();
}

class _AreaConfigurationScreenState extends State<AreaConfigurationScreen> {
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
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'CONFIG: ${widget.areaName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
      ),
      body: ParkingScreenAdmin(),
    );
  }
}
