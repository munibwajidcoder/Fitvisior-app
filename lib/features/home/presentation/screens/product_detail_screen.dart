import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/product_service.dart';
import '../../data/wardrobe_service.dart';
import 'home_screen.dart';
import 'store_partnerships_screen.dart';
import 'physics_drape_screen.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';

class ProductDetailScreen extends StatefulWidget {
  /// Full ProductModel — sab data yahan se aata hai, kuch hardcoded nahi
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedColorIndex = 0;
  int _selectedSizeIndex = 0;
  bool _fabricExpanded = true;
  bool _isFavorite = false;
  int _imagePageIndex = 0;

  @override
  void initState() {
    super.initState();
    _isFavorite = WardrobeService.instance.isInWardrobe(widget.product.id, productName: widget.product.name);
  }

  final PageController _pageController = PageController();

  static const Color _midnightNavy = Color(0xFF172554);

  // ── Dynamic from ProductModel ─────────────────────────────────────────────
  ProductModel get p => widget.product;

  String get _name => p.displayName;
  String get _brand => p.brand;
  String get _price => '${p.price.toStringAsFixed(0)} €';
  String get _recSize => p.recSize.replaceAll('Rec: ', '').replaceAll('Taille cons.: ', '');
  String get _fitPercent => p.fitPercent;

  // Gallery: use galleryImages from Supabase if available, else fallback to imageUrl
  late final List<String> _productImages = () {
    if (p.galleryImages.isNotEmpty) return p.galleryImages;
    return [p.imageUrl];
  }();

  // Colors: parse from ProductModel.availableColors [{'name':..., 'hex':...}]
  late final List<Color> _colorOptions = p.availableColors
      .map((c) => _hexToColor(c['hex']?.toString() ?? '#172554'))
      .toList();

  late final List<String> _colorNames = p.availableColors
      .map((c) {
        final raw = c['name']?.toString() ?? 'Couleur';
        return LanguageService.instance.isEnglish ? AppStrings.translateColor(raw, 'en') : raw;
      })
      .toList();

  // Sizes: from ProductModel.availableSizes
  List<String> get _sizes => p.availableSizes.isNotEmpty
      ? p.availableSizes
      : ['XS', 'S', 'M', 'L', 'XL'];

  // Rating stars (1-5)
  double get _rating => p.rating.clamp(0.0, 5.0);
  int get _reviewCount => p.reviewCount;

  // Tried count text
  String get _triedCountText => p.displayTriedCountText.isNotEmpty
      ? p.displayTriedCountText
      : (LanguageService.instance.isEnglish ? "Try-on data not available" : "Données d'essayage non disponibles");

  // Badge
  String get _badge => p.displayBadge.isNotEmpty ? p.displayBadge : _fitPercent;

  // ── Hex color parser ────────────────────────────────────────────────────────
  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) {
      return Color(int.parse('FF$h', radix: 16));
    } else if (h.length == 8) {
      return Color(int.parse(h, radix: 16));
    }
    return const Color(0xFF172554);
  }

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
            _buildTopAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImageCard(),
                    const SizedBox(height: 12),
                    _buildBrandRow(),
                    _buildProductTitle(),
                    _buildPriceAndRating(),
                    _buildStorePartnershipsLink(),
                    const SizedBox(height: 16),
                    _buildSizeGuidanceCard(),
                    const SizedBox(height: 20),
                    if (_colorOptions.isNotEmpty) _buildColorSelector(),
                    if (_colorOptions.isNotEmpty) const SizedBox(height: 20),
                    _buildSizeSelector(),
                    const SizedBox(height: 20),
                    _buildTriedCountBadge(),
                    const SizedBox(height: 16),
                    _buildFabricAndFitCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
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
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_left_rounded, size: 30, color: _midnightNavy),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            LanguageService.instance.isEnglish ? "Product Details" : "Détails du Produit",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _midnightNavy,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              await WardrobeService.instance.toggleWardrobe(widget.product, context);
              if (mounted) {
                setState(() {
                  _isFavorite = WardrobeService.instance.isInWardrobe(widget.product.id, productName: widget.product.name);
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 22,
                color: _isFavorite ? const Color(0xFFE11D48) : _midnightNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. HERO IMAGE ─────────────────────────────────────────────────────────
  Widget _buildHeroImageCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 380,
          color: const Color(0xFFF1F5F9),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _productImages.length,
                onPageChanged: (i) => setState(() => _imagePageIndex = i),
                itemBuilder: (context, index) {
                  final img = _productImages[index];
                  if (img.startsWith('http')) {
                    return Image.network(img, fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (ctx, e, st) => Image.asset('assets/images/product_dress.jpg', fit: BoxFit.cover));
                  }
                  return Image.asset(img, fit: BoxFit.cover, width: double.infinity,
                    errorBuilder: (ctx, e, st) => Image.asset('assets/images/product_dress.jpg', fit: BoxFit.cover));
                },
              ),
              // Fit badge top-left
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
                  ),
                  child: Text(
                    _fitPercent,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A)),
                  ),
                ),
              ),
              // Out of stock badge
              if (!p.inStock)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(isEn ? "Sold Out" : "Épuisé", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              // Sale badge
              if (p.isSale && p.discountTag != null)
                Positioned(
                  top: p.inStock ? 14 : 46,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(20)),
                    child: Text(p.discountTag!, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              // Page dots
              if (_productImages.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_productImages.length, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _imagePageIndex == i ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _imagePageIndex == i ? _midnightNavy : _midnightNavy.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ),
              // 3D button
              Positioned(
                bottom: 12,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.view_in_ar_rounded, size: 15, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 5),
                      Text(isEn ? "View in 3D" : "Voir 3D", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: _midnightNavy)),
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
    final isEn = LanguageService.instance.isEnglish;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            _brand.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.6),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF4F46E5)),
                const SizedBox(width: 4),
                Text(isEn ? "Partner Brand" : "Marque Partenaire", style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
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
        style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: _midnightNavy, letterSpacing: -0.4, height: 1.2),
      ),
    );
  }

  // ── 4. PRICE + RATING ─────────────────────────────────────────────────────
  Widget _buildPriceAndRating() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Price (and old price if sale)
          if (p.isSale && p.oldPrice != null) ...[
            Text('${p.oldPrice!.toStringAsFixed(0)} €',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF94A3B8), decoration: TextDecoration.lineThrough)),
            const SizedBox(width: 8),
          ],
          Text(_price, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: p.isSale ? const Color(0xFFE11D48) : _midnightNavy)),
          const Spacer(),
          // Rating stars (dynamic from Supabase)
          if (_rating > 0) ...[
            Row(
              children: List.generate(5, (i) {
                if (i < _rating.floor()) return const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B));
                if (i < _rating && (_rating - _rating.floor()) >= 0.5) return const Icon(Icons.star_half_rounded, size: 14, color: Color(0xFFF59E0B));
                return const Icon(Icons.star_outline_rounded, size: 14, color: Color(0xFFCBD5E1));
              }),
            ),
            const SizedBox(width: 4),
            Text(
              _reviewCount > 0 ? '${_rating.toStringAsFixed(1)} ($_reviewCount)' : _rating.toStringAsFixed(1),
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ],
        ],
      ),
    );
  }

  // ── 4.5 STORE PARTNERSHIPS LINK ───────────────────────────────────────────
  Widget _buildStorePartnershipsLink() {
    final isEn = LanguageService.instance.isEnglish;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => StorePartnershipsScreen(
              productName: _name,
              productSize: _sizes.isNotEmpty ? _sizes[_selectedSizeIndex] : 'M',
              productImage: _productImages[0],
            ),
          ));
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
              const Icon(Icons.store_outlined, size: 16, color: Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.partnerStoreName.isNotEmpty
                      ? (isEn ? 'Available at ${p.partnerStoreName}' : 'Disponible chez ${p.partnerStoreName}')
                      : (isEn ? 'View partner stores' : 'Voir les boutiques partenaires'),
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  // ── 5. SIZE GUIDANCE CARD ─────────────────────────────────────────────────
  Widget _buildSizeGuidanceCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _midnightNavy,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _midnightNavy.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.straighten_rounded, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEn ? "SIZE GUIDANCE" : "CONSEIL DE TAILLE",
                        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.65), letterSpacing: 0.6)),
                      const SizedBox(height: 3),
                      Text(
                        isEn ? "Suggested size : $_recSize" : "Taille suggérée : $_recSize",
                        style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isEn
                  ? "Based on your body measurements and this brand's size chart. Fit may vary slightly depending on fabric and silhouette."
                  : "Basé sur vos mensurations corporelles et le guide des tailles de cette marque. L'ajustement peut varier selon le tissu et la coupe.",
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white.withValues(alpha: 0.8), height: 1.45),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(isEn ? "AI Estimation — not a guarantee" : "Estimation — pas une garantie", style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
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
    if (_colorOptions.isEmpty) return const SizedBox.shrink();
    final isEn = LanguageService.instance.isEnglish;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEn ? "Colour" : "Couleur", style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: _midnightNavy)),
              Text(
                _selectedColorIndex < _colorNames.length ? _colorNames[_selectedColorIndex] : '',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_colorOptions.length, (index) {
              final selected = _selectedColorIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 14),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _colorOptions[index],
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? _midnightNavy : const Color(0xFFCBD5E1), width: selected ? 2.5 : 1),
                    boxShadow: selected ? [BoxShadow(color: _midnightNavy.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                  ),
                  child: selected
                      ? Icon(Icons.check_rounded, size: 18,
                          color: _colorOptions[index].computeLuminance() > 0.5 ? _midnightNavy : Colors.white)
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
    final isEn = LanguageService.instance.isEnglish;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEn ? "Select Size" : "Sélectionner la taille", style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: _midnightNavy)),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isEn ? "FitVisor size guide opened" : "Guide des tailles FitVisor ouvert", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Row(
                  children: [
                    const Icon(Icons.straighten_rounded, size: 15, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 4),
                    Text(isEn ? "Size Guide" : "Voir le Guide", style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF4F46E5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_sizes.length, (index) {
              final selected = _selectedSizeIndex == index;
              // Highlight recommended size
              final isRecommended = _sizes[index] == _recSize || _sizes[index].contains(_recSize.replaceAll('Rec: ', ''));
              return GestureDetector(
                onTap: () => setState(() => _selectedSizeIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? _midnightNavy : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? _midnightNavy : (isRecommended ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0)),
                      width: selected || isRecommended ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_sizes[index],
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? Colors.white : _midnightNavy)),
                      if (isRecommended && !selected)
                        Text("Rec.", style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5))),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 7.5 TRIED COUNT BADGE ─────────────────────────────────────────────────
  Widget _buildTriedCountBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E9)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDA4AF), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFE11D48)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _triedCountText,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF9F1239)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_badge, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 8. FABRIC & FIT ACCORDION ─────────────────────────────────────────────
  Widget _buildFabricAndFitCard() {
    final isEn = LanguageService.instance.isEnglish;
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
            InkWell(
              onTap: () => setState(() => _fabricExpanded = !_fabricExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    const Icon(Icons.texture_rounded, size: 20, color: _midnightNavy),
                    const SizedBox(width: 10),
                    Text(isEn ? "Fabric & Cut" : "Tissu & Coupe", style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: _midnightNavy)),
                    const Spacer(),
                    Icon(_fabricExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 22, color: const Color(0xFF64748B)),
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
                    // Fabric Composition — DYNAMIC
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEn ? "COMPOSITION" : "COMPOSITION",
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(
                            p.displayFabricComposition.isNotEmpty ? p.displayFabricComposition : 'N/A',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: _midnightNavy),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 38, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 16)),
                    // Silhouette/Cut — DYNAMIC
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEn ? "SILHOUETTE / CUT" : "COUPE",
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(
                            p.displaySilhouette.isNotEmpty ? p.displaySilhouette : 'N/A',
                            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: _midnightNavy),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              // Care Instructions — DYNAMIC
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.dry_cleaning_rounded, size: 15, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.displayCareInstructions.isNotEmpty ? p.displayCareInstructions : (isEn ? "See garment label" : "Voir étiquette du vêtement"),
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── BOTTOM ACTION BUTTONS ─────────────────────────────────────────────────
  Widget _buildBottomActionButton() {
    final isEn = LanguageService.instance.isEnglish;
    final selectedSize = _sizes.isNotEmpty ? _sizes[_selectedSizeIndex] : 'M';
    final selectedColorName = _selectedColorIndex < _colorNames.length ? _colorNames[_selectedColorIndex] : '';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AR Try-on Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final nav = Navigator.of(context);
                Map<String, dynamic>? profile;
                try { profile = await AuthService.getProfile(); } catch (_) {}
                if (!mounted) return;
                final isMale = (profile?['gender'] as String?)?.toLowerCase().contains('homme') == true;
                final h = (profile?['height_cm'] as num?)?.toDouble() ?? 174.0;
                final b = (profile?['bust_cm'] as num?)?.toDouble() ?? (isMale ? 98.0 : 86.0);
                final w = (profile?['waist_cm'] as num?)?.toDouble() ?? (isMale ? 82.0 : 66.0);
                final hips = (profile?['hip_cm'] as num?)?.toDouble() ?? (isMale ? 96.0 : 94.0);
                final avatarUrl = profile?['avatar_glb_url'] as String? ??
                    UserAvatarService.avatarGlbNotifier.value ??
                    (isMale ? 'assets/models/base_avatar_male.glb' : 'assets/models/base_avatar_female.glb');
                nav.push(MaterialPageRoute(
                  builder: (context) => PhysicsDrapeScreen(
                    garment: GarmentTryOnData(
                      productName: _name,
                      brandName: _brand,
                      price: _price,
                      selectedSize: selectedSize,
                      selectedColor: _colorOptions.isNotEmpty ? _colorOptions[_selectedColorIndex] : const Color(0xFF172554),
                      colorName: selectedColorName,
                      productImagePath: p.imageUrl,
                    ),
                    bustCm: b, waistCm: w, hipsCm: hips, heightCm: h,
                    gender: profile?['gender'] as String? ?? 'female',
                    avatarGlbUrl: avatarUrl,
                  ),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.checkroom_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(isEn ? "Try in 3D / AR" : "Essayez-le en 3D / RA", style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Add to cart Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: p.inStock ? () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(isEn ? "Product added to cart!" : "Produit ajouté au panier !", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  ]),
                  backgroundColor: const Color(0xFF172554),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ));
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen(initialIndex: 3)),
                  (route) => false,
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: p.inStock ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
                foregroundColor: const Color(0xFF172554),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 19, color: Color(0xFF172554)),
                  const SizedBox(width: 8),
                  Text(
                    p.inStock
                        ? (isEn ? "Add to Cart — $_price" : "Ajouter au Panier — $_price")
                        : (isEn ? "Sold Out" : "Épuisé"),
                    style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: const Color(0xFF172554)),
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
