import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../data/product_service.dart';
import 'change_size_color_screen.dart';

class LiveArMirrorScreen extends StatefulWidget {
  final ProductModel? product;
  const LiveArMirrorScreen({super.key, this.product});

  @override
  State<LiveArMirrorScreen> createState() => _LiveArMirrorScreenState();
}

class _LiveArMirrorScreenState extends State<LiveArMirrorScreen> {
  bool _showAfter = true;
  bool _is3DActive = true;
  final int _selectedColorIndex = 0; // 0 = Navy Blue

  static const Color _midnightNavy = Color(0xFF172554);

  final List<Color> _colorOptions = [
    const Color(0xFF172554), // Navy Blue
    const Color(0xFF0F172A), // Black
    const Color(0xFFE7E5E4), // Beige / Ecru
    const Color(0xFF4D5B46), // Olive Green
    const Color(0xFF881337), // Burgundy Maroon
  ];

  List<String> get _colorNames {
    final isEn = LanguageService.instance.isEnglish;
    return isEn
        ? ["Midnight Blue", "Deep Black", "Beige Ecru", "Olive Green", "Deep Burgundy"]
        : ["Bleu Nuit", "Noir Intense", "Beige Écru", "Vert Olive", "Bordeaux Profond"];
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
            // ── TOP NAVIGATION BAR ──────────────────────────────────
            _buildTopBar(context),

            // ── MAIN AR VIEWPORT WITH OVERLAYS ───────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // 1. HERO AR VIEWPORT CARD WITH OVERLAYS
                    _buildArHeroViewportCard(context),

                    const SizedBox(height: 16),

                    // 2. BOTTOM CONTROLS & SELECTION PANEL
                    _buildBottomControlsPanel(context),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. TOP NAVIGATION BAR ─────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Circular Back Button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                size: 26,
                color: _midnightNavy,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              LanguageService.instance.isEnglish ? "Live AR Mirror" : "Miroir RA en Direct",
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

          // Before / After Toggle Pill
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showAfter = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: !_showAfter ? _midnightNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      LanguageService.instance.isEnglish ? "Before" : "Avant",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: !_showAfter ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showAfter = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _showAfter ? _midnightNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      LanguageService.instance.isEnglish ? "After" : "Après",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _showAfter ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. HERO AR VIEWPORT CARD WITH OVERLAYS ─────────────────────────────────
  Widget _buildArHeroViewportCard(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    // Strictly use only the current logged-in user's own GLB — no shared default fallback
    final glbSrc = UserAvatarService.avatarGlbNotifier.value;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 540,
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center: Real 3D Avatar GLB Model in AR Mirror
            Positioned.fill(
              child: _is3DActive && glbSrc != null && glbSrc.isNotEmpty
                  ? ModelViewer(
                      key: ValueKey('live_ar_avatar_$glbSrc'),
                      src: glbSrc,
                      alt: isEn ? '3D AR Mirror Avatar' : 'Avatar Miroir RA 3D',
                      autoRotate: false, // No auto-spinning — user controls rotation
                      cameraControls: true,
                      backgroundColor: Colors.white,
                      cameraOrbit: '0deg 75deg 180%',
                      cameraTarget: 'auto auto auto',
                      fieldOfView: 'auto',
                      minCameraOrbit: 'auto auto 100%',
                      maxCameraOrbit: 'auto auto 300%',
                      shadowIntensity: 1.0,
                      exposure: 1.0,
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.accessibility_new_rounded,
                              size: 72, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 14),
                          Text(
                            isEn ? "Avatar not created" : "Avatar non créé",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEn ? "Create your avatar during sign-up" : "Créez votre avatar lors de l'inscription",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Top Gradient Shadow Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
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

            // Top Row: Confidence Gauge (Right)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
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
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            value: 0.92,
                            strokeWidth: 2.5,
                            backgroundColor: Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                          ),
                        ),
                        Text(
                          "92%",
                          style: GoogleFonts.inter(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                            color: _midnightNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isEn ? "Confidence" : "Confiance",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _midnightNavy,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 10,
                              color: Color(0xFF64748B),
                            ),
                          ],
                        ),
                        Text(
                          isEn ? "Good fit" : "Bon ajustement",
                          style: GoogleFonts.inter(
                            fontSize: 9,
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
          ],
        ),
      ),
    );
  }

  // ── 3. BOTTOM CONTROLS & SELECTION PANEL ──────────────────────────────────
  Widget _buildBottomControlsPanel(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Size Pill (Left) & Color Pill (Right)
          Row(
            children: [
              // Size Pill Card
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final nav = Navigator.of(context);
                    setState(() => _is3DActive = false);
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted) return;
                    await nav.push(
                      MaterialPageRoute(
                        builder: (context) => ChangeSizeColorScreen(product: widget.product),
                      ),
                    );
                    if (mounted) setState(() => _is3DActive = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.checkroom_rounded,
                          size: 18,
                          color: _midnightNavy,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? "Size" : "Taille",
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                "M",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: _midnightNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Color Pill Card
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final nav = Navigator.of(context);
                    setState(() => _is3DActive = false);
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted) return;
                    await nav.push(
                      MaterialPageRoute(
                        builder: (context) => ChangeSizeColorScreen(product: widget.product),
                      ),
                    );
                    if (mounted) setState(() => _is3DActive = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _colorOptions[_selectedColorIndex],
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? "Colour" : "Couleur",
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                _colorNames[_selectedColorIndex],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: _midnightNavy,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // PRIMARY MAIN CTA BUTTON — SOLID CORAL PINK (#F43F5E)
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
                    builder: (context) => ChangeSizeColorScreen(product: widget.product),
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
                  const Icon(Icons.tune_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isEn ? "Continue to Change Size & Colour" : "Continuer vers le Changement de Taille / Couleur",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
