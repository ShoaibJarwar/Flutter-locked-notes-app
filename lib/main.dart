import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locked_notes_app/core/routes/app_routes.dart';
import 'package:locked_notes_app/features/auth/screens/login_screen.dart';
import 'package:locked_notes_app/features/auth/screens/signup_screen.dart';
import 'package:locked_notes_app/features/auth/screens/splash_screen.dart';
import 'package:locked_notes_app/features/notes/screens/add_note_screen.dart';
import 'package:locked_notes_app/features/notes/screens/home_screen.dart';
import 'package:locked_notes_app/features/notes/screens/locked_notes_screen.dart';
import 'package:locked_notes_app/features/profile/screens/profile_screen.dart';
import 'package:locked_notes_app/models/notes_model.dart';
import 'package:locked_notes_app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LockedNotesApp());
}

class LockedNotesApp extends StatelessWidget {
  const LockedNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Locked Notes',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignupScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.lockedNotes: (_) => const LockedNotesScreen(),
        AppRoutes.addNote: (context) {
          final note =
              ModalRoute.of(context)!.settings.arguments as NotesModel?;
          return AddNoteScreen(note: note);
        },
      },
    );
  }
}
