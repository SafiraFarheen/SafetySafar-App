import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'reset_password_screen.dart';
import 'screens/tourist_dashboard.dart';
import 'screens/authority_dashboard.dart';
import 'utils/app_colors.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('[Firebase] ✓ Firebase initialized successfully');
  } catch (e) {
    debugPrint("[Firebase] ✗ Initialization failed: $e. Ensure google-services.json is present.");
  }
  runApp(const SafetySafarApp());
}

class SafetySafarApp extends StatelessWidget {
  const SafetySafarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safety Safar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDeepBlue,
          primary: AppColors.primaryDeepBlue,
          secondary: AppColors.successGreen,
          tertiary: AppColors.primarySkyBlue,
          error: AppColors.emergencyRed,
          background: AppColors.backgroundLight,
          surface: AppColors.white,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textDark,
            fontSize: 16,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textMedium,
            fontSize: 14,
          ),
          bodySmall: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textMedium,
            fontSize: 12,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textDark,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          labelLarge: const TextStyle(
            fontFamily: 'Outfit',
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDeepBlue,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDeepBlue,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDeepBlue,
            side: const BorderSide(color: AppColors.primaryDeepBlue),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          hintStyle: const TextStyle(color: AppColors.textLight),
          labelStyle: const TextStyle(color: AppColors.textDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryDeepBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.emergencyRed),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        // Note: TouristDashboard and AuthorityDashboard are navigated via Navigator.push
        // because they require authToken and userId parameters at runtime
      },
    );
  }
}