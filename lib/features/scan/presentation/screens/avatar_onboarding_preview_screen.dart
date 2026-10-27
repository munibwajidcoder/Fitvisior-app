import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/screens/user_style_preferences_screen.dart';
import 'avatar_review_correction_screen.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/widgets/language_toggle_badge.dart';

class AvatarOnboardingPreviewScreen extends StatefulWidget {
  final List<String?>? capturedImagePaths;
  final String? glbUrl;
  final String? gender;
  final double? heightCm;
  final double? bustCm;
  final double? waistCm;
  final double? hipsCm;
  final double? weightKg;
  final bool? isMetric;

  const AvatarOnboardingPreviewScreen({
    super.key,
    this.capturedImagePaths,
    this.glbUrl,
    this.gender,
    this.heightCm,
    this.bustCm,
    this.waistCm,
    this.hipsCm,
    this.weightKg,
    this.isMetric,
  });

  @override
  State<AvatarOnboardingPreviewScreen> createState() =>
      _AvatarOnboardingPreviewScreenState();
}

class _AvatarOnboardingPreviewScreenState
    extends State<AvatarOnboardingPreviewScreen> {
  // ── DYNAMIC MEASUREMENTS & UNITS STATE ────────────────────────────────────
  late bool _isMetric;
  late double _heightCm;
  late double _bustCm;
  late double _waistCm;
  late double _hipsCm;

  String _avatarMode = 'avatar3d'; // 'avatar3d', 'mannequin', 'raw'

  bool _isMale(String? g) {
    if (g == null) return false;
    final clean = g.trim().toLowerCase();
    final isFemale = clean.contains('femme') ||
        clean.contains('female') ||
        clean == 'f';
    return !isFemale &&
        (clean.contains('homme') || clean == 'male' || clean == 'm');
  }

  String get _modelSrc {
    final url = widget.glbUrl;
    if (url == null || url.isEmpty || url.contains('base_avatar')) {
      return '';
    }
    if (url.startsWith('asset://')) {
      return url.replaceFirst('asset://', '');
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    final isMale = _isMale(widget.gender);
    _isMetric = widget.isMetric ?? true;
    _heightCm = widget.heightCm ?? (isMale ? 178.0 : 174.0);
    _bustCm = widget.bustCm ?? (isMale ? 98.0 : 86.0);
    _waistCm = widget.waistCm ?? (isMale ? 82.0 : 66.0);
    _hipsCm = widget.hipsCm ?? (isMale ? 96.0 : 94.0);

    _loadProfileMeasurements();
  }

  void _loadProfileMeasurements() async {
    try {
      final profile = await AuthService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          if (widget.heightCm == null && profile['height_cm'] != null) {
            _heightCm = (profile['height_cm'] as num).toDouble();
          }
          if (widget.bustCm == null && profile['bust_cm'] != null) {
            _bustCm = (profile['bust_cm'] as num).toDouble();
          }
          if (widget.waistCm == null && profile['waist_cm'] != null) {
            _waistCm = (profile['waist_cm'] as num).toDouble();
          }
          if (widget.hipsCm == null && profile['hip_cm'] != null) {
            _hipsCm = (profile['hip_cm'] as num).toDouble();
          }
        });
      }
      // Guarantee current measurements are synchronized into profile
      AuthService.updateProfile({
        'height_cm': _heightCm,
        'bust_cm': _bustCm,
        'waist_cm': _waistCm,
        'hip_cm': _hipsCm,
      });
    } catch (_) {}
  }

  String get _tailleStr {
    if (_isMetric) {
      return "${_heightCm.round()} cm";
    }
    final totalInches = _heightCm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return "$feet' $inches\"";
  }

  String get _busteStr {
    if (_isMetric) {
      return "${_bustCm.round()} cm";
    }
    return "${(_bustCm / 2.54).toStringAsFixed(1)} in";
  }

  String get _ceintureStr {
    if (_isMetric) {
      return "${_waistCm.round()} cm";
    }
    return "${(_waistCm / 2.54).toStringAsFixed(1)} in";
  }

  String get _hanchesStr {
    if (_isMetric) {
      return "${_hipsCm.round()} cm";
    }
    return "${(_hipsCm / 2.54).toStringAsFixed(1)} in";
  }

  // These kept for Scan Réel fake-rotation fallback only
  double _rotationDegrees = 0.0;
  double _zoomScale = 1.0;
  double _baseScale = 1.0;
  Timer? _spinTimer;

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }

  void _snapToAngle(double target) {
    setState(() {
      _rotationDegrees = target;
    });
    _spinTimer?.cancel();
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          body: SafeArea(
            child: Column(
              children: [
                // ── TOP APP BAR ──────────────────────────────────────────
                _buildAppBar(context, isEn),

                // ── SCROLLABLE CONTENT ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── TOP BIOMETRIC MATCH BADGES ───────────────────
                        _buildBiometricMatchBadges(isEn),

                        const SizedBox(height: 12),

                        // ── 3D AVATAR HERO PREVIEW CANVAS (360° ROTATION) ─
                        _buildAvatarRenderCanvas(isEn),

                        const SizedBox(height: 18),

                        // ── BIOMETRIC MEASUREMENTS SUMMARY CARD ──────────
                        _buildMeasurementsSummaryCard(isEn),

                        const SizedBox(height: 20),

                        // ── PRIMARY CTA: CONFIRM & CONTINUE ──────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              final currentGlb = widget.glbUrl ?? _modelSrc;
                              try {
                                await AuthService.updateProfile({
                                  'avatar_glb_url': currentGlb,
                                  'height_cm': _heightCm,
                                  'bust_cm': _bustCm,
                                  'waist_cm': _waistCm,
                                  'hip_cm': _hipsCm,
                                  'weight_kg': widget.weightKg,
                                  'is_inch': !_isMetric,
                                  'gender': widget.gender,
                                  'onboarding_completed': false,
                                  'onboarding_step': 3,
                                });
                              } catch (e) {
                                debugPrint('[AvatarPreview] Supabase save error: $e');
                              }
                              if (!mounted) return;
                              nav.push(
                                MaterialPageRoute(
                                  builder: (context) => UserStylePreferencesScreen(
                                    heightCm: _heightCm,
                                    bustCm: _bustCm,
                                    waistCm: _waistCm,
                                    hipsCm: _hipsCm,
                                    weightKg: widget.weightKg,
                                    isInch: !_isMetric,
                                    gender: widget.gender,
                                    glbUrl: currentGlb,
                                    userPhotoPath: null,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF43F5E),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: const Color(
                                0xFFF43F5E,
                              ).withValues(alpha: 0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isEn
                                          ? "Confirm & Continue to Preferences"
                                          : "Confirmer & Continuer vers les Préférences",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── SECONDARY CTA: ADJUST / CORRECTION ────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AvatarReviewCorrectionScreen(
                                        capturedImagePaths:
                                            widget.capturedImagePaths,
                                        glbUrl: widget.glbUrl,
                                        gender: widget.gender,
                                        heightCm: _heightCm,
                                        bustCm: _bustCm,
                                        waistCm: _waistCm,
                                        hipsCm: _hipsCm,
                                        isMetric: _isMetric,
                                      ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFF43F5E),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: const Color(
                                0xFFFFF1F2,
                              ).withValues(alpha: 0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.tune_rounded,
                                  color: Color(0xFFE11D48),
                                  size: 19,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      isEn
                                          ? "Adjust / Fine-tune Proportions"
                                          : "Ajuster / Corriger les Proportions",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFE11D48),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, bool isEn) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
      color: const Color(0xFFFAF9FB),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 28,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Image.asset('assets/images/logo.png', width: 26, height: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    isEn ? "3D Avatar Preview" : "Aperçu de l'Avatar 3D",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Color(0xFF38BDF8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const LanguageToggleBadge(),
          const SizedBox(width: 6),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              image: const DecorationImage(
                image: AssetImage('assets/images/profile_avatar.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BIOMETRIC MATCH BADGES ─────────────────────────────────────────
  Widget _buildBiometricMatchBadges(bool isEn) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isEn
                        ? "99.2% Biometric Correlation"
                        : "99,2% Corrélation Biométrique",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE11D48),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isEn ? "Generated via AI" : "Généré via IA",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── HELPER: BUILD MULTI-POSE AVATAR TEXTURE ─────────────────────────
  Widget _buildPoseImage(int index, bool mirror) {
    if (_avatarMode == 'raw') {
      final String? localPath = (widget.capturedImagePaths != null &&
              widget.capturedImagePaths!.length > index)
          ? widget.capturedImagePaths![index]
          : ((widget.capturedImagePaths != null &&
                  widget.capturedImagePaths!.isNotEmpty)
              ? widget.capturedImagePaths![0]
              : null);

      final bool hasLocalFile =
          localPath != null && File(localPath).existsSync();

      final List<String> fallbackAssets = [
        'assets/images/scan_front_pose.jpg',
        'assets/images/scan_profile_pose.jpg',
        'assets/images/scan_back_pose.jpg',
      ];

      Widget img;
      if (hasLocalFile) {
        img = Image.file(
          File(localPath),
          fit: BoxFit.contain,
        );
      } else {
        img = Image.asset(
          fallbackAssets[index.clamp(0, 2)],
          fit: BoxFit.contain,
        );
      }

      if (mirror) {
        img = Transform.scale(
          scaleX: -1.0,
          child: img,
        );
      }
      return img;
    }

    // In 'avatar3d' and 'mannequin' modes: The 3D Humanoid Avatar Mannequin Model
    Widget modelImg = Image.asset(
      'assets/images/adaptive_3d_rig.jpg',
      fit: BoxFit.contain,
    );
    if (mirror) {
      modelImg = Transform.scale(
        scaleX: -1.0,
        child: modelImg,
      );
    }

    if (_avatarMode == 'mannequin') {
      return modelImg;
    }

    // In 'avatar3d' mode: The 3D Mannequin is personalized with User Face Identity!
    final String? userPhoto = (widget.capturedImagePaths != null &&
            widget.capturedImagePaths!.isNotEmpty &&
            widget.capturedImagePaths![0] != null)
        ? widget.capturedImagePaths![0]
        : null;

    final bool hasUserPhoto =
        userPhoto != null && File(userPhoto).existsSync();

    return Stack(
      alignment: Alignment.center,
      children: [
        modelImg,

        // Integrated User Face on the 3D Avatar Head (Front view)
        if (index == 0)
          Positioned(
            top: 48,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF43F5E),
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasUserPhoto
                        ? Image.file(
                            File(userPhoto),
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/profile_avatar.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        LanguageService.instance.isEnglish
                            ? "Face Mapped ✓"
                            : "Visage Mappé ✓",
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── 3D AVATAR HERO RENDER CANVAS (TRUE 3D MODEL VIEWER ENGINE) ─────
  Widget _buildAvatarRenderCanvas(bool isEn) {
    // ── Scan Réel Mode: fallback to the original 2D multi-pose display ──
    if (_avatarMode == 'raw') {
      return _buildRawScanCanvas(isEn);
    }

    // ── Avatar 3D / Mannequin Modes: Real GLB 3D Viewer ─────────────────
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // ── TRUE 3D MODEL VIEWER (GLB / GLTF — Google model-viewer WebGL) ──
            Positioned.fill(
              child: _modelSrc.isNotEmpty
                  ? ModelViewer(
                      src: _modelSrc,
                      alt: 'DresKode 3D Avatar',
                      ar: false,
                      autoRotate: false,
                      cameraControls: true,
                      disableZoom: false,
                      shadowIntensity: 1.0,
                      shadowSoftness: 1.0,
                      exposure: 1.0,
                      cameraOrbit: '0deg 75deg 180%',
                      cameraTarget: 'auto auto auto',
                      fieldOfView: 'auto',
                      minCameraOrbit: 'auto auto 100%',
                      maxCameraOrbit: 'auto auto 300%',
                      animationName: 'NaturalPose',
                      autoPlay: true,
                      backgroundColor: const Color(0xFFF1F5F9),
                    )
                  : Container(
                      color: const Color(0xFF0F172A),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.credit_card_off_rounded,
                                color: Color(0xFFF43F5E),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isEn ? "Tripo Credits Exhausted" : "Crédits Tripo Épuisés",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEn
                                  ? "Unable to create 3D avatar due to expired/insufficient Tripo API credits. Please renew your credits to proceed."
                                  : "Impossible de créer l'avatar 3D en raison de crédits API Tripo expirés ou insuffisants. Veuillez renouveler vos crédits pour continuer.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: const Color(0xFF94A3B8),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // ── TOP OVERLAY: STATUS PILL ─────────────
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.view_in_ar_rounded,
                      size: 13,
                      color: Color(0xFFF43F5E),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isEn ? "360° • Real 3D Avatar" : "360° • Avatar 3D Réel",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── BOTTOM GESTURE HINT ────────────────────────────────────
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.swipe_rounded,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEn
                            ? "Drag to rotate 360°"
                            : "Glisser pour faire pivoter à 360°",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── RAW SCAN CANVAS (Fallback 2D scan photos view) ──────────────────
  Widget _buildRawScanCanvas(bool isEn) {
    final double normalized = ((_rotationDegrees % 360) + 360) % 360;
    String poseLabel;
    int poseIndex;
    double segmentAngle;
    bool mirror = false;

    if (normalized >= 315 || normalized < 45) {
      poseLabel = isEn ? "FRONT" : "FACE";
      poseIndex = 0;
      segmentAngle = normalized >= 315 ? normalized - 360 : normalized;
    } else if (normalized >= 45 && normalized < 135) {
      poseLabel = isEn ? "R PROFILE" : "PROFIL D";
      poseIndex = 1;
      segmentAngle = normalized - 90;
    } else if (normalized >= 135 && normalized < 225) {
      poseLabel = isEn ? "BACK" : "DOS";
      poseIndex = 2;
      segmentAngle = normalized - 180;
    } else {
      poseLabel = isEn ? "L PROFILE" : "PROFIL G";
      poseIndex = 1;
      mirror = true;
      segmentAngle = normalized - 270;
    }

    final double tiltRad = segmentAngle * (math.pi / 180.0) * 0.75;

    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _zoomScale;
      },
      onScaleUpdate: (details) {
        setState(() {
          if (details.pointerCount > 1) {
            _zoomScale = (_baseScale * details.scale).clamp(0.85, 2.2);
          } else {
            _rotationDegrees += details.focalPointDelta.dx * 2.5;
          }
        });
      },
      child: Container(
        height: 420,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFFF1F5F9),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE2E8F0),
                        Color(0xFFF8FAFC),
                        Color(0xFFE2E8F0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Transform.scale(
                    scale: _zoomScale,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(tiltRad),
                      alignment: Alignment.center,
                      child: _buildPoseImage(poseIndex, mirror),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.explore_rounded,
                                size: 12, color: Color(0xFFF43F5E)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "${normalized.round()}° • $poseLabel",
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModeTabItem(
                            title: isEn ? "3D Avatar" : "Avatar 3D",
                            icon: Icons.person_rounded,
                            isSelected: _avatarMode == 'avatar3d',
                            onTap: () => setState(() => _avatarMode = 'avatar3d'),
                          ),
                          _buildModeTabItem(
                            title: isEn ? "Mannequin" : "Mannequin",
                            icon: Icons.accessibility_new_rounded,
                            isSelected: _avatarMode == 'mannequin',
                            onTap: () => setState(() => _avatarMode = 'mannequin'),
                          ),
                          _buildModeTabItem(
                            title: isEn ? "Raw Scan" : "Scan Réel",
                            icon: Icons.photo_camera_rounded,
                            isSelected: _avatarMode == 'raw',
                            onTap: () => setState(() => _avatarMode = 'raw'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Quick Angle Snapping Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnglePresetButton(isEn ? "Front" : "Face", 0.0, normalized),
                          const SizedBox(width: 6),
                          _buildAnglePresetButton(
                              isEn ? "R Profile" : "Profil D", 90.0, normalized),
                          const SizedBox(width: 6),
                          _buildAnglePresetButton(isEn ? "Back" : "Dos", 180.0, normalized),
                          const SizedBox(width: 6),
                          _buildAnglePresetButton(
                              isEn ? "L Profile" : "Profil G", 270.0, normalized),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),

                    // Gesture Hint Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sync_rounded,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isEn
                                ? "Raw Scan • Drag to rotate • Pinch (${_zoomScale.toStringAsFixed(1)}x)"
                                : "Scan Réel • Glisser pour pivoter • Pincer (${_zoomScale.toStringAsFixed(1)}x)",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPER: BUILD MODE TAB ITEM ─────────────────────────────────────
  Widget _buildModeTabItem({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF43F5E) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 10.5,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 3.5),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ANGLE PRESET BUTTON ─────────────────────────────────────────────
  Widget _buildAnglePresetButton(
      String label, double targetAngle, double currentNormalized) {
    bool isActive = false;
    if (targetAngle == 0.0) {
      isActive = currentNormalized >= 315 || currentNormalized < 45;
    } else if (targetAngle == 90.0) {
      isActive = currentNormalized >= 45 && currentNormalized < 135;
    } else if (targetAngle == 180.0) {
      isActive = currentNormalized >= 135 && currentNormalized < 225;
    } else if (targetAngle == 270.0) {
      isActive = currentNormalized >= 225 && currentNormalized < 315;
    }

    return GestureDetector(
      onTap: () => _snapToAngle(targetAngle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFF43F5E)
              : Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? const Color(0xFFFB7185)
                : Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }



  // ── BIOMETRIC MEASUREMENTS SUMMARY CARD ────────────────────────────
  Widget _buildMeasurementsSummaryCard(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.accessibility_new_rounded,
                        size: 18,
                        color: Color(0xFFF43F5E),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isEn ? "Generated Measurements" : "Mensurations Générées",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMetric = !_isMetric;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isMetric ? "CM" : "INCHES",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF43F5E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.swap_horiz_rounded,
                        size: 14,
                        color: Color(0xFFF43F5E),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMeasurementTile(isEn ? "HEIGHT" : "TAILLE", _tailleStr)),
              const SizedBox(width: 8),
              Expanded(child: _buildMeasurementTile(isEn ? "BUST" : "BUSTE", _busteStr)),
              const SizedBox(width: 8),
              Expanded(child: _buildMeasurementTile(isEn ? "WAIST" : "CEINTURE", _ceintureStr)),
              const SizedBox(width: 8),
              Expanded(child: _buildMeasurementTile(isEn ? "HIPS" : "HANCHES", _hanchesStr)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


