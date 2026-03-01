class BiometricState {
  final bool isSupported;
  final bool hasBiometrics;
  final bool isEnabled;

  const BiometricState({
    required this.isSupported,
    required this.hasBiometrics,
    required this.isEnabled,
  });

  factory BiometricState.initial() {
    return const BiometricState(
      isSupported: false,
      hasBiometrics: false,
      isEnabled: false,
    );
  }

  BiometricState copyWith({
    bool? isSupported,
    bool? hasBiometrics,
    bool? isEnabled,
  }) {
    return BiometricState(
      isSupported: isSupported ?? this.isSupported,
      hasBiometrics: hasBiometrics ?? this.hasBiometrics,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
