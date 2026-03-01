import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../app/widgets/login_button.dart';
import '../../../controller/auth_controller.dart';

class GoogleButton extends ConsumerWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return loginButton(
      text: 'Continue with Google',
      icon: SvgPicture.asset('assets/icons/google.svg', width: height * 0.04),
      onPressed: () {
        // context.push('/login-email');
        // context.go('/engineer-home');
        final authController = ref.read(authControllerProvider.notifier);
        authController.signInWithGoogle();
      },
      width: width,
      height: height,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
    );
  }
}
