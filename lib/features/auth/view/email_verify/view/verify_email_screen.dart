import 'dart:async';
import 'package:smart_parking_ble/app/helpers/info/logging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../controller/auth_controller.dart';

class VerifyAccountScreen extends ConsumerStatefulWidget {
  const VerifyAccountScreen({super.key});
  @override
  ConsumerState<VerifyAccountScreen> createState() =>
      _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends ConsumerState<VerifyAccountScreen> {
  TextEditingController? textController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _timer;
  int _start = 100;
  bool _isResendEnabled = false;
  final EmailVerificationChecker _emailVerificationChecker =
      EmailVerificationChecker();

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    startTimer();
    _emailVerificationChecker.startChecking(
      onVerified: () {
        ref.invalidate(authControllerProvider);
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    textController?.dispose();
    _emailVerificationChecker.stopChecking();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _isResendEnabled = false;
      _start = 100;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isResendEnabled = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String get timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final authController = ref.read(authControllerProvider.notifier);
    final user = ref.watch(authControllerProvider);

    if (user.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(automaticallyImplyLeading: false),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                child: Text(
                  'Verify Account',
                  style: TextStyle(
                    fontSize: height * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        32,
                        16,
                        0,
                      ),
                      child: Text(
                        'Click on the link received via e-mail, to confirm your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: height * 0.02),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 45, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          16,
                          0,
                          0,
                          0,
                        ),
                        child: Text(
                          'Didn\'t receive?',
                          style: TextStyle(fontSize: height * 0.02),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          8,
                          0,
                          0,
                          0,
                        ),
                        child: _isResendEnabled
                            ? InkWell(
                                onTap: () async {
                                  await authController
                                      .resendVerificationEmail();
                                  startTimer();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Verification email resent!',
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    color: AppColors.greenHover,
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Text(
                                'Resend in $timerText',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: height * 0.02,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                child: CircularProgressIndicator(
                  color: AppColors.greenHover,
                  strokeWidth: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
                child: TextButton(
                  child: Text(user.isLoading ? 'Loading...' : 'Logout'),
                  onPressed: () {
                    if (user.isLoading) return;
                    authController.signOut();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailVerificationChecker {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;

  void startChecking({
    required VoidCallback onVerified,
    Duration interval = const Duration(seconds: 4),
  }) {
    _timer = Timer.periodic(interval, (_) async {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await user.reload();
          logApp(' verified : ${user.emailVerified}');
          if (user.emailVerified) {
            _timer?.cancel();
            onVerified();
          }
        }
      } catch (e) {}
    });
  }

  void stopChecking() {
    _timer?.cancel();
  }
}
