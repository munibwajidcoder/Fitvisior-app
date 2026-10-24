import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:io';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../data/product_service.dart';
import 'home_screen.dart';

class QualityInformationScreen extends StatefulWidget {
  final ProductModel? product;
  const QualityInformationScreen({super.key, this.product});

  @override
  State<QualityInformationScreen> createState() =>
      _QualityInformationScreenState();
}

class _QualityInformationScreenState extends State<QualityInformationScreen> {
  static const Color _midnightNavy = Color(0xFF172554);
  bool _is3DActive = false;

  @override
  void initState() {
    super.initState();
    // Wait for the slide transition to complete before starting WebGL (prevents SurfaceView GPU collision crash)
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _is3DActive = true);
      }
    });
  }

  @override
  void dispose() {
    _is3DActive = false;
    super.dispose();
  }

  int get _fitScore {
    if (widget.product != null && widget.product!.fitPercent.isNotEmpty) {
      final parsed = int.tryParse(widget.product!.fitPercent.replaceAll('%', '').trim());
      if (parsed != null && parsed > 0) return parsed;
    }
    return 94;
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. TOP APP BAR ───────────────────────────────────────
            _buildAppBar(context),

            // ── 2. SCROLLABLE BODY ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // 2A. VIEWPORT SCAN HERO CARD
                    _buildViewportScanHeroCard(),

                    const SizedBox(height: 16),

                    // 2B. MAIN QUALITY INSPECTION CARD
                    _buildMainQualityInspectionCard(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. TOP APP BAR ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 28,
                color: _midnightNavy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEn ? "Quality Information" : "Informations de Qualité",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
                letterSpacing: -0.4,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // User Avatar Profile
          ValueListenableBuilder<File?>(
            valueListenable: UserAvatarService.avatarNotifier,
            builder: (context, avatarFile, _) {
              return Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: ClipOval(
                  child: avatarFile != null
                      ? Image.file(avatarFile, fit: BoxFit.cover)
                      : const Icon(Icons.person_rounded, size: 20, color: Color(0xFF2563EB)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 2A. VIEWPORT SCAN HERO CARD ───────────────────────────────────────────
  Widget _buildViewportScanHeroCard() {
    String? glbSrc = UserAvatarService.avatarGlbNotifier.value;
    final g = (widget.product?.gender ?? '').toLowerCase();
    final isMale = g.contains('homme') || g.contains('male');
    final defaultAsset = isMale ? 'assets/models/base_avatar_male.glb' : 'assets/models/base_avatar_female.glb';

    if (glbSrc == null || glbSrc.isEmpty) {
      glbSrc = defaultAsset;
    }
    if (glbSrc.startsWith('asset://')) {
      glbSrc = glbSrc.replaceFirst('asset://', '');
    }
    if (!glbSrc.startsWith('http://') &&
        !glbSrc.startsWith('https://') &&
        !glbSrc.startsWith('assets/')) {
      glbSrc = defaultAsset;
    }

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Center: 3D Avatar Model
          Positioned.fill(
            child: _is3DActive && glbSrc.isNotEmpty
                ? ModelViewer(
                    key: ValueKey('quality_avatar_$glbSrc'),
                    src: glbSrc,
                    alt: LanguageService.instance.isEnglish ? '3D Avatar Inspection' : 'Avatar 3D Inspection',
                    autoRotate: false, // No auto-spinning
                    cameraControls: true,
                    backgroundColor: Colors.white,
                    cameraOrbit: '0deg 75deg 180%',
                    cameraTarget: 'auto auto auto',
                    fieldOfView: 'auto',
                    minCameraOrbit: 'auto auto 100%',
                    maxCameraOrbit: 'auto auto 300%',
                    shadowIntensity: 0.8,
                    exposure: 1.05,
                  )
                : Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Color(0xFFF43F5E),
                              strokeWidth: 2.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            LanguageService.instance.isEnglish ? "Loading 3D Avatar..." : "Chargement Avatar 3D...",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

            // Top Gradient Shadow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x22000000), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),

            // Content inside Hero Card
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Sub-header text
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _midnightNavy.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      LanguageService.instance.isEnglish ? "3D VIEWPORT SCAN" : "SCAN DU VIEWPORT 3D",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),

                  // Bottom Badges Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 16,
                                color: Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.product?.displayName ?? (LanguageService.instance.isEnglish ? "Model 04 • Wool & Silk Twill" : "Modèle 04 • Sergé de Laine & Soie"),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _midnightNavy,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _midnightNavy,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          LanguageService.instance.isEnglish ? "3D Spatial" : "Spatial 3D",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  // ── 2B. MAIN QUALITY INSPECTION CARD ──────────────────────────────────────
  Widget _buildMainQualityInspectionCard(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Red Inspection Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 6),
                Text(
                  isEn ? "AI DRAPE INSPECTION • VALID" : "INSPECTION DU DRAPÉ IA • VALIDE",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE11D48),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Circular Progress Ring / Fit Accuracy Gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 125,
                height: 125,
                child: CircularProgressIndicator(
                  value: _fitScore / 100.0,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(_midnightNavy),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Top Red Dot Indicator on Gauge Ring
              Positioned(
                top: 2,
                right: 36,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "$_fitScore",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _midnightNavy,
                        ),
                      ),
                      Text(
                        "%",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isEn ? "DRAPE ACCURACY" : "PRÉCISION DU DRAPÉ",
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Headline
          Text(
            isEn
                ? "Excellent Fit with Optimal Silhouette Drape"
                : "Ajustement Excellent avec Légères Remarques Ambiances",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _midnightNavy,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 8),

          // Main Body Description
          Text(
            isEn
                ? "Our spatial engine adapted the silhouette to your measurements with high-fidelity drape simulation."
                : "Notre moteur spatial a adapté la silhouette à vos mensurations avec une haute fidélité de drapé.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 24),

          // PRIMARY CTA BUTTON: SOLID CORAL PINK (#F43F5E)
          // NAVIGATES DIRECTLY TO HOME SCREEN AS REQUESTED BY USER IN AUDIO!
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(initialIndex: 3),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E), // Solid Coral Pink
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isEn ? "Save Look — Perfect Fit ✓" : "C'est Parfait, Super Look ✓",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

