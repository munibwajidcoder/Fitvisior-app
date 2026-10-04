import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'share_outfit_screen.dart';
import 'size_selection_screen.dart';
import 'store_partnerships_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? imagePath;
  final String? brand;
  final String? name;
  final String? price;
  final String? fitPercent;
  final String? recSize;

  const ProductDetailScreen({
    super.key,
    this.imagePath,
    this.brand,
    this.name,
    this.price,
    this.fitPercent,
    this.recSize,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedColor = 0;
  int _selectedSize = 2; // M by default
  bool _fabricExpanded = true;
  bool _isFavorite = false;
  int _imagePageIndex = 0;

  final PageController _pageController = PageController();

  // Midnight Blue theme color requested by user: #172554
  static const Color _midnightNavy = Color(0xFF172554);

  final List<Color> _colorOptions = [
    _midnightNavy, // Midnight Navy #172554
    const Color(0xFF881337), // Dark Maroon
    const Color(0xFFE7E5E4), // Beige
    const Color(0xFF4D5B46), // Olive Green
  ];

  final List<String> _colorNames = [
    "Bleu Nuit",
    "Bordeaux Profond",
    "Beige Écru",
    "Vert Olive",
  ];

  final List<String> _sizes = ["XS", "S", "M", "L", "XL"];

  // Default values matching uploaded mockup design
  String get _brand => widget.brand ?? "ATELIER COLLECTION";
  String get _name => widget.name ?? "Robe Midi en Soie Drapée Sculptée";
  String get _price => widget.price ?? "285,00 €";
  String get _recSize => widget.recSize ?? "M";
  String get _imagePath => widget.imagePath ?? 'assets/images/product_dress.jpg';

  late final List<String> _productImages = [
    _imagePath,
    'assets/images/hero_banner.jpg',
    'assets/images/product_suit.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP APP BAR (W/ BACKGROUND WHITE) ───────────────────
            _buildTopAppBar(),

            // ── SCROLLABLE PRODUCT DETAILS ──────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HERO IMAGE IN A ROUNDED CARD CONTAINER
                    _buildHeroImageCard(),

                    const SizedBox(height: 12),

                    // 2. BRAND & PARTNER BADGE ROW
                    _buildBrandRow(),

                    // 3. PRODUCT TITLE
                    _buildProductTitle(),

                    // 4. PRICE
                    _buildPrice(),

                    // 4.5. STORE PARTNERSHIPS LINK
                    _buildStorePartnershipsLink(),

                    const SizedBox(height: 16),

                    // 5. SIZE GUIDANCE CARD (MIDNIGHT NAVY CONTAINER #172554)
                    _buildSizeGuidanceCard(),

                    const SizedBox(height: 20),

                    // 6. COLOR SELECTOR
                    _buildColorSelector(),

                    const SizedBox(height: 20),

                    // 7. SIZE SELECTOR
                    _buildSizeSelector(),

                    const SizedBox(height: 20),

                    // 8. FABRIC & FIT ACCORDION CARD
                    _buildFabricAndFitCard(),

                    const SizedBox(height: 12),

                    // 9. NOTICE INFO BANNER
                    _buildNoticeBanner(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── BOTTOM ACTION BUTTON BAR (SINGLE PRIMARY BUTTON ONLY) ─
            _buildBottomActionButton(),
          ],
        ),
      ),
    );
  }

  // ── TOP APP BAR ───────────────────────────────────────────────────────────
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back Arrow Button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 30,
                color: _midnightNavy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "Détails du Produit",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _midnightNavy,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Share Button
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShareOutfitScreen(
                    productName: _name,
                    productBrand: '$_brand • Taille ${_sizes[_selectedSize]}',
                    productImage: _productImages[_imagePageIndex],
                    fitPercent: '99,4%',
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.share_outlined,
                size: 20,
                color: _midnightNavy,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Heart / Favorite Button
          InkWell(
            onTap: () => setState(() => _isFavorite = !_isFavorite),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 22,
                color: _isFavorite
                    ? const Color(0xFFE11D48)
                    : _midnightNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. HERO IMAGE IN ROUNDED CONTAINER CARD ──────────────────────────────
  Widget _buildHeroImageCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 380,
          color: const Color(0xFFF1F5F9),
          child: Stack(
            children: [
              // Image PageView
              PageView.builder(
                controller: _pageController,
                itemCount: _productImages.length,
                onPageChanged: (index) =>
                    setState(() => _imagePageIndex = index),
                itemBuilder: (context, index) {
                  return Image.asset(
                    _productImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 380,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.checkroom_rounded,
                          size: 80,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Top Left Badge: "APERÇU SIMULÉ DU PRODUIT"
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
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
                        "APERÇU SIMULÉ DU PRODUIT",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: _midnightNavy,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Center Pagination Dots
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_productImages.length, (i) {
                    final active = i == _imagePageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? _midnightNavy
                            : _midnightNavy.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),

              // Bottom Right "Voir 3D" Button
              Positioned(
                bottom: 12,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
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
                      const Icon(
                        Icons.view_in_ar_rounded,
                        size: 15,
                        color: Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Voir 3D",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _midnightNavy,
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
    );
  }

  // ── 2. BRAND ROW ─────────────────────────────────────────────────────────
  Widget _buildBrandRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            _brand.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(width: 4),
                Text(
                  "Marque Partenaire",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. PRODUCT TITLE ──────────────────────────────────────────────────────
  Widget _buildProductTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: _midnightNavy,
          letterSpacing: -0.4,
          height: 1.2,
        ),
      ),
    );
  }

  // ── 4. PRICE ──────────────────────────────────────────────────────────────
  Widget _buildPrice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Text(
        _price,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: _midnightNavy,
        ),
      ),
    );
  }

  // ── 4.5. STORE PARTNERSHIPS LINK ──────────────────────────────────────────
  Widget _buildStorePartnershipsLink() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StorePartnershipsScreen(
                productName: _name,
                productSize: _sizes[_selectedSize],
                productImage: _productImages[0],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.storefront_rounded,
                  color: Color(0xFF3B82F6), size: 20),
              const SizedBox(width: 8),
              Text(
                "Trouver en magasin",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── 5. SIZE GUIDANCE CARD (MIDNIGHT NAVY CONTAINER #172554) ───────────────
  Widget _buildSizeGuidanceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _midnightNavy, // Midnight Navy #172554
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _midnightNavy.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ruler Circular Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.straighten_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CONSEIL DE TAILLE",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.65),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Taille suggérée : $_recSize",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Basé sur vos mensurations corporelles et le guide des tailles de cette marque. L'ajustement peut varier selon le tissu et la coupe.",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),

            // Estimate Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Estimation — pas une garantie",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  // ── 6. COLOR SELECTOR ─────────────────────────────────────────────────────
  Widget _buildColorSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Couleur",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _midnightNavy,
                ),
              ),
              Text(
                _colorNames[_selectedColor],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_colorOptions.length, (index) {
              final selected = _selectedColor == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 14),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _colorOptions[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _midnightNavy : const Color(0xFFCBD5E1),
                      width: selected ? 2.5 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: _midnightNavy.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: _colorOptions[index] == const Color(0xFFE7E5E4)
                              ? _midnightNavy
                              : Colors.white,
                        )
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 7. SIZE SELECTOR ──────────────────────────────────────────────────────
  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sélectionner la taille",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _midnightNavy,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Guide des tailles FitVisor ouvert",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.straighten_rounded,
                      size: 15,
                      color: Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Voir le Guide des Tailles",
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_sizes.length, (index) {
              final selected = _selectedSize == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSize = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right: index == _sizes.length - 1 ? 0 : 8,
                    ),
                    height: 48,
                    decoration: BoxDecoration(
                      color: selected ? _midnightNavy : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? _midnightNavy
                            : const Color(0xFFE2E8F0),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _sizes[index],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : _midnightNavy,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 8. FABRIC & FIT ACCORDION CARD ─────────────────────────────────────────
  Widget _buildFabricAndFitCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            // Accordion Header
            InkWell(
              onTap: () => setState(() => _fabricExpanded = !_fabricExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.texture_rounded,
                      size: 20,
                      color: _midnightNavy,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Tissu & Coupe",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _midnightNavy,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _fabricExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ),

            if (_fabricExpanded) ...[
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    // Composition Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "COMPOSITION",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "100% Soie",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _midnightNavy,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 38,
                      color: const Color(0xFFE2E8F0),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),

                    // Cut Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "COUPE",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Drapé Biais de Précision",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _midnightNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

              // Subtext
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Text(
                  "Examinez les détails du produit et le guide des tailles avant de choisir.",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 9. NOTICE BANNER ─────────────────────────────────────────────────────
  Widget _buildNoticeBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDBEAFE)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "L'ajustement peut varier selon la taille, le tissu et la morphologie.",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM ACTION BUTTON BAR (SINGLE PRIMARY BUTTON ONLY) ──────────────────
  Widget _buildBottomActionButton() {
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
          // 1. Top Button (Primary Coral Pink): Essayez-le en 3D / RA ➔
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SizeSelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E), // Exact Coral Pink theme color
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.checkroom_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Essayez-le en 3D / RA",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
          const SizedBox(height: 10),

          // 2. Bottom Button (Light Grey): Ajouter au Panier — 285,00 €
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Produit ajouté au panier !",
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF172554),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(initialIndex: 3),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9), // Light grey matching screenshot #1
                foregroundColor: const Color(0xFF172554), // Dark Navy text
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 19,
                    color: Color(0xFF172554),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Ajouter au Panier — $_price",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
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
    );
  }
}

