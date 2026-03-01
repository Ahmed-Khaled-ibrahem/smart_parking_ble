import 'package:smart_parking_ble/app/helpers/dialogs/confirmation_dialog.dart';
import 'package:smart_parking_ble/app/helpers/toast/app_toast.dart';
import 'package:smart_parking_ble/app/theme/app_theme.dart';
import 'package:smart_parking_ble/app/theme/theme_provider.dart';
import 'package:smart_parking_ble/features/biometric/controller/biometric_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final biometricEnabledCtrl = ref.read(biometricControllerProvider.notifier);
    final biometricState = ref.watch(biometricControllerProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/onboarding', extra: true);
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Preferences'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildLanguageWidget(),
                  const Divider(height: 1),
                  _buildThemeOption(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // _buildSectionTitle('Notifications'),
            // const SizedBox(height: 12),
            // _buildSettingsCard(child: _buildNotificationToggle()),
            const SizedBox(height: 32),
            _buildSectionTitle('Authentication'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              child: SwitchListTile(
                title: const Text('Enable Biometric Login'),
                value: biometricEnabledCtrl.isEnabled,
                inactiveThumbColor: AppColors.blue,
                activeTrackColor: AppColors.blue.withValues(alpha: 0.1),
                activeThumbColor: AppColors.blue,
                onChanged: (value) async {
                  if (biometricEnabledCtrl.isEnabled) {
                    await biometricEnabledCtrl.setBiometricEnabled(value);
                    return;
                  }

                  final supported =
                       biometricState.requireValue.isSupported;
                  final hasBio =
                       biometricState.requireValue.hasBiometrics;

                  if (!supported) {
                    AppToast.info(
                      'Biometric authentication is not supported on this device',
                    );
                    return;
                  }
                  if (!hasBio) {
                    AppToast.info(
                      'No biometric authentication available on this device',
                    );
                    return;
                  }
                  if (!mounted) {
                    return;
                  }
                  bool? isConfirmed = await ConfirmationDialog.show(
                    title: 'Biometric',
                    message: 'Are you sure you want to enable biometric login',
                    context: mounted ? context : null,
                  );

                  if (isConfirmed == true) {
                    final success = await biometricEnabledCtrl.authenticate(
                      reason: 'Login with fingerprint or face',
                    );
                    if (success) {
                      await biometricEnabledCtrl.setBiometricEnabled(value);
                      AppToast.success('Biometric login enabled');
                    }
                  }
                },
                secondary: const Icon(Icons.fingerprint),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage(
                      'assets/images/logo/IElectrony-Logo-Final-arabic.png',
                    ),
                    height: 60,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Powered by iElectrony',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildLanguageWidget() {
    return InkWell(
      onTap: () => _showLanguageDialog(),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.language,
                color: AppColors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Language',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.locale == const Locale('en') ? 'english' : 'arabic',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFA0AEC0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption() {
    final themeMode = ref.read(themeModeProvider);

    return InkWell(
      onTap: () => _showThemeDialog(),
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.palette_outlined,
                color: AppColors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    themeMode.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFA0AEC0),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption('en'),
              const SizedBox(height: 12),
              _buildLanguageOption('ar'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String languageCode) {
    // final currentLanguage = ref.read(languageProvider);
    final isSelected = context.locale.languageCode == languageCode;
    return InkWell(
      onTap: () {
        context.setLocale(Locale(languageCode));
        context.pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.gray ,
          ),
        ),
        child: Row(
          children: [
            Text(
              languageCode == 'en' ? 'english' : 'Arabic',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.blue : AppColors.gray ,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.blue, size: 20),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Theme',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildThemeOptionItem(ThemeMode.light, Icons.light_mode),
              const SizedBox(height: 12),
              _buildThemeOptionItem(ThemeMode.dark, Icons.dark_mode),
              const SizedBox(height: 12),
              _buildThemeOptionItem(ThemeMode.system, Icons.brightness_auto),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptionItem(ThemeMode theme, IconData icon) {
    final themeModeCtrl = ref.read(themeModeProvider.notifier);
    final themeMode = ref.read(themeModeProvider);
    final isSelected = themeMode == theme;

    return InkWell(
      onTap: () {
        themeModeCtrl.setThemeMode(theme);
        context.pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.gray,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.blue : AppColors.gray,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.blue : AppColors.gray,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.blue, size: 20),
          ],
        ),
      ),
    );
  }
}
