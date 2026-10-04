import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/friend_feedback_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const FitVisorApp());
}

class FitVisorApp extends StatelessWidget {
  const FitVisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitVisor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accentRed,
        ),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        // Deep linking handler
        if (settings.name != null && settings.name!.startsWith('/feedback/')) {
          return MaterialPageRoute(
            builder: (context) => const FriendFeedbackScreen(
              productName: 'Shared Outfit',
              productSize: 'Taille M',
              visibilityLabel: 'Community',
              linkExpiry: 'Valid for 7 days',
            ),
          );
        }
        return null; // Let MaterialApp handle normal routing (e.g. home)
      },
    );
  }
}

