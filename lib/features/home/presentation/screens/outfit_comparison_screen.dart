import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class OutfitComparisonScreen extends StatefulWidget {
  const OutfitComparisonScreen({super.key});

  @override
  State<OutfitComparisonScreen> createState() => _OutfitComparisonScreenState();
}

class _OutfitComparisonScreenState extends State<OutfitComparisonScreen> {
  double _sliderPos = 0.5; // Split comparison slider (0.0 to 1.0)

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Interactive Split-Screen Comparison View (As in Screenshot)
              _buildSplitComparisonCard(),
              const SizedBox(height: 16),

              // 2. Atelier & Product Metrics Card
              _buildProductMetricsCard(),
              const SizedBox(height: 20),

              // 3. Primary Action Button: "Conserver ce Look ✓" -> Wardrobe
              _buildKeepLookButton(),
              const SizedBox(height: 12),

              // 4. Secondary Action Button: "Essayer une autre Taille / Couleur" -> Back
              _buildTryAnotherSizeButton(),
              const SizedBox(height: 16),

              // 5. Footer Warranty Disclaimer
              _buildFooterDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAF9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF172554)),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Comparaison de Tenues",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF172554),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
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
        ),
      ],
    );
  }

  // ── 1. SPLIT COMPARISON CARD (MATCHING SCREENSHOT 1000%) ──────────────────

  Widget _buildSplitComparisonCard() {
    return Container(
      height: 440,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final cardHeight = constraints.maxHeight;

            return Stack(
              children: [
                // Right Layer: Draped Outfit Model (Full Background)
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/product_dress.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),

                // Left Layer: 3D Base Avatar (Clipped to Slider Width)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: cardWidth * _sliderPos,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minWidth: cardWidth,
                      maxWidth: cardWidth,
                      minHeight: cardHeight,
                      maxHeight: cardHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/adaptive_3d_rig.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),

                          // 3D Biometric Node Overlays on Left Model
                          Positioned(
                            top: 45,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                "TAILLE: 172cm / POIDS: 58kg",
                                style: GoogleFonts.inter(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 85,
                            left: 35,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.cyan.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.cyanAccent),
                              ),
                              child: Text(
                                "POSTURE: 98%",
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 170,
                            left: 15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.blueAccent.shade100),
                              ),
                              child: Text(
                                "ALIGNEMENT OPTIMAL",
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top Left Badge: BEFORE • BASE
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "AVANT • BASE",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                // Top Right Action Buttons (Orbit 3D & Share)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Column(
                    children: [
                      // 3D Rotate Button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.threed_rotation_rounded,
                          size: 18,
                          color: Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Share Button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.ios_share_rounded,
                          size: 18,
                          color: Color(0xFF172554),
                        ),
                      ),
                    ],
                  ),
                ),

                // Split Divider Line
                Positioned(
                  left: cardWidth * _sliderPos - 1.5,
                  top: 0,
                  bottom: 0,
                  width: 3,
                  child: Container(color: Colors.white),
                ),

                // Interactive Drag Handle Badge in Center
                Positioned(
                  left: cardWidth * _sliderPos - 20,
                  top: cardHeight * 0.45,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _sliderPos += details.delta.dx / cardWidth;
                        _sliderPos = _sliderPos.clamp(0.05, 0.95);
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF172554),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Bottom Floating Pill: "Glissez pour comparer la tension"
                Positioned(
                  bottom: 14,
                  left: (cardWidth - 230) / 2,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _sliderPos += details.delta.dx / cardWidth;
                        _sliderPos = _sliderPos.clamp(0.05, 0.95);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
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
                          const Icon(Icons.sync_alt_rounded,
                              size: 14, color: Color(0xFF172554)),
                          const SizedBox(width: 6),
                          Text(
                            "Glissez pour comparer la tension",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF172554),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── 2. ATELIER & PRODUCT METRICS CARD ────────────────────────────────────

  Widget _buildProductMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header Row: ATELIER VIRTUEL • Prêt à Couper | ✓ Ajustement Sur-Mesure
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      "ATELIER VIRTUEL",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Prêt à Couper",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF43F5E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Bespoke Match Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 13, color: Color(0xFFE11D48)),
                    const SizedBox(width: 4),
                    Text(
                      "Ajustement Sur-Mesure",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Product Title
          Text(
            "Midi en Soie Drapé Sculpté",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),

          // 3 Stat Metrics Grid Row
          Row(
            children: [
              // Stat 1: Précision Mesh 99.2%
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Précision Mesh",
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.tune_rounded,
                              size: 13, color: Color(0xFF64748B)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "99.2%",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      Text(
                        "Zéro collision",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF94A3B8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Stat 2: Aisance Taille +1.4"
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Aisance Taille",
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE11D48),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.straighten_rounded,
                              size: 13, color: Color(0xFFE11D48)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "+1.4\"",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                      Text(
                        "Contouré",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF43F5E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Stat 3: Silhouette Colonne
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Silhouette",
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.accessibility_new_rounded,
                              size: 13, color: Color(0xFF64748B)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Colonne",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Drapé équilibré",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: const Color(0xFF94A3B8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Fabric Node Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.grid_4x4_rounded,
                    size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Élasticité dynamique du tissu calculée sur 18 nœuds biométriques de posture.",
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                      height: 1.3,
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

  // ── 3. KEEP THIS LOOK BUTTON (REDIRECTS TO WARDROBE) ───────────────────────

  Widget _buildKeepLookButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Navigates directly to main Wardrobe Tab in HomeScreen with full bottom nav bar
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(initialIndex: 3),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF43F5E), // Exact Coral Pink theme color
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Conserver ce Look",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.check_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // ── 4. TRY ANOTHER SIZE / COLOR BUTTON (BACK TO PRODUCT COMPARISON) ──────

  Widget _buildTryAnotherSizeButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Pops back to Product Comparison Screen so user can adjust products/sizes
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEE2E2), // Soft Pink tint matching screenshot
          foregroundColor: const Color(0xFFBE123C), // Deep Rose text
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.palette_outlined, size: 18),
            const SizedBox(width: 8),
            Text(
              "Essayer une autre Taille / Couleur",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. FOOTER DISCLAIMER ──────────────────────────────────────────────────

  Widget _buildFooterDisclaimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "Garantie d'échange de taille AR 30 jours • Livraison neutre en carbone",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }
}
