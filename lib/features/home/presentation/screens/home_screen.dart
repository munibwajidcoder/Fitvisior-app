import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../scan/presentation/screens/avatar_preview_screen.dart';
import '../../data/favorites_manager.dart';
import '../../data/product_service.dart';
import 'filter_screen.dart';
import 'product_detail_screen.dart';

import 'wardrobe_favorites_screen.dart';
import 'checkout_screen.dart';
import 'account_settings_screen.dart';
import 'notifications_screen.dart';
import '../widgets/fashion_category_icons.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/notification_service.dart';



class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _bottomNavIndex;

  // Supabase Live Products State
  bool _isLoadingProducts = true;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _heroBanners = [];
  List<ProductModel> _trendingProducts = [];
  List<ProductModel> _newArrivals = [];
  List<ProductModel> _flashSaleProducts = [];
  List<ProductModel> _catalogueProducts = [];

  // Filter & Search State
  FilterCriteria? _activeFilterCriteria;
  String _catalogueSearchQuery = '';
  final TextEditingController _homeSearchController = TextEditingController();
  final TextEditingController _catalogueSearchController = TextEditingController();

  // Hero banner auto-rotate state
  final PageController _heroBannerController = PageController();
  int _heroBannerIndex = 0;
  Timer? _heroBannerTimer;
  bool _showTopToast = false;
  Timer? _topToastTimer;
  String _topToastTitleEn = "Welcome to FitVisor!";
  String _topToastTitleFr = "Bienvenue sur FitVisor !";
  String _topToastBodyEn = "Your virtual styling studio is ready.";
  String _topToastBodyFr = "Votre studio d'essayage 3D est prêt.";

  @override
  void initState() {
    super.initState();
    LanguageService.instance.addListener(_onLanguageChanged);
    FcmService.foregroundMessageNotifier.addListener(_onFcmForegroundMessage);
    _bottomNavIndex = widget.initialIndex;
    UserAvatarService.loadSavedAvatar();
    _loadAllDataFromSupabase();
    _heroBannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_heroBannerController.hasClients) {
        final count = _heroBanners.isNotEmpty ? _heroBanners.length : 4;
        final next = (_heroBannerIndex + 1) % count;
        _heroBannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    // Refresh notifications count and check welcome banner
    NotificationService.getUnreadCount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcomeBanner();
    });
  }

  Future<void> _checkAndShowWelcomeBanner() async {
    // Wait for the screen to settle after launch / Ctrl+R restart
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    // Persist Welcome notification into the notification center so bell icon shows badge and item is listed!
    final welcome = await NotificationService.ensureWelcomeNotification();

    setState(() {
      _topToastTitleEn = welcome.titleEn;
      _topToastTitleFr = welcome.titleFr;
      _topToastBodyEn = welcome.bodyEn;
      _topToastBodyFr = welcome.bodyFr;
      _showTopToast = true;
    });

    // Play system notification chime (ting ting sound) and haptic vibration
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();

    _topToastTimer?.cancel();
    _topToastTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        setState(() {
          _showTopToast = false;
        });
      }
    });
  }

  void _onFcmForegroundMessage() {
    final msg = FcmService.foregroundMessageNotifier.value;
    if (msg == null || !mounted) return;

    final isFr = LanguageService.instance.isFrench;
    final fcmTitle = msg.notification?.title ?? msg.data['title'] ?? (isFr ? "Nouvelle alerte" : "New Alert");
    final fcmBody = msg.notification?.body ?? msg.data['body'] ?? "";
    final fcmTitleFr = msg.data['title_fr'] ?? (isFr ? fcmTitle : null);
    final fcmBodyFr = msg.data['body_fr'] ?? (isFr ? fcmBody : null);

    // Save into notification center as a new distinct card
    NotificationService.addIncomingNotification(
      title: fcmTitle,
      body: fcmBody,
      titleFr: fcmTitleFr,
      bodyFr: fcmBodyFr,
      category: msg.data['category']?.toString() ?? 'system',
    );

    setState(() {
      _topToastTitleEn = fcmTitle;
      _topToastTitleFr = fcmTitleFr ?? (isFr ? fcmTitle : "Notification FitVisor");
      _topToastBodyEn = fcmBody;
      _topToastBodyFr = fcmBodyFr ?? (isFr ? fcmBody : "");
      _showTopToast = true;
    });

    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.alert);

    _topToastTimer?.cancel();
    _topToastTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        setState(() {
          _showTopToast = false;
        });
      }
    });
  }

  Widget _buildTopNotificationToast(bool isEn) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      offset: _showTopToast ? Offset.zero : const Offset(0, -1.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _showTopToast ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 6, 14, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF172554),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _showTopToast = false);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? _topToastTitleEn : _topToastTitleFr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn ? _topToastBodyEn : _topToastBodyFr,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFCBD5E1),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() => _showTopToast = false);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEn ? "View" : "Voir",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFDA4AF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() => _showTopToast = false);
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAllDataFromSupabase() async {
    setState(() => _isLoadingProducts = true);
    try {
      final products = await ProductService.instance.getProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products;
        _heroBanners = products.where((p) => p.isFeatured).toList();
        if (_heroBanners.isEmpty && products.isNotEmpty) {
          _heroBanners = products.take(4).toList();
        }
        _trendingProducts = products.where((p) => p.isTrending).toList();
        if (_trendingProducts.isEmpty && products.isNotEmpty) {
          _trendingProducts = products.take(2).toList();
        }
        _newArrivals = products.where((p) => p.isNewArrival).toList();
        if (_newArrivals.isEmpty && products.isNotEmpty) {
          _newArrivals = products.take(4).toList();
        }
        _flashSaleProducts = products.where((p) => p.isSale).toList();
        if (_flashSaleProducts.isEmpty && products.isNotEmpty) {
          _flashSaleProducts = products.take(4).toList();
        }
        _isLoadingProducts = false;
      });
      _filterCatalogueProducts();
    } catch (e) {
      debugPrint('[HomeScreen] Error loading products: $e');
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  void _filterCatalogueProducts() {
    List<ProductModel> list = List.from(_allProducts);

    // 1. Category Filter (0-indexed, no 'All' option — first tab = Jackets)
    if (_catalogueSelectedCategory < _catalogueCategories.length) {
      list = list.where((p) {
        if (_catalogueSelectedCategory == 0) return p.category.toLowerCase().contains('jacket') || p.category.contains('Veste') || p.category.contains('Blazer');
        if (_catalogueSelectedCategory == 1) return p.category.toLowerCase().contains('trouser') || p.category.contains('Pantalon') || p.category.contains('Denim') || p.category.toLowerCase().contains('pant');
        if (_catalogueSelectedCategory == 2) return p.category.toLowerCase().contains('dress') || p.category.contains('Robe');
        if (_catalogueSelectedCategory == 3) return p.category.toLowerCase().contains('short');
        return true;
      }).toList();
    }

    // 2. Search Query
    if (_catalogueSearchQuery.trim().isNotEmpty) {
      final q = _catalogueSearchQuery.toLowerCase().trim();
      list = list.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.brand.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q)
      ).toList();
    }

    // 3. Filter Sheet Criteria (Brand, Size, Colour, Fit)
    if (_activeFilterCriteria != null && !_activeFilterCriteria!.isEmpty) {
      final f = _activeFilterCriteria!;

      // 3a. Brand
      if (f.brands.isNotEmpty) {
        list = list.where((p) => f.brands.any((b) =>
          p.brand.toLowerCase().trim() == b.toLowerCase().trim() ||
          p.brand.toLowerCase().contains(b.toLowerCase())
        )).toList();
      }

      // 3b. Fit level
      if (f.fitLevel.isNotEmpty) {
        final minFit = int.tryParse(f.fitLevel) ?? 0;
        list = list.where((p) {
          final match = RegExp(r'(\d+)%').firstMatch(p.fitPercent);
          if (match != null) {
            final pct = int.tryParse(match.group(1) ?? '0') ?? 0;
            return pct >= minFit;
          }
          return true;
        }).toList();
      }
    }

    setState(() {
      _catalogueProducts = list;
    });
  }

  Widget _buildProductImage(String imagePath, {double? width, double? height, BoxFit fit = BoxFit.cover, Alignment alignment = Alignment.topCenter}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (ctx, err, stack) => Image.asset(
          'assets/images/product_dress.jpg',
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
        ),
      );
    }
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (ctx, err, stack) => Image.asset(
        'assets/images/product_dress.jpg',
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
      ),
    );
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    FcmService.foregroundMessageNotifier.removeListener(_onFcmForegroundMessage);
    _heroBannerTimer?.cancel();
    _topToastTimer?.cancel();
    _heroBannerController.dispose();
    _homeSearchController.dispose();
    _catalogueSearchController.dispose();
    super.dispose();
  }


  // Catalogue state
  int _catalogueSelectedCategory = 0;
  List<String> get _catalogueCategories => [
    tr('cat_jackets'),
    tr('cat_trousers'),
    tr('cat_dresses'),
    tr('cat_shorts'),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
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

                // ── TOP FLOATING NOTIFICATION POPUP ───────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: !_showTopToast,
                    child: _buildTopNotificationToast(LanguageService.instance.isEnglish),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                "Fit Visor",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Language Switcher (EN / FR)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              LanguageService.instance.toggleLanguage();
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 16, color: Color(0xFFF43F5E)),
                  const SizedBox(width: 4),
                  Text(
                    LanguageService.instance.isEnglish ? 'EN' : 'FR',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Notifications Bell with dynamic numeric badge
          ValueListenableBuilder<int>(
            valueListenable: NotificationService.unreadCountNotifier,
            builder: (context, unreadCount, _) {
              return _iconButton(
                Icons.notifications_none_rounded,
                badgeCount: unreadCount,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                  NotificationService.getUnreadCount();
                },
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
          // User Profile Avatar (switches to Profile tab keeping bottom nav intact)
          GestureDetector(
            onTap: () {
              setState(() {
                _bottomNavIndex = 4;
              });
            },
            child: ValueListenableBuilder<File?>(
              valueListenable: UserAvatarService.avatarNotifier,
              builder: (context, avatarFile, _) {
                return Container(
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
                    child: avatarFile != null
                        ? Image.file(
                            avatarFile,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFFEFF6FF),
                            child: const Center(
                              child: Icon(Icons.person_rounded, size: 20, color: Color(0xFF2563EB)),
                            ),
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

  Widget _iconButton(IconData icon, {VoidCallback? onTap, bool hasBadge = false, int badgeCount = 0}) {
    final showBadge = hasBadge || badgeCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
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
          if (showBadge)
            Positioned(
              top: badgeCount > 0 ? -3 : 2,
              right: badgeCount > 0 ? -4 : 2,
              child: badgeCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : '$badgeCount',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Container(
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
              const SizedBox(height: 18),

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

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  // ── SHOP BY CATEGORY SECTION ─────────────────────────────────────────────
  Widget _buildShopByCategorySection() {
    final categories = [
      {
        'label': tr('cat_jackets'),
        'catIndex': 0,
        'bgColor': const Color(0xFFFFF1F2), // Soft Rose / Pink blush
        'iconColor': const Color(0xFFE11D48), // Rose
      },
      {
        'label': tr('cat_trousers'),
        'catIndex': 1,
        'bgColor': const Color(0xFFECFDF5), // Soft Mint / Green
        'iconColor': const Color(0xFF059669), // Emerald
      },
      {
        'label': tr('cat_dresses'),
        'catIndex': 2,
        'bgColor': const Color(0xFFFAF5FF), // Soft Lavender
        'iconColor': const Color(0xFF9333EA), // Purple
      },
      {
        'label': tr('cat_shorts'),
        'catIndex': 3,
        'bgColor': const Color(0xFFEFF6FF), // Soft Sky Blue
        'iconColor': const Color(0xFF2563EB), // Royal / Denim Blue
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            tr('shop_by_category'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(categories.length, (index) {
              final cat = categories[index];
              final isLast = index == categories.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _catalogueSelectedCategory = cat['catIndex'] as int;
                        _bottomNavIndex = 1;
                      });
                      _filterCatalogueProducts();
                    },
                    child: Container(
                      height: 90,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cat['bgColor'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: FashionCategoryIcon(
                                categoryIndex: cat['catIndex'] as int,
                                color: cat['iconColor'] as Color,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            cat['label'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF172554),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── NEW ARRIVALS SECTION ─────────────────────────────────────────────────
  Widget _buildNewArrivalsSection() {
    final arrivals = _newArrivals.isNotEmpty
        ? _newArrivals
        : (_allProducts.isNotEmpty
            ? _allProducts.take(4).toList()
            : ProductService.instance.fallbackProducts.where((p) => p.isNewArrival).take(4).toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('new_arrivals'),
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
                  tr('view_all'),
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
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: a),
                  ),
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
                            child: _buildProductImage(
                              a.imageUrl,
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
                                tr('badge_new'),
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
                            child: ValueListenableBuilder<List<FavoriteItem>>(
                              valueListenable: FavoritesManager.instance.favoriteItemsNotifier,
                              builder: (context, favList, child) {
                                final itemId = '${a.brand}_${a.name}'.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
                                final isFav = FavoritesManager.instance.isFavorite(itemId, name: a.name);
                                return GestureDetector(
                                  onTap: () {
                                    final favItem = FavoriteItem(
                                      id: itemId,
                                      brand: a.brand,
                                      name: a.name,
                                      price: '${a.price.toStringAsFixed(0)} €',
                                      size: a.recSize.replaceAll('Rec: ', ''),
                                      fitMatch: a.fitPercent,
                                      imagePath: a.imageUrl,
                                    );
                                    FavoritesManager.instance.toggleFavorite(context, favItem);
                                  },
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: isFav ? const Color(0xFFFFF1F2) : Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      size: 14,
                                      color: isFav ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                );
                              },
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
                              a.displayName,
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
                                  '${a.price.toStringAsFixed(0)} €',
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
                controller: _homeSearchController,
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    setState(() {
                      _bottomNavIndex = 1;
                      _catalogueSearchController.text = val;
                      _catalogueSearchQuery = val;
                    });
                    _filterCatalogueProducts();
                  }
                },
                decoration: InputDecoration(
                  hintText: tr('home_search_hint'),
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

  Widget _buildHomeHeroBanner() {
    final banners = _heroBanners.isNotEmpty
        ? _heroBanners
        : (_allProducts.isNotEmpty
            ? _allProducts.take(4).toList()
            : ProductService.instance.fallbackProducts.take(4).toList());

    final gradients = [
      const [Color(0xCC0F172A), Colors.transparent],
      const [Color(0xCC1A0533), Colors.transparent],
      const [Color(0xCC0F1F3A), Colors.transparent],
      const [Color(0xCC1A1A2E), Colors.transparent],
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
                  final grad = gradients[index % gradients.length];
                  final rawTag = b.bannerTag ?? (b.isSale ? 'PROMO' : (b.isNewArrival ? 'NOUVEAUTÉ' : 'SÉLECTION'));
                  final tag = b.displayBannerTag(rawTag);
                  final badge = b.displayBadge.isNotEmpty ? b.displayBadge : '✨ ${b.fitPercent} Fit';

                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: b),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: _buildProductImage(
                            b.imageUrl,
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
                                colors: grad,
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
                                      tag,
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
                                      badge,
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
                                b.displayName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${b.brand} • ${b.displayCategory} • ${b.displaySilhouette}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(product: b),
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
                                        tr('try_now'),
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
                    ),
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
                tr('curated_for_you'),
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
                  tr('view_all'),
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
            tr('based_on_measurements'),
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
    final products = _allProducts.isNotEmpty
        ? _allProducts.take(6).toList()
        : ProductService.instance.fallbackProducts.take(6).toList();

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

  Widget _buildHomeProductCard(ProductModel p) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: p),
        ),
      ),
      child: Container(
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
                      child: _buildProductImage(
                        p.imageUrl,
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
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.fitPercent,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16A34A),
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
                              price: '${p.price.toStringAsFixed(0)} €',
                              size: p.recSize.replaceAll('Rec: ', ''),
                              fitMatch: p.fitPercent,
                              imagePath: p.imageUrl,
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
                      p.displayName,
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
                          '${p.price.toStringAsFixed(0)} €',
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

              // Category scroll pills: Jackets / Trousers / Dresses / Shorts
              _buildCatalogueCategoryPills(),

              const SizedBox(height: 16),

              // 2-Column Product Grid
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
    int activeCount = 0;
    if (_activeFilterCriteria != null) {
      activeCount = _activeFilterCriteria!.brands.length +
          _activeFilterCriteria!.sizes.length +
          _activeFilterCriteria!.colours.length +
          (_activeFilterCriteria!.fitLevel.isNotEmpty ? 1 : 0);
    }

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
                      controller: _catalogueSearchController,
                      onChanged: (val) {
                        _catalogueSearchQuery = val;
                        _filterCatalogueProducts();
                      },
                      decoration: InputDecoration(
                        hintText: tr('search_hint'),
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
                  if (_catalogueSearchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _catalogueSearchController.clear();
                        _catalogueSearchQuery = '';
                        _filterCatalogueProducts();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filtres button — navigates to FilterScreen with return criteria
          GestureDetector(
            onTap: () async {
              final criteria = await Navigator.of(context).push<FilterCriteria>(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      FilterScreen(
                        initialFilters: _activeFilterCriteria,
                        allProducts: _allProducts.isNotEmpty ? _allProducts : ProductService.instance.fallbackProducts,
                      ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
              if (criteria != null) {
                setState(() {
                  _activeFilterCriteria = criteria;
                });
                _filterCatalogueProducts();
              }
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
                      tr('filters_title'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (activeCount > 0) ...[
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
                          "$activeCount",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogueCategoryPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_catalogueCategories.length, (index) {
          final selected = _catalogueSelectedCategory == index;
          final isLast = index == _catalogueCategories.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _catalogueSelectedCategory = index);
                  _filterCatalogueProducts();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 38,
                  alignment: Alignment.center,
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
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCatalogueProductGrid() {

    if (_isLoadingProducts && _allProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF172554),
          ),
        ),
      );
    }

    if (_allProducts.isNotEmpty && _catalogueProducts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF172554).withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.filter_list_off_rounded,
                  size: 28,
                  color: Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tr('search_empty_title'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tr('search_empty_desc'),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _activeFilterCriteria = null;
                    _catalogueSelectedCategory = 0;
                    _catalogueSearchController.clear();
                    _catalogueSearchQuery = '';
                  });
                  _filterCatalogueProducts();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF172554),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tr('reset_filters'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

    final List<ProductModel> catalogueProducts = _catalogueProducts.isNotEmpty
        ? _catalogueProducts
        : (_allProducts.isNotEmpty
            ? _allProducts
            : ProductService.instance.fallbackProducts);

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

  Widget _buildCatalogueProductCard(ProductModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: item),
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
                      child: Container(
                        color: const Color(0xFFF8F8F8),
                        child: _buildProductImage(
                          item.imageUrl,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
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
                              price: '${item.price.toStringAsFixed(0)} €',
                              size: item.recSize.replaceAll('Rec: ', ''),
                              fitMatch: item.fitPercent,
                              imagePath: item.imageUrl,
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
                    item.displayName,
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
                          '${item.price.toStringAsFixed(0)} €',
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
                        item.displayRecSize,
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
                          builder: (context) => AvatarPreviewScreen(product: item),
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
                            tr('virtual_try_on'),
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
    final trendingProducts = _trendingProducts.isNotEmpty
        ? _trendingProducts.take(4).toList()
        : (_allProducts.isNotEmpty
            ? _allProducts.where((p) => p.isTrending).take(4).toList()
            : ProductService.instance.fallbackProducts.where((p) => p.isTrending).take(4).toList());

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
                        tr('section_trending'),
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
                tr('live_ar'),
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
            itemCount: trendingProducts.length,
            separatorBuilder: (ctx, i) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = trendingProducts[index];
              final triedText = item.displayTriedCountText.isNotEmpty ? item.displayTriedCountText : (LanguageService.instance.isEnglish ? "412 tried on today" : "412 essayés aujourd'hui");

              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: item),
                  ),
                ),
                child: Container(
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
                                child: Container(
                                  color: const Color(0xFFF8F8F8),
                                  child: _buildProductImage(
                                    item.imageUrl,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                  ),
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
                                        price: '${item.price.toStringAsFixed(0)} €',
                                        size: item.recSize.replaceAll('Rec: ', ''),
                                        fitMatch: item.fitPercent,
                                        imagePath: item.imageUrl,
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
                                        triedText,
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
                              item.displayName,
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
                              '${item.price.toStringAsFixed(0)} €',
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
    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        final items = [
          _NavItem(Icons.home_rounded, tr('nav_home')),
          _NavItem(Icons.grid_view_rounded, tr('nav_catalogue')),
          _NavItem(Icons.auto_awesome_rounded, ""), // Center FAB
          _NavItem(Icons.checkroom_rounded, tr('nav_dressing')),
          _NavItem(Icons.person_outline_rounded, tr('nav_profile')),
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
                        final activeProduct = _trendingProducts.isNotEmpty
                            ? _trendingProducts.first
                            : (_allProducts.isNotEmpty ? _allProducts.first : null);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AvatarPreviewScreen(
                              product: activeProduct,
                              allProducts: _allProducts,
                            ),
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
      },
    );
  }
}

// ── DATA MODELS ──────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
