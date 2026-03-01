import 'package:smart_parking_ble/features/biometric/model/bio_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final biometricControllerProvider =
    AsyncNotifierProvider<BiometricController, BiometricState>(
      BiometricController.new,
    );

class BiometricController extends AsyncNotifier<BiometricState> {
  final _enabledKey = 'biometric_enabled';

  final LocalAuthentication _auth = LocalAuthentication();

  bool get isEnabled => state.requireValue.isEnabled;

  @override
  Future<BiometricState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isSupported = await _safe(() => _auth.isDeviceSupported());
    final hasBiometrics = await _safe(() => _auth.canCheckBiometrics);
    final isEnabled = prefs.getBool(_enabledKey) ?? false;
    return BiometricState(
      isSupported: isSupported,
      hasBiometrics: hasBiometrics,
      isEnabled: isEnabled,
    );
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);
      state = AsyncData(state.requireValue.copyWith(isEnabled: enabled));
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }

  Future<bool> getBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    final bool success = await _auth.authenticate(localizedReason: reason);
    return success;
  }

  Future<bool> _safe(Future<bool> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return false;
    }
  }
}
