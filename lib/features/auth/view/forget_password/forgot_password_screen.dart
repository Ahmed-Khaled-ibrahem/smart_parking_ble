
import 'package:smart_parking_ble/app/helpers/toast/app_toast.dart';
import 'package:smart_parking_ble/app/helpers/validators/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../controller/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  TextEditingController? textController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isEdited = true;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final authController = ref.read(authControllerProvider.notifier);
    return Scaffold(
      key: scaffoldKey,
      body: Form(
        key: formKey,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                  child: Text(
                    'Forgot Password',
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
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 32, 16, 0),
                        child: Text(
                          'Enter your e-mail address bellow to receive the code for setting up a new password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: height * 0.02),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                          child: TextFormField(
                            controller: textController,
                            onChanged: (value) {
                              setState(() {
                                isEdited = true;
                              });
                            },
                            style: TextStyle(fontSize: height * 0.02),
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x98757575),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x98757575),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            validator: verifyEmail,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text('we will sent reset mail to you'),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.darkBackGround,
                      minimumSize: Size.fromHeight(height * 0.06),
                    ),
                    onPressed: () {
                      if (!isEdited) {
                        return;
                      }
                      if (!(formKey.currentState?.validate() ?? false)) {
                        return;
                      }

                      isEdited = false;
                      authController.sendPasswordResetEmail(
                        textController!.text.trim(),
                      );
                      context.pop();
                      AppToast.success('Check your email for reset code!');
                      // context.push('/reset-password');
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.01),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: height * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
