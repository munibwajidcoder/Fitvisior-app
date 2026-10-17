import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../auth/data/auth_service.dart';
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
      if (val < min) return (min - val) / min; // too tight (negative margin)
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
  int    _selectedPreset  = 0; // 0 = Catwalk, 1 = Seated, 2 = Urban Walk
  int    _selectedSpeed   = 2; // 0=0.25x 1=0.5x 2=1.0x
  bool   _isPlaying       = true;
  double _timelineValue   = 0.56;
  bool   _showHeatmap     = false;
  bool   _showGarment     = true;
  bool   _isLoading       = true;

  late FitResult _fitResult;
  late AnimationController _scoreAnimCtrl;
  late Animation<double> _scoreAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  Timer? _simulationTimer;
  String? _profileAvatarUrl;
  String? _userGender;

  // Avatar GLB — use passed URL or user's saved profile avatar, with gender fallback
  String get _avatarUrl {
    final url = widget.avatarGlbUrl ?? _profileAvatarUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('asset://')) {
        return url.replaceFirst('asset://', '');
      }
      return url;
    }
    final g = (_userGender ?? widget.gender).trim().toLowerCase();
    final isFemale = g.contains('femme') || g.contains('female') || g == 'f';
    return isFemale
        ? 'assets/models/base_avatar_female.glb'
        : 'assets/models/base_avatar_male.glb';
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

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    // Calculate real fit score
    _fitResult = FitScoreEngine.calculate(
      size:    _garment.selectedSize,
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

    // Simulate loading then start animations
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _scoreAnimCtrl.forward();
    });

    // Advance timeline when playing
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _timelineValue = (_timelineValue + 0.002) % 1.0;
      });
    });
  }

  void _loadUserProfile() async {
    try {
      final profile = await AuthService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _profileAvatarUrl = profile['avatar_glb_url'] as String?;
          _userGender = profile['gender'] as String?;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scoreAnimCtrl.dispose();
    _pulseCtrl.dispose();
    _simulationTimer?.cancel();
    super.dispose();
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

  String get _speedLabel {
    switch (_selectedPreset) {
      case 0: return '1.2 m/s • Catwalk';
      case 1: return '0.3 m/s • Assis';
      case 2: return '0.9 m/s • Urbain';
      default: return '1.0 m/s';
    }
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
                    _buildTopStatusRow(),
                    const SizedBox(height: 12),
                    _buildAvatarViewportCard(),
                    const SizedBox(height: 16),
                    _buildFitScoreCard(),
                    const SizedBox(height: 16),
                    _buildTensionHeatmapCard(),
                    const SizedBox(height: 16),
                    _buildKinematicPresetsSection(),
                    const SizedBox(height: 16),
                    _buildTimelineCard(),
                    const SizedBox(height: 16),
                    _buildGarmentSpecsCard(),
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
          // Garment toggle
          GestureDetector(
            onTap: () => setState(() => _showGarment = !_showGarment),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _showGarment ? _navy : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checkroom_rounded, size: 14, color: _showGarment ? Colors.white : _slate),
                  const SizedBox(width: 4),
                  Text(
                    _showGarment ? 'Vêtement ON' : 'Vêtement OFF',
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w700,
                      color: _showGarment ? Colors.white : _slate,
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

  // ── TOP STATUS ROW ─────────────────────────────────────────────────────────
  Widget _buildTopStatusRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'MOTEUR PHYSIQUE HAVOK CLOTH V4.2',
                  style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: _slate, letterSpacing: 0.3),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, size: 12, color: _slate),
              const SizedBox(width: 4),
              Text(
                _garment.colorName,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _slate),
              ),
              const SizedBox(width: 6),
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: _garment.selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 3D AVATAR VIEWPORT ─────────────────────────────────────────────────────
  Widget _buildAvatarViewportCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 440,
        color: _navy,
        child: Stack(
          children: [
            // 3D Model Viewer — avatar
            if (!_isLoading)
              Positioned.fill(
                child: ModelViewer(
                  src: _avatarUrl,
                  alt: 'Avatar 3D ${widget.gender}',
                  autoRotate: _isPlaying,
                  autoRotateDelay: 0,
                  cameraControls: true,
                  backgroundColor: const Color.fromARGB(255, 15, 23, 42),
                  cameraOrbit: '0deg 75deg 180%',
                  cameraTarget: 'auto auto auto',
                  fieldOfView: 'auto',
                  minCameraOrbit: 'auto auto 100%',
                  maxCameraOrbit: 'auto auto 300%',
                ),
              ),

            // Loading state
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 48, height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: _coral,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement du Drapé 3D…',
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
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
                              'TÉLÉMÉTRIE EN DIRECT • $_speedLabel',
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
                          const SizedBox(width: 8),
                          Expanded(child: _buildLiveMetric('Taille', _deltaLabel(widget.waistCm - 66), _tensionColor(_fitResult.waistTension))),
                          const SizedBox(width: 8),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 9.5, color: _slate), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: valueColor), overflow: TextOverflow.ellipsis),
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
                    Row(
                      children: [
                        _buildBadge('${widget.heightCm.toInt()} cm', Icons.height_rounded),
                        const SizedBox(width: 6),
                        _buildBadge('B ${widget.bustCm.toInt()}', Icons.straighten_rounded),
                        const SizedBox(width: 6),
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

  // ── TENSION HEATMAP CARD ───────────────────────────────────────────────────
  Widget _buildTensionHeatmapCard() {
    return Container(
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
            children: [
              Expanded(
                child: Text(
                  'Carte de Tension par Zone',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: _navy),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'TOLÉRANCE SÉCURISÉE',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: _coral, letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTensionRow('Épaules & Col', _fitResult.shoulderTension, _deltaLabel(0.0)),
          const SizedBox(height: 10),
          _buildTensionRow('Poitrine (${widget.bustCm.toInt()} cm)', _fitResult.bustTension, _deltaLabel(widget.bustCm - 86)),
          const SizedBox(height: 10),
          _buildTensionRow('Taille (${widget.waistCm.toInt()} cm)', _fitResult.waistTension, _deltaLabel(widget.waistCm - 66)),
          const SizedBox(height: 10),
          _buildTensionRow('Hanches (${widget.hipsCm.toInt()} cm)', _fitResult.hipsTension, _deltaLabel(widget.hipsCm - 94)),
        ],
      ),
    );
  }

  Widget _buildTensionRow(String label, double tension, String deltaLabel) {
    final color = _tensionColor(tension);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: GoogleFonts.inter(fontSize: 11.5, color: _slate), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Text(
              deltaLabel,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            height: 7,
            child: LinearProgressIndicator(
              value: tension.clamp(0.01, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  // ── KINEMATIC PRESETS ──────────────────────────────────────────────────────
  Widget _buildKinematicPresetsSection() {
    final presets = [
      {'icon': Icons.directions_walk_rounded,  'title': 'Foulée Catwalk', 'sub': '1.2 m/s'},
      {'icon': Icons.chair_alt_rounded,        'title': 'Salon Assis',    'sub': 'Test pli'},
      {'icon': Icons.air_rounded,              'title': 'Marche Urbaine', 'sub': '0.9 m/s'},
      {'icon': Icons.directions_run_rounded,   'title': 'Course Légère',  'sub': '2.5 m/s'},
      {'icon': Icons.self_improvement_rounded, 'title': 'Position Debout','sub': 'Statique'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Préréglages Kinématiques',
                style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: _navy),
              ),
            ),
            Text(
              '${presets.length} Simulations',
              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: _slate),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedPreset == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedPreset = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _navy : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [BoxShadow(color: _navy.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(presets[index]['icon'] as IconData, size: 18,
                          color: isSelected ? _coral : _slate),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            presets[index]['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            presets[index]['sub'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: isSelected ? Colors.white.withValues(alpha: 0.7) : _slate,
                            ),
                          ),
                        ],
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

  // ── TIMELINE CARD ──────────────────────────────────────────────────────────
  Widget _buildTimelineCard() {
    final speeds = ['0.25×', '0.5×', '1.0×'];
    final totalSec = 180; // 3:00
    final currentSec = (_timelineValue * totalSec).toInt();
    final mm = currentSec ~/ 60;
    final ss = currentSec % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CHRONOLOGIE  ${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')} / 03:00',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: _slate, letterSpacing: 0.3),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(speeds.length, (i) {
                  final isSel = _selectedSpeed == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSpeed = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSel ? _navy : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(speeds[i], style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: isSel ? Colors.white : _slate)),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: _navy,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: _navy,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _timelineValue,
              onChanged: (val) => setState(() { _timelineValue = val; _isPlaying = false; }),
              onChangeEnd: (_) => setState(() => _isPlaying = true),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.skip_previous_rounded, size: 22, color: _navy), onPressed: () => setState(() => _timelineValue = 0.0)),
              IconButton(icon: Icon(Icons.fast_rewind_rounded, size: 22, color: _navy), onPressed: () => setState(() => _timelineValue = (_timelineValue - 0.1).clamp(0.0, 1.0))),
              GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(color: _navy, shape: BoxShape.circle),
                  child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 26, color: Colors.white),
                ),
              ),
              IconButton(icon: Icon(Icons.fast_forward_rounded, size: 22, color: _navy), onPressed: () => setState(() => _timelineValue = (_timelineValue + 0.1).clamp(0.0, 1.0))),
              IconButton(icon: Icon(Icons.skip_next_rounded, size: 22, color: _navy), onPressed: () => setState(() => _timelineValue = 1.0)),
            ],
          ),
        ],
      ),
    );
  }

  // ── GARMENT SPECS CARD ─────────────────────────────────────────────────────
  Widget _buildGarmentSpecsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caractéristiques du Tissu',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: _navy),
          ),
          const SizedBox(height: 12),
          _buildSpecRow('Composition', 'Soie 78% • Élasthanne 22%'),
          _buildSpecRow('Grammage', '280 GSM — Tissu Laine'),
          _buildSpecRow('Récupération Plissement', '99.4% Instantanée'),
          _buildSpecRow('Coefficient de Friction', '0.12 N — Sécurisé'),
          _buildSpecRow('Résistance à la Traction', '18.4 kPa / 60 kPa max'),
          _buildSpecRow('Solveur Physique', 'Havok Cloth V4.2 • 60 FPS'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 11.5, color: _slate), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: _navy)),
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
                      'Confirmer Taille ${_garment.selectedSize} — ${_garment.price}',
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
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiveArMirrorScreen()));
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
