import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color buttonGreen = Color(0xFF52796F);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<double>(
      begin: 30,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    checkUserLoggedIn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: AnimatedBuilder(
            animation: _slideUp,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _slideUp.value),
                child: child,
              );
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo - location pin with car
                    _MawqifiLogo(),

                    const SizedBox(height: 32),

                    // Welcome To MAWQIFI
                    const Text(
                      'WELCOME\nTO\nMAWQIFI',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: primaryGreen,
                        height: 1.1,
                        letterSpacing: 1,
                        fontFamily: 'Georgia',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    const Text(
                      'A SMART ASSISTANT PARKING APP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // GET STARTED Button
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryGreen,
                          side: const BorderSide(
                            color: buttonGreen,
                            width: 1.5,
                          ),
                          backgroundColor: const Color(0xFFE8F0EC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'GET STARTED',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void checkUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}

class _MawqifiLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 150,
      child: Image.asset('assets/images/logo/logo.png'),
    );
  }
}
