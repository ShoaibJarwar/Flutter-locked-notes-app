import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/core/routes/app_routes.dart';
import 'package:locked_notes_app/models/user_model.dart';
import 'package:locked_notes_app/services/database/db_helper.dart';
import 'package:locked_notes_app/widgets/app_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _db = DBHelper.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final alreadyExists = await _db.emailExists(email);
      if (!mounted) return;
      if (alreadyExists) {
        _showSnack('An account with this email already exists.', isError: true);
        return;
      }

      final user = UserModel(
        name: _nameController.text.trim(),
        email: email,
        password: _passwordController.text.trim(),
      );
      await _db.insertUser(user);

      if (mounted) {
        _showSnack('Account created! Please log in.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      _showSnack('Registration failed. Try again.', isError: true);
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
              left: -60,
              child: GlowBlob(
                color: Colors.green.withValues(alpha: 0.35),
                size: 260,
              ),
            ),
            Positioned(
              bottom: 80,
              right: -80,
              child: GlowBlob(
                color: Colors.blue.withValues(alpha: 0.25),
                size: 300,
              ),
            ),

            // Responsive main content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      vertical: constraints.maxHeight > 700 ? 40 : 20,
                      horizontal: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
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

                                      // Icon badge
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
                                          Icons.lock_outline,
                                          color: Colors.greenAccent,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Sign up to get started',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),

                                      // Name
                                      GlassField(
                                        controller: _nameController,
                                        label: 'Name',
                                        hint: 'Enter your name',
                                        icon: Icons.person_outline,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Email
                                      GlassField(
                                        controller: _emailController,
                                        label: 'Email',
                                        hint: 'Enter your email',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
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
                                        hint: 'Enter your password',
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

                                      // Sign up button
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
                                              : _register,
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
                                                  'Sign Up',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Login link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Already have an account? ',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.55,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                Navigator.pushReplacementNamed(
                                                  context,
                                                  AppRoutes.login,
                                                ),
                                            child: const Text(
                                              'Log In',
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
