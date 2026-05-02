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
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _contentController;

  late Animation<double> _bgScale;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _chipsFade;
  late Animation<Offset> _chipsSlide;
  late Animation<double> _btnScale;

  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bgScale = Tween<double>(
      begin: 1.08,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeOut));

    _fadeIn = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );

    _chipsFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
    );

    _chipsSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
          ),
        );

    _btnScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _bgController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkUserLoggedIn();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgController, _contentController]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // — Animated dark-green background —
              Transform.scale(
                scale: _bgScale.value,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF0A1F14), g1, g2],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              // — Decorative circles —
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF52796F).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -50,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: g5.withOpacity(0.12), width: 1),
                  ),
                ),
              ),
              Positioned(
                bottom: 155,
                left: 0,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: g6.withOpacity(0.1), width: 1),
                  ),
                ),
              ),
              // — Content —
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideUp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Brand row
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: g5.withOpacity(0.18),
                                  border: Border.all(
                                    color: g5.withOpacity(0.3),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Center(
                                  child: Text(
                                    'P',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: g5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'MAWQIFI',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.5,
                                  color: g6.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                          // logo
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 40,
                              ),
                              child: Image.asset(
                                'assets/images/logo/logo.png',
                                width: 200,
                                height: 200,
                              ),
                            ),
                          ),
                          // Pill tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: g5.withOpacity(0.12),
                              border: Border.all(
                                color: g5.withOpacity(0.22),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'SMART PARKING',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.2,
                                color: g5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Main title
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                color: Colors.white,
                              ),
                              children: [
                                const TextSpan(text: 'Find\nYour '),
                                TextSpan(
                                  text: 'Spot,',
                                  style: TextStyle(color: g5),
                                ),
                                const TextSpan(text: '\nEasily.'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'YOUR PARKING ASSISTANT APP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                              color: g6.withOpacity(0.55),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Feature chips
                          FadeTransition(
                            opacity: _chipsFade,
                            child: SlideTransition(
                              position: _chipsSlide,
                              child: Row(
                                children: [
                                  _FeatureChip(label: 'Real-time'),
                                  const SizedBox(width: 8),
                                  _FeatureChip(label: 'BLE Detect'),
                                  const SizedBox(width: 8),
                                  _FeatureChip(label: 'Navigate'),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // CTA Button
                          ScaleTransition(
                            scale: _btnScale,
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: g5,
                                  foregroundColor: g1,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'START NOW',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2.5,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: g1.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        size: 13,
                                        color: g1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Login link
                          Center(
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: g5.withOpacity(0.45),
                                  ),
                                  children: [
                                    const TextSpan(text: 'Already a member? '),
                                    TextSpan(
                                      text: 'Sign in',
                                      style: TextStyle(
                                        color: g5,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: g5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future _checkUserLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = await _readProfileFromFirebase(user.uid);
      if (profile == null) return;
      ref.read(profileProvider.notifier).setProfile(profile);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      if (profile.role == UserRole.admin) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<Profile?> _readProfileFromFirebase(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return Profile.fromJson(doc.data() ?? {});
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF74C69D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: const Color(0xFFB7E4C7).withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
