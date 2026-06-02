import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Soft glow blob for background depth ──────────────────────────────────────
class GlowBlob extends StatelessWidget {
  const GlowBlob({super.key, required this.color, required this.size});

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

// ── Frosted glass text field ──────────────────────────────────────────────────
class GlassField extends StatelessWidget {
  const GlassField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
        prefixIcon: Icon(icon, color: Colors.white54),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}

// ── Frosted glass card container ──────────────────────────────────────────────
class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(28),
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 1.2,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

// ── Frosted AppBar icon button ────────────────────────────────────────────────
class FrostedIconButton extends StatelessWidget {
  const FrostedIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip = '',
    this.color = Colors.white,
    this.size = 38,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Icon(icon, color: color, size: size * 0.47),
        ),
      ),
    );
  }
}

// ── PIN dialog ────────────────────────────────────────────────────────────────
Future<String?> showPinDialog(
  BuildContext context, {
  required String title,
  required String actionLabel,
}) {
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
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.4),
                    ),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 8,
                      fontSize: 24,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
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
                              color: Colors.white.withValues(alpha: 0.15),
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
                        onPressed: () => Navigator.pop(ctx, pinController.text),
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

// ── App gradient background ───────────────────────────────────────────────────
class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
  });

  final Widget child;
  final bool showBlobs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF0A0A0A), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: showBlobs
          ? Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -60,
                  child: GlowBlob(
                    color: Colors.green.withValues(alpha: 0.25),
                    size: 260,
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: -80,
                  child: GlowBlob(
                    color: Colors.blue.withValues(alpha: 0.2),
                    size: 300,
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}
