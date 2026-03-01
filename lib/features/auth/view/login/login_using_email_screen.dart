import 'package:smart_parking_ble/app/helpers/validators/email_validator.dart';
import 'package:smart_parking_ble/features/auth/view/login/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../controller/auth_controller.dart';

class LoginWithEmailScreen extends ConsumerStatefulWidget {
  const LoginWithEmailScreen({super.key});

  @override
  ConsumerState createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends ConsumerState<LoginWithEmailScreen> {
  TextEditingController? textController1;
  TextEditingController? textController2;
  late bool passwordVisibility;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isEdited = true;

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    textController2 = TextEditingController();
    passwordVisibility = false;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final authController = ref.read(authControllerProvider.notifier);
    final user = ref.watch(authControllerProvider);

    return Form(
      key: formKey,
      child: Scaffold(
        key: scaffoldKey,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const LogoWidget(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20,
                          ),
                          child: TextFormField(
                            controller: textController1,
                            style: TextStyle(
                              fontSize: height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (value) {
                              isEdited = true;
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
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20,
                          ),
                          child: TextFormField(
                            controller: textController2,
                            obscureText: !passwordVisibility,
                            style: TextStyle(
                              fontSize: height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (value) {
                              isEdited = true;
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
                                  () =>
                                      passwordVisibility = !passwordVisibility,
                                ),
                                child: Icon(
                                  passwordVisibility
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0x98757575),
                                  size: 18,
                                ),
                              ),
                            ),
                            validator: (val) {
                              if (val == null) {
                                return 'Required';
                              }
                              if (val.isEmpty) {
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
                Align(
                  alignment: AlignmentGeometry.topRight,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 20, 0),
                    child: InkWell(
                      onTap: () {
                        context.push('/forgot-password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: height * 0.02,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.greenHover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 25),
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: AppColors.darkBackGround,
                          fixedSize: Size(width * 0.8, height * 0.06),
                        ),
                        onPressed: () {
                          if (user.isLoading) return;
                          if (!isEdited) return;

                          isEdited = false;
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          authController.signInWithEmail(
                            textController1!.text.trim(),
                            textController2!.text.trim(),
                          );
                        },
                        child: user.isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.gray,
                              )
                            : Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: height * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.02),
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(fontSize: height * 0.02),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          4,
                          0,
                          0,
                          0,
                        ),
                        child: InkWell(
                          onTap: () async {
                            context.push('/sign-up');
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: height * 0.02,
                              color: AppColors.greenHover,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
