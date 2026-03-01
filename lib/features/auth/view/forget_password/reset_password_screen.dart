import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController? textController1;
  late bool passwordVisibility1;
  TextEditingController? textController2;
  late bool passwordVisibility2;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    textController1 = TextEditingController();
    passwordVisibility1 = false;
    textController2 = TextEditingController();
    passwordVisibility2 = false;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Form(
      key: formKey,
      child: Scaffold(
        key: scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.02,
                  horizontal: width * 0.04,
                ),
                child: Text(
                  'Reset Password',
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
                        'Set up the new password bellow.',
                        style: TextStyle(fontSize: height * 0.02),
                        textAlign: TextAlign.center,
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
                          controller: textController1,
                          obscureText: !passwordVisibility1,
                          style: TextStyle(fontSize: height * 0.02),
                          decoration: InputDecoration(
                            hintText: 'New Password',
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
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () =>
                                    passwordVisibility1 = !passwordVisibility1,
                              ),
                              child: Icon(
                                passwordVisibility1
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xB2757575),
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Required';
                            }
                            if (val.length < 6) {
                              return 'Password should greater than 6 characters';
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
                padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
                        child: TextFormField(
                          controller: textController2,
                          obscureText: !passwordVisibility2,
                          style: TextStyle(fontSize: height * 0.02),
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',

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
                            suffixIcon: InkWell(
                              onTap: () => setState(
                                () =>
                                    passwordVisibility2 = !passwordVisibility2,
                              ),
                              child: Icon(
                                passwordVisibility2
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xB2757575),
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return 'Required';
                            }
                            if (val.length < 6) {
                              return 'Password should greater than 6 characters';
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
                padding: const EdgeInsetsDirectional.fromSTEB(32, 45, 32, 0),
                child: ElevatedButton(
                  onPressed: () {
                    print('Button pressed ...');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.darkBackGround,
                    minimumSize: Size.fromHeight(height * 0.06),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: height * 0.01),
                    child: Text(
                      'Finish',
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
    );
  }
}
