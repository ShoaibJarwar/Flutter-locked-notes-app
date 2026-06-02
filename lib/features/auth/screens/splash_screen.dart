import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/core/routes/app_routes.dart';
import 'package:locked_notes_app/services/session_service.dart';
import 'package:locked_notes_app/widgets/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _dotsController;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  int _dotCount = 1;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoController.forward();

    _dotsController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (mounted) setState(() => _dotCount = (_dotCount % 3) + 1);
            _dotsController.forward(from: 0);
          }
        });
    _dotsController.forward();

    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    await _checkLogin();
  }

  Future<void> _checkLogin() async {
    try {
      final loggedIn = await SessionService().isLoggedIn();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        loggedIn ? AppRoutes.home : AppRoutes.login,
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
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
            Positioned(
              top: -80,
              left: -80,
              child: GlowBlob(
                color: Colors.green.withValues(alpha: 0.3),
                size: 280,
              ),
            ),
            Positioned(
              bottom: 60,
              right: -100,
              child: GlowBlob(
                color: Colors.blue.withValues(alpha: 0.2),
                size: 320,
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.15,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.greenAccent,
                              size: 52,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Locked Notes',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your private space',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.greenAccent.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Loading${'.' * _dotCount}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
