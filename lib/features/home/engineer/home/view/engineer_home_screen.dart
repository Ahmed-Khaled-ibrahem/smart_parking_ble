import 'package:smart_parking_ble/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EngineerHomeScreen extends ConsumerStatefulWidget {
  const EngineerHomeScreen({super.key});

  @override
  EngineerHomeScreenState createState() => EngineerHomeScreenState();
}

class EngineerHomeScreenState extends ConsumerState<EngineerHomeScreen> {
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    // final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Sample data - replace with actual data from your state management
    final kpiData = {
      'Money Made': r'$2,450',
      'Total Projects': '12',
      'Open Projects': '3',
      'Unread Messages': '5',
    };

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/images/logo/logo.png',
                      height: 40,
                      width: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.engineering,
                        size: 60,
                        color: AppColors.greenHover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ielectronyhub',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hi, Ahmed 👋',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),

                // Active for new projects card
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.blue.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.work_outline_rounded,
                          color: isActive ? AppColors.blue : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Active State',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Available to receive Messages',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isActive,
                        activeThumbColor: AppColors.blue,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // KPIs Grid
                Text(
                  'Overview',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildKpiGrid(kpiData, theme, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getKpiIcon(String title) {
    switch (title) {
      case 'Money Made':
        return Icons.attach_money_rounded;
      case 'Total Projects':
        return Icons.folder_copy_rounded;
      case 'Open Projects':
        return Icons.folder_open_rounded;
      case 'Unread Messages':
        return Icons.mark_email_unread_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildKpiGrid(
    Map<String, String> kpiData,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    final entries = kpiData.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final icon = _getKpiIcon(entry.key);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 24, color: AppColors.blue),
              const Spacer(),
              Text(
                entry.value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.key,
                style: textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
        );
      },
    );
  }
}
