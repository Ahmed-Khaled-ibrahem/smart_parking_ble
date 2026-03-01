import 'package:smart_parking_ble/features/auth/controller/auth_controller.dart';
import 'package:smart_parking_ble/features/auth/view/login/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/helpers/validators/email_validator.dart';
import '../../../../app/theme/app_theme.dart';
import '../login/widgets/agreement_widget.dart';

class SignupWithEmailScreen extends ConsumerStatefulWidget {
  const SignupWithEmailScreen({super.key});
  @override
  ConsumerState createState() => _SignupWithEmailScreenState();
}

class _SignupWithEmailScreenState extends ConsumerState<SignupWithEmailScreen> {
  TextEditingController? emailTextController;
  TextEditingController? passwordTextController;
  TextEditingController? confirmPasswordTextController;
  late bool passwordVisibility1;
  late bool passwordVisibility2;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isEdited = true;

  @override
  void initState() {
    super.initState();
    emailTextController = TextEditingController();
    passwordTextController = TextEditingController();
    passwordVisibility1 = false;
    confirmPasswordTextController = TextEditingController();
    passwordVisibility2 = false;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final authController = ref.read(authControllerProvider.notifier);
    final user = ref.watch(authControllerProvider);

    if (user.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: formKey,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: InkWell(
              onTap: () async {
                context.pop();
              },
              child: const Icon(Icons.arrow_back_ios_new),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const LogoWidget(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            32,
                            0,
                            32,
                            0,
                          ),
                          child: TextFormField(
                            controller: emailTextController,
                            onChanged: (value) {
                              setState(() {
                                isEdited = true;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xA6696969),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xA6696969),
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
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            32,
                            0,
                            32,
                            0,
                          ),
                          child: TextFormField(
                            controller: passwordTextController,
                            obscureText: !passwordVisibility1,
                            onChanged: (value) {
                              setState(() {
                                isEdited = true;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xA6696969),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xA6696969),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              suffixIcon: InkWell(
                                onTap: () => setState(
                                  () => passwordVisibility1 =
                                      !passwordVisibility1,
                                ),
                                child: Icon(
                                  passwordVisibility1
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0x98757575),
                                  size: 18,
                                ),
                              ),
                            ),

                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Required';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            32,
                            0,
                            32,
                            0,
                          ),
                          child: TextFormField(
                            controller: confirmPasswordTextController,
                            obscureText: !passwordVisibility2,
                            onChanged: (value) {
                              setState(() {
                                isEdited = true;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xA6696969),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xA6696969),
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              suffixIcon: InkWell(
                                onTap: () => setState(
                                  () => passwordVisibility2 =
                                      !passwordVisibility2,
                                ),
                                child: Icon(
                                  passwordVisibility2
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0x98757575),
                                  size: 18,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Required';
                              }
                              if (val != passwordTextController!.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(32, 32, 32, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.darkBackGround,
                      minimumSize: Size.fromHeight(height * 0.06),
                    ),
                    onPressed: () async {
                      if (user.isLoading) {
                        return;
                      }
                      if (!isEdited) {
                        return;
                      }
                      isEdited = false;

                      if (!(formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      await authController.signUpWithEmail(
                        emailTextController?.text.trim() ?? '',
                        passwordTextController?.text.trim() ?? '',
                      );
                      // context.push('/verify-email');
                    },
                    child: user.isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const AgreementWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
