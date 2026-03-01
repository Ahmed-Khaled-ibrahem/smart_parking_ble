import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/images/logo/logo.png',
                  width: width * 0.5,
                  height: height * 0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: Text(
                  'ielectronyhub',
                  style: TextStyle(
                    fontSize: width * 0.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Lottie.asset(
                'assets/lottie/loading.json',
                width: width * 0.3,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
