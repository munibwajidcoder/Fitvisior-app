import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../scan/presentation/screens/capture_guide_screen.dart';
import '../../data/favorites_manager.dart';
import 'product_comparison_screen.dart';
import 'product_detail_screen.dart';

class WardrobeFavoritesScreen extends StatefulWidget {
  const WardrobeFavoritesScreen({super.key});

  @override
  State<WardrobeFavoritesScreen> createState() => _WardrobeFavoritesScreenState();
}

class _WardrobeFavoritesScreenState extends State<WardrobeFavoritesScreen> {
  int _selectedSegment = 0; // 0 = Tenues Enregistrées, 1 = Historique 3D

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      appBar: canPop ? _buildAppBar() : null,
      body: SafeArea(
        top: !canPop,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: ValueListenableBuilder<List<FavoriteItem>>(
            valueListenable: FavoritesManager.instance.favoriteItemsNotifier,
            builder: (context, favList, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Digital Closet + Saved Looks & Favorites)
                  _buildHeader(favList.length),
                  const SizedBox(height: 16),

                  // 2. Segmented Control (Tenues Enregistrées vs Historique 3D)
                  _buildSegmentedControl(favList.length),
                  const SizedBox(height: 18),

                  // 3. Banner Card (Spatial Wardrobe - Instant Fit Mirror)
                  _buildSpatialWardrobeBanner(),
                  const SizedBox(height: 20),

                  // 4. Product Grid (Favorite Items)
                  if (favList.isNotEmpty && _selectedSegment == 0) ...[
                    _buildProductGrid(favList),
                    const SizedBox(height: 24),
                  ] else if (_selectedSegment == 1) ...[
                    _buildHistoryPlaceholder(),
                    const SizedBox(height: 24),
                  ],

                  // 5. AI Stylist Silhouette Synthesis Card
                  _buildAiStylistSynthesisCard(),
                  const SizedBox(height: 24),

                  // 6. Exploration / Empty State Card
                  _buildExplorationCard(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF172554)),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Tenues Enregistrées & Favoris",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
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
            width: 32,
            height: 32,
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

  // ── 1. HEADER ────────────────────────────────────────────────────────────

  Widget _buildHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded, size: 12, color: Color(0xFFE11D48)),
                  const SizedBox(width: 5),
                  Text(
                    "GARDE-ROBE DIGITALE",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE11D48),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                "Tenues Enregistrées & Favoris",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                  letterSpacing: -0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECDD3)),
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
              const SizedBox(width: 5),
              Text(
                "$count articles",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172554),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. SEGMENTED CONTROL ─────────────────────────────────────────────────

  Widget _buildSegmentedControl(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Tab 1: Tenues Enregistrées
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedSegment == 0 ? const Color(0xFF172554) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedSegment == 0
                      ? [
                          BoxShadow(
                            color: const Color(0xFF172554).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Tenues Enregistrées",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _selectedSegment == 0 ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _selectedSegment == 0
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$count",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _selectedSegment == 0 ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tab 2: Historique 3D
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedSegment = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedSegment == 1 ? const Color(0xFF172554) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _selectedSegment == 1
                      ? [
                          BoxShadow(
                            color: const Color(0xFF172554).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Historique 3D",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _selectedSegment == 1 ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _selectedSegment == 1
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "8",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _selectedSegment == 1 ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. SPATIAL WARDROBE BANNER ───────────────────────────────────────────

  Widget _buildSpatialWardrobeBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172554), Color(0xFF172554)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      "GARDE-ROBE SPATIALE",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Miroir d'Essayage Instantané",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Simuler les pièces enregistrées...",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CaptureGuideScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    "Essayer sur Avatar",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  // ── 4. PRODUCT GRID ───────────────────────────────────────────────────────

  Widget _buildProductGrid(List<FavoriteItem> favList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.54,
      ),
      itemBuilder: (context, index) {
        final item = favList[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  imagePath: item.imagePath,
                  brand: item.brand,
                  name: item.name,
                  price: item.price,
                ),
              ),
            );
          },
          child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with heart & fit match overlay
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                        child: Image.asset(
                          item.imagePath,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Red Heart Button top right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          FavoritesManager.instance.toggleFavorite(context, item);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ),
                    // Fit Match overlay bar at bottom of image
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        color: Colors.white.withValues(alpha: 0.92),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ajustement",
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              item.fitMatch.replaceAll(' Fit', '%'),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF172554),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details section below image
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.brand.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Try in AR full width dark navy button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CaptureGuideScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF172554),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.view_in_ar_rounded, size: 13, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              "Essayer en RA",
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    );
  }

  // ── 5. HISTORIQUE 3D PLACEHOLDER ─────────────────────────────────────────

  Widget _buildHistoryPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded, size: 40, color: Color(0xFF172554)),
          const SizedBox(height: 12),
          Text(
            "Historique d'Essayage 3D (8 Séances)",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Vos 8 dernières simulations d'essayage virtuel 3D sont enregistrées et prêtes à être analysées.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. EXPLORATION CARD ──────────────────────────────────────────────────

  Widget _buildExplorationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hanger Circle Avatar with red badge
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checkroom_rounded,
                  size: 28,
                  color: Color(0xFFE11D48),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFF43F5E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Rien d'enregistré — commencez à explorer !",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Appuyez sur le cœur de n'importe quelle pièce de luxe pour tester les silhouettes, calibrer le drapé et prévisualiser le style 3D en temps réel.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dark Navy Explore Catalogue button
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF172554),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.explore_outlined, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Explorer le Catalogue",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Reset button
              GestureDetector(
                onTap: () {
                  // Keep current favorites intact
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Réinitialiser",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── AI STYLIST SILHOUETTE SYNTHESIS CARD ───────────────────────────────

  Widget _buildAiStylistSynthesisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172554), Color(0xFF172554)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Synthèse de Silhouette Styliste IA",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "Vos articles enregistrés composent 4 tenues polyvalentes pour le climat automnal parisien avec une harmonie de silhouette globale de 97,2%. Le blazer en laine Balmain équilibre parfaitement la robe en soie The Row.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Cohesion progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Score de Cohésion de Capsule",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              Text(
                "97,2%",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.972,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              color: const Color(0xFFE11D48),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 14),

          // Compare Side-by-Side Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProductComparisonScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF172554),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.compare_arrows_rounded,
                      size: 16, color: Color(0xFF172554)),
                  const SizedBox(width: 6),
                  Text(
                    "Comparer Côte à Côte",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172554),
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

