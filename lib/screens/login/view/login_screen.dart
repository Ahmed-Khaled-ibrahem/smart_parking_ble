import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
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
    _emailController.dispose();
    _passwordController.dispose();
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
                                'WELCOME BACK',
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
                                  TextSpan(text: 'Sign into\nyour '),
                                  TextSpan(
                                    text: 'account',
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
                              'Enter your credentials to continue',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5a7a65),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // — Floating car accent —
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20, bottom: 4),
                          child: Transform.rotate(
                            angle: 0.14,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFB7E4C7), cardGreen],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: g3.withOpacity(0.18),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: g2.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  '🚗',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

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
                                          hint: '••••••••',
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

                                        const SizedBox(height: 6),

                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {},
                                            child: const Text(
                                              'Forgot password?',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: g3,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: g3,
                                              ),
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
                                      onPressed: _isLoading ? null : _onSignIn,
                                      style:
                                          ElevatedButton.styleFrom(
                                            backgroundColor: g2,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            shadowColor: g1.withOpacity(0.3),
                                          ).copyWith(
                                            elevation: WidgetStateProperty.all(
                                              4,
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
                                                  'SIGN IN',
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

                                  // Register link
                                  Column(
                                    children: [
                                      const Text(
                                        "DON'T HAVE AN ACCOUNT?",
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
                                              '/register',
                                            ),
                                        child: const Text(
                                          'REGISTER',
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

  Future<void> _onSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } on Exception catch (e) {
      _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
