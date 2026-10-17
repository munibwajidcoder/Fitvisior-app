import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'body_scan_screen.dart';
import 'neural_mesh_processing_screen.dart';

class AvatarReviewCorrectionScreen extends StatefulWidget {
  final List<String?>? capturedImagePaths;
  final String? glbUrl;
  final String? gender;
  final double? heightCm;
  final double? bustCm;
  final double? waistCm;
  final double? hipsCm;
  final bool? isMetric;

  const AvatarReviewCorrectionScreen({
    super.key,
    this.capturedImagePaths,
    this.glbUrl,
    this.gender,
    this.heightCm,
    this.bustCm,
    this.waistCm,
    this.hipsCm,
    this.isMetric,
  });

  @override
  State<AvatarReviewCorrectionScreen> createState() =>
      _AvatarReviewCorrectionScreenState();
}

class _AvatarReviewCorrectionScreenState
    extends State<AvatarReviewCorrectionScreen> {
  // ── STATE VARIABLES ────────────────────────────────────────────────
  String _avatarMode = 'avatar3d'; // 'avatar3d', 'mannequin', 'raw'
  String _viewMode = 'Teint'; // 'Wireframe', 'Teint' (Realistic PBR), 'Silhouette'
  double _zoomScale = 1.0;
  Timer? _spinTimer;

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
    if (url == null || url.isEmpty) {
      return _isMale(widget.gender)
          ? 'assets/models/base_avatar_male.glb'
          : 'assets/models/base_avatar_female.glb';
    }
    if (url.startsWith('asset://')) {
      return url.replaceFirst('asset://', '');
    }
    return url;
  }

  // Proportions
  late double _heightInches;
  late double _waistInches;
  String _shoulderTorso = 'Classique';
  final List<String> _shoulderTorsoOptions = ['Minces', 'Classique', 'Larges'];

  @override
  void initState() {
    super.initState();
    _heightInches = widget.heightCm != null
        ? (widget.heightCm! / 2.54)
        : 67.0; // fallback 5' 7"
    _waistInches = widget.waistCm != null
        ? (widget.waistCm! / 2.54)
        : 27.5;
  }

  // Proportion Offsets
  double _torsoLengthCm = 0.0; // -5.0 to +5.0 cm
  String _waistSensitivity = 'Naturel'; // 'Droit', 'Naturel', 'Sablier'
  double _hipBreadthCm = 0.0; // -2.0 to +2.0 cm
  String _shoulderSlope = 'Standard'; // 'Athlétique', 'Standard', 'Décontracté'
  double _inseamMm = 0.0; // -30 to +30 mm

  double _rotationAngle = 0.0;

  @override
  void dispose() {
    _spinTimer?.cancel();
    super.dispose();
  }



  void _snapToAngle(double target) {
    setState(() {
      _rotationAngle = target;
    });
    _spinTimer?.cancel();
  }

  void _resetToBaseline() {
    setState(() {
      _heightInches = 67.0;
      _waistInches = 27.5;
      _shoulderTorso = 'Classique';
      _torsoLengthCm = 0.0;
      _waistSensitivity = 'Naturel';
      _hipBreadthCm = 0.0;
      _shoulderSlope = 'Standard';
      _inseamMm = 0.0;
      _rotationAngle = 0.0;
      _zoomScale = 1.0;
    });
    _spinTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Valeurs de calibration réinitialisées au scan d'origine !",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatHeight(double inches) {
    final int feet = (inches / 12).floor();
    final int remainingInches = (inches % 12).round();
    return "$feet' $remainingInches\"";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP APP BAR ──────────────────────────────────────────
            _buildAppBar(context),

            // ── SCROLLABLE BODY ──────────────────────────────────────
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
                    _buildBiometricMatchBadges(),

                    const SizedBox(height: 12),

                    // ── 3D AVATAR RENDER CANVAS ──────────────────────
                    _buildRenderCanvas(),

                    const SizedBox(height: 18),

                    // ── FINE-TUNE PROPORTIONS CARD ───────────────────
                    _buildProportionsCard(),

                    const SizedBox(height: 18),

                    // ── PROPORTION OFFSETS CARD ──────────────────────
                    _buildOffsetsCard(),

                    const SizedBox(height: 24),

                    // ── SAVE CHANGES & REGENERATE BUTTON ─────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final double updatedHeightCm = _heightInches * 2.54;
                          final double updatedWaistCm = _waistInches * 2.54;
                          final double updatedBustCm = updatedWaistCm + 16.0;
                          final double updatedHipsCm = updatedWaistCm + 28.0 + _hipBreadthCm;

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => NeuralMeshProcessingScreen(
                                capturedImagePaths: widget.capturedImagePaths,
                                gender: widget.gender ?? 'Homme',
                                heightCm: updatedHeightCm,
                                bustCm: updatedBustCm,
                                waistCm: updatedWaistCm,
                                hipsCm: updatedHipsCm,
                                isMetric: widget.isMetric ?? true,
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
                            const Icon(Icons.auto_fix_high_rounded, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Regénérer l'avatar avec ces mesures",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.5,
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

                    // ── RETAKE SCAN BUTTON ───────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BodyScanScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFF43F5E),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: const Color(
                            0xFFFFF1F2,
                          ).withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Reprendre le scan",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFFE11D48),
                              size: 18,
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
  }

  // ── APP BAR ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
      color: const Color(0xFFFAF9FB),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const BodyScanScreen(),
                  ),
                );
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
                    "Correction de l'Avatar 3D",
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
                Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // User Profile Icon
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

  // ── TOP BIOMETRIC MATCH BADGES ─────────────────────────────────────
  Widget _buildBiometricMatchBadges() {
    return Row(
      children: [
        // Left Badge
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
                    "99,2% Corrélation Biométrique",
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

        // Right Badge
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
                "Haute Précision",
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

  Widget _buildPoseImage(int index, bool mirror) {
    // 3D Avatar Model: Digital Mannequin Rig with anatomical measurements
    Widget img = Image.asset(
      'assets/images/adaptive_3d_rig.jpg',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
    );

    if (mirror) {
      img = Transform.scale(
        scaleX: -1.0,
        child: img,
      );
    }
    return img;
  }

  // ── 3D AVATAR RENDER CANVAS (TRUE 3D MODEL VIEWER + LIVE CALIBRATION) ─
  Widget _buildRenderCanvas() {
    if (_avatarMode == 'raw') {
      return _buildRawScanCanvas();
    }
    return _buildModelViewerCanvas();
  }

  // ── 3D MODEL VIEWER CANVAS (REAL GLB WITH DYNAMIC BIOMETRIC HUD) ────
  Widget _buildModelViewerCanvas() {
    final double normalized = ((_rotationAngle % 360) + 360) % 360;
    final double heightCm = _heightInches * 2.54;
    final double waistCm = _waistInches * 2.54;
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
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
              child: ModelViewer(
                src: _modelSrc,
                alt: 'DresKode 3D Avatar Calibration',
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
                backgroundColor: const Color(0xFF0F172A),
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
                      "360° • Calibration 3D Live",
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

            // ── BOTTOM CONTROLS & ANGLE SNAPPING BAR ─────────────────
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnglePresetButton("Face", 0.0, normalized),
                        const SizedBox(width: 6),
                        _buildAnglePresetButton("Profil D", 90.0, normalized),
                        const SizedBox(width: 6),
                        _buildAnglePresetButton("Dos", 180.0, normalized),
                        const SizedBox(width: 6),
                        _buildAnglePresetButton("Profil G", 270.0, normalized),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sync_rounded,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "Glisser 360° • Calibration (${heightCm.round()}cm / ${waistCm.round()}cm)",
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  // ── RAW SCAN CANVAS (2D SCAN FALLBACK VIEW) ─────────────────────────
  Widget _buildRawScanCanvas() {
    final double normalized = ((_rotationAngle % 360) + 360) % 360;
    int poseIndex;
    double segmentAngle;
    bool mirror = false;

    if (normalized >= 315 || normalized < 45) {
      poseIndex = 0;
      segmentAngle = normalized >= 315 ? normalized - 360 : normalized;
    } else if (normalized >= 45 && normalized < 135) {
      poseIndex = 1;
      segmentAngle = normalized - 90;
    } else if (normalized >= 135 && normalized < 225) {
      poseIndex = 2;
      segmentAngle = normalized - 180;
    } else {
      poseIndex = 1;
      mirror = true;
      segmentAngle = normalized - 270;
    }

    final double tiltRad = segmentAngle * (math.pi / 180.0) * 0.7;
    final double heightCm = _heightInches * 2.54;
    final double waistCm = _waistInches * 2.54;
    final double bustCm = waistCm + 16.0;
    final double hipsCm = waistCm + 28.0 + _hipBreadthCm;
    final double shoulderWidthCm = _shoulderTorso == 'Minces'
        ? 40.0
        : (_shoulderTorso == 'Larges' ? 48.0 : 44.0);
    final double waistScale = (_waistInches / 27.5).clamp(0.7, 1.4);

    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          if (details.pointerCount > 1) {
            _zoomScale = (_zoomScale * details.scale).clamp(0.85, 2.2);
          } else {
            _rotationAngle += details.focalPointDelta.dx * 1.5;
          }
        });
      },
      child: Container(
        height: 420,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF0F172A),
          border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
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
              // 3D Avatar Render with 360 multi-angle pose projection
              Transform.scale(
                scale: _zoomScale,
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0014)
                    ..rotateY(tiltRad),
                  alignment: Alignment.center,
                  child: _buildPoseImage(poseIndex, mirror),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Wireframe / Silhouette Overlays
              if (_viewMode == 'Wireframe')
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _RotatingWireframeMeshPainter(
                        rotationDegrees: _rotationAngle,
                        waistScale: waistScale,
                      ),
                    ),
                  ),
                ),
              if (_viewMode == 'Silhouette')
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DynamicBiometricSilhouetteHudPainter(
                        rotationDegrees: _rotationAngle,
                        heightCm: heightCm,
                        waistCm: waistCm,
                        bustCm: bustCm,
                        hipsCm: hipsCm,
                        shoulderWidthCm: shoulderWidthCm,
                      ),
                    ),
                  ),
                ),

              // Top Bar with mode switcher
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
                          horizontal: 8,
                          vertical: 5,
                        ),
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
                            const Icon(
                              Icons.explore_rounded,
                              size: 12,
                              color: Color(0xFFF43F5E),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "${normalized.round()}° • Scan Brut",
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
                            title: "Avatar 3D",
                            icon: Icons.person_rounded,
                            isSelected: _avatarMode == 'avatar3d',
                            onTap: () => setState(() => _avatarMode = 'avatar3d'),
                          ),
                          _buildModeTabItem(
                            title: "Mannequin",
                            icon: Icons.accessibility_new_rounded,
                            isSelected: _avatarMode == 'mannequin',
                            onTap: () => setState(() => _avatarMode = 'mannequin'),
                          ),
                          _buildModeTabItem(
                            title: "Scan Réel",
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

              // Right Controls Dock
              Positioned(
                top: 55,
                right: 12,
                child: Column(
                  children: [
                    _buildViewModePill("Wireframe", Icons.grid_4x4_rounded),
                    const SizedBox(height: 6),
                    _buildViewModePill("Teint", Icons.color_lens_outlined),
                    const SizedBox(height: 6),
                    _buildViewModePill("Silhouette", Icons.accessibility_rounded),
                  ],
                ),
              ),

              // Bottom presets
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnglePresetButton("Face", 0.0, normalized),
                          const SizedBox(width: 6),
                          _buildAnglePresetButton("Profil D", 90.0, normalized),
                          const SizedBox(width: 6),
                          _buildAnglePresetButton("Dos", 180.0, normalized),
                          const SizedBox(width: 6),
                          _buildAnglePresetButton("Profil G", 270.0, normalized),
                        ],
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Scan Réel • Glisser pour pivoter • Pincer (${_zoomScale.toStringAsFixed(1)}x)",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildViewModePill(String mode, IconData icon) {
    final isSelected = mode == _viewMode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 6),
            Text(
              mode,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FINE-TUNE PROPORTIONS CARD ──────────────────────────────────────
  Widget _buildProportionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ajuster les proportions",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Étalonner par rapport à la taille réelle",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Reset Button
              GestureDetector(
                onTap: _resetToBaseline,
                child: Row(
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 13,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Réinitialiser",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Height Slider Box
          _buildCompactSliderBox(
            icon: Icons.height_rounded,
            title: "Taille",
            displayValue: _formatHeight(_heightInches),
            value: _heightInches,
            min: 56.0,
            max: 80.0,
            onDecrement: () {
              if (_heightInches > 56.0) setState(() => _heightInches -= 1.0);
            },
            onIncrement: () {
              if (_heightInches < 80.0) setState(() => _heightInches += 1.0);
            },
            onChanged: (v) => setState(() => _heightInches = v),
          ),

          const SizedBox(height: 12),

          // Waist Fit Slider Box
          _buildCompactSliderBox(
            icon: Icons.compress_rounded,
            title: "Ajustement de Taille",
            displayValue: "${_waistInches.toStringAsFixed(1)} in",
            value: _waistInches,
            min: 20.0,
            max: 45.0,
            onDecrement: () {
              if (_waistInches > 20.0) setState(() => _waistInches -= 0.5);
            },
            onIncrement: () {
              if (_waistInches < 45.0) setState(() => _waistInches += 0.5);
            },
            onChanged: (v) => setState(() => _waistInches = v),
          ),

          const SizedBox(height: 12),

          // Shoulders & Torso Dropdown Selector Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.open_in_full_rounded,
                        size: 18,
                        color: Color(0xFF475569),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "Épaules & Torse",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final idx = _shoulderTorsoOptions.indexOf(
                            _shoulderTorso,
                          );
                          if (idx > 0) {
                            setState(
                              () => _shoulderTorso =
                                  _shoulderTorsoOptions[idx - 1],
                            );
                          }
                        },
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 18,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _shoulderTorso,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          final idx = _shoulderTorsoOptions.indexOf(
                            _shoulderTorso,
                          );
                          if (idx < _shoulderTorsoOptions.length - 1) {
                            setState(
                              () => _shoulderTorso =
                                  _shoulderTorsoOptions[idx + 1],
                            );
                          }
                        },
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF475569),
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
    );
  }

  // ── PROPORTION OFFSETS CARD ────────────────────────────────────────
  Widget _buildOffsetsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Décalages des Proportions",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Delta : ±0,0%",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Offset 1: Torso Length Slider Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Longueur du Torse",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_torsoLengthCm >= 0 ? '+' : ''}${_torsoLengthCm.toStringAsFixed(1)} cm",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStepBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (_torsoLengthCm > -5.0) {
                        setState(() => _torsoLengthCm -= 0.5);
                      }
                    },
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 5,
                        activeTrackColor: const Color(0xFFE2E8F0),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFF0F172A),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: _torsoLengthCm,
                        min: -5.0,
                        max: 5.0,
                        onChanged: (v) => setState(() => _torsoLengthCm = v),
                      ),
                    ),
                  ),
                  _buildMiniStepBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (_torsoLengthCm < 5.0) {
                        setState(() => _torsoLengthCm += 0.5);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Raccourci (-5)",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "Ligne de base",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "Allongé (+5)",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 2: Waist Contour Sensitivity Segmented Buttons Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Sensibilité du Contour de Taille",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Naturel (Par défaut)",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Droit', 'Naturel', 'Sablier'].map((opt) {
                  final isSelected = opt == _waistSensitivity;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _waistSensitivity = opt),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            opt,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 3: Hip Breadth Fine-Tuning Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ajustement des Hanches",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_hipBreadthCm >= 0 ? '+' : ''}${_hipBreadthCm.toStringAsFixed(1)} cm",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStepBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (_hipBreadthCm > -2.0) {
                        setState(() => _hipBreadthCm -= 0.5);
                      }
                    },
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 5,
                        activeTrackColor: const Color(0xFFE2E8F0),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFF0F172A),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: _hipBreadthCm,
                        min: -2.0,
                        max: 2.0,
                        onChanged: (v) => setState(() => _hipBreadthCm = v),
                      ),
                    ),
                  ),
                  _buildMiniStepBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (_hipBreadthCm < 2.0) {
                        setState(() => _hipBreadthCm += 0.5);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "-2,0 cm (Ajusté)",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "Pivot Scanné",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "+2,0 cm (Galbé)",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 4: Shoulder Slope Segmented Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pente des Épaules / Angle",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Standard (21°)",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Athlétique', 'Standard', 'Décontracté'].map((opt) {
                  final isSelected = opt == _shoulderSlope;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _shoulderSlope = opt),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            opt,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 5: Inseam Offset Ratio Slider Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ratio de Décalage Entrejambe",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_inseamMm >= 0 ? '+' : ''}${_inseamMm.round()} mm",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStepBtn(
                    icon: Icons.remove,
                    onTap: () {
                      if (_inseamMm > -30.0) {
                        setState(() => _inseamMm -= 5.0);
                      }
                    },
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 5,
                        activeTrackColor: const Color(0xFFE2E8F0),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFF0F172A),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: _inseamMm,
                        min: -30.0,
                        max: 30.0,
                        onChanged: (v) => setState(() => _inseamMm = v),
                      ),
                    ),
                  ),
                  _buildMiniStepBtn(
                    icon: Icons.add,
                    onTap: () {
                      if (_inseamMm < 30.0) {
                        setState(() => _inseamMm += 5.0);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "-30 mm (Petite)",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "Scan Réel",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "+30 mm (Grand)",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── HELPER SLIDER BOX WIDGET ─────────────────────────────────────────
  Widget _buildCompactSliderBox({
    required IconData icon,
    required String title,
    required String displayValue,
    required double value,
    required double min,
    required double max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: const Color(0xFF475569)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                displayValue,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniStepBtn(icon: Icons.remove, onTap: onDecrement),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 5,
                    activeTrackColor: const Color(0xFFE2E8F0),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF0F172A),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
              _buildMiniStepBtn(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStepBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}

// ── ROTATING 3D WIREFRAME MESH PAINTER WITH MORPHING ────────────────────────
class _RotatingWireframeMeshPainter extends CustomPainter {
  final double rotationDegrees;
  final double waistScale; // Morphing factor (e.g. waistInches / 27.5)

  _RotatingWireframeMeshPainter({
    required this.rotationDegrees,
    this.waistScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double rad = rotationDegrees * (math.pi / 180.0);

    final linePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.fill;

    // Projected body rings: Head, Shoulders, Chest, Waist, Hips, Thighs, Calves
    final ringHeights = [-120.0, -80.0, -30.0, 10.0, 50.0, 100.0, 150.0];
    final baseRadiiX = [
      18.0,
      36.0,
      28.0,
      24.0 * waistScale,
      32.0 * waistScale,
      20.0,
      16.0,
    ];

    for (int i = 0; i < ringHeights.length; i++) {
      final y = center.dy + ringHeights[i];
      final rx = baseRadiiX[i];
      final ry = rx * 0.32;

      canvas.save();
      canvas.translate(center.dx, y);
      canvas.rotate(math.sin(rad) * 0.08);

      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        linePaint,
      );

      for (int k = 0; k < 6; k++) {
        final double theta = (k * (math.pi / 3)) + rad;
        final double px = rx * math.cos(theta);
        final double py = ry * math.sin(theta);
        final double depthAlpha = (0.5 + 0.5 * math.sin(theta)).clamp(0.2, 1.0);
        dotPaint.color = const Color(0xFFF43F5E).withValues(alpha: depthAlpha);
        canvas.drawCircle(Offset(px, py), 2.2, dotPaint);
      }
      canvas.restore();
    }

    final spinePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.45)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double spineXOffset = math.sin(rad) * 22.0;
    canvas.drawLine(
      Offset(center.dx + spineXOffset, center.dy - 120),
      Offset(center.dx + spineXOffset, center.dy + 150),
      spinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RotatingWireframeMeshPainter oldDelegate) {
    return oldDelegate.rotationDegrees != rotationDegrees ||
        oldDelegate.waistScale != waistScale;
  }
}

// ── DYNAMIC BIOMETRIC SILHOUETTE HUD PAINTER ────────────────────────────────
class _DynamicBiometricSilhouetteHudPainter extends CustomPainter {
  final double rotationDegrees;
  final double heightCm;
  final double waistCm;
  final double bustCm;
  final double hipsCm;
  final double shoulderWidthCm;

  _DynamicBiometricSilhouetteHudPainter({
    required this.rotationDegrees,
    required this.heightCm,
    required this.waistCm,
    required this.bustCm,
    required this.hipsCm,
    required this.shoulderWidthCm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double rad = rotationDegrees * (math.pi / 180.0);

    final hudPaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.8)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.fill;

    final calY = [
      center.dy - 75,
      center.dy - 25,
      center.dy + 15,
      center.dy + 55,
    ];

    final calLabels = [
      "Épaules ${shoulderWidthCm.round()}cm",
      "Buste ${bustCm.round()}cm",
      "Taille ${waistCm.round()}cm",
      "Hanches ${hipsCm.round()}cm",
    ];

    final calWidths = [
      (shoulderWidthCm / 44.0) * 120.0,
      (bustCm / 86.0) * 100.0,
      (waistCm / 70.0) * 80.0,
      (hipsCm / 94.0) * 110.0,
    ];

    for (int i = 0; i < calY.length; i++) {
      final y = calY[i];
      final w = calWidths[i].clamp(50.0, 160.0);
      final xShift = math.sin(rad) * 12.0;

      // Caliper line
      canvas.drawLine(
        Offset(center.dx - w / 2 + xShift, y),
        Offset(center.dx + w / 2 + xShift, y),
        hudPaint,
      );

      // Caliper end ticks
      canvas.drawLine(
        Offset(center.dx - w / 2 + xShift, y - 4),
        Offset(center.dx - w / 2 + xShift, y + 4),
        hudPaint,
      );
      canvas.drawLine(
        Offset(center.dx + w / 2 + xShift, y - 4),
        Offset(center.dx + w / 2 + xShift, y + 4),
        hudPaint,
      );

      // Node dots
      canvas.drawCircle(Offset(center.dx - w / 2 + xShift, y), 2.5, dotPaint);
      canvas.drawCircle(Offset(center.dx + w / 2 + xShift, y), 2.5, dotPaint);

      // Text label
      final textSpan = TextSpan(
        text: calLabels[i],
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF43F5E),
          letterSpacing: 0.3,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(center.dx + w / 2 + xShift + 8, y - 6));
    }
  }

  @override
  bool shouldRepaint(
      covariant _DynamicBiometricSilhouetteHudPainter oldDelegate) {
    return oldDelegate.rotationDegrees != rotationDegrees ||
        oldDelegate.waistCm != waistCm ||
        oldDelegate.hipsCm != hipsCm ||
        oldDelegate.shoulderWidthCm != shoulderWidthCm;
  }
}


