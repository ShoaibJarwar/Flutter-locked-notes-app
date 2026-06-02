import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locked_notes_app/core/routes/app_routes.dart';
import 'package:locked_notes_app/features/notes/screens/notes_list_screen.dart';
import 'package:locked_notes_app/services/session_service.dart';
import 'package:locked_notes_app/widgets/app_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── PIN dialogs ────────────────────────────────────────────────────────────
  Future<void> _handleLockedNotes(BuildContext context) async {
    final session = SessionService();
    String? savedPin = await session.getPin();
    if (!context.mounted) return;

    if (savedPin == null || savedPin.isEmpty) {
      final newPin = await showPinDialog(
        context,
        title: 'Set PIN',
        actionLabel: 'Save',
      );
      if (!context.mounted || newPin == null || newPin.isEmpty) return;
      await session.savePin(newPin);
      if (context.mounted) {
        Navigator.pushNamed(context, AppRoutes.lockedNotes);
      }
      return;
    }

    final enteredPin = await showPinDialog(
      context,
      title: 'Enter PIN',
      actionLabel: 'Unlock',
    );
    if (!context.mounted || enteredPin == null) return;

    savedPin = await session.getPin();
    if (!context.mounted) return;

    if (enteredPin == savedPin) {
      Navigator.pushNamed(context, AppRoutes.lockedNotes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.lock, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Incorrect PIN'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await _showLogoutDialog(context);
    if (confirm == true) {
      await SessionService().logOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 36,
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
                      color: Colors.white.withValues(alpha: 0.5),
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
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.15),
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
                            padding: const EdgeInsets.symmetric(vertical: 13),
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
            SafeArea(
              child: Column(
                children: [
                  // Custom frosted AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.green.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.greenAccent,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'My Notes',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              FrostedIconButton(
                                icon: Icons.lock_outline,
                                tooltip: 'Locked Notes',
                                onTap: () => _handleLockedNotes(context),
                              ),
                              const SizedBox(width: 8),
                              FrostedIconButton(
                                icon: Icons.person_outline,
                                tooltip: 'Profile',
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.profile,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              FrostedIconButton(
                                icon: Icons.logout_rounded,
                                tooltip: 'Log Out',
                                color: Colors.redAccent.withValues(alpha: 0.85),
                                onTap: () => _handleLogout(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Notes list
                  const Expanded(child: NotesListScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addNote);
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }
}
