import 'package:smart_parking_ble/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo/logo.png',
                        height: 80,
                        width: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.engineering,
                              size: 60,
                              color: AppColors.greenHover,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ielectronyhub',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 24),
                // KPIs Grid
                const Text('Overview'),
                const SizedBox(height: 16),
                const SizedBox(height: 24),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
