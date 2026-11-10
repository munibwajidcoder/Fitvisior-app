import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../auth/presentation/screens/age_eligibility_screen.dart';
import '../../../auth/presentation/screens/avatar_identity_screen.dart';
import '../../../auth/presentation/screens/consent_privacy_screen.dart';
import '../../../auth/presentation/screens/welcome_back_screen.dart';
import '../../../auth/presentation/screens/user_style_preferences_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../../core/localization/language_service.dart';
import '../../../scan/presentation/screens/manual_measurements_screen.dart';
import '../../../scan/presentation/screens/avatar_onboarding_preview_screen.dart';
import '../../../scan/presentation/screens/scan_verification_screen.dart';
import '../../../scan/presentation/screens/body_scan_screen.dart';
import '../../../scan/presentation/screens/neural_mesh_processing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  Widget _nextScreen = const WelcomeBackScreen();
  bool _authCheckDone = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Exactly 2 seconds
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        while (!_authCheckDone && mounted) {
          await Future.delayed(const Duration(milliseconds: 25));
        }
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  _nextScreen,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          );
        }
      }
    });

    _animationController.forward();
  }

  Future<void> _checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check active Supabase session
      Session? session = Supabase.instance.client.auth.currentSession;
      final bool hadTokens = prefs.getKeys().any((k) => k.contains('auth-token') || k.contains('supabase'));

      // ── On cold start, wait for async disk session restore if tokens exist
      if (session == null && hadTokens) {
        for (int i = 0; i < 8; i++) {
          await Future.delayed(const Duration(milliseconds: 40));
          session = Supabase.instance.client.auth.currentSession;
          if (session != null) break;
        }
      }

      if (session == null) {
        try {
          final refreshed = await Supabase.instance.client.auth.refreshSession();
          session = refreshed.session;
        } catch (_) {
          session = Supabase.instance.client.auth.currentSession;
        }
      }

      final user = session?.user ?? Supabase.instance.client.auth.currentUser;

      // ── If genuinely logged out / no user session → WelcomeBackScreen ──
      if (session == null && user == null) {
        _nextScreen = const WelcomeBackScreen();
        _authCheckDone = true;
        return;
      }

      // Restore user avatar and 3D GLB model on startup/restart
      try {
        await UserAvatarService.loadSavedAvatar();
      } catch (_) {}

      // ── Valid session exists → Check onboarding completion ──
      Map<String, dynamic>? profile;
      try {
        profile = await AuthService.getProfile();
      } catch (_) {}

      final bool localCompleted = prefs.getBool('fitvisor_onboarding_completed') == true;
      final bool serverCompleted = profile?['onboarding_completed'] == true;
      final bool isCompleted = localCompleted || serverCompleted;

      // ── ONLY fully finished users go to HomeScreen! ──
      if (isCompleted) {
        await prefs.setBool('fitvisor_is_logged_in', true);
        await prefs.setBool('fitvisor_onboarding_completed', true);
        _nextScreen = const HomeScreen();
        _authCheckDone = true;
        return;
      }

      // ── If onboarding is NOT completed, resume at the EXACT last screen where user quit! ──
      final String? currentScreen = prefs.getString('fitvisor_current_screen');
      final int localStep = prefs.getInt('fitvisor_onboarding_step') ?? 0;
      final int serverStep = (profile?['onboarding_step'] as num?)?.toInt() ?? 0;
      final int step = (serverStep > localStep) ? serverStep : localStep;

      final String avatarType = profile?['avatar_type'] as String? ?? 'realistic';
      final String gender = profile?['gender'] as String? ?? 'female';
      final double h = (profile?['height_cm'] as num?)?.toDouble() ?? 174.0;
      final double b = (profile?['bust_cm'] as num?)?.toDouble() ?? (profile?['chest_cm'] as num?)?.toDouble() ?? 86.0;
      final double w = (profile?['waist_cm'] as num?)?.toDouble() ?? 66.0;
      final double hips = (profile?['hip_cm'] as num?)?.toDouble() ?? (profile?['hips_cm'] as num?)?.toDouble() ?? 94.0;
      final double wt = (profile?['weight_kg'] as num?)?.toDouble() ?? 60.0;
      final String? glbUrl = profile?['avatar_glb_url'] as String?;
      final bool isMetric = !(profile?['is_inch'] as bool? ?? false);

      if (currentScreen == 'scan_verification') {
        _nextScreen = ScanVerificationScreen(
          gender: gender,
          heightCm: h,
          bustCm: b,
          waistCm: w,
          hipsCm: hips,
          isMetric: isMetric,
        );
      } else if (currentScreen == 'neural_mesh') {
        _nextScreen = NeuralMeshProcessingScreen(
          gender: gender,
          heightCm: h,
          bustCm: b,
          waistCm: w,
          hipsCm: hips,
          weightKg: wt,
          isMetric: isMetric,
        );
      } else if (currentScreen == 'body_scan') {
        _nextScreen = BodyScanScreen(
          gender: gender,
          heightCm: h,
          bustCm: b,
          waistCm: w,
          hipsCm: hips,
          isMetric: isMetric,
        );
      } else if (currentScreen == 'avatar_preview' || step == 4) {
        final effectiveGlb = (glbUrl != null && glbUrl.isNotEmpty)
            ? glbUrl
            : UserAvatarService.avatarGlbNotifier.value;
        _nextScreen = AvatarOnboardingPreviewScreen(
          glbUrl: effectiveGlb,
          gender: gender,
          heightCm: h,
          bustCm: b,
          waistCm: w,
          hipsCm: hips,
          weightKg: wt,
          isMetric: isMetric,
        );
      } else if (currentScreen == 'style_preferences' || step == 5) {
        _nextScreen = UserStylePreferencesScreen(
          heightCm: h,
          bustCm: b,
          waistCm: w,
          hipsCm: hips,
          weightKg: wt,
          gender: gender,
          glbUrl: glbUrl,
        );
      } else if (currentScreen == 'manual_measurements' || step == 3) {
        _nextScreen = ManualMeasurementsScreen(
          avatarType: avatarType,
          initialMetric: isMetric,
        );
      } else if (step == 2) {
        _nextScreen = const AvatarIdentityScreen();
      } else if (step == 1) {
        _nextScreen = const ConsentPrivacyScreen();
      } else if (step <= 0) {
        _nextScreen = const AgeEligibilityScreen();
      } else {
        _nextScreen = const HomeScreen();
      }
    } catch (e) {
      debugPrint('[SplashScreen] Auth check error: $e');
      final prefs = await SharedPreferences.getInstance();
      final bool localCompleted = prefs.getBool('fitvisor_onboarding_completed') == true;
      if (localCompleted) {
        _nextScreen = const HomeScreen();
      } else {
        final int localStep = prefs.getInt('fitvisor_onboarding_step') ?? 0;
        if (localStep <= 0) {
          _nextScreen = const AgeEligibilityScreen();
        } else if (localStep == 1) {
          _nextScreen = const ConsentPrivacyScreen();
        } else if (localStep == 2) {
          _nextScreen = const AvatarIdentityScreen();
        } else if (localStep == 3) {
          _nextScreen = const ManualMeasurementsScreen(avatarType: 'realistic');
        } else if (localStep == 5) {
          _nextScreen = const UserStylePreferencesScreen();
        } else {
          _nextScreen = const AgeEligibilityScreen();
        }
      }
    } finally {
      _authCheckDone = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgGradientTop,
              Colors.white,
              AppColors.bgGradientBottom,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ---------------- HEADER BAR ----------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // AR Studio Ready Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            LanguageService.instance.isEnglish
                                ? "AR STUDIO READY"
                                : "STUDIO AR PRÊT",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // AR Cube Icon Box
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.view_in_ar_rounded,
                        color: Color(0xFF334155),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // ---------------- MAIN LOGO & BRANDING ----------------
              Image.asset(
                'assets/images/logo.png',
                width: 95,
                height: 95,
              ),

              const SizedBox(height: 22),

              // Title: Fit Visor
              Text(
                "Fit Visor",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle Tagline (Localized)
              Text(
                LanguageService.instance.isEnglish
                    ? "Try on. Explore. Find your style."
                    : "Essayez. Explorez. Trouvez votre style.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE11D48),
                  letterSpacing: 0.1,
                ),
              ),

              const SizedBox(height: 20),

              // Feature Badges Row (Localized)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFeatureBadge(
                    icon: Icons.alt_route_rounded,
                    label: LanguageService.instance.isEnglish
                        ? "Real-time drape"
                        : "Drapé en temps réel",
                  ),
                  const SizedBox(width: 12),
                  _buildFeatureBadge(
                    icon: Icons.auto_awesome_rounded,
                    label: LanguageService.instance.isEnglish
                        ? "Real 3D Fit"
                        : "Ajustement 3D Réel",
                  ),
                ],
              ),

              const Spacer(flex: 4),

              // ---------------- BOTTOM LOADING SECTION ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    // Animated Progress Bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF172554),
                                        Color(0xFFE11D48),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Progress Label & Percentage Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    LanguageService.instance.isEnglish
                                        ? "Weaving high-resolution textile meshes..."
                                        : "Tissage des maillages textiles haute résolution...",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${(_progressAnimation.value * 100).toInt()}%",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Version & Certification Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "v2.4.1 (Spatial Studio)",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.0),
                          child: Icon(
                            Icons.circle,
                            size: 4,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        const Icon(
                          Icons.verified_outlined,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          LanguageService.instance.isEnglish ? "Certified" : "Certifié",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFE11D48)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
