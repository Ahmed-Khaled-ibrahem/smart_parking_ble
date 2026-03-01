
import 'package:smart_parking_ble/features/auth/view/login/widgets/agreement_widget.dart';
import 'package:smart_parking_ble/features/auth/view/login/widgets/email_button.dart';
import 'package:smart_parking_ble/features/auth/view/login/widgets/google_button.dart';
import 'package:smart_parking_ble/features/auth/view/login/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider);

    if (user.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LogoWidget(),
                        SizedBox(height: 24),
                        EmailButton(),
                        GoogleButton(),
                        // AppleButton(),
                      ],
                    ),
                  ),
                  const AgreementWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
