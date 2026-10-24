import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:io';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../data/product_service.dart';
import 'multi_object_try_on_screen.dart';
import 'physics_drape_screen.dart' show FitScoreEngine;

class ChangeSizeColorScreen extends StatefulWidget {
  final ProductModel? product;
  const ChangeSizeColorScreen({super.key, this.product});

  @override
  State<ChangeSizeColorScreen> createState() => _ChangeSizeColorScreenState();
}

class _ChangeSizeColorScreenState extends State<ChangeSizeColorScreen> {
  int _selectedSizeIndex = 2;
  int _selectedColorIndex = 0;
  bool _is3DActive = true;

  static const Color _midnightNavy = Color(0xFF172554);

  List<Map<String, String>> _sizes = [
    {'code': 'XS', 'percent': '74%'},
    {'code': 'S', 'percent': '88%'},
    {'code': 'M', 'percent': '95% ★'},
    {'code': 'L', 'percent': '84%'},
    {'code': 'XL', 'percent': '70%'},
  ];

  @override
  void initState() {
    super.initState();
    _initDynamicData();
  }

  void _initDynamicData() async {
    final available = widget.product?.availableSizes ?? ['XS', 'S', 'M', 'L', 'XL'];
    final rec = widget.product?.recSize ?? 'M';

    Map<String, dynamic>? profile;
    try { profile = await AuthService.getProfile(); } catch (_) {}

    final double b = (profile?['bust_cm'] as num?)?.toDouble() ?? 88.0;
    final double w = (profile?['waist_cm'] as num?)?.toDouble() ?? 70.0;
    final double hips = (profile?['hip_cm'] as num?)?.toDouble() ?? 94.0;

    final list = <Map<String, String>>[];
    int targetIdx = 0;
    for (int i = 0; i < available.length; i++) {
      final code = available[i];
      final res = FitScoreEngine.calculate(size: code, bustCm: b, waistCm: w, hipsCm: hips);
      final score = res.score.round();
      final isRec = code == rec;
      list.add({
        'code': code,
        'percent': isRec ? '$score% ★' : '$score%',
      });
      if (isRec) {
        targetIdx = i;
      }
    }
    if (mounted) {
      setState(() {
        _sizes = list;
        _selectedSizeIndex = targetIdx;
      });
    }
  }

  final List<Color> _colors = [
    const Color(0xFF172554), // Midnight Noir
    const Color(0xFFB91C1C), // Crimson Red
    const Color(0xFFE7E5E4), // Pearl Cream
    const Color(0xFF09090B), // Deep Onyx
  ];

  List<String> get _colorNames {
    final isEn = LanguageService.instance.isEnglish;
    return isEn
        ? ["Midnight Black", "Crimson Red", "Pearl Cream", "Deep Onyx"]
        : ["Noir Nuit", "Rouge Crayon", "Crème Nacre", "Noir Profond"];
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // 2A. HERO VIEWPORT HALF-CARD
                    _buildHeroViewportCard(),

                    const SizedBox(height: 16),

                    // 2B. BOTTOM SELECTION SHEET CONTAINER
                    _buildSelectionSheetContainer(context),

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
              LanguageService.instance.isEnglish ? "Change Size / Colour" : "Changer la Taille / Couleur",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
                letterSpacing: -0.3,
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

  // ── 2A. HERO VIEWPORT HALF-CARD ───────────────────────────────────────────
  Widget _buildHeroViewportCard() {
    final isEn = LanguageService.instance.isEnglish;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 280,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floor Shadow
            Positioned(
              bottom: 12,
              child: Container(
                width: 140,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),

            // Full-width 3D Avatar (user's own avatar ONLY — no product image)
            Positioned.fill(
              child: Builder(
                builder: (context) {
                  final glbSrc = UserAvatarService.avatarGlbNotifier.value;
                  if (!_is3DActive) {
                    return Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF43F5E),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  if (glbSrc == null || glbSrc.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.accessibility_new_rounded,
                              size: 56, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 10),
                          Text(
                            isEn ? "Avatar not created" : "Avatar non créé",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ModelViewer(
                    key: ValueKey('change_size_avatar_$glbSrc'),
                    src: glbSrc,
                    alt: isEn ? '3D Avatar' : 'Avatar 3D',
                    autoRotate: false, // No auto-spinning
                    cameraControls: true,
                    backgroundColor: Colors.white,
                    cameraOrbit: '0deg 75deg 180%',
                    cameraTarget: 'auto auto auto',
                    fieldOfView: 'auto',
                    minCameraOrbit: 'auto auto 100%',
                    maxCameraOrbit: 'auto auto 300%',
                  );
                },
              ),
            ),

            // Top Gradient Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 70,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x88000000), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Top Left Pill: "• Drapé Spatial Actif • 60 FPS"
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _midnightNavy.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? "Active Spatial Drape • 60 FPS" : "Drapé Spatial Actif • 60 FPS",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Right Pill: "Profil : 99,2% Calibré"
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 13,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isEn ? "Profile: 99.2% Calibrated" : "Profil : 99,2% Calibré",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _midnightNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Left Product Tag Box: "Soie Drapée Midi • Taille M • Noir Nuit"
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.view_in_ar_rounded,
                      size: 18,
                      color: _midnightNavy,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.product?.name ?? (isEn ? "Draped Silk Dress" : "Robe Soie Drapée"),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _midnightNavy,
                          ),
                        ),
                        Text(
                          isEn
                              ? "Size ${_sizes[_selectedSizeIndex]['code']} • ${_colorNames[_selectedColorIndex]}"
                              : "Taille ${_sizes[_selectedSizeIndex]['code']} • ${_colorNames[_selectedColorIndex]}",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Right Refresh Floating Circle Button
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: _midnightNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2B. BOTTOM SELECTION SHEET CONTAINER ──────────────────────────────────
  Widget _buildSelectionSheetContainer(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle Pill Bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Row: Title & "✨ Maillage Dynamique" Badge
          Row(
            children: [
              Expanded(
                child: Text(
                  isEn ? "Select Size & Colour" : "Sélectionner Taille & Couleur",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 12,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? "Dynamic Mesh" : "Maillage Dynamique",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            isEn
                ? "Real-time drape re-simulation on your calibrated avatar"
                : "Re-simulation du drapé en temps réel sur votre avatar calibré",
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // 1. FIT CONFIDENCE CARD (LIGHT PINK/CREAM CONTAINER)
          _buildFitConfidenceCard(),

          const SizedBox(height: 16),

          // 2. AVAILABLE SIZES SECTION
          _buildAvailableSizesSection(),

          const SizedBox(height: 16),

          // 3. COLORWAY SECTION
          _buildColorwaySection(),

          const SizedBox(height: 20),

          // 5. PRIMARY MAIN CTA BUTTON: SOLID CORAL PINK (#F43F5E)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                setState(() => _is3DActive = false);
                await Future.delayed(const Duration(milliseconds: 100));
                if (!mounted) return;
                await nav.push(
                  MaterialPageRoute(
                    builder: (context) => MultiObjectTryOnScreen(product: widget.product),
                  ),
                );
                if (mounted) setState(() => _is3DActive = true);
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
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isEn ? "✨ Apply to Avatar" : "✨ Appliquer à l'Avatar",
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
          // Note: Secondary button "View 3D Tension Heatmap" REMOVED as requested in audio!
        ],
      ),
    );
  }

  // ── 1. FIT CONFIDENCE CARD ────────────────────────────────────────────────
  Widget _buildFitConfidenceCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Color(0xFFE11D48),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isEn
                        ? "Fit Confidence: 94% — Flattering Cut"
                        : "Confiance d'Ajustement : 94% — Coupe Flatteuse",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _midnightNavy,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFECDD3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isEn ? "Recommended" : "Recommandé",
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFBE123C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. AVAILABLE SIZES SECTION ────────────────────────────────────────────
  Widget _buildAvailableSizesSection() {
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? "Available Sizes" : "Tailles Disponibles",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.straighten_rounded,
                  size: 14,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 4),
                Text(
                  isEn ? "Measurement Guide" : "Guide des Mensurations",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE11D48),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_sizes.length, (index) {
            final isSelected = _selectedSizeIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedSizeIndex = index),
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == _sizes.length - 1 ? 0 : 6,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? _midnightNavy : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? _midnightNavy
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _sizes[index]['code']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : _midnightNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _sizes[index]['percent']!,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── 3. COLORWAY SECTION ───────────────────────────────────────────────────
  Widget _buildColorwaySection() {
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEn ? "Colour : " : "Couleur : ",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      _colorNames[_selectedColorIndex],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _midnightNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.texture_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  isEn ? "Lustrous Georgette Silk" : "Soie Georgette Lustrée",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_colors.length, (index) {
            final isSelected = _selectedColorIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 14),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _colors[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _midnightNavy : const Color(0xFFCBD5E1),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _midnightNavy.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: _colors[index] == const Color(0xFFE7E5E4)
                            ? _midnightNavy
                            : Colors.white,
                      )
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

}

