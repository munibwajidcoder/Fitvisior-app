import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'multi_object_try_on_screen.dart';

class ChangeSizeColorScreen extends StatefulWidget {
  const ChangeSizeColorScreen({super.key});

  @override
  State<ChangeSizeColorScreen> createState() => _ChangeSizeColorScreenState();
}

class _ChangeSizeColorScreenState extends State<ChangeSizeColorScreen> {
  int _selectedSizeIndex = 2; // 2 = M (94%)
  int _selectedColorIndex = 0; // 0 = Midnight Noir

  static const Color _midnightNavy = Color(0xFF172554);

  final List<Map<String, String>> _sizes = [
    {'code': 'XS', 'percent': '74%'},
    {'code': 'S', 'percent': '88%'},
    {'code': 'M', 'percent': '94% ★'},
    {'code': 'L', 'percent': '89%'},
    {'code': 'XL', 'percent': '79%'},
  ];

  final List<Color> _colors = [
    const Color(0xFF172554), // Midnight Noir
    const Color(0xFFB91C1C), // Crimson Red
    const Color(0xFFE7E5E4), // Pearl Cream
    const Color(0xFF09090B), // Deep Onyx
  ];

  final List<String> _colorNames = [
    "Noir Nuit",
    "Rouge Crayon",
    "Crème Nacre",
    "Noir Profond",
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
              "Changer la Taille / Couleur",
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

  // ── 2A. HERO VIEWPORT HALF-CARD ───────────────────────────────────────────
  Widget _buildHeroViewportCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 280,
        color: const Color(0xFF0F172A),
        child: Stack(
          children: [
            // Background 3D Render Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_banner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => Container(
                  color: const Color(0xFF172554),
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 80,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
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
                      "Drapé Spatial Actif • 60 FPS",
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
                      "Profil : 99,2% Calibré",
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
                          "Soie Drapée Midi",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _midnightNavy,
                          ),
                        ),
                        Text(
                          "Taille ${_sizes[_selectedSizeIndex]['code']} • ${_colorNames[_selectedColorIndex]}",
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
                  "Sélectionner Taille & Couleur",
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
                      "Maillage Dynamique",
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
            "Re-simulation du drapé en temps réel sur votre avatar calibré",
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

          const SizedBox(height: 16),

          // 4. PHYSICS METRICS CARD
          _buildPhysicsMetricsCard(),

          const SizedBox(height: 20),

          // 5. PRIMARY MAIN CTA BUTTON: SOLID CORAL PINK (#F43F5E)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MultiObjectTryOnScreen(),
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
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "✨ Appliquer à l'Avatar",
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
                    "Confiance d'Ajustement : 94% — Coupe Flatteuse",
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
                  "Recommandé",
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFBE123C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Le contour de la taille s'ajuste parfaitement avec 2 cm d'aisance ; le tombé des épaules et l'ourlet sont fluides à mi-mollet.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. AVAILABLE SIZES SECTION ────────────────────────────────────────────
  Widget _buildAvailableSizesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tailles Disponibles",
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
                  "Guide des Mensurations",
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Couleur : ",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  _colorNames[_selectedColorIndex],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.texture_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  "Soie Georgette Lustrée",
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

  // ── 4. PHYSICS METRICS CARD ───────────────────────────────────────────────
  Widget _buildPhysicsMetricsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Metric 1: Chest Tension
          Expanded(
            child: Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tension Poitrine",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Optimale (0.3 kPa)",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _midnightNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Metric 2: Waist Drape
          Expanded(
            child: Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Drapé Taille",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Fluide Naturel",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _midnightNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Metric 3: Hemline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Longueur Ourlet",
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "116 cm (Midi)",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

