import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'size_selection_screen.dart';
import 'change_size_color_screen.dart';

class LiveArMirrorScreen extends StatefulWidget {
  const LiveArMirrorScreen({super.key});

  @override
  State<LiveArMirrorScreen> createState() => _LiveArMirrorScreenState();
}

class _LiveArMirrorScreenState extends State<LiveArMirrorScreen> {
  bool _showAfter = true;
  int _selectedColorIndex = 0; // 0 = Navy Blue
  int _selectedThumbIndex = 1; // 1 = After (dress)

  static const Color _midnightNavy = Color(0xFF172554);

  final List<Color> _colorOptions = [
    const Color(0xFF172554), // Navy Blue
    const Color(0xFF0F172A), // Black
    const Color(0xFFE7E5E4), // Beige / Ecru
    const Color(0xFF4D5B46), // Olive Green
    const Color(0xFF881337), // Burgundy Maroon
  ];

  final List<String> _colorNames = [
    "Bleu Nuit",
    "Noir Intense",
    "Beige Écru",
    "Vert Olive",
    "Bordeaux Profond",
  ];

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
              "Miroir RA en Direct",
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: !_showAfter ? _midnightNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Avant",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            !_showAfter ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showAfter = true),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _showAfter ? _midnightNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Après",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color:
                            _showAfter ? Colors.white : const Color(0xFF64748B),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 540,
        color: const Color(0xFF0F172A),
        child: Stack(
          children: [
            // Background AR Live Render Image
            Positioned.fill(
              child: Image.asset(
                _showAfter
                    ? 'assets/images/product_dress.jpg'
                    : 'assets/images/avatar_3d.jpg',
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  color: const Color(0xFF172554),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 90,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),

            // Top Gradient Shadow Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
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

            // Top Row: Simulated Render Badge (Left) & Confidence Gauge (Right)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Badge: "Rendu simulé (i)"
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
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
                        const Icon(
                          Icons.view_in_ar_rounded,
                          size: 14,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Rendu simulé",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _midnightNavy,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ),

                  // Right Badge: "92% Confiance - Bon ajustement"
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0D9488)),
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
                                  "Confiance",
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
                              "Bon ajustement",
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
                ],
              ),
            ),

            // Left Card: "Conditions de Capture" & Notice
            Positioned(
              top: 60,
              left: 12,
              child: SizedBox(
                width: 165,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny_outlined,
                                  size: 13, color: Colors.white),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  "Conditions Capture",
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _buildConditionCheckRow("Éclairage optimal"),
                          const SizedBox(height: 3),
                          _buildConditionCheckRow("Caméra hauteur yeux"),
                          const SizedBox(height: 3),
                          _buildConditionCheckRow("Arrière-plan dégagé"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 13,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "La qualité de rendu peut varier selon l'éclairage.",
                              style: GoogleFonts.inter(
                                fontSize: 8.5,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.25,
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

            // Right Vertical Control Buttons Toolbar & Color Selector
            Positioned(
              right: 12,
              top: 70,
              child: Column(
                children: [
                  // Button 1: Fullscreen
                  _buildFloatingCircleButton(
                    icon: Icons.fullscreen_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),

                  // Button 2: Camera Capture
                  _buildFloatingCircleButton(
                    icon: Icons.camera_alt_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Capture d'écran enregistrée !",
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Button 3: Refresh / Rotate
                  _buildFloatingCircleButton(
                    icon: Icons.refresh_rounded,
                    onTap: () {
                      setState(() {
                        _selectedThumbIndex = (_selectedThumbIndex + 1) % 2;
                        _showAfter = (_selectedThumbIndex == 1);
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Vertical Color Palette Picker Box
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children:
                          List.generate(_colorOptions.length, (index) {
                        final isSelected = _selectedColorIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColorIndex = index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Couleur changée : ${_colorNames[index]}",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600),
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _colorOptions[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFCBD5E1),
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: _colorOptions[index] ==
                                            const Color(0xFFE7E5E4)
                                        ? _midnightNavy
                                        : Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Left Side-by-Side Thumbnail Cards ("Before" / "After")
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Before Thumbnail
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedThumbIndex = 0;
                        _showAfter = false;
                      }),
                      child: Container(
                        width: 48,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedThumbIndex == 0
                                ? const Color(0xFF3B82F6)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/avatar_3d.jpg',
                                width: 48,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: Colors.black.withValues(alpha: 0.6),
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Avant",
                                style: GoogleFonts.inter(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // After Thumbnail
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedThumbIndex = 1;
                        _showAfter = true;
                      }),
                      child: Container(
                        width: 48,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedThumbIndex == 1
                                ? const Color(0xFF3B82F6)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/product_dress.jpg',
                                width: 48,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              color: Colors.black.withValues(alpha: 0.6),
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                "Après",
                                style: GoogleFonts.inter(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildConditionCheckRow(String text) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(
          Icons.check_rounded,
          size: 11,
          color: Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildFloatingCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: _midnightNavy,
        ),
      ),
    );
  }

  // ── 3. BOTTOM CONTROLS & SELECTION PANEL ──────────────────────────────────
  Widget _buildBottomControlsPanel(BuildContext context) {
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SizeSelectionScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
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
                                "Taille",
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
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
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
                            border: Border.all(
                                color: const Color(0xFFCBD5E1), width: 1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Couleur",
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

          const SizedBox(height: 12),

          // Row 2: 3 Quick Action Outlined Buttons
          Row(
            children: [
              _buildMiniActionTile(
                icon: Icons.grid_view_rounded,
                title: "Changer Taille / Couleur",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChangeSizeColorScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              _buildMiniActionTile(
                icon: Icons.shopping_bag_outlined,
                title: "Ajouter Chaussures & Accessoires",
                onTap: () {},
              ),
              const SizedBox(width: 6),
              _buildMiniActionTile(
                icon: Icons.straighten_rounded,
                title: "Guide des Tailles ↗",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SizeSelectionScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 3: PRIMARY MAIN CTA BUTTON — SOLID CORAL PINK (#F43F5E)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ChangeSizeColorScreen(),
                  ),
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
                  const Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Continuer vers le Changement de Taille / Couleur",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Row 4: Footer Notice & Camera Access Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Camera Link
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Autorisation caméra mise à jour.",
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          "Besoin d'aide ? Autoriser l'accès caméra",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Right: Fallback Photo/Video Banner
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.photo_camera_outlined,
                        size: 13,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          "Si la caméra ne fonctionne pas, utilisez une photo ou vidéo.",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: const Color(0xFF64748B),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: _midnightNavy),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _midnightNavy,
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

