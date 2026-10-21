import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../data/product_service.dart';
import 'live_ar_mirror_screen.dart';
import 'checkout_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL: Product info passed from ProductDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class GarmentTryOnData {
  final String productName;
  final String brandName;
  final String price;
  final String selectedSize;
  final Color selectedColor;
  final String colorName;
  final String productImagePath;
  final String? glbUrl; // optional real 3D garment model

  const GarmentTryOnData({
    required this.productName,
    required this.brandName,
    required this.price,
    required this.selectedSize,
    required this.selectedColor,
    required this.colorName,
    required this.productImagePath,
    this.glbUrl,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FIT SCORE ENGINE
// ─────────────────────────────────────────────────────────────────────────────
class FitScoreEngine {
  /// Size chart mapping (bust_cm ranges)
  static const Map<String, Map<String, double>> _sizeChart = {
    'XS': {'bust_min': 78, 'bust_max': 82, 'waist_min': 60, 'waist_max': 64, 'hips_min': 84, 'hips_max': 88},
    'S':  {'bust_min': 82, 'bust_max': 86, 'waist_min': 64, 'waist_max': 68, 'hips_min': 88, 'hips_max': 92},
    'M':  {'bust_min': 86, 'bust_max': 92, 'waist_min': 68, 'waist_max': 74, 'hips_min': 92, 'hips_max': 98},
    'L':  {'bust_min': 92, 'bust_max': 98, 'waist_min': 74, 'waist_max': 80, 'hips_min': 98, 'hips_max': 104},
    'XL': {'bust_min': 98, 'bust_max': 106, 'waist_min': 80, 'waist_max': 88, 'hips_min': 104, 'hips_max': 112},
  };

  static FitResult calculate({
    required String size,
    required double bustCm,
    required double waistCm,
    required double hipsCm,
  }) {
    final chart = _sizeChart[size] ?? _sizeChart['M']!;

    double fitZone(double val, double min, double max) {
      if (val < min) return (val - min) / min; // too tight (negative margin)
      if (val > max) return (val - max) / max; // too loose
      return 0.0; // perfect
    }

    final bustDelta  = fitZone(bustCm,  chart['bust_min']!,  chart['bust_max']!);
    final waistDelta = fitZone(waistCm, chart['waist_min']!, chart['waist_max']!);
    final hipsDelta  = fitZone(hipsCm,  chart['hips_min']!,  chart['hips_max']!);

    // Weighted composite delta
    final composite = (bustDelta * 0.4 + waistDelta * 0.35 + hipsDelta * 0.25).abs();
    final score = ((1.0 - composite.clamp(0.0, 1.0)) * 100).roundToDouble();

    // Fit category
    FitCategory category;
    if (bustDelta < -0.04 || waistDelta < -0.04 || hipsDelta < -0.04) {
      category = FitCategory.tight;
    } else if (bustDelta > 0.05 || waistDelta > 0.05 || hipsDelta > 0.05) {
      category = FitCategory.loose;
    } else {
      category = FitCategory.perfect;
    }

    // Tension heatmap values (0.0 - 1.0)
    final bustTension  = (bustDelta.abs() * 3.0).clamp(0.0, 1.0);
    final waistTension = (waistDelta.abs() * 3.0).clamp(0.0, 1.0);
    final hipsTension  = (hipsDelta.abs() * 3.0).clamp(0.0, 1.0);
    final shoulderTension = (composite * 2.0).clamp(0.0, 1.0);

    return FitResult(
      score: score,
      category: category,
      bustTension: bustTension,
      waistTension: waistTension,
      hipsTension: hipsTension,
      shoulderTension: shoulderTension,
      bustDeltaCm: (bustDelta * bustCm),
      waistDeltaCm: (waistDelta * waistCm),
      hipsDeltaCm: (hipsDelta * hipsCm),
    );
  }
}

enum FitCategory { tight, perfect, loose }

class FitResult {
  final double score;
  final FitCategory category;
  final double bustTension;
  final double waistTension;
  final double hipsTension;
  final double shoulderTension;
  final double bustDeltaCm;
  final double waistDeltaCm;
  final double hipsDeltaCm;

  const FitResult({
    required this.score,
    required this.category,
    required this.bustTension,
    required this.waistTension,
    required this.hipsTension,
    required this.shoulderTension,
    required this.bustDeltaCm,
    required this.waistDeltaCm,
    required this.hipsDeltaCm,
  });

  String get categoryLabel {
    switch (category) {
      case FitCategory.tight:   return 'SERRÉ';
      case FitCategory.perfect: return 'PARFAIT';
      case FitCategory.loose:   return 'AMPLE';
    }
  }

  Color get categoryColor {
    switch (category) {
      case FitCategory.tight:   return const Color(0xFFDC2626);
      case FitCategory.perfect: return const Color(0xFF16A34A);
      case FitCategory.loose:   return const Color(0xFFD97706);
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case FitCategory.tight:   return Icons.compress_rounded;
      case FitCategory.perfect: return Icons.check_circle_rounded;
      case FitCategory.loose:   return Icons.expand_rounded;
    }
  }

  String get smartAdvisory {
    switch (category) {
      case FitCategory.tight:
        final delta = bustDeltaCm.abs() > 0.1 ? bustDeltaCm.abs() : 2.5;
        return "Cette taille est trop ajustée à votre morphologie (+${delta.toStringAsFixed(1)} cm de tension). Nous vous recommandons de choisir la taille au-dessus pour un confort optimal et un tombé fluide.";
      case FitCategory.loose:
        final delta = bustDeltaCm.abs() > 0.1 ? bustDeltaCm.abs() : 3.0;
        return "Cette taille offre une coupe ample (+${delta.toStringAsFixed(1)} cm d'aisance). Si vous préférez une silhouette plus cintrée, optez pour la taille en-dessous.";
      case FitCategory.perfect:
        return "Cette taille correspond idéalement à vos mensurations réelles. Ajustement parfait au buste, à la taille et aux hanches.";
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class PhysicsDrapeScreen extends StatefulWidget {
  final GarmentTryOnData? garment;

  // Avatar biometrics (from scan session or defaults)
  final double bustCm;
  final double waistCm;
  final double hipsCm;
  final double heightCm;
  final String gender;
  final String? avatarGlbUrl;

  const PhysicsDrapeScreen({
    super.key,
    this.garment,
    this.bustCm   = 86.0,
    this.waistCm  = 66.0,
    this.hipsCm   = 94.0,
    this.heightCm = 174.0,
    this.gender   = 'female',
    this.avatarGlbUrl,
  });

  @override
  State<PhysicsDrapeScreen> createState() => _PhysicsDrapeScreenState();
}

class _PhysicsDrapeScreenState extends State<PhysicsDrapeScreen>
    with TickerProviderStateMixin {

  static const Color _navy    = Color(0xFF172554);
  static const Color _coral   = Color(0xFFF43F5E);
  static const Color _slate   = Color(0xFF475569);
  static const Color _surface = Color(0xFFF8FAFC);

  // ── UI state ────────────────────────────────────────────────────────────
  bool   _showHeatmap     = false;
  bool   _showGarment     = false; // Default to 3D Avatar (opens directly in 3D)
  bool   _showAfter       = true; // Avant / Après toggle
  bool   _isLoading       = true;
  int    _loadingStage    = 0;
  String _loadingMessage  = "Connexion au Moteur 3D Tripo...";
  Timer? _loadingTimer;

  late FitResult _fitResult;
  late AnimationController _scoreAnimCtrl;
  late Animation<double> _scoreAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  String? _profileAvatarUrl;

  // Avatar GLB — use passed URL, user's saved profile avatar, or UserAvatarService notifier, with base avatar fallback
  String get _avatarUrl {
    final url = widget.avatarGlbUrl ?? _profileAvatarUrl ?? UserAvatarService.avatarGlbNotifier.value;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('asset://')) {
        return url.replaceFirst('asset://', '');
      }
      return url;
    }
    final g = widget.gender.toLowerCase();
    final isMale = g.contains('homme') || g.contains('male');
    return isMale ? 'assets/models/base_avatar_male.glb' : 'assets/models/base_avatar_female.glb';
  }

  GarmentTryOnData get _garment => widget.garment ?? const GarmentTryOnData(
    productName: 'Robe Midi en Soie Drapée',
    brandName:   'ATELIER COLLECTION',
    price:       '285,00 €',
    selectedSize: 'M',
    selectedColor: Color(0xFF172554),
    colorName:   'Bleu Nuit',
    productImagePath: 'assets/images/product_dress.jpg',
  );

  late String _currentSelectedSize;

  @override
  void initState() {
    super.initState();
    _currentSelectedSize = _garment.selectedSize;
    _loadUserProfile();

    // Calculate real fit score
    _fitResult = FitScoreEngine.calculate(
      size:    _currentSelectedSize,
      bustCm:  widget.bustCm,
      waistCm: widget.waistCm,
      hipsCm:  widget.hipsCm,
    );

    // Score counter animation
    _scoreAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = Tween<double>(begin: 0, end: _fitResult.score)
        .animate(CurvedAnimation(parent: _scoreAnimCtrl, curve: Curves.easeOutCubic));

    // Pulse animation for fit badge
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Multi-phase Tripo 3D loading sequence
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_loadingStage == 0) {
        setState(() {
          _loadingStage = 1;
          _loadingMessage = "Moteur 3D Tripo — Drapé morphologique...";
        });
      } else if (_loadingStage == 1) {
        setState(() {
          _loadingStage = 2;
          _loadingMessage = "Calcul des points de tension sur mesure...";
        });
      } else {
        timer.cancel();
        setState(() => _isLoading = false);
        _scoreAnimCtrl.forward();
      }
    });
  }

  void _loadUserProfile() async {
    try {
      final profile = await AuthService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _profileAvatarUrl = profile['avatar_glb_url'] as String?;
        });
      }
      await UserAvatarService.loadSavedAvatar();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _scoreAnimCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _changeSize(String newSize) {
    if (_currentSelectedSize == newSize) return;
    setState(() {
      _currentSelectedSize = newSize;
      _fitResult = FitScoreEngine.calculate(
        size: newSize,
        bustCm: widget.bustCm,
        waistCm: widget.waistCm,
        hipsCm: widget.hipsCm,
      );
    });
    _scoreAnim = Tween<double>(begin: _scoreAnim.value, end: _fitResult.score)
        .animate(CurvedAnimation(parent: _scoreAnimCtrl, curve: Curves.easeOutCubic));
    _scoreAnimCtrl.reset();
    _scoreAnimCtrl.forward();
  }

  // ── HELPERS ────────────────────────────────────────────────────────────────
  Color _tensionColor(double t) {
    if (t < 0.3) return const Color(0xFF16A34A);
    if (t < 0.6) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String _deltaLabel(double delta) {
    if (delta.abs() < 0.5) return 'Parfait';
    return delta > 0 ? '+${delta.toStringAsFixed(1)} cm (ample)' : '${delta.toStringAsFixed(1)} cm (serré)';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarViewportCard(),
                    const SizedBox(height: 16),
                    _buildFitScoreCard(),
                    const SizedBox(height: 16),
                    _buildSmartAdvisoryCard(),
                    const SizedBox(height: 16),
                    _buildQuickSizeSelector(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
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
              child: Icon(Icons.chevron_left_rounded, size: 28, color: _navy),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Essayage Virtuel 3D',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w800, color: _navy, letterSpacing: -0.3,
                  ),
                ),
                Text(
                  _garment.productName,
                  style: GoogleFonts.inter(fontSize: 11, color: _slate),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Mode toggle: 3D 360° vs Porté Studio
          GestureDetector(
            onTap: () => setState(() => _showGarment = !_showGarment),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _showGarment ? const Color(0xFFEFF6FF) : _navy,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _showGarment ? const Color(0xFFBFDBFE) : _navy),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showGarment ? Icons.threed_rotation_rounded : Icons.checkroom_rounded,
                    size: 14,
                    color: _showGarment ? const Color(0xFF1D4ED8) : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showGarment ? 'Vue 3D 360°' : 'Rendu Porté Studio',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _showGarment ? const Color(0xFF1D4ED8) : Colors.white,
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

  Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.contain}) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (ctx, err, stack) => Image.asset(
          'assets/images/product_dress.jpg',
          fit: fit,
        ),
      );
    }
    return Image.asset(
      path,
      fit: fit,
      errorBuilder: (ctx, err, stack) => Image.asset(
        'assets/images/product_dress.jpg',
        fit: fit,
      ),
    );
  }

  // ── 3D AVATAR VIEWPORT ─────────────────────────────────────────────────────
  Widget _buildAvatarViewportCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 440,
        color: Colors.white,
        child: Stack(
          children: [
            // Avatar Viewport: Either 3D Interactive Model or Studio Try-On
            if (!_isLoading)
              Positioned.fill(
                child: _showGarment
                    ? Container(
                        color: Colors.white,
                        child: Center(
                          child: _showAfter
                              ? _buildImageWidget(_garment.productImagePath, fit: BoxFit.contain)
                              : ValueListenableBuilder<File?>(
                                  valueListenable: UserAvatarService.avatarNotifier,
                                  builder: (context, avatarFile, _) {
                                    if (avatarFile != null) {
                                      return Image.file(avatarFile, fit: BoxFit.contain);
                                    }
                                    return Image.asset(
                                      'assets/images/scan_front_pose.jpg',
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, stack) => const Center(
                                        child: Icon(Icons.person_outline_rounded, size: 140, color: Color(0xFF94A3B8)),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      )
                    : ModelViewer(
                        key: ValueKey('physics_avatar_$_avatarUrl'),
                        src: _avatarUrl,
                        alt: 'Avatar 3D ${widget.gender}',
                        autoRotate: false, // No auto-spinning
                        cameraControls: true,
                        backgroundColor: Colors.white,
                        cameraOrbit: '0deg 75deg 180%',
                        cameraTarget: 'auto auto auto',
                        fieldOfView: 'auto',
                        minCameraOrbit: 'auto auto 100%',
                        maxCameraOrbit: 'auto auto 300%',
                        shadowIntensity: 0.8,
                        exposure: 1.05,
                      ),
              ),

            // Top-Left Avant / Après Toggle Pill (Only in Studio Try-On Mode)
            if (!_isLoading && _showGarment)
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showAfter = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: !_showAfter ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Avant',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: !_showAfter ? _navy : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showAfter = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _showAfter ? _coral : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Porté',
                            style: GoogleFonts.inter(
                              fontSize: 10,
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

            // Floating Garment Try-On Badge
            if (!_isLoading)
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 36,
                          height: 48,
                          child: _garment.productImagePath.startsWith('http')
                              ? Image.network(_garment.productImagePath, fit: BoxFit.cover)
                              : Image.asset(
                                  _garment.productImagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => Image.asset(
                                    'assets/images/product_dress.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'PIÈCE ESSAYÉE',
                            style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w800, color: _coral),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: 120,
                            child: Text(
                              _garment.productName,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _navy),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Loading state (Luxury Studio Tripo 3D)
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 90, height: 90,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.5,
                              color: _coral,
                              backgroundColor: const Color(0xFFF1F5F9),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 58,
                              height: 58,
                              child: _garment.productImagePath.startsWith('http')
                                  ? Image.network(_garment.productImagePath, fit: BoxFit.cover)
                                  : Image.asset(
                                      _garment.productImagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Image.asset(
                                        'assets/images/product_dress.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        _loadingMessage,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: _navy,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Étape ${_loadingStage + 1} sur 3 • Moteur 3D Tripo',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: _slate,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Heatmap overlay (when enabled)
            if (!_isLoading && _showHeatmap)
              Positioned.fill(
                child: CustomPaint(
                  painter: _HeatmapOverlayPainter(fitResult: _fitResult),
                ),
              ),

            // Garment overlay badge
            if (!_isLoading && _showGarment)
              Positioned(
                top: 14, right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _garment.selectedColor.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: _garment.selectedColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_garment.selectedSize} • ${_garment.colorName}',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

            // Top left: realtime tag
            Positioned(
              top: 14, left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record, size: 8, color: _coral),
                    const SizedBox(width: 5),
                    Text(
                      'TEMPS RÉEL 60 FPS',
                      style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.4),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom: live stress card
            if (!_isLoading)
              Positioned(
                bottom: 12, left: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_graph_rounded, size: 15, color: _coral),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'AJUSTEMENT EN DIRECT • TAILLE $_currentSelectedSize',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: _slate, letterSpacing: 0.3),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ScaleTransition(
                            scale: _pulseAnim,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _fitResult.categoryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _fitResult.categoryLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 9, fontWeight: FontWeight.w800,
                                  color: _fitResult.categoryColor, letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildLiveMetric('Poitrine', _garment.selectedSize, _tensionColor(_fitResult.bustTension))),
                          const SizedBox(width: 6),
                          Expanded(child: _buildLiveMetric('Taille', _deltaLabel(widget.waistCm - 66), _tensionColor(_fitResult.waistTension))),
                          const SizedBox(width: 6),
                          Expanded(child: _buildLiveMetric('Hanches', _deltaLabel(widget.hipsCm - 94), _tensionColor(_fitResult.hipsTension))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Heatmap toggle button
            Positioned(
              top: 46, right: 14,
              child: GestureDetector(
                onTap: () => setState(() => _showHeatmap = !_showHeatmap),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _showHeatmap ? _coral : Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)],
                  ),
                  child: Icon(
                    Icons.thermostat_rounded, size: 18,
                    color: _showHeatmap ? Colors.white : _navy,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMetric(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9, color: _slate), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── FIT SCORE CARD ─────────────────────────────────────────────────────────
  Widget _buildFitScoreCard() {
    return AnimatedBuilder(
      animation: _scoreAnim,
      builder: (context, child) {
        final displayScore = _scoreAnim.value;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_navy, const Color(0xFF1E3A8A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: _navy.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              // Score ring
              SizedBox(
                width: 80, height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: CircularProgressIndicator(
                        value: displayScore / 100,
                        strokeWidth: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          displayScore >= 85 ? const Color(0xFF4ADE80)
                              : displayScore >= 60 ? const Color(0xFFFBBF24)
                              : _coral,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${displayScore.toInt()}%',
                          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        Text('FIT', style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.2)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_fitResult.categoryIcon, size: 16, color: _fitResult.categoryColor),
                        const SizedBox(width: 6),
                        Text(
                          _fitResult.categoryLabel,
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Taille ${_garment.selectedSize} recommandée pour vos mesures',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.75)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildBadge('${widget.heightCm.toInt()} cm', Icons.height_rounded),
                        _buildBadge('B ${widget.bustCm.toInt()}', Icons.straighten_rounded),
                        _buildBadge('T ${widget.waistCm.toInt()}', Icons.radio_button_unchecked_rounded),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(width: 3),
          Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }

  // ── SMART ADVISORY CARD ───────────────────────────────────────────────────
  Widget _buildSmartAdvisoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _fitResult.categoryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _fitResult.categoryIcon,
                  size: 18,
                  color: _fitResult.categoryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Conseil Morphologique Personnalisé",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    Text(
                      "Analyse basée sur vos mensurations réelles",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: _slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _fitResult.smartAdvisory,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.45,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK SIZE SELECTOR ────────────────────────────────────────────────────
  Widget _buildQuickSizeSelector() {
    const sizes = ['XS', 'S', 'M', 'L', 'XL'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Ajuster la Taille en Direct",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Taille Actuelle : $_currentSelectedSize",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: sizes.map((s) {
              final isSelected = s == _currentSelectedSize;
              final res = FitScoreEngine.calculate(
                size: s,
                bustCm: widget.bustCm,
                waistCm: widget.waistCm,
                hipsCm: widget.hipsCm,
              );
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => _changeSize(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _navy : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? _navy : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : _navy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${res.score.round()}%",
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white.withValues(alpha: 0.8) : _slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ACTION BAR ──────────────────────────────────────────────────────
  Widget _buildBottomBar() {
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
          // Primary: Add to cart with fit indicator
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _navy.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_rounded, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Confirmer Taille $_currentSelectedSize — ${_garment.price}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _fitResult.categoryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_fitResult.score.toInt()}%',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: _fitResult.categoryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Secondary: AR Mirror
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LiveArMirrorScreen(
                    product: ProductModel(
                      id: 'current_tryon',
                      name: _garment.productName,
                      brand: _garment.brandName,
                      category: 'Mode',
                      subCategory: 'Prêt-à-porter',
                      gender: widget.gender,
                      description: '',
                      price: double.tryParse(_garment.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 285.0,
                      isSale: false,
                      imageUrl: _garment.productImagePath,
                      galleryImages: [_garment.productImagePath],
                      availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
                      availableColors: [{'name': _garment.colorName, 'hex': '#172554'}],
                      recSize: _currentSelectedSize,
                      fitPercent: '${_fitResult.score.toInt()}%',
                      fabricComposition: '100% Soie',
                      silhouetteType: 'Ajustée',
                      careInstructions: '',
                      isFeatured: true,
                      isTrending: true,
                      isNewArrival: false,
                      triedCountText: '342 essayages',
                      badge: 'Premium',
                      badgeColor: '#F43F5E',
                      badgeBg: '#FFF1F2',
                      inStock: true,
                      stockQuantity: 12,
                      partnerStoreName: 'Boutique Paris Vendôme',
                      partnerStoreUrl: '',
                      storeReservationAvailable: true,
                    ),
                  ),
                ));
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _navy,
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flip_camera_android_rounded, size: 18, color: _navy),
                  const SizedBox(width: 8),
                  Text(
                    'Essayer dans le Miroir RA',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: _navy),
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

// ─────────────────────────────────────────────────────────────────────────────
// HEATMAP OVERLAY PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _HeatmapOverlayPainter extends CustomPainter {
  final FitResult fitResult;
  _HeatmapOverlayPainter({required this.fitResult});

  Color _zone(double t) {
    if (t < 0.3) return const Color(0x3316A34A);
    if (t < 0.6) return const Color(0x44D97706);
    return const Color(0x55DC2626);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawZone(Rect rect, double tension) {
      final paint = Paint()..color = _zone(tension);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      canvas.drawRRect(rRect, paint);
    }

    // Shoulder zone
    drawZone(Rect.fromLTWH(w * 0.15, h * 0.10, w * 0.70, h * 0.14), fitResult.shoulderTension);
    // Bust zone
    drawZone(Rect.fromLTWH(w * 0.18, h * 0.24, w * 0.64, h * 0.16), fitResult.bustTension);
    // Waist zone
    drawZone(Rect.fromLTWH(w * 0.22, h * 0.42, w * 0.56, h * 0.12), fitResult.waistTension);
    // Hips zone
    drawZone(Rect.fromLTWH(w * 0.16, h * 0.56, w * 0.68, h * 0.15), fitResult.hipsTension);
  }

  @override
  bool shouldRepaint(_HeatmapOverlayPainter old) =>
      old.fitResult.bustTension != fitResult.bustTension;
}
