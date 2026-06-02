import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/core/routes/app_routes.dart';
import 'package:locked_notes_app/services/database/db_helper.dart';
import 'package:locked_notes_app/services/session_service.dart';
import 'package:locked_notes_app/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _db = DBHelper.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _db.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      if (user != null) {
        await SessionService().saveLogin(user.id!);
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        _showSnack('Invalid email or password', isError: true);
      }
    } catch (_) {
      _showSnack('Login failed. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            // Background blobs
            Positioned(
              top: -60,
              right: -60,
              child: GlowBlob(
                color: Colors.green.withValues(alpha: 0.35),
                size: 260,
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: GlowBlob(
                color: Colors.blue.withValues(alpha: 0.25),
                size: 300,
              ),
            ),

            // Main content — responsive card
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: constraints.maxHeight > 700 ? 60 : 24,
                          horizontal: 24,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 18,
                                  sigmaY: 18,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 12),

                                          // Lock icon badge
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(
                                                alpha: 0.2,
                                              ),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.green.withValues(
                                                  alpha: 0.4,
                                                ),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.lock_open_outlined,
                                              color: Colors.greenAccent,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          const Text(
                                            'Welcome Back',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Log in to continue',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white.withValues(
                                                alpha: 0.55,
                                              ),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 32),

                                          // Email
                                          GlassField(
                                            controller: _emailController,
                                            label: 'Email',
                                            hint: 'Enter your email',
                                            icon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (v) {
                                              if (v == null ||
                                                  v.trim().isEmpty) {
                                                return 'Email is required';
                                              }
                                              if (!v.contains('@')) {
                                                return 'Enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),

                                          // Password
                                          GlassField(
                                            controller: _passwordController,
                                            label: 'Password',
                                            hint: '••••••',
                                            icon: Icons.lock_outline,
                                            obscureText: _obscurePassword,
                                            suffixIcon: IconButton(
                                              onPressed: () => setState(
                                                () => _obscurePassword =
                                                    !_obscurePassword,
                                              ),
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.white54,
                                              ),
                                            ),
                                            validator: (v) {
                                              if (v == null || v.isEmpty) {
                                                return 'Password is required';
                                              }
                                              if (v.length < 6) {
                                                return 'At least 6 characters';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 32),

                                          // Login button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 52,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                elevation: 0,
                                              ),
                                              onPressed: _isLoading
                                                  ? null
                                                  : _login,
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation(
                                                              Colors.white,
                                                            ),
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Log In',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          // Register link
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Don't have an account? ",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.55),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    Navigator.pushReplacementNamed(
                                                      context,
                                                      AppRoutes.signup,
                                                    ),
                                                child: const Text(
                                                  'Register',
                                                  style: TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
