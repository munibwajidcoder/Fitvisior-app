import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../data/product_service.dart';
import 'quality_information_screen.dart';

class MultiObjectTryOnScreen extends StatefulWidget {
  final ProductModel? product;
  const MultiObjectTryOnScreen({super.key, this.product});

  @override
  State<MultiObjectTryOnScreen> createState() => _MultiObjectTryOnScreenState();
}

class _MultiObjectTryOnScreenState extends State<MultiObjectTryOnScreen> {
  int _selectedEquippedItem = 0; // 0 = Trouser, 1 = Skirt
  bool _is3DActive = true;

  static const Color _midnightNavy = Color(0xFF172554);

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
                    // 2A. 3D HERO INTERACTIVE VIEWPORT CARD
                    _buildHeroInteractiveViewportCard(context),

                    const SizedBox(height: 16),

                    // 2B. 2 GARMENT SWAPPING PRODUCTS ROW
                    _buildSwappingProductsSection(),

                    const SizedBox(height: 16),
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

  // ── 2A. 3D HERO INTERACTIVE VIEWPORT CARD ─────────────────────────────────
  Widget _buildHeroInteractiveViewportCard(BuildContext context) {
    final glbSrc = UserAvatarService.avatarGlbNotifier.value ?? 'assets/models/base_avatar_female.glb';
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 480,
        color: Colors.white,
        child: Stack(
          children: [
            // Center: 3D Avatar Model
            Positioned.fill(
              child: _is3DActive && glbSrc.isNotEmpty
                  ? ModelViewer(
                      key: ValueKey('multi_object_avatar_$glbSrc'),
                      src: glbSrc,
                      alt: 'Avatar Multi-Objets 3D',
                      autoRotate: false,
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
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF43F5E),
                        strokeWidth: 2,
                      ),
                    ),
            ),

            // Top Gradient Shadow
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50,
              child: IgnorePointer(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x15000000), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2B. 2 GARMENT SWAPPING PRODUCTS ROW ───────────────────────────────────
  Widget _buildSwappingProductsSection() {
    return Row(
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
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) => Container(
                      height: 160,
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
                      Flexible(
                        child: Text(
                          price,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _midnightNavy,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          sizeText,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
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
              onPressed: () async {
                final nav = Navigator.of(context);
                setState(() => _is3DActive = false);
                await Future.delayed(const Duration(milliseconds: 100));
                if (!mounted) return;
                await nav.push(
                  MaterialPageRoute(
                    builder: (context) => QualityInformationScreen(product: widget.product),
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
