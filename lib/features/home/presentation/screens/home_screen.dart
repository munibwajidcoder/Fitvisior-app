import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../scan/presentation/screens/capture_guide_screen.dart';
import '../../../scan/presentation/screens/avatar_preview_screen.dart';
import '../../data/favorites_manager.dart';
import 'filter_screen.dart';
import 'product_detail_screen.dart';
import 'multi_object_try_on_screen.dart';
import 'wardrobe_favorites_screen.dart';
import 'checkout_screen.dart';
import 'account_settings_screen.dart';
import 'notifications_screen.dart';
import 'community_screen.dart';
import 'live_ar_mirror_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _bottomNavIndex;

  // Hero banner auto-rotate state
  final PageController _heroBannerController = PageController();
  int _heroBannerIndex = 0;
  Timer? _heroBannerTimer;

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialIndex;
    _heroBannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_heroBannerController.hasClients) {
        final next = (_heroBannerIndex + 1) % 4;
        _heroBannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _heroBannerTimer?.cancel();
    _heroBannerController.dispose();
    super.dispose();
  }

  // Home state
  int _homeSelectedCategory = 0;
  final List<String> _homeCategories = [
    'Tout',
    'À la une',
  ];

  // Catalogue state
  int _catalogueSelectedCategory = 0;
  bool _catalogueFitOnly = true;
  final List<String> _catalogueCategories = [
    'Tous les Articles',
    'Blazers & Vestes',
    'Robes & Soirée',
    'Manteaux & Vestes',
    'Pantalons & Denim',
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR (SHARED ACROSS TABS) ──────────────────────
            _buildTopBar(),

            // ── DYNAMIC BODY CONTENT BASED ON BOTTOM NAV INDEX ────
            Expanded(
              child: _buildCurrentTabBody(),
            ),

            // ── BOTTOM NAV BAR ────────────────────────────────────
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── ROUTER FOR TAB BODIES ──────────────────────────────────────────────────

  Widget _buildCurrentTabBody() {
    switch (_bottomNavIndex) {
      case 1:
        return _buildCatalogueBody();
      case 3:
        return _buildWardrobeBody();
      case 4:
        return _buildProfileBody();
      case 0:
      default:
        return _buildHomeBody();
    }
  }

  // ── TOP BAR ────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Logo + Brand
          Row(
            children: [
              Image.asset('assets/images/logo.png', width: 28, height: 28),
              const SizedBox(width: 8),
              Text(
                "FitVisor",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Icons
          _iconButton(
            Icons.notifications_none_rounded,
            hasBadge: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
          _iconButton(
            Icons.shopping_bag_outlined,
            hasBadge: true,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
          // User Profile Avatar
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.asset(
                      'assets/images/profile_avatar.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => Container(
                        color: const Color(0xFF6366F1),
                        child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
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

  Widget _iconButton(IconData icon, {VoidCallback? onTap, bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 19, color: const Color(0xFF334155)),
          ),
          if (hasBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFFF43F5E),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. HOME TAB BODY
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHomeBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHomeSearchBar(),
              const SizedBox(height: 10),
              _buildAvatarCalibrationBar(),
              const SizedBox(height: 12),
              _buildCommunityBannerCard(),
              const SizedBox(height: 14),
              _buildHomeCategoryPills(),
              const SizedBox(height: 14),
              _buildHomeHeroBanner(),
              const SizedBox(height: 22),

              // ── SHOP BY CATEGORY ──────────────────────────────────────
              _buildShopByCategorySection(),
              const SizedBox(height: 22),

              // ── NEW ARRIVALS ──────────────────────────────────────────
              _buildNewArrivalsSection(),
              const SizedBox(height: 22),

              // ── CURATED FOR YOUR FIT ──────────────────────────────────
              _buildHomeSectionHeader(),
              const SizedBox(height: 12),
              _buildHomeProductGrid(),
              const SizedBox(height: 22),

              // ── SALES & PROMOTIONS ────────────────────────────────────
              _buildSalesPromotionsSection(),
              const SizedBox(height: 22),

              // ── COMPLETE THE LOOK ─────────────────────────────────────
              _buildCompleteTheLookSection(),
              const SizedBox(height: 22),

              _buildSpatialMirrorBanner(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ── SHOP BY CATEGORY SECTION ─────────────────────────────────────────────
  Widget _buildShopByCategorySection() {
    final categories = [
      {'icon': Icons.checkroom_rounded, 'label': 'Robes'},
      {'icon': Icons.dry_cleaning_rounded, 'label': 'Hauts'},
      {'icon': Icons.straighten_rounded, 'label': 'Jeans'},
      {'icon': Icons.business_center_rounded, 'label': 'Costumes'},
      {'icon': Icons.shopping_bag_outlined, 'label': 'Chaussures'},
      {'icon': Icons.backpack_rounded, 'label': 'Sacs'},
      {'icon': Icons.style_rounded, 'label': 'Foulards'},
      {'icon': Icons.diamond_outlined, 'label': 'Accessoires'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Acheter par Catégorie',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () => setState(() => _bottomNavIndex = 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        size: 26,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── NEW ARRIVALS SECTION ─────────────────────────────────────────────────
  Widget _buildNewArrivalsSection() {
    final arrivals = [
      _ArrivalData('Lumiera', 'Robe en Soie Midi', '129 €', 'assets/images/product_dress.jpg'),
      _ArrivalData('Vellura', 'Blazer en Laine Taillé', '189 €', 'assets/images/product_suit.jpg'),
      _ArrivalData('Denimora', 'Jean Droit', '79 €', 'assets/images/product_pants.jpg'),
      _ArrivalData('Nordette', 'Bottes Chelsea Cuir', '149 €', 'assets/images/product_sweater.jpg'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nouveautés',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _bottomNavIndex = 1),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: arrivals.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final a = arrivals[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
                ),
                child: Container(
                  width: 148,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Image.asset(
                              a.imagePath,
                              height: 140,
                              width: 148,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Nouveau',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite_border_rounded, size: 14, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.brand,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF172554),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  a.price,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF172554),
                                  ),
                                ),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F2),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Icon(Icons.add_rounded, size: 15, color: Color(0xFFE11D48)),
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
            },
          ),
        ),
      ],
    );
  }

  // ── SALES & PROMOTIONS SECTION ─────────────────────────────────────────────
  Widget _buildSalesPromotionsSection() {
    final sales = [
      _SaleProductData('Sac en Cuir Classique', '159 €', '119 €', '-25%', 'assets/images/hero_banner.jpg'),
      _SaleProductData('Foulard en Soie Imprimé', '69 €', '45 €', '-35%', 'assets/images/product_suit.jpg'),
      _SaleProductData('Baskets Blanches Premium', '99 €', '59 €', '-40%', 'assets/images/product_pants.jpg'),
      _SaleProductData('Short en Denim Taillé', '49 €', '29 €', '-40%', 'assets/images/product_dress.jpg'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_offer_rounded, size: 16, color: Color(0xFFF43F5E)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offres et promos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _bottomNavIndex = 1),
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 235,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: sales.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final s = sales[index];
              return Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.asset(
                            s.imagePath,
                            height: 120,
                            width: 150,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        // Discount Badge
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE11D48),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.discountTag,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_border_rounded, size: 14, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF172554),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                s.salePrice,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFE11D48),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                s.oldPrice,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF94A3B8),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 30,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF43F5E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Essayer',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
            },
          ),
        ),
      ],
    );
  }

  // ── COMPLETE THE LOOK SECTION ─────────────────────────────────────────────
  int _lookSourceFilter = 0; // 0=Tous, 1=Depuis mon dressing, 2=Depuis la boutique

  Widget _buildCompleteTheLookSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Complétez le Look',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Depuis mon dressing ou depuis la boutique',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE11D48),
            ),
          ),
          const SizedBox(height: 10),
          // Source selector pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSourceFilterChip(0, 'Tout (Dressing & Boutique)'),
                const SizedBox(width: 8),
                _buildSourceFilterChip(1, 'Depuis mon dressing'),
                const SizedBox(width: 8),
                _buildSourceFilterChip(2, 'Depuis la boutique'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Outfit Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/product_dress.jpg',
                    width: 110,
                    height: 270,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                // Right: Items list matching PDF (Basket/chaussures, Sac/sacoche, Foulard, Écharpe)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_lookSourceFilter == 0 || _lookSourceFilter == 1)
                          _buildLookItem('Baskets Blanches (Chaussures)', '99 €', 'assets/images/product_pants.jpg', 'Depuis mon dressing', isDressing: true),
                        if (_lookSourceFilter == 0 || _lookSourceFilter == 2) ...[
                          const SizedBox(height: 8),
                          _buildLookItem('Sac Beige en Cuir (Sacoche)', '159 €', 'assets/images/hero_banner.jpg', 'Depuis la boutique', isDressing: false),
                        ],
                        if (_lookSourceFilter == 0 || _lookSourceFilter == 1) ...[
                          const SizedBox(height: 8),
                          _buildLookItem('Foulard en Soie Imprimé', '45 €', 'assets/images/product_suit.jpg', 'Depuis mon dressing', isDressing: true),
                        ],
                        if (_lookSourceFilter == 0 || _lookSourceFilter == 2) ...[
                          const SizedBox(height: 8),
                          _buildLookItem('Écharpe Laine Cashmere', '59 €', 'assets/images/product_sweater.jpg', 'Depuis la boutique', isDressing: false),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MultiObjectTryOnScreen()),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE11D48),
                              side: const BorderSide(color: Color(0xFFE11D48), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Essayer le Look Complet',
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceFilterChip(int index, String label) {
    final selected = _lookSourceFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _lookSourceFilter = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF172554) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildLookItem(String name, String price, String imagePath, String sourceLabel, {required bool isDressing}) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            imagePath,
            width: 34,
            height: 34,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172554),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  if (!isDressing)
                    Text(
                      price,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  if (!isDressing)
                    const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isDressing ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      sourceLabel,
                      style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: isDressing ? const Color(0xFF16A34A) : const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildCommunityBannerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CommunityScreen()),
          );
        },
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF1F3), Color(0xFFFFE4E9)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDA4AF), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_rounded,
                    size: 18, color: Color(0xFFF43F5E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Communauté FitVisor',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Text(
                      'Looks, avis & inspirations partagés',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Color(0xFFF43F5E)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, size: 20, color: Color(0xFFF43F5E)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher pièces, robes, jeans...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF172554),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCalibrationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/avatar_3d.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: const Color(0xFF1E3A6E),
                    child: const Icon(Icons.face_rounded, size: 20, color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "Avatar 3D de Camille",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF172554),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "99,2% Match",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Calibré pour un drapé dynamique et précis",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF172554),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Calibrer",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeCategoryPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _homeCategories.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _homeSelectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _homeSelectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                _homeCategories[index],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeHeroBanner() {
    final banners = [
      _HeroBannerData(
        tag: 'NOUVELLE SAISON',
        badge: '🔴 Sim en direct',
        title: "La Passerelle\nd'Automne",
        subtitle: 'Drapé 3D instantané calculé pour votre silhouette',
        image: 'assets/images/hero_banner.jpg',
        gradient: const [Color(0xCC0F172A), Colors.transparent],
      ),
      _HeroBannerData(
        tag: 'TENDANCE',
        badge: '✨ Nouveauté',
        title: 'Collection\nHiver 2026',
        subtitle: 'Essayez les dernières pièces en 3D sur votre avatar',
        image: 'assets/images/product_dress.jpg',
        gradient: const [Color(0xCC1A0533), Colors.transparent],
      ),
      _HeroBannerData(
        tag: 'EXCLUSIF',
        badge: '🔥 Limité',
        title: "Soirée\nÉlégante",
        subtitle: 'Tenues de soirée ajustées à votre morphologie',
        image: 'assets/images/product_suit.jpg',
        gradient: const [Color(0xCC0F1F3A), Colors.transparent],
      ),
      _HeroBannerData(
        tag: 'PROMO',
        badge: '🏷️ -30%',
        title: 'Styles\nPremium',
        subtitle: 'Profitez des offres exclusives avant qu\'elles expirent',
        image: 'assets/images/product_pants.jpg',
        gradient: const [Color(0xCC1A1A2E), Colors.transparent],
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 190,
              child: PageView.builder(
                controller: _heroBannerController,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _heroBannerIndex = i),
                itemBuilder: (context, index) {
                  final b = banners[index];
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          b.image,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: b.gradient,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE11D48),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    b.tag,
                                    style: GoogleFonts.inter(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A6E),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    b.badge,
                                    style: GoogleFonts.inter(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              b.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              b.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CaptureGuideScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF43F5E),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Essayer maintenant',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
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
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _heroBannerIndex == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _heroBannerIndex == i
                      ? const Color(0xFFE11D48)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sélectionné pour vous",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                  letterSpacing: -0.4,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _bottomNavIndex = 1),
                child: Text(
                  "Voir tout",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "Adapté à votre taille 70 cm & 1 m 70",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeProductGrid() {
    final products = [
      _ProductData(
        badge: "98% Ajusté",
        badgeColor: const Color(0xFF16A34A),
        badgeBg: const Color(0xFFECFDF5),
        imagePath: 'assets/images/product_dress.jpg',
        brand: "Maison Noir",
        name: "Soie sculptée…",
        price: "285 €",
      ),
      _ProductData(
        badge: "Ajust. exact",
        badgeColor: const Color(0xFFE11D48),
        badgeBg: const Color(0xFFFFF1F2),
        imagePath: 'assets/images/product_suit.jpg',
        brand: "Atelier Studio",
        name: "Tailleur sur…",
        price: "340 €",
      ),
      _ProductData(
        badge: "Vrai ajust.",
        badgeColor: const Color(0xFF16A34A),
        badgeBg: const Color(0xFFECFDF5),
        imagePath: 'assets/images/product_pants.jpg',
        brand: "Studio V",
        name: "Pantalon large…",
        price: "195 €",
      ),
      _ProductData(
        badge: "Confort",
        badgeColor: const Color(0xFFEA580C),
        badgeBg: const Color(0xFFFFF7ED),
        imagePath: 'assets/images/product_sweater.jpg',
        brand: "L'Avenue",
        name: "Pull cachemire…",
        price: "220 €",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.61,
        ),
        itemBuilder: (context, index) => _buildHomeProductCard(products[index]),
      ),
    );
  }

  Widget _buildHomeProductCard(_ProductData p) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: Image.asset(
                      p.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: p.badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.badge,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: p.badgeColor,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<List<FavoriteItem>>(
                    valueListenable: FavoritesManager.instance.favoriteItemsNotifier,
                    builder: (context, favList, child) {
                      final itemId = '${p.brand}_${p.name}'.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
                      final isFav = FavoritesManager.instance.isFavorite(itemId, name: p.name);
                      return GestureDetector(
                        onTap: () {
                          final favItem = FavoriteItem(
                            id: itemId,
                            brand: p.brand,
                            name: p.name,
                            price: p.price,
                            size: 'FR 38',
                            fitMatch: p.badge.contains('Fit') ? p.badge : '97% Fit',
                            imagePath: p.imagePath,
                          );
                          FavoritesManager.instance.toggleFavorite(context, favItem);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isFav ? const Color(0xFFFFF1F2) : Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 15,
                            color: isFav ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.brand,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172554),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.open_in_new_rounded,
                            size: 13, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpatialMirrorBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LiveArMirrorScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_front_rounded,
                    size: 24, color: Color(0xFFF43F5E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Mode Miroir Spatial",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Accessible",
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Passez devant la caméra pour changer de tenues",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                    size: 17, color: Color(0xFFF43F5E)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. CATALOGUE TAB BODY (MATCHING EXACT SCREENSHOT & PDF SPEC)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCatalogueBody() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input + Filters badge button
              _buildCatalogueSearchBar(),

              const SizedBox(height: 12),

              // Category scroll pills
              _buildCatalogueCategoryPills(),

              const SizedBox(height: 12),

              // Camille's 3D Avatar 95%+ Fit Match toggle card
              _buildCatalogueAvatarToggleBar(),

              const SizedBox(height: 14),

              // Autumn/Winter Atelier Capsule hero banner
              _buildCatalogueHeroBanner(),

              const SizedBox(height: 18),

              // Section header: Sélection Personnalisée (48 articles)
              _buildCatalogueCurationHeader(),

              const SizedBox(height: 12),

              // 2-Column Product Grid (Balmain, The Row, Bottega Veneta, Jacquemus)
              _buildCatalogueProductGrid(),

              const SizedBox(height: 22),

              // Trending in fitting room section
              _buildCatalogueTrendingSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogueSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        children: [
          // Search box
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Designer, blazer, soie, manteau…",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF172554),
                      ),
                    ),
                  ),
                  const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFF64748B)),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filtres 3 button — navigates to FilterScreen
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const FilterScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF172554),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune_rounded, size: 17, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "Filtres",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE11D48),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "4",
                      style: GoogleFonts.inter(
                        fontSize: 10,
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
        ],
      ),
    );
  }

  Widget _buildCatalogueCategoryPills() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _catalogueCategories.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _catalogueSelectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _catalogueSelectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: selected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                _catalogueCategories[index],
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogueAvatarToggleBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF172554),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Avatar 3D de Camille",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Afficher 95%+ Fit Match uniquement",
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
            // Red toggle switch
            GestureDetector(
              onTap: () {
                setState(() {
                  _catalogueFitOnly = !_catalogueFitOnly;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 26,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _catalogueFitOnly
                      ? const Color(0xFFE11D48)
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: _catalogueFitOnly
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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

  Widget _buildCatalogueHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/hero_banner.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xEE0F172A),
                        Color(0x880F172A),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "DROP CAPSULE",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Sélectionné pour Sablier 174cm",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Capsule Atelier Automne/Hiver",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "12 pièces prêtes à l'essayage",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CaptureGuideScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF172554).withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Explorer",
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, size: 13, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildCatalogueCurationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Sélection Personnalisée",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
              letterSpacing: -0.4,
            ),
          ),
          Text(
            "48 articles",
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogueProductGrid() {
    final catalogueProducts = [
      _CatalogueItemData(
        brand: "BALMAIN",
        name: "Grain de Poudre",
        price: "2 190 €",
        recSize: "Rec: FR 36",
        fitPercent: "98% Fit",
        imagePath: 'assets/images/product_suit.jpg',
      ),
      _CatalogueItemData(
        brand: "THE ROW",
        name: "Robe en Soie Amalia",
        price: "1 850 €",
        recSize: "Rec: S",
        fitPercent: "99% Fit",
        imagePath: 'assets/images/product_dress.jpg',
      ),
      _CatalogueItemData(
        brand: "BOTTEGA VENETA",
        name: "Flanelle Plissée",
        price: "1 200 €",
        recSize: "Rec: IT 40",
        fitPercent: "96% Fit",
        imagePath: 'assets/images/product_pants.jpg',
      ),
      _CatalogueItemData(
        brand: "JACQUEMUS",
        name: "La Robe Bahia",
        price: "690 €",
        recSize: "Rec: FR 36",
        fitPercent: "97% Fit",
        imagePath: 'assets/images/product_sweater.jpg',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: catalogueProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.54, // Tuned to eliminate 2px overflow
        ),
        itemBuilder: (context, index) => _buildCatalogueProductCard(catalogueProducts[index]),
      ),
    );
  }

  Widget _buildCatalogueProductCard(_CatalogueItemData item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              imagePath: item.imagePath,
              brand: item.brand,
              name: item.name,
              price: item.price,
              fitPercent: item.fitPercent,
              recSize: "Taille Recommandée : ${item.recSize.replaceAll('Rec: ', '')}",
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
          // Image Container
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
                // Fit Match Pill Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.fitPercent,
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
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: ValueListenableBuilder<List<FavoriteItem>>(
                    valueListenable: FavoritesManager.instance.favoriteItemsNotifier,
                    builder: (context, favList, child) {
                      final itemId = '${item.brand}_${item.name}'.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
                      final isFav = FavoritesManager.instance.isFavorite(itemId, name: item.name);
                      return GestureDetector(
                        onTap: () {
                          final favItem = FavoriteItem(
                            id: itemId,
                            brand: item.brand,
                            name: item.name,
                            price: item.price,
                            size: item.recSize.replaceAll('Rec: ', ''),
                            fitMatch: item.fitPercent,
                            imagePath: item.imagePath,
                          );
                          FavoritesManager.instance.toggleFavorite(context, favItem);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isFav ? const Color(0xFFFFF1F2) : Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 16,
                            color: isFav ? const Color(0xFFE11D48) : const Color(0xFF475569),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Details Section — wrapped in SizedBox to prevent 2px overflow
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.brand,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
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
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        item.price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.recSize,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Try-On Action Button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AvatarPreviewScreen(),
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
                        const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          "Essayage Virtuel",
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
  }

  Widget _buildCatalogueTrendingSection() {
    final trendingItems = [
      _TrendingItemData(
        brand: "SAINT LAURENT",
        name: "Trench en Vinyle",
        price: "2 950 €",
        triedText: "412 essayés aujourd'hui",
        imagePath: 'assets/images/product_suit.jpg',
      ),
      _TrendingItemData(
        brand: "PRADA",
        name: "Blouson Re-Nylon",
        price: "1 750 €",
        triedText: "389 essayés aujourd'hui",
        imagePath: 'assets/images/product_sweater.jpg',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        size: 18, color: Color(0xFFE11D48)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Tendance en Cabine d'Essayage",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "En Direct RA",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE11D48),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: trendingItems.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = trendingItems[index];
              return Container(
                width: 165,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.asset(
                                item.imagePath,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: ValueListenableBuilder<List<FavoriteItem>>(
                              valueListenable: FavoritesManager.instance.favoriteItemsNotifier,
                              builder: (context, favList, child) {
                                final itemId = '${item.brand}_${item.name}'.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
                                final isFav = FavoritesManager.instance.isFavorite(itemId, name: item.name);
                                return GestureDetector(
                                  onTap: () {
                                    final favItem = FavoriteItem(
                                      id: itemId,
                                      brand: item.brand,
                                      name: item.name,
                                      price: item.price,
                                      size: 'FR 36',
                                      fitMatch: '95% Fit',
                                      imagePath: item.imagePath,
                                    );
                                    FavoritesManager.instance.toggleFavorite(context, favItem);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: isFav ? const Color(0xFFFFF1F2) : Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      size: 14,
                                      color: isFav ? const Color(0xFFE11D48) : const Color(0xFF475569),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars_rounded,
                                      size: 11, color: Color(0xFFE11D48)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.triedText,
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF172554),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.brand,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF172554),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.price,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. WARDROBE TAB BODY
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWardrobeBody() {
    return const WardrobeFavoritesScreen();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. PROFILE TAB BODY
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProfileBody() {
    return const AccountSettingsScreen();
  }

  // ── BOTTOM NAV BAR ─────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      _NavItem(Icons.home_rounded, "Accueil"),
      _NavItem(Icons.grid_view_rounded, "Catalogue"),
      _NavItem(Icons.auto_awesome_rounded, ""), // Center FAB
      _NavItem(Icons.checkroom_rounded, "Mon dressing"),
      _NavItem(Icons.person_outline_rounded, "Profil"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isCenter = index == 2;
              final isSelected = _bottomNavIndex == index;

              if (isCenter) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AvatarPreviewScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, size: 22, color: Colors.white),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => setState(() => _bottomNavIndex = index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: isSelected ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF43F5E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── DATA MODELS ──────────────────────────────────────────────────────────────

class _ProductData {
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final String imagePath;
  final String brand;
  final String name;
  final String price;

  const _ProductData({
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.imagePath,
    required this.brand,
    required this.name,
    required this.price,
  });
}

class _CatalogueItemData {
  final String brand;
  final String name;
  final String price;
  final String recSize;
  final String fitPercent;
  final String imagePath;

  const _CatalogueItemData({
    required this.brand,
    required this.name,
    required this.price,
    required this.recSize,
    required this.fitPercent,
    required this.imagePath,
  });
}

class _TrendingItemData {
  final String brand;
  final String name;
  final String price;
  final String triedText;
  final String imagePath;

  const _TrendingItemData({
    required this.brand,
    required this.name,
    required this.price,
    required this.triedText,
    required this.imagePath,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _ArrivalData {
  final String brand;
  final String name;
  final String price;
  final String imagePath;
  const _ArrivalData(this.brand, this.name, this.price, this.imagePath);
}

class _SaleProductData {
  final String name;
  final String oldPrice;
  final String salePrice;
  final String discountTag;
  final String imagePath;
  const _SaleProductData(this.name, this.oldPrice, this.salePrice, this.discountTag, this.imagePath);
}

class _HeroBannerData {
  final String tag;
  final String badge;
  final String title;
  final String subtitle;
  final String image;
  final List<Color> gradient;
  const _HeroBannerData({
    required this.tag,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.gradient,
  });
}
