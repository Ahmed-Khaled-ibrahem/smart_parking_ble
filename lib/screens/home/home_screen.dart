import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/profile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _heroSlide;
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;

  // — Color palette —
  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeIn);

    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );

    _cardsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    _cardsSlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _userInitials {
    final profile = ref.read(profileProvider);
    if (profile == null) return 'ME';
    final name = profile.name!.trim();
    if (name.isEmpty) return 'ME';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String get _fullName {
    final profile = ref.read(profileProvider);
    return profile?.name ?? 'User';
  }

  String get _userEmail {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email ?? 'user@example.com';
  }

  String get _firstName {
    final profile = ref.read(profileProvider);
    if (profile == null) return 'there';
    final name = profile.name!.trim();
    if (name.isEmpty) return 'there';
    return name.split(' ').first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _openProfileSheet() {
    showModalBottomSheet(
      context: context,
      constraints: null,
      isScrollControlled: true,
      builder: (context) {
        return bottomSheet();
      },
    );
  }

  void _closeProfileSheet() {
    Navigator.pop(context);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // — Gradient top strip —
              Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [g5, g2, g1]),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SafeArea(
                  top: false,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // — Top bar —
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Center(
                                      // logo
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/logo/logo.png',
                                        ),
                                        width: 32,
                                        height: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'MAWQIFI',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.8,
                                        color: darkText,
                                      ),
                                    ),
                                  ],
                                ),

                                // Profile button
                                GestureDetector(
                                  onTap: _openProfileSheet,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [g3, g1],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: g6, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: g2.withOpacity(0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _userInitials,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // — Hero greeting —
                          SlideTransition(
                            position: _heroSlide,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                12,
                                20,
                                18,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFf0f7f3), Colors.white],
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: g3.withOpacity(0.08),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // Deco circle
                                  Positioned(
                                    right: -20,
                                    top: -20,
                                    child: Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            g5.withOpacity(0.12),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: g5.withOpacity(0.15),
                                              border: Border.all(
                                                color: g5.withOpacity(0.25),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '👋',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _greeting,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: mutedText,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            height: 1.05,
                                            color: darkText,
                                            fontFamily: 'Georgia',
                                          ),
                                          children: [
                                            const TextSpan(text: 'Hi, '),
                                            TextSpan(
                                              text: _firstName,
                                              style: const TextStyle(
                                                color: g2,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Where are you parking today?',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: mutedText,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: g3.withOpacity(0.08),
                                          border: Border.all(
                                            color: g3.withOpacity(0.18),
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF40C074),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Text(
                                              '3 SLOTS NEARBY',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.2,
                                                color: g3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // — Actions section with big cards —
                          SlideTransition(
                            position: _cardsSlide,
                            child: FadeTransition(
                              opacity: _cardsFade,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section label
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 2,
                                        bottom: 12,
                                      ),
                                      child: Text(
                                        'ACTIONS',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2,
                                          color: mutedText,
                                        ),
                                      ),
                                    ),

                                    // Find Parking Card (full width, dark gradient)
                                    _ActionCard(
                                      label: 'FIND PARKING',
                                      sublabel:
                                          'Scan & locate nearby available slots',
                                      icon: Icons.search_rounded,
                                      isDark: true,
                                      onTap: () =>
                                          Navigator.pushNamed(context, '/find'),
                                    ),

                                    const SizedBox(height: 12),

                                    // Two-column grid for Current and History
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ActionCard(
                                            label: 'CURRENT',
                                            sublabel: 'Active session',
                                            icon: Icons.directions_car_outlined,
                                            isDark: false,
                                            isSecondary: true,
                                            onTap: () => Navigator.pushNamed(
                                              context,
                                              '/current',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _ActionCard(
                                            label: 'HISTORY',
                                            sublabel: 'Past sessions',
                                            icon: Icons.assignment_outlined,
                                            isDark: false,
                                            isLight: true,
                                            onTap: () => Navigator.pushNamed(
                                              context,
                                              '/history',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {}, // Prevent closing when tapping the sheet
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: g2.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  // Sheet Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [g1, g2],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Header deco circle
                        Positioned(
                          right: -40,
                          top: -40,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                      border: Border.all(
                                        color: g6.withOpacity(0.5),
                                        width: 2.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _userInitials,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _userEmail,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: g6.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: g5.withOpacity(0.2),
                                      border: Border.all(
                                        color: g5.withOpacity(0.3),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: g5,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'USER',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.5,
                                            color: g5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Close button
                            GestureDetector(
                              onTap: _closeProfileSheet,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '✕',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Info rows
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_outline,
                          label: 'FULL NAME',
                          value: _fullName,
                        ),
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label: 'EMAIL',
                          value: _userEmail,
                        ),
                        _InfoRow(
                          icon: Icons.local_parking_outlined,
                          label: 'PARKING SESSIONS',
                          value: '12 total sessions',
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'MEMBER SINCE',
                          value: 'April 2025',
                        ),
                      ],
                    ),
                  ),

                  // Logout button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC3232).withOpacity(0.06),
                          border: Border.all(
                            color: const Color(0xFFDC3232).withOpacity(0.18),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '↩',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFc0392b),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'LOGOUT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: Color(0xFFc0392b),
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
          ),
        ],
      ),
    );
  }
}

// ——————————————————————————————
// Big Action Card Widget
// ——————————————————————————————

class _ActionCard extends StatefulWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool isDark;
  final bool isSecondary;
  final bool isLight;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.onTap,
    this.isDark = false,
    this.isSecondary = false,
    this.isLight = false,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  static const Color g1 = Color(0xFF1B4332);
  static const Color g2 = Color(0xFF2D6A4F);
  static const Color g3 = Color(0xFF40916C);
  static const Color g5 = Color(0xFF74C69D);
  static const Color g6 = Color(0xFFB7E4C7);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);
  static const Color cardGreen = Color(0xFFDDEDD8);
  static const Color lightGreen = Color(0xFFD8EAD3);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: g3.withOpacity(0.1), width: 1),
            gradient: widget.isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [g1, g2],
                  )
                : null,
            color: widget.isDark
                ? null
                : widget.isSecondary
                ? cardGreen
                : widget.isLight
                ? lightGreen
                : cardGreen,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Decorative circles
                if (widget.isDark) ...[
                  Positioned(
                    right: -30,
                    bottom: -40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: 20,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                ] else if (widget.isSecondary) ...[
                  Positioned(
                    right: -20,
                    bottom: -25,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: g2.withOpacity(0.05),
                      ),
                    ),
                  ),
                ] else if (widget.isLight) ...[
                  Positioned(
                    right: -15,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: g2.withOpacity(0.05),
                      ),
                    ),
                  ),
                ],

                // Card content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top row with icon and arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon box
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : widget.isSecondary
                                  ? g2.withOpacity(0.12)
                                  : g2.withOpacity(0.08),
                              border: widget.isDark
                                  ? null
                                  : Border.all(
                                      color: widget.isSecondary
                                          ? g2.withOpacity(0.18)
                                          : g2.withOpacity(0.12),
                                      width: 1,
                                    ),
                            ),
                            child: Icon(
                              widget.icon,
                              size: 20,
                              color: widget.isDark ? Colors.white : g2,
                            ),
                          ),
                          // Arrow
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isDark
                                  ? Colors.white.withOpacity(0.15)
                                  : widget.isSecondary
                                  ? g2.withOpacity(0.1)
                                  : g2.withOpacity(0.08),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 13,
                              color: widget.isDark ? Colors.white : g2,
                            ),
                          ),
                        ],
                      ),

                      // Label and sublabel
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: widget.isDark ? 15 : 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: widget.isDark ? Colors.white : darkText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.sublabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: widget.isDark
                                  ? g6.withOpacity(0.75)
                                  : mutedText,
                            ),
                          ),
                        ],
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

// ——————————————————————————————
// Info Row Widget for Profile Sheet
// ——————————————————————————————

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  static const Color g2 = Color(0xFF2D6A4F);
  static const Color darkText = Color(0xFF0A1F14);
  static const Color mutedText = Color(0xFF5a7a65);

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: g2.withOpacity(0.07), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: g2.withOpacity(0.08),
            ),
            child: Icon(icon, size: 12, color: g2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: mutedText,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
