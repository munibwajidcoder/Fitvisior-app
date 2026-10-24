import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:io';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../home/data/product_service.dart';
import '../../../home/presentation/screens/physics_drape_screen.dart';
import '../../../home/presentation/screens/change_size_color_screen.dart';
import '../../../home/presentation/screens/multi_object_try_on_screen.dart';
import '../../../home/presentation/screens/product_comparison_screen.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/widgets/language_toggle_badge.dart';

class AvatarPreviewScreen extends StatefulWidget {
  final ProductModel? product;
  final List<ProductModel>? allProducts;
  const AvatarPreviewScreen({super.key, this.product, this.allProducts});

  @override
  State<AvatarPreviewScreen> createState() => _AvatarPreviewScreenState();
}

class _AvatarPreviewScreenState extends State<AvatarPreviewScreen> {
  // State variables
  int _fittingViewMode = 0; // 0: Avatar (default — opens directly in 3D), 1: Essayé, 2: Côte à côte
  int _selectedThumbnail = 0;
  bool _is3DActive = true;
  static const Color _midnightNavy = Color(0xFF172554);

  Map<String, dynamic>? _userProfile;
  late List<String> _thumbnails;
  ProductModel? _currentProduct;
  List<ProductModel> _availableProducts = [];
  int _selectedCategoryIndex = 0;
  final List<String> _garmentCategories = ['Vestes', 'Pantalons', 'Robes', 'Shorts'];

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _initThumbnails();
    _loadProfile();
    _initAvailableProducts();
  }

  void _initAvailableProducts() async {
    List<ProductModel> list = [];
    if (widget.allProducts != null && widget.allProducts!.isNotEmpty) {
      list = List.from(widget.allProducts!);
    } else {
      try {
        final products = await ProductService.instance.getProducts();
        if (products.isNotEmpty) {
          list = List.from(products);
        }
      } catch (_) {}
    }

    // Ensure multi-brand luxury diversity across all 4 categories (Vestes, Pantalons, Robes, Shorts)
    final existingIds = list.map((e) => e.id).toSet();
    final extraMultiBrandItems = [
      ProductModel(
        id: 'mb_ysl_jacket',
        name: 'Veste Smoking Grain de Poudre',
        brand: 'Saint Laurent',
        category: 'Blazers & Vestes',
        subCategory: 'Vestes',
        gender: 'Femme',
        description: 'Veste de smoking iconique à revers en satin de soie.',
        price: 2490.0,
        isSale: false,
        imageUrl: 'assets/images/product_suit.jpg',
        galleryImages: ['assets/images/product_suit.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38', 'FR 40'],
        availableColors: [{'name': 'Noir Profond', 'hex': '#0F172A'}],
        recSize: 'FR 36',
        fitPercent: '99% Fit',
        fabricComposition: 'Laine & Soie',
        silhouetteType: 'Structuré',
        careInstructions: 'Nettoyage à sec',
        isFeatured: true,
        isTrending: true,
        isNewArrival: true,
        triedCountText: "520 essayés",
        badge: '99% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 5,
        partnerStoreName: 'Saint Laurent Paris',
        partnerStoreUrl: 'https://www.ysl.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: 'mb_jacquemus_short',
        name: 'Bermuda Tailleur en Lin Le Short',
        brand: 'Jacquemus',
        category: 'Shorts & Bermudas',
        subCategory: 'Shorts',
        gender: 'Femme',
        description: 'Short tailleur taille haute à pinces en lin pur.',
        price: 490.0,
        isSale: false,
        imageUrl: 'assets/images/product_pants.jpg',
        galleryImages: ['assets/images/product_pants.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38'],
        availableColors: [{'name': 'Beige Naturel', 'hex': '#D4C5B9'}],
        recSize: 'FR 36',
        fitPercent: '97% Fit',
        fabricComposition: '100% Lin Français',
        silhouetteType: 'Détendu Ample',
        careInstructions: 'Lavage délicat',
        isFeatured: false,
        isTrending: true,
        isNewArrival: true,
        triedCountText: "310 essayés",
        badge: '97% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 8,
        partnerStoreName: 'Jacquemus Montaigne',
        partnerStoreUrl: 'https://www.jacquemus.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: 'mb_chanel_short',
        name: 'Short Tailleur Tweed Signature',
        brand: 'Chanel',
        category: 'Shorts & Bermudas',
        subCategory: 'Shorts',
        gender: 'Femme',
        description: 'Short structuré boutonné en tweed et laine vierge.',
        price: 1650.0,
        isSale: false,
        imageUrl: 'assets/images/product_pants.jpg',
        galleryImages: ['assets/images/product_pants.jpg'],
        availableSizes: ['FR 36', 'FR 38'],
        availableColors: [{'name': 'Noir / Blanc', 'hex': '#1E293B'}],
        recSize: 'FR 38',
        fitPercent: '95% Fit',
        fabricComposition: 'Tweed de Laine',
        silhouetteType: 'Classique Ajusté',
        careInstructions: 'Nettoyage à sec',
        isFeatured: false,
        isTrending: false,
        isNewArrival: true,
        triedCountText: "190 essayés",
        badge: '95% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 4,
        partnerStoreName: 'Chanel Cambon',
        partnerStoreUrl: 'https://www.chanel.com',
        storeReservationAvailable: true,
      ),
    ];

    for (final item in extraMultiBrandItems) {
      if (!existingIds.contains(item.id)) {
        list.add(item);
      }
    }

    if (mounted) {
      setState(() {
        _availableProducts = list;
        if (_currentProduct == null && _availableProducts.isNotEmpty) {
          _currentProduct = _availableProducts.first;
          _initThumbnails();
        }
      });
    }
  }

  void _initThumbnails() {
    if (_currentProduct != null) {
      final list = <String>[];
      if (_currentProduct!.imageUrl.isNotEmpty) list.add(_currentProduct!.imageUrl);
      for (final g in _currentProduct!.galleryImages) {
        if (!list.contains(g)) list.add(g);
      }
      _thumbnails = list.isNotEmpty ? list : ['assets/images/product_suit.jpg'];
    } else {
      _thumbnails = [
        'assets/images/product_suit.jpg',
        'assets/images/product_dress.jpg',
        'assets/images/hero_banner.jpg',
        'assets/images/product_pants.jpg',
      ];
    }
  }

  Future<void> _loadProfile() async {
    try {
      final p = await AuthService.getProfile();
      if (mounted && p != null) {
        setState(() => _userProfile = p);
      }
      await UserAvatarService.loadSavedAvatar();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                // ── TOP APP BAR ──────────────────────────────────────────
                _buildAppBar(context, isEn),

                // ── SCROLLABLE BODY ──────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. 3D FITTING ROOM HERO VIEWPORT CARD
                        _buildFittingRoomViewportCard(),

                        const SizedBox(height: 16),

                        // WARDROBE GARMENT SELECTOR TRAY
                        _buildWardrobeGarmentSelectorTray(),

                        const SizedBox(height: 16),

                        // 2. SELECTED GARMENT CARD
                        _buildSelectedGarmentCard(),

                        const SizedBox(height: 14),

                        // 3. FIT ESTIMATE CARD
                        _buildFitEstimateCard(),

                        const SizedBox(height: 14),

                        // 4. THREE QUICK ACTION CARDS ROW
                        _buildQuickActionCardsRow(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ── BOTTOM ACTION BUTTONS BAR ─────────────────────────────
                _buildBottomActionButtonsBar(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context, bool isEn) {
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
              isEn ? "Fitting Room" : "Cabine d'Essayage",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const LanguageToggleBadge(),
          const SizedBox(width: 8),
          // User Avatar
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

  Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => Image.asset(
          'assets/images/hero_banner.jpg',
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (ctx, err, stack) => Image.asset(
        'assets/images/hero_banner.jpg',
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  Widget _build3DAvatarViewer({bool isDark = false}) {
    if (!_is3DActive) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF43F5E),
            strokeWidth: 2,
          ),
        ),
      );
    }
    String? glbSrc = _userProfile?['avatar_glb_url'] as String? ??
        UserAvatarService.avatarGlbNotifier.value;
    if (glbSrc == null || glbSrc.isEmpty) {
      final gender = (_userProfile?['gender'] as String?)?.toLowerCase() ?? '';
      final isMale = gender.contains('homme') || gender.contains('male');
      glbSrc = isMale ? 'assets/models/base_avatar_male.glb' : 'assets/models/base_avatar_female.glb';
    }
    if (glbSrc.startsWith('asset://')) {
      glbSrc = glbSrc.replaceFirst('asset://', '');
    }

    return ModelViewer(
      key: ValueKey('avatar_model_$glbSrc'),
      src: glbSrc,
      alt: "Avatar Morphologique 3D",
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
    );
  }

  // ── 1. 3D FITTING ROOM HERO VIEWPORT CARD ─────────────────────────────────
  Widget _buildFittingRoomViewportCard() {
    final currentImg = _thumbnails.isNotEmpty ? _thumbnails[_selectedThumbnail] : 'assets/images/hero_banner.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 440,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Stack(
          children: [
            // Background Viewport: Avatar (0), Porté (1), or Côte à côte (2)
            Positioned.fill(
              child: Builder(
                builder: (context) {
                  if (_fittingViewMode == 0) {
                    // 100% 3D Avatar View on clean White Background
                    return Container(
                      color: Colors.white,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _build3DAvatarViewer(isDark: false),
                          Positioned(
                            bottom: 12,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.accessibility_new_rounded, size: 13, color: Color(0xFFF43F5E)),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Avatar Morphologique 3D",
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _midnightNavy),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (_fittingViewMode == 2) {
                    // Side-by-Side (Côte à côte) View on White Background
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _build3DAvatarViewer(isDark: false),
                                Positioned(
                                  bottom: 10,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.06),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "Votre Avatar 3D",
                                      style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: _midnightNavy),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1.5, color: const Color(0xFFE2E8F0)),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildImageWidget(currentImg, fit: BoxFit.cover),
                                Positioned(
                                  bottom: 10,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE11D48),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "Vêtement Porté",
                                      style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Default: Porté (1) View
                  return Container(
                    color: Colors.white,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImageWidget(currentImg, fit: BoxFit.cover),
                        Positioned(
                          bottom: 12,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.checkroom_rounded, size: 13, color: Color(0xFFF43F5E)),
                                const SizedBox(width: 5),
                                Text(
                                  "Simulation Porté sur Avatar",
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Top Bar Overlay: 3-Way Toggle Pill only (badge removed per user request)
            Positioned(
              top: 12,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 3-Way Toggle Pill: Avatar | Porté | Côte à côte
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildViewModeTab(tr('fitting_view_avatar'), 0),
                        _buildViewModeTab(tr('fitting_view_worn'), 1),
                        _buildViewModeTab(tr('fitting_view_side'), 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right Vertical Thumbnail Views Carousel Overlay — REMOVED per user request

            // Bottom Right Fullscreen Button
            Positioned(
              right: 14,
              bottom: 46,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fullscreen_rounded,
                  size: 22,
                  color: _midnightNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeTab(String title, int mode) {
    final isSelected = _fittingViewMode == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _fittingViewMode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _midnightNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ── WARDROBE GARMENT SELECTOR TRAY ────────────────────────────────────────
  Widget _buildWardrobeGarmentSelectorTray() {
    final selectedCat = _garmentCategories[_selectedCategoryIndex];
    final filtered = _availableProducts.where((p) {
      if (selectedCat == 'Tous') return true;
      if (selectedCat == 'Vestes') return p.category.toLowerCase().contains('jacket') || p.category.contains('Veste') || p.category.contains('Blazer');
      if (selectedCat == 'Pantalons') return p.category.toLowerCase().contains('trouser') || p.category.contains('Pantalon') || p.category.contains('Denim') || p.category.toLowerCase().contains('pant');
      if (selectedCat == 'Robes') return p.category.toLowerCase().contains('dress') || p.category.contains('Robe');
      if (selectedCat == 'Shorts') return p.category.toLowerCase().contains('short');
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.checkroom_rounded, size: 16, color: Color(0xFFE11D48)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Dressing Virtuel",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _midnightNavy,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Appuyez pour essayer",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _garmentCategories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cat = _garmentCategories[index];
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF172554) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF172554) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "Aucun article dans cette catégorie",
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            SizedBox(
              height: 138,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  final isSelected = _currentProduct != null &&
                      (_currentProduct!.id == p.id || _currentProduct!.name == p.name);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentProduct = p;
                        _selectedThumbnail = 0;
                        _initThumbnails();
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: const Color(0xFFE11D48).withValues(alpha: 0.18),
                              blurRadius: 8,
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
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: _buildImageWidget(
                                  p.imageUrl,
                                  width: 96,
                                  height: 82,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE11D48),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 5, 6, 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? const Color(0xFFE11D48) : _midnightNavy,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${p.price.toStringAsFixed(0)} €',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: _midnightNavy,
                                      ),
                                    ),
                                    Text(
                                      p.fitPercent,
                                      style: GoogleFonts.inter(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF10B981),
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
                },
              ),
            ),
        ],
      ),
    );
  }

  // ── 2. SELECTED GARMENT CARD ──────────────────────────────────────────────
  Widget _buildSelectedGarmentCard() {
    final curImg = _thumbnails.isNotEmpty ? _thumbnails[_selectedThumbnail] : (_currentProduct?.imageUrl ?? 'assets/images/product_suit.jpg');
    final pName = _currentProduct?.name ?? "Blazer Bleu Nuit";
    final pBrand = _currentProduct?.brand.toUpperCase() ?? "SAINT LAURENT";
    final pSize = _currentProduct?.recSize ?? "Taille M";
    final pPrice = _currentProduct != null ? "${_currentProduct!.price.toStringAsFixed(0)} €" : "2 450 €";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImageWidget(
              curImg,
              width: 52,
              height: 52,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$pBrand • $pSize • $pPrice",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  // ── 3. FIT ESTIMATE CARD ──────────────────────────────────────────────────
  Widget _buildFitEstimateCard() {
    final fitText = _currentProduct?.fitPercent.isNotEmpty == true ? _currentProduct!.fitPercent : "98% Fit";
    final recSize = _currentProduct?.recSize ?? "Taille M";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              size: 18,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ajustement : $fitText • Taille $recSize",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Correspondance morphologique optimale",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

  // ── 4. THREE QUICK ACTION CARDS ROW ────────────────────────────────────────
  Widget _buildQuickActionCardsRow() {
    return Row(
      children: [
        _buildActionTile(
          icon: Icons.checkroom_rounded,
          title: "Changer Taille / Couleur",
          onTap: () async {
            setState(() => _is3DActive = false);
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangeSizeColorScreen(product: _currentProduct),
              ),
            );
            if (mounted) setState(() => _is3DActive = true);
          },
        ),
        const SizedBox(width: 8),
        _buildActionTile(
          icon: Icons.shopping_bag_outlined,
          title: "Ajouter Chaussures & Accessoires",
          onTap: () async {
            setState(() => _is3DActive = false);
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MultiObjectTryOnScreen(product: _currentProduct),
              ),
            );
            if (mounted) setState(() => _is3DActive = true);
          },
        ),
        const SizedBox(width: 8),
        _buildActionTile(
          icon: Icons.view_carousel_outlined,
          title: "Voir Comparaison",
          onTap: () async {
            setState(() => _is3DActive = false);
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProductComparisonScreen(),
              ),
            );
            if (mounted) setState(() => _is3DActive = true);
          },
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: _midnightNavy),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _midnightNavy,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── BOTTOM ACTION BUTTONS BAR ──────────────────────────────────────────────
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
          // Primary Button: Coral Pink Gradient
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final p = _currentProduct;
                final b = (_userProfile?['bust_cm'] as num?)?.toDouble() ?? 86.0;
                final w = (_userProfile?['waist_cm'] as num?)?.toDouble() ?? 66.0;
                final hips = (_userProfile?['hip_cm'] as num?)?.toDouble() ?? 94.0;
                final h = (_userProfile?['height_cm'] as num?)?.toDouble() ?? 174.0;
                final avatarUrl = _userProfile?['avatar_glb_url'] as String? ??
                    UserAvatarService.avatarGlbNotifier.value ??
                    (((_userProfile?['gender'] as String?)?.toLowerCase().contains('homme') ?? false)
                        ? 'assets/models/base_avatar_male.glb'
                        : 'assets/models/base_avatar_female.glb');

                setState(() => _is3DActive = false);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhysicsDrapeScreen(
                      garment: GarmentTryOnData(
                        productName: p?.name ?? 'Blazer Bleu Nuit',
                        brandName: p?.brand ?? 'ATELIER COLLECTION',
                        price: p != null ? '${p.price.toStringAsFixed(0)} €' : '245,00 €',
                        selectedSize: p?.recSize ?? 'M',
                        selectedColor: const Color(0xFF172554),
                        colorName: 'Bleu Nuit',
                        productImagePath: p?.imageUrl ?? 'assets/images/product_suit.jpg',
                        glbUrl: p?.glbModelUrl,
                      ),
                      bustCm: b,
                      waistCm: w,
                      hipsCm: hips,
                      heightCm: h,
                      gender: _userProfile?['gender'] as String? ?? 'female',
                      avatarGlbUrl: avatarUrl,
                    ),
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
                    Icons.waves_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "✨ Explorer la Physique du Tissu & Mouvement",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
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

          const SizedBox(height: 10),

          // Secondary Button: Back to Product
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: _midnightNavy,
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: _midnightNavy,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Retour au Produit",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
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
    );
  }
}

