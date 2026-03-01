import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/widgets/login_button.dart';
import '../../../../../app/theme/app_theme.dart';

class EmailButton extends StatelessWidget {
  const EmailButton({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return loginButton(
      text: 'Continue with E-mail',
      icon: Icon(Icons.mail, size: height * 0.04),
      onPressed: () {
        context.push('/login-email');
        // context.push('/profile-setup');
        // context.go('/client-home');
      },
      width: width,
      height: height,
      foregroundColor: AppColors.darkBackGround,
      backgroundColor: AppColors.orange,
    );
  }
}
