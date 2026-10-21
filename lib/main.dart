import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_colors.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/friend_feedback_screen.dart';
import 'features/home/data/wardrobe_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file (saari secret keys wahan se aayengi)
  await dotenv.load(fileName: ".env");

  // Supabase initialize
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  // Initialize Wardrobe & Digital Closet
  await WardrobeService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FitVisorApp());
}

// Supabase client ko globally access karne ka shortcut
// Kisi bhi file se: supabase.from('table').select()
final supabase = Supabase.instance.client;


class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class FitVisorApp extends StatelessWidget {
  const FitVisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fit Visor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
          },
        ),
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

