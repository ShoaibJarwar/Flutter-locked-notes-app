import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/core/routes/app_routes.dart';
import 'package:locked_notes_app/services/database/db_helper.dart';
import 'package:locked_notes_app/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String? name;
  String? email;
  bool _isLoading = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    loadUser();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) return;

    final user = await DBHelper.instance.getUser(userId);
    if (!mounted) return;
    if (user != null) {
      setState(() {
        name = user.name;
        email = user.email;
        _isLoading = false;
      });
    }
  }

  // ── Frosted PIN dialog ─────────────────────────────────────────────────────
  Future<String?> _showPinDialog({
    required String title,
    required String actionLabel,
  }) async {
    final pinController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.greenAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '••••••',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 8,
                        fontSize: 24,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.greenAccent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white54,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () =>
                              Navigator.pop(ctx, pinController.text),
                          child: Text(
                            actionLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );
  }

  void changePin() async {
    final newPin = await _showPinDialog(
      title: 'Set New PIN',
      actionLabel: 'Save',
    );
    if (!mounted || newPin == null || newPin.isEmpty) return;
    await SessionService().savePin(newPin);
    _showSnack('PIN updated successfully');
  }

  void logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.4)),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Log Out?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will be returned to the login screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white54,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
      ),
    );

    if (confirm == true) {
      await SessionService().logOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Avatar initials ────────────────────────────────────────────────────────
  String get _initials {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0A0A0A), Color(0xFF1A237E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Glow blobs ───────────────────────────────────────────────
            Positioned(
              top: -70,
              left: -60,
              child: _GlowBlob(
                color: Colors.green.withOpacity(0.28),
                size: 260,
              ),
            ),
            Positioned(
              bottom: 60,
              right: -80,
              child: _GlowBlob(color: Colors.blue.withOpacity(0.2), size: 300),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    // ── AppBar ─────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pop(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        child: Column(
                          children: [
                            // ── Avatar card ──────────────────────────
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 32,
                                    horizontal: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.greenAccent
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            // Avatar circle
                                            Container(
                                              width: 84,
                                              height: 84,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.green.withOpacity(
                                                  0.25,
                                                ),
                                                border: Border.all(
                                                  color: Colors.greenAccent
                                                      .withOpacity(0.5),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _initials,
                                                  style: const TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              name ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              email ?? '',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.5,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Info tiles ───────────────────────────
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.13),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      _InfoTile(
                                        icon: Icons.person_outline,
                                        label: 'Name',
                                        value: name ?? '—',
                                      ),
                                      Divider(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.08),
                                        indent: 56,
                                      ),
                                      _InfoTile(
                                        icon: Icons.email_outlined,
                                        label: 'Email',
                                        value: email ?? '—',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Action tiles ─────────────────────────
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.07),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.13),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      _ActionTile(
                                        icon: Icons.pin_outlined,
                                        label: 'Change PIN',
                                        iconColor: Colors.greenAccent,
                                        onTap: changePin,
                                      ),
                                      Divider(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.08),
                                        indent: 56,
                                      ),
                                      _ActionTile(
                                        icon: Icons.logout_rounded,
                                        label: 'Log Out',
                                        iconColor: Colors.redAccent,
                                        labelColor: Colors.redAccent,
                                        onTap: logout,
                                        showChevron: false,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Icon(icon, color: Colors.white54, size: 17),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Action tile ───────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.labelColor = Colors.white,
    this.showChevron = true,
  });
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: iconColor.withOpacity(0.25)),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.25),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Glow blob ─────────────────────────────────────────────────────────────────
class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.8,
            spreadRadius: size * 0.2,
          ),
        ],
      ),
    );
  }
}
