import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../scan/presentation/screens/capture_guide_screen.dart';
import '../../data/favorites_manager.dart';
import '../../data/product_service.dart';
import 'product_comparison_screen.dart';
import 'product_detail_screen.dart';
import 'friend_feedback_screen.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';

class WardrobeFavoritesScreen extends StatefulWidget {
  const WardrobeFavoritesScreen({super.key});

  @override
  State<WardrobeFavoritesScreen> createState() => _WardrobeFavoritesScreenState();
}

class _WardrobeFavoritesScreenState extends State<WardrobeFavoritesScreen> {
  int _selectedSegment = 0; // 0 = Tenues Enregistrées, 1 = Historique 3D

  ProductModel _toProductModel(FavoriteItem item) {
    return ProductModel(
      id: item.id,
      name: item.name,
      brand: item.brand,
      category: 'Vêtements',
      subCategory: '',
      gender: 'Femme',
      description: '',
      price: double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
      isSale: false,
      imageUrl: item.imagePath,
      galleryImages: [item.imagePath],
      availableSizes: [item.size],
      availableColors: const [{'name': 'Couleur', 'hex': '#172554'}],
      recSize: 'Rec: ${item.size}',
      fitPercent: item.fitMatch,
      fabricComposition: 'Matière Noble',
      silhouetteType: '',
      careInstructions: '',
      isFeatured: false,
      isTrending: false,
      isNewArrival: false,
      triedCountText: '',
      badge: item.fitMatch,
      badgeColor: '#16A34A',
      badgeBg: '#ECFDF5',
      inStock: true,
      stockQuantity: 1,
      partnerStoreName: '',
      partnerStoreUrl: '',
      storeReservationAvailable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final canPop = Navigator.canPop(context);

    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        final isFr = LanguageService.instance.isFrench;
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          appBar: canPop ? _buildAppBar(isFr) : null,
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
                      _buildHeader(favList.length, isFr),
                      const SizedBox(height: 16),

                      // 2. Segmented Control (Tenues Enregistrées vs Historique 3D)
                      _buildSegmentedControl(favList.length, isFr),
                      const SizedBox(height: 18),

                      // 3. Banner Card (Spatial Wardrobe - Instant Fit Mirror)
                      _buildSpatialWardrobeBanner(isFr),
                      const SizedBox(height: 20),

                      // 4. Product Grid (Favorite Items)
                      if (favList.isNotEmpty && _selectedSegment == 0) ...[
                        _buildProductGrid(favList, isFr),
                        const SizedBox(height: 24),
                      ] else if (_selectedSegment == 1) ...[
                        _buildHistoryPlaceholder(isFr),
                        const SizedBox(height: 24),
                      ],

                      // 5. AI Stylist Silhouette Synthesis Card
                      _buildAiStylistSynthesisCard(isFr),
                      const SizedBox(height: 24),

                      // 6. Exploration / Empty State Card
                      _buildExplorationCard(isFr),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar([bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
        isFr
            ? "Tenues Enregistrées & Favoris"
            : "Saved Outfits & Favorites",
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

  Widget _buildHeader(int count, [bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
                    isFr ? "MON DRESSING DIGITAL" : "MY DIGITAL WARDROBE",
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
                isFr ? "Tenues Enregistrées & Favoris" : "Saved Outfits & Favorites",
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
                isFr ? "$count articles" : "$count items",
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

  Widget _buildSegmentedControl(int count, [bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
                      isFr ? "Tenues Enregistrées" : "Saved Outfits",
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
                      isFr ? "Historique 3D" : "3D History",
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

  Widget _buildSpatialWardrobeBanner([bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
                    Flexible(
                      child: Text(
                        isFr ? "MON DRESSING SPATIAL" : "MY SPATIAL WARDROBE",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isFr ? "Miroir d'Essayage Instantané" : "Instant Fit Mirror",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isFr ? "Simuler les pièces enregistrées..." : "Simulate saved pieces in 3D...",
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
                    isFr ? "Essayer sur Avatar" : "Try on Avatar",
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

  Widget _buildProductGrid(List<FavoriteItem> favList, [bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
        final displayName = isFr ? item.name : AppStrings.translateProduct(item.name, 'en');
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: _toProductModel(item),
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
                        child: item.imagePath.startsWith('http')
                            ? Image.network(
                                item.imagePath,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (_, error, stack) => Image.asset(
                                  'assets/images/product_dress.jpg',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              )
                            : Image.asset(
                                item.imagePath,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (_, error, stack) => Image.asset(
                                  'assets/images/product_dress.jpg',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
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
                              isFr ? "Ajustement" : "Fit Match",
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
                      displayName,
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
                            builder: (context) => ProductDetailScreen(
                              product: _toProductModel(item),
                            ),
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
                              isFr ? "Essayer en RA" : "Try in AR",
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
                    // Feedback button — only for shared looks (index 0 simulates shared)
                    if (index == 0) ...[
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FriendFeedbackScreen(
                                productName: item.name,
                                productSize: 'Taille M',
                                productImage: item.imagePath,
                                visibilityLabel: 'Friends only',
                                linkExpiry: 'Link expires in 7 days',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFFDA4AF),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded,
                                  size: 12, color: Color(0xFFF43F5E)),
                              const SizedBox(width: 5),
                              Text(
                                'Feedback (3)',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFF43F5E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildHistoryPlaceholder([bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
            isFr
                ? "Historique d'Essayage 3D (8 Séances)"
                : "3D Fitting History (8 Sessions)",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isFr
                ? "Vos 8 dernières simulations d'essayage virtuel 3D sont enregistrées et prêtes à être analysées."
                : "Your last 8 3D virtual try-on simulations are saved and ready to be analyzed.",
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

  Widget _buildExplorationCard([bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
            isFr
                ? "Rien d'enregistré — commencez à explorer !"
                : "Nothing saved yet — start exploring!",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFr
                ? "Appuyez sur le cœur de n'importe quelle pièce de luxe pour tester les silhouettes, calibrer le drapé et prévisualiser le style 3D en temps réel."
                : "Tap the heart on any luxury piece to test silhouettes, calibrate draping, and preview 3D styling in real-time.",
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
                            isFr ? "Explorer le Catalogue" : "Explore Catalogue",
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
                    isFr ? "Réinitialiser" : "Reset",
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

  Widget _buildAiStylistSynthesisCard([bool? isFrParam]) {
    final isFr = isFrParam ?? LanguageService.instance.isFrench;
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
                  isFr ? "Synthèse de Silhouette Styliste IA" : "AI Stylist Silhouette Synthesis",
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
            isFr
                ? "Vos articles enregistrés composent 4 tenues polyvalentes pour le climat automnal parisien avec une harmonie de silhouette globale de 97,2%. Le blazer en laine Balmain équilibre parfaitement la robe en soie The Row."
                : "Your saved items compose 4 versatile outfits for the Parisian autumn weather with an overall silhouette harmony of 97.2%. The Balmain wool blazer perfectly balances The Row silk dress.",
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
                isFr ? "Score de Cohésion de Capsule" : "Capsule Cohesion Score",
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
                    isFr ? "Comparer Côte à Côte" : "Compare Side-by-Side",
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

