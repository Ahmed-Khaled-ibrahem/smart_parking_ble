import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../model/profile.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _formSlide;
  late Animation<double> _formFade;

  // — Color palette —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _formSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
          ),
        );

    _formFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.9, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // — Gradient top strip —
            Container(
              height: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [g5, g2, g1]),
              ),
            ),

            SizedBox(height: 20),
            Expanded(
              child: SafeArea(
                top: false,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // — Top bar —
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            _CircleIconButton(
                              onTap: () => Navigator.pop(context),
                              color: lightGreen,
                              icon: Icons.chevron_left,
                              iconColor: g2,
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: g2,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Center(
                                child: Text(
                                  'P',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'MAWQIFI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                                color: Color(0xFF0A1F14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // — Hero header —
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: g3.withOpacity(0.08),
                                border: Border.all(
                                  color: g3.withOpacity(0.18),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'NEW ACCOUNT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: g3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  color: Color(0xFF0A1F14),
                                ),
                                children: [
                                  TextSpan(text: 'Create your\n'),
                                  TextSpan(
                                    text: 'profile',
                                    style: TextStyle(
                                      color: g2,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Join MAWQIFI in seconds',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5a7a65),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // — Step indicator —
                            Row(
                              children: [
                                _StepDot(active: true),
                                const SizedBox(width: 4),
                                _StepDot(active: false),
                                const SizedBox(width: 4),
                                _StepDot(active: false),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // — Form —
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SlideTransition(
                            position: _formSlide,
                            child: FadeTransition(
                              opacity: _formFade,
                              child: Column(
                                children: [
                                  // Form card
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cardGreen,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: g3.withOpacity(0.12),
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _FieldLabel(
                                          icon: Icons.person_outline,
                                          label: 'FULL NAME',
                                        ),
                                        const SizedBox(height: 6),
                                        _StyledTextField(
                                          controller: _nameController,
                                          hint: 'Enter your name',
                                          keyboardType: TextInputType.name,
                                        ),

                                        const SizedBox(height: 14),

                                        _FieldLabel(
                                          icon: Icons.alternate_email,
                                          label: 'EMAIL',
                                        ),
                                        const SizedBox(height: 6),
                                        _StyledTextField(
                                          controller: _emailController,
                                          hint: 'your@email.com',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),

                                        const SizedBox(height: 14),

                                        _FieldLabel(
                                          icon: Icons.lock_outline,
                                          label: 'PASSWORD',
                                        ),
                                        const SizedBox(height: 6),
                                        _StyledTextField(
                                          controller: _passwordController,
                                          hint: 'Create password',
                                          obscureText: _obscurePassword,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: const Color(0xFF8aab95),
                                              size: 18,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        _FieldLabel(
                                          icon: Icons.check_circle_outline,
                                          label: 'CONFIRM PASSWORD',
                                        ),
                                        const SizedBox(height: 6),
                                        _StyledTextField(
                                          controller:
                                              _confirmPasswordController,
                                          hint: 'Repeat password',
                                          obscureText: _obscureConfirm,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirm
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: const Color(0xFF8aab95),
                                              size: 18,
                                            ),
                                            onPressed: () => setState(
                                              () => _obscureConfirm =
                                                  !_obscureConfirm,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Submit button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _onRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: g2,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: g1.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'CREATE ACCOUNT',
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
                                                    color: Colors.white
                                                        .withOpacity(0.18),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.arrow_forward,
                                                    size: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Login link
                                  Column(
                                    children: [
                                      const Text(
                                        'ALREADY HAVE AN ACCOUNT?',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF8aab95),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      GestureDetector(
                                        onTap: () =>
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/login',
                                            ),
                                        child: const Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: g2,
                                            letterSpacing: 0.5,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: g2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                ],
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
          ],
        ),
      ),
    );
  }

  Future<void> _onRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }
    if (password != confirm) {
      _showSnack('Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        _showSnack('Failed to register user', isError: true);
        return;
      }
      await _addNewUserProfile(user.uid, email, name);
      if (mounted) Navigator.pushReplacementNamed(context, '/');
    } on Exception catch (e) {
      _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addNewUserProfile(String uid, String email, String name) async {
    final profile = Profile(
      uid: uid,
      email: email,
      name: name.isNotEmpty ? name : email,
      createdAt: DateTime.now(),
      role: UserRole.user,
      parkingHistory: [],
      currentParking: null,
    );
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(uid)
        .set(profile.toJson());
  }


  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : g2,
      ),
    );
  }
}

// — Shared widgets —

class _CircleIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final Color iconColor;

  const _CircleIconButton({
    required this.onTap,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FieldLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF40916C),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 9, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: Color(0xFF5a7a65),
          ),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool active;

  const _StepDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 3,
      width: active ? 20 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2D6A4F) : const Color(0xFFB7E4C7),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF0A1F14)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFb0c4b8), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 1.5),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
