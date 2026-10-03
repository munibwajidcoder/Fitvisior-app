import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quality_information_screen.dart';

class MultiObjectTryOnScreen extends StatefulWidget {
  const MultiObjectTryOnScreen({super.key});

  @override
  State<MultiObjectTryOnScreen> createState() => _MultiObjectTryOnScreenState();
}

class _MultiObjectTryOnScreenState extends State<MultiObjectTryOnScreen> {
  int _selectedCategoryTab = 2; // 0 = Outerwear, 1 = Tops, 2 = Bottoms
  int _selectedEquippedItem = 0; // 0 = Trouser, 1 = Skirt
  bool _isSaved = false;

  static const Color _midnightNavy = Color(0xFF172554);

  final List<String> _categories = [
    "Extérieur (1)",
    "Hauts (1)",
    "Bas (Actif)",
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2A. STUDIO BANNER HEADER ROW
                    _buildStudioBannerHeader(context),

                    const SizedBox(height: 12),

                    // 2B. 3D HERO INTERACTIVE VIEWPORT CARD
                    _buildHeroInteractiveViewportCard(context),

                    const SizedBox(height: 18),

                    // 2C. WARDROBE LAYERS CATEGORY TABS & SWAPPING SECTION
                    _buildWardrobeLayersSection(),

                    const SizedBox(height: 18),

                    // 2D. CAPSULE BREAKDOWN SUMMARY CARD
                    _buildCapsuleBreakdownCard(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── 3. BOTTOM FIXED ACTION BUTTONS BAR ───────────────────
            _buildBottomActionButtonsBar(context),
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
              "Essayage Multi-Objets",
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
          // Profile Avatar
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

  // ── 2A. STUDIO BANNER HEADER ROW ──────────────────────────────────────────
  Widget _buildStudioBannerHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.layers_rounded,
            size: 18,
            color: Color(0xFFF43F5E),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Studio de Superposition",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _midnightNavy,
                ),
              ),
              Text(
                "4 Articles Superposés • Synchronisé à la Silhouette",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Save Look Button
        GestureDetector(
          onTap: () {
            setState(() => _isSaved = !_isSaved);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isSaved ? "Look enregistré !" : "Look retiré !",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  size: 14,
                  color: _midnightNavy,
                ),
                const SizedBox(width: 4),
                Text(
                  "Enregistrer",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _midnightNavy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 2B. 3D HERO INTERACTIVE VIEWPORT CARD ─────────────────────────────────
  Widget _buildHeroInteractiveViewportCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 480,
        color: const Color(0xFF0F172A),
        child: Stack(
          children: [
            // Background 3D Layered Render Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_banner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => Container(
                  color: const Color(0xFF172554),
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 90,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),

            // Top Gradient Shadow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 90,
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

            // Top Left Controls (Rotate & Side Pill)
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                      color: _midnightNavy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Profil",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _midnightNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Right Badge: "✓ 99,2% Ajustement Drapé"
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: Color(0xFFE11D48),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "99,2% Ajustement Drapé",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _midnightNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Interactive Hotspot Pins on Outfit:
            // Pin 1: Blazer
            Positioned(
              top: 150,
              left: 60,
              child: _buildOutfitHotspotPin(
                label: "Blazer 340 €",
                isCheck: false,
              ),
            ),

            // Pin 2: Turtleneck
            Positioned(
              top: 195,
              right: 50,
              child: _buildOutfitHotspotPin(
                label: "Col Roulé 120 €",
                isCheck: false,
              ),
            ),

            // Pin 3: Silk Trousers (Selected)
            Positioned(
              bottom: 160,
              left: 90,
              child: _buildOutfitHotspotPin(
                label: "Pantalon en Soie 195 €",
                isCheck: true,
              ),
            ),

            // Bottom Overlay Bar inside Viewport
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Éclairage Studio Jour",
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Text(
                              "Mannequin : S (1m75)",
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Modifier",
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE11D48),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitHotspotPin({
    required String label,
    required bool isCheck,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCheck ? _midnightNavy : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCheck ? Colors.white : const Color(0xFFE11D48),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isCheck ? Colors.white : _midnightNavy,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2C. WARDROBE LAYERS CATEGORY TABS & SWAPPING SECTION ───────────────────
  Widget _buildWardrobeLayersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Couches de la Garde-robe",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: _midnightNavy,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  "Personnalisation des Bas",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3 Category Tabs
        Row(
          children: List.generate(_categories.length, (index) {
            final isSelected = _selectedCategoryTab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategoryTab = index),
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == _categories.length - 1 ? 0 : 6,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _midnightNavy : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _midnightNavy
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _categories[index],
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),

        // Subtext Instruction Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Appuyez pour simuler & échanger le drapé",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              "3 Variations",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _midnightNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 2 Garment Swapping Cards Row
        Row(
          children: [
            // Card 1: Wide Leg Silk Trouser (Equipped)
            Expanded(
              child: _buildSwappingGarmentCard(
                imagePath: 'assets/images/product_pants.jpg',
                tagText: "✓ Équipé",
                tagColor: const Color(0xFFBE123C),
                tagBg: const Color(0xFFFFF1F2),
                brand: "Studio Atelier",
                title: "Pantalon Large en Soie",
                price: "195 €",
                sizeText: "Taille 36",
                isSelected: _selectedEquippedItem == 0,
                onTap: () => setState(() => _selectedEquippedItem = 0),
              ),
            ),
            const SizedBox(width: 10),

            // Card 2: Pleated Midi Skirt (Swap option)
            Expanded(
              child: _buildSwappingGarmentCard(
                imagePath: 'assets/images/product_dress.jpg',
                tagText: "Appuyez pour Draper",
                tagColor: _midnightNavy,
                tagBg: Colors.white.withValues(alpha: 0.9),
                brand: "Studio Atelier",
                title: "Jupe Midi Plissée",
                price: "165 €",
                sizeText: "Taille 38",
                isSelected: _selectedEquippedItem == 1,
                onTap: () => setState(() => _selectedEquippedItem = 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSwappingGarmentCard({
    required String imagePath,
    required String tagText,
    required Color tagColor,
    required Color tagBg,
    required String brand,
    required String title,
    required String price,
    required String sizeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.asset(
                    imagePath,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) => Container(
                      height: 170,
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(Icons.checkroom_rounded,
                            size: 40, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tagText,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: tagColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.view_in_ar_rounded,
                      size: 14,
                      color: _midnightNavy,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _midnightNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _midnightNavy,
                        ),
                      ),
                      Text(
                        sizeText,
                        style: GoogleFonts.inter(
                          fontSize: 10,
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
    );
  }

  // ── 2D. CAPSULE BREAKDOWN SUMMARY CARD ────────────────────────────────────
  Widget _buildCapsuleBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFFE11D48),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Détail de la Capsule",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Économie Pack 65 €",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Item Lines
          _buildCapsuleItemRow("Blazer Croisé en Laine", "340 €"),
          const SizedBox(height: 8),
          _buildCapsuleItemRow("Col Roulé Cratelé Mérinos", "120 €"),
          const SizedBox(height: 8),
          _buildCapsuleItemRow("Pantalon Large en Soie", "195 €",
              isHighlight: true),
          const SizedBox(height: 8),
          _buildCapsuleItemRow("Stiletto Minimaliste à Brides", "65 €"),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 12),

          // Total Capsule Summary Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Capsule Complète 4 Pièces",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "655,00 €",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _midnightNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "720,00 €",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "4 Synchronisés",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Sub-features Row: Photometric 3D Drape & Free Concierge Exchange
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.view_in_ar_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Drapé 3D Photométrique",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Échange Concierge Gratuit",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleItemRow(String title, String price,
      {bool isHighlight = false}) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFFE11D48) : _midnightNavy,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? const Color(0xFFE11D48) : _midnightNavy,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          price,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isHighlight ? const Color(0xFFE11D48) : _midnightNavy,
          ),
        ),
      ],
    );
  }

  // ── 3. BOTTOM FIXED ACTION BUTTONS BAR ────────────────────────────────────
  Widget _buildBottomActionButtonsBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Button 1: Solid Coral Pink (#F43F5E)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const QualityInformationScreen(),
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
                    Icons.view_in_ar_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "✨ Essayer le Look Complet en 3D RA",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
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

          const SizedBox(height: 10),

          // Primary Button 2: Soft Pink Outlined / Light Container Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Capsule complète ajoutée au panier !",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF1F2),
                foregroundColor: const Color(0xFFE11D48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Tout Ajouter au Panier — 655,00 €",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
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
        ],
      ),
    );
  }
}

