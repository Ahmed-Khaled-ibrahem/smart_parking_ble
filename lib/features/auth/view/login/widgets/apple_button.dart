import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/widgets/login_button.dart';
import '../../../controller/auth_controller.dart';

class AppleButton extends ConsumerWidget {
  const AppleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final authController = ref.read(authControllerProvider.notifier);

    return loginButton(
      text: 'Continue with Apple',
      icon: Icon(Icons.apple, size: height * 0.04),
      onPressed: () {
        // authController.signInWithApple();
        // context.push('/login-email');
        // context.go('/admin-home');
      },
      width: width,
      height: height,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }
}
