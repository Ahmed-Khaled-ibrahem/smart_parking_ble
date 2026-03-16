import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../model/profile.dart';
import '../../../providers/profile.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkUserLoggedIn();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
      ),
    );
  }

  Future checkUserLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await readProfileFromFirebase(user.uid);
      if (profile == null) {
        return;
      }
      ref.read(profileProvider.notifier).setProfile(profile);
      await Future.delayed(Duration(microseconds: 800));
      if (profile.role == UserRole.admin) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<Profile?> readProfileFromFirebase(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return Profile.fromJson(doc.data() ?? {});
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
