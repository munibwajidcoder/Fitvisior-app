import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../data/product_service.dart';
import 'live_ar_mirror_screen.dart';
import 'checkout_screen.dart';
import '../../data/fashn_tryon_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL: Product info passed from ProductDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class GarmentTryOnData {
  final String productId;
  final String productName;
  final String brandName;
  final String price;
  final String selectedSize;
  final Color selectedColor;
  final String colorName;
  final String productImagePath;
  final String? glbUrl; // optional real 3D garment model
  final List<String> availableSizes;
  final List<Map<String, dynamic>> availableColors;

  const GarmentTryOnData({
    this.productId = '',
    required this.productName,
    required this.brandName,
    required this.price,
    required this.selectedSize,
    required this.selectedColor,
    required this.colorName,
    required this.productImagePath,
    this.glbUrl,
    this.availableSizes = const [],
    this.availableColors = const [],
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// FIT SCORE ENGINE
// ─────────────────────────────────────────────────────────────────────────────
class FitScoreEngine {
  // Female standard size ranges (cm)
  static const Map<String, Map<String, double>> _femaleSizeChart = {
    'XXS': {'bust_min': 74, 'bust_max': 78, 'waist_min': 56, 'waist_max': 60, 'hips_min': 80, 'hips_max': 84},
    'XS':  {'bust_min': 78, 'bust_max': 83, 'waist_min': 60, 'waist_max': 65, 'hips_min': 84, 'hips_max': 89},
    'S':   {'bust_min': 83, 'bust_max': 88, 'waist_min': 65, 'waist_max': 70, 'hips_min': 89, 'hips_max': 94},
    'M':   {'bust_min': 88, 'bust_max': 94, 'waist_min': 70, 'waist_max': 76, 'hips_min': 94, 'hips_max': 100},
    'L':   {'bust_min': 94, 'bust_max': 101, 'waist_min': 76, 'waist_max': 83, 'hips_min': 100, 'hips_max': 107},
    'XL':  {'bust_min': 101, 'bust_max': 109, 'waist_min': 83, 'waist_max': 91, 'hips_min': 107, 'hips_max': 115},
    '2XL': {'bust_min': 109, 'bust_max': 117, 'waist_min': 91, 'waist_max': 99, 'hips_min': 115, 'hips_max': 123},
    '3XL': {'bust_min': 117, 'bust_max': 125, 'waist_min': 99, 'waist_max': 107, 'hips_min': 123, 'hips_max': 131},
    // French women numeric (FR 32 - FR 48)
    '32':  {'bust_min': 76, 'bust_max': 80, 'waist_min': 58, 'waist_max': 62, 'hips_min': 82, 'hips_max': 86},
    '34':  {'bust_min': 80, 'bust_max': 84, 'waist_min': 62, 'waist_max': 66, 'hips_min': 86, 'hips_max': 90},
    '36':  {'bust_min': 84, 'bust_max': 88, 'waist_min': 66, 'waist_max': 70, 'hips_min': 90, 'hips_max': 94},
    '38':  {'bust_min': 88, 'bust_max': 92, 'waist_min': 70, 'waist_max': 74, 'hips_min': 94, 'hips_max': 98},
    '40':  {'bust_min': 92, 'bust_max': 96, 'waist_min': 74, 'waist_max': 78, 'hips_min': 98, 'hips_max': 102},
    '42':  {'bust_min': 96, 'bust_max': 102, 'waist_min': 78, 'waist_max': 84, 'hips_min': 102, 'hips_max': 108},
    '44':  {'bust_min': 102, 'bust_max': 108, 'waist_min': 84, 'waist_max': 90, 'hips_min': 108, 'hips_max': 114},
    '46':  {'bust_min': 108, 'bust_max': 114, 'waist_min': 90, 'waist_max': 96, 'hips_min': 114, 'hips_max': 120},
    '48':  {'bust_min': 114, 'bust_max': 120, 'waist_min': 96, 'waist_max': 102, 'hips_min': 120, 'hips_max': 126},
  };

  // Male / Unisex standard size ranges (cm)
  static const Map<String, Map<String, double>> _maleSizeChart = {
    'XS':  {'bust_min': 84, 'bust_max': 88, 'waist_min': 70, 'waist_max': 74, 'hips_min': 86, 'hips_max': 90},
    'S':   {'bust_min': 88, 'bust_max': 94, 'waist_min': 74, 'waist_max': 80, 'hips_min': 90, 'hips_max': 96},
    'M':   {'bust_min': 94, 'bust_max': 100, 'waist_min': 80, 'waist_max': 86, 'hips_min': 96, 'hips_max': 102},
    'L':   {'bust_min': 100, 'bust_max': 106, 'waist_min': 86, 'waist_max': 92, 'hips_min': 102, 'hips_max': 108},
    'XL':  {'bust_min': 106, 'bust_max': 114, 'waist_min': 92, 'waist_max': 100, 'hips_min': 108, 'hips_max': 116},
    '2XL': {'bust_min': 114, 'bust_max': 122, 'waist_min': 100, 'waist_max': 108, 'hips_min': 116, 'hips_max': 124},
    '3XL': {'bust_min': 122, 'bust_max': 130, 'waist_min': 108, 'waist_max': 116, 'hips_min': 124, 'hips_max': 132},
    // French men numeric (suits, blazers, coats, shirts: FR 44 - FR 60)
    '44':  {'bust_min': 88, 'bust_max': 92, 'waist_min': 74, 'waist_max': 78, 'hips_min': 90, 'hips_max': 94},
    '46':  {'bust_min': 92, 'bust_max': 96, 'waist_min': 78, 'waist_max': 82, 'hips_min': 94, 'hips_max': 98},
    '48':  {'bust_min': 96, 'bust_max': 100, 'waist_min': 82, 'waist_max': 86, 'hips_min': 98, 'hips_max': 102},
    '50':  {'bust_min': 100, 'bust_max': 104, 'waist_min': 86, 'waist_max': 90, 'hips_min': 102, 'hips_max': 106},
    '52':  {'bust_min': 104, 'bust_max': 108, 'waist_min': 90, 'waist_max': 95, 'hips_min': 106, 'hips_max': 110},
    '54':  {'bust_min': 108, 'bust_max': 114, 'waist_min': 95, 'waist_max': 101, 'hips_min': 110, 'hips_max': 116},
    '56':  {'bust_min': 114, 'bust_max': 120, 'waist_min': 101, 'waist_max': 107, 'hips_min': 116, 'hips_max': 122},
    '58':  {'bust_min': 120, 'bust_max': 126, 'waist_min': 107, 'waist_max': 113, 'hips_min': 122, 'hips_max': 128},
    '60':  {'bust_min': 126, 'bust_max': 132, 'waist_min': 113, 'waist_max': 119, 'hips_min': 128, 'hips_max': 134},
  };

  static Map<String, double> getBoundsForSize(String rawSize, {String gender = 'female'}) {
    final clean = rawSize.toUpperCase().trim();
    final isMale = gender.toLowerCase().contains('homme') || gender.toLowerCase().contains('male');
    final chart = isMale ? _maleSizeChart : _femaleSizeChart;

    if (chart.containsKey(clean)) return chart[clean]!;

    final digits = RegExp(r'\d+').firstMatch(clean)?.group(0);
    if (digits != null) {
      if (chart.containsKey(digits)) return chart[digits]!;
      if (_maleSizeChart.containsKey(digits)) return _maleSizeChart[digits]!;
      if (_femaleSizeChart.containsKey(digits)) return _femaleSizeChart[digits]!;
    }

    if (clean.contains('3XL') || clean.contains('XXXL')) return chart['3XL'] ?? _maleSizeChart['3XL']!;
    if (clean.contains('2XL') || clean.contains('XXL')) return chart['2XL'] ?? _maleSizeChart['2XL']!;
    if (clean.contains('XL')) return chart['XL'] ?? _maleSizeChart['XL']!;
    if (clean.contains('XS')) return chart['XS'] ?? _maleSizeChart['XS']!;
    if (clean.contains('S')) return chart['S'] ?? _maleSizeChart['S']!;
    if (clean.contains('L')) return chart['L'] ?? _maleSizeChart['L']!;

    return chart['M'] ?? _maleSizeChart['M']!;
  }

  static FitResult calculate({
    required String size,
    required double bustCm,
    required double waistCm,
    required double hipsCm,
    String gender = 'female',
  }) {
    final bounds = getBoundsForSize(size, gender: gender);
    final bMin = bounds['bust_min']!;
    final bMax = bounds['bust_max']!;
    final wMin = bounds['waist_min']!;
    final wMax = bounds['waist_max']!;
    final hMin = bounds['hips_min']!;
    final hMax = bounds['hips_max']!;

    // Deltas:
    // Positive delta = body exceeds garment max (tight / tension)
    // Negative delta = body is smaller than garment min (loose / ease)
    // 0 = within optimal tailored range (perfect)
    double calcDelta(double val, double min, double max) {
      if (val > max) return val - max;
      if (val < min) return val - min;
      return 0.0;
    }

    final bustDeltaCm  = calcDelta(bustCm, bMin, bMax);
    final waistDeltaCm = calcDelta(waistCm, wMin, wMax);
    final hipsDeltaCm  = calcDelta(hipsCm, hMin, hMax);

    // Weighted deviation in cm
    final totalDiff = bustDeltaCm.abs() * 0.40 + waistDeltaCm.abs() * 0.35 + hipsDeltaCm.abs() * 0.25;

    // Realistic production fit score
    double score;
    if (totalDiff == 0.0) {
      final bCenter = (bMin + bMax) / 2;
      final wCenter = (wMin + wMax) / 2;
      final hCenter = (hMin + hMax) / 2;
      final off = ((bustCm - bCenter).abs() / 4.0 + (waistCm - wCenter).abs() / 4.0 + (hipsCm - hCenter).abs() / 4.0);
      score = (99.0 - (off * 1.2)).clamp(95.0, 99.0);
    } else {
      score = (94.0 - (totalDiff * 4.2)).clamp(35.0, 93.0);
    }

    // Fit category
    FitCategory category;
    if (bustDeltaCm > 1.2 || waistDeltaCm > 1.2 || hipsDeltaCm > 1.2) {
      category = FitCategory.tight;
    } else if (bustDeltaCm < -1.8 || waistDeltaCm < -1.8 || hipsDeltaCm < -1.8) {
      category = FitCategory.loose;
    } else {
      category = FitCategory.perfect;
    }

    // Tension levels for heatmaps / indicators (0.0 to 1.0)
    final bustTension  = (bustDeltaCm.abs() / 6.0).clamp(0.0, 1.0);
    final waistTension = (waistDeltaCm.abs() / 6.0).clamp(0.0, 1.0);
    final hipsTension  = (hipsDeltaCm.abs() / 6.0).clamp(0.0, 1.0);
    final shoulderTension = ((bustDeltaCm.abs() * 0.6 + waistDeltaCm.abs() * 0.4) / 6.0).clamp(0.0, 1.0);

    return FitResult(
      score: score.roundToDouble(),
      category: category,
      bustTension: bustTension,
      waistTension: waistTension,
      hipsTension: hipsTension,
      shoulderTension: shoulderTension,
      bustDeltaCm: bustDeltaCm,
      waistDeltaCm: waistDeltaCm,
      hipsDeltaCm: hipsDeltaCm,
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
    final isEn = LanguageService.instance.isEnglish;
    switch (category) {
      case FitCategory.tight:   return isEn ? 'TIGHT' : 'SERRÉ';
      case FitCategory.perfect: return isEn ? 'PERFECT' : 'PARFAIT';
      case FitCategory.loose:   return isEn ? 'LOOSE' : 'AMPLE';
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
    final isEn = LanguageService.instance.isEnglish;
    switch (category) {
      case FitCategory.tight:
        String zone = isEn ? 'bust' : 'buste';
        double maxDelta = bustDeltaCm;
        if (waistDeltaCm > maxDelta) {
          maxDelta = waistDeltaCm;
          zone = isEn ? 'waist' : 'taille';
        }
        if (hipsDeltaCm > maxDelta) {
          maxDelta = hipsDeltaCm;
          zone = isEn ? 'hips' : 'hanches';
        }
        final dStr = maxDelta > 0.1 ? maxDelta.toStringAsFixed(1) : '2.0';
        return isEn
            ? "This size is too snug around your $zone (+$dStr cm tension). We recommend choosing one size up for optimal comfort and fluid drape."
            : "Cette taille est trop ajustée au niveau de votre $zone (+$dStr cm de tension). Nous vous recommandons de choisir la taille au-dessus pour un confort optimal et un tombé fluide.";
      case FitCategory.loose:
        String zone = isEn ? 'bust' : 'buste';
        double minDelta = bustDeltaCm;
        if (waistDeltaCm < minDelta) {
          minDelta = waistDeltaCm;
          zone = isEn ? 'waist' : 'taille';
        }
        if (hipsDeltaCm < minDelta) {
          minDelta = hipsDeltaCm;
          zone = isEn ? 'hips' : 'hanches';
        }
        final dStr = minDelta.abs() > 0.1 ? minDelta.abs().toStringAsFixed(1) : '2.5';
        return isEn
            ? "This size provides generous ease around your $zone (-$dStr cm). If you prefer a more tailored silhouette, choose one size down."
            : "Cette taille offre une aisance généreuse au niveau de votre $zone (-$dStr cm). Si vous préférez une silhouette plus cintrée, optez pour la taille en-dessous.";
      case FitCategory.perfect:
        return isEn
            ? "This size corresponds ideally to your actual measurements (${score.toInt()}% Fit). Perfect drape across bust, waist, and hips."
            : "Cette taille correspond idéalement à vos mensurations réelles (${score.toInt()}% d'ajustement). Coupe parfaite au buste, à la taille et aux hanches.";
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
  bool   _showGarment     = false; // Default directly to 3D Interactive Avatar View (360° Rotatable)
  bool   _is3DActive      = true;
  String _loadingMessage  = "Connexion au Moteur 3D Tripo...";

  // ── FASHN.ai (2D) + Tripo 3D Try-On State ────────────────────────────────
  String? _fashnTryOnUrl;
  String? _liveGeneratedGlbUrl;
  bool    _is2DLoading = false;
  bool    _is3DLoading = false;
  String? _fashnError;
  int     _fashnElapsedSeconds = 0;
  Timer?  _fashnTimer;

  Future<void> _triggerFashnTryOn() async {
    final pKey = _garment.productId.isNotEmpty
        ? _garment.productId
        : _garment.productName.toLowerCase().replaceAll(' ', '_');

    final g = widget.gender.toLowerCase();
    final isMale = g.contains('homme') || g.contains('male') || _garment.productName.toLowerCase().contains('homme');
    final fallbackGlb = isMale ? 'assets/models/avatar_blazer_tryon.glb' : 'assets/models/avatar_dressed.glb';

    // 1. Instant check: if already loaded in state or memory cache, restore in 0.01s!
    if (_fashnTryOnUrl != null && _liveGeneratedGlbUrl != null) {
      setState(() {
        _is2DLoading = false;
        _is3DLoading = false;
      });
      _fashnTimer?.cancel();
      UserAvatarService.setLatestTryOn(glbUrl: _liveGeneratedGlbUrl, imageUrl: _fashnTryOnUrl);
      return;
    }

    final cImg = FashnTryOnService.getCachedTryOn(pKey) ??
        FashnTryOnService.getCachedTryOn('${pKey}_${_garment.productImagePath}');
    final cGlb = FashnTryOnService.getCachedGlb(pKey) ??
        FashnTryOnService.getCachedGlb('${pKey}_${_garment.productImagePath}') ??
        UserAvatarService.latestTryOnGlbNotifier.value;

    if (cImg != null && cImg.isNotEmpty) {
      final effectiveGlb = (cGlb != null && cGlb.isNotEmpty) ? cGlb : fallbackGlb;
      setState(() {
        _fashnTryOnUrl = cImg;
        _liveGeneratedGlbUrl = effectiveGlb;
        _is2DLoading = false;
        _is3DLoading = false;
      });
      _fashnTimer?.cancel();
      UserAvatarService.setLatestTryOn(glbUrl: effectiveGlb, imageUrl: cImg);
      return;
    }

    if (_is2DLoading || _is3DLoading) return;
    setState(() {
      if (cImg != null) _fashnTryOnUrl = cImg;
      if (cGlb != null) _liveGeneratedGlbUrl = cGlb;
      _is2DLoading = _fashnTryOnUrl == null;
      _is3DLoading = _liveGeneratedGlbUrl == null;
      _fashnError = null;
      _fashnElapsedSeconds = 0;
    });

    if (!_is2DLoading && !_is3DLoading) {
      _fashnTimer?.cancel();
      UserAvatarService.setLatestTryOn(glbUrl: _liveGeneratedGlbUrl, imageUrl: _fashnTryOnUrl);
      return;
    }

    _fashnTimer?.cancel();
    _fashnTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _fashnElapsedSeconds++;
          // Safety cap: Never let timer run past 180s!
          if (_fashnElapsedSeconds >= 180) {
            _fashnTimer?.cancel();
            _is2DLoading = false;
            _is3DLoading = false;
            if (_liveGeneratedGlbUrl == null || _liveGeneratedGlbUrl!.isEmpty) {
              _liveGeneratedGlbUrl = fallbackGlb;
            }
          }
        });
      }
    });

    final avatarFile = UserAvatarService.avatarNotifier.value;
    try {
      final result = await FashnTryOnService.instance.executeTryOn(
        garmentImagePath: _garment.productImagePath,
        productId: pKey,
        userAvatarFile: avatarFile,
        userAvatarUrl: _profileAvatarUrl,
        category: _garment.productName,
        isMale: isMale,
        onProgress: (stageMsg) {
          if (mounted) {
            setState(() => _loadingMessage = stageMsg);
          }
        },
        onImageReady: (imageUrl) {
          if (mounted) {
            setState(() {
              _fashnTryOnUrl = imageUrl;
              _is2DLoading = false;
            });
            UserAvatarService.setLatestTryOn(imageUrl: imageUrl);
          }
        },
        onGlbReady: (glbUrl) {
          if (mounted) {
            setState(() {
              _liveGeneratedGlbUrl = glbUrl;
              _is3DLoading = false;
            });
            UserAvatarService.setLatestTryOn(glbUrl: glbUrl);
            _fashnTimer?.cancel();
          }
        },
      );

      if (!mounted) return;
      setState(() {
        _is2DLoading = false;
        _is3DLoading = false;
        if (result.isSuccess) {
          if (result.tryOnImageUrl != null) {
            _fashnTryOnUrl = result.tryOnImageUrl;
          }
          if (result.glbModelUrl != null && result.glbModelUrl!.isNotEmpty) {
            _liveGeneratedGlbUrl = result.glbModelUrl;
          } else {
            _liveGeneratedGlbUrl = fallbackGlb;
          }
          UserAvatarService.setLatestTryOn(glbUrl: _liveGeneratedGlbUrl, imageUrl: _fashnTryOnUrl);
        } else {
          _fashnError = result.errorMessage;
          _liveGeneratedGlbUrl ??= fallbackGlb;
        }
      });
    } finally {
      _fashnTimer?.cancel();
      if (mounted) {
        setState(() {
          _is2DLoading = false;
          _is3DLoading = false;
        });
      }
    }
  }

  late FitResult _fitResult;
  late AnimationController _scoreAnimCtrl;
  late Animation<double> _scoreAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  String? _profileAvatarUrl;

  // Live user biometric measurements (dynamically loaded from Supabase profile)
  late double _userBustCm;
  late double _userWaistCm;
  late double _userHipsCm;
  late double _userHeightCm;
  late String _userGender;

  // Avatar GLB — use live generated Tripo 3D model, garment dressed 3D model, latest tryon, or realistic dressed fallback
  String get _avatarUrl {
    if (_liveGeneratedGlbUrl != null && _liveGeneratedGlbUrl!.isNotEmpty) {
      if (_liveGeneratedGlbUrl!.startsWith('asset://')) return _liveGeneratedGlbUrl!.replaceFirst('asset://', '');
      return _liveGeneratedGlbUrl!;
    }
    final garmentGlb = _garment.glbUrl;
    if (garmentGlb != null && garmentGlb.isNotEmpty) {
      if (garmentGlb.startsWith('asset://')) return garmentGlb.replaceFirst('asset://', '');
      return garmentGlb;
    }
    final latestGlb = UserAvatarService.latestTryOnGlbNotifier.value;
    if (latestGlb != null && latestGlb.isNotEmpty) {
      if (latestGlb.startsWith('asset://')) return latestGlb.replaceFirst('asset://', '');
      return latestGlb;
    }
    if (widget.avatarGlbUrl != null && widget.avatarGlbUrl!.isNotEmpty) {
      return widget.avatarGlbUrl!;
    }
    final isMale = _userGender.toLowerCase().contains('homme') || _userGender.toLowerCase().contains('male');
    return isMale ? 'assets/models/avatar_blazer_tryon.glb' : 'assets/models/avatar_dressed.glb';
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

  List<String> get _effectiveAvailableSizes {
    if (_garment.availableSizes.isNotEmpty) {
      return _garment.availableSizes;
    }
    final raw = _garment.selectedSize.toUpperCase().trim();
    final hasDigits = RegExp(r'\d+').hasMatch(raw);
    if (hasDigits) {
      final isFr = raw.startsWith('FR');
      final isMale = _userGender.toLowerCase().contains('homme') || _userGender.toLowerCase().contains('male');
      if (isMale || raw.contains('48') || raw.contains('50') || raw.contains('52') || raw.contains('54') || raw.contains('56')) {
        final nums = ['46', '48', '50', '52', '54', '56'];
        return isFr ? nums.map((n) => 'FR $n').toList() : nums;
      } else {
        final nums = ['34', '36', '38', '40', '42', '44'];
        return isFr ? nums.map((n) => 'FR $n').toList() : nums;
      }
    }
    return const ['XS', 'S', 'M', 'L', 'XL', '2XL'];
  }

  String _getRecommendedSize() {
    final sizesToEvaluate = _effectiveAvailableSizes;
    if (sizesToEvaluate.isEmpty) return _currentSelectedSize;

    String bestSize = sizesToEvaluate.first;
    double bestScore = -1.0;

    for (final s in sizesToEvaluate) {
      final res = FitScoreEngine.calculate(
        size: s,
        bustCm: _userBustCm,
        waistCm: _userWaistCm,
        hipsCm: _userHipsCm,
        gender: _userGender,
      );
      if (res.score > bestScore) {
        bestScore = res.score;
        bestSize = s;
      }
    }
    return bestSize;
  }

  @override
  void initState() {
    super.initState();
    _currentSelectedSize = _garment.selectedSize;
    _userBustCm = widget.bustCm;
    _userWaistCm = widget.waistCm;
    _userHipsCm = widget.hipsCm;
    _userHeightCm = widget.heightCm;
    _userGender = widget.gender;

    // Check pre-cached try-on results immediately for instant restoration!
    final pKey = _garment.productId.isNotEmpty
        ? _garment.productId
        : _garment.productName.toLowerCase().replaceAll(' ', '_');
    final isMale = widget.gender.toLowerCase().contains('homme') || widget.gender.toLowerCase().contains('male');
    final fallbackGlb = isMale ? 'assets/models/avatar_blazer_tryon.glb' : 'assets/models/avatar_dressed.glb';

    final cImg = FashnTryOnService.getCachedTryOn(pKey) ??
        FashnTryOnService.getCachedTryOn('${pKey}_${_garment.productImagePath}');
    final cGlb = FashnTryOnService.getCachedGlb(pKey) ??
        FashnTryOnService.getCachedGlb('${pKey}_${_garment.productImagePath}') ??
        UserAvatarService.latestTryOnGlbNotifier.value;

    if (cImg != null && cImg.isNotEmpty) {
      _fashnTryOnUrl = cImg;
      _liveGeneratedGlbUrl = (cGlb != null && cGlb.isNotEmpty) ? cGlb : fallbackGlb;
      _is2DLoading = false;
      _is3DLoading = false;
    } else if (cGlb != null && cGlb.isNotEmpty) {
      _liveGeneratedGlbUrl = cGlb;
      _is3DLoading = false;
    }

    _loadUserProfile();
    _triggerFashnTryOn();
    _restoreDiskCache(pKey, isMale);

    // Calculate real dynamic fit score
    _fitResult = FitScoreEngine.calculate(
      size:    _currentSelectedSize,
      bustCm:  _userBustCm,
      waistCm: _userWaistCm,
      hipsCm:  _userHipsCm,
      gender:  _userGender,
    );

    // Score counter animation
    _scoreAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scoreAnim = Tween<double>(begin: 0, end: _fitResult.score)
        .animate(CurvedAnimation(parent: _scoreAnimCtrl, curve: Curves.easeOutCubic));
    _scoreAnimCtrl.forward();

    // Pulse animation for fit badge
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  void _loadUserProfile() async {
    try {
      final profile = await AuthService.getProfile();
      if (profile != null && mounted) {
        final double? b = (profile['bust_cm'] as num?)?.toDouble();
        final double? w = (profile['waist_cm'] as num?)?.toDouble();
        final double? h = (profile['hip_cm'] as num?)?.toDouble() ?? (profile['hips_cm'] as num?)?.toDouble();
        final double? ht = (profile['height_cm'] as num?)?.toDouble();
        final String? g = profile['gender'] as String?;

        setState(() {
          _profileAvatarUrl = profile['avatar_glb_url'] as String?;
          if (b != null && b > 40) _userBustCm = b;
          if (w != null && w > 30) _userWaistCm = w;
          if (h != null && h > 40) _userHipsCm = h;
          if (ht != null && ht > 50) _userHeightCm = ht;
          if (g != null && g.isNotEmpty) _userGender = g;

          _fitResult = FitScoreEngine.calculate(
            size:    _currentSelectedSize,
            bustCm:  _userBustCm,
            waistCm: _userWaistCm,
            hipsCm:  _userHipsCm,
            gender:  _userGender,
          );
        });

        _scoreAnim = Tween<double>(begin: _scoreAnim.value, end: _fitResult.score)
            .animate(CurvedAnimation(parent: _scoreAnimCtrl, curve: Curves.easeOutCubic));
        _scoreAnimCtrl.forward(from: 0);
      }
      await UserAvatarService.loadSavedAvatar();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _restoreDiskCache(String pKey, bool isMale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final diskImg = prefs.getString('tryon_img_$pKey') ?? prefs.getString('tryon_img_${pKey}_${_garment.productImagePath}');
      final diskGlb = prefs.getString('tryon_glb_$pKey') ?? prefs.getString('tryon_glb_${pKey}_${_garment.productImagePath}');
      if (diskImg != null && diskImg.isNotEmpty && mounted) {
        final effGlb = (diskGlb != null && diskGlb.isNotEmpty)
            ? diskGlb
            : (isMale ? 'assets/models/avatar_blazer_tryon.glb' : 'assets/models/avatar_dressed.glb');
        setState(() {
          _fashnTryOnUrl = diskImg;
          _liveGeneratedGlbUrl = effGlb;
          _is2DLoading = false;
          _is3DLoading = false;
        });
        _fashnTimer?.cancel();
        UserAvatarService.setLatestTryOn(glbUrl: effGlb, imageUrl: diskImg);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _fashnTimer?.cancel();
    _scoreAnimCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _changeSize(String newSize) {
    if (_currentSelectedSize == newSize) return;
    setState(() {
      _currentSelectedSize = newSize;
      _fitResult = FitScoreEngine.calculate(
        size:    newSize,
        bustCm:  _userBustCm,
        waistCm: _userWaistCm,
        hipsCm:  _userHipsCm,
        gender:  _userGender,
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
    final isEn = LanguageService.instance.isEnglish;
    if (delta.abs() < 0.6) return isEn ? 'Perfect' : 'Parfait';
    if (delta > 0) {
      return isEn ? '+${delta.toStringAsFixed(1)} cm (tight)' : '+${delta.toStringAsFixed(1)} cm (serré)';
    }
    return isEn ? '${delta.toStringAsFixed(1)} cm (loose)' : '${delta.toStringAsFixed(1)} cm (ample)';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
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
                    // ── SEGMENTED VIEW SWITCHER ──────────────────────────────
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!_showGarment) {
                                  setState(() => _showGarment = true);
                                  if (_fashnTryOnUrl == null && !_is2DLoading) {
                                    _triggerFashnTryOn();
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _showGarment ? const Color(0xFFF43F5E) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 16,
                                      color: _showGarment ? Colors.white : const Color(0xFF172554),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isEn ? "AI Worn Try-On" : "Essayage IA (Porté)",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: _showGarment ? Colors.white : const Color(0xFF172554),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (_showGarment) {
                                  setState(() => _showGarment = false);
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_showGarment ? const Color(0xFF172554) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.threed_rotation_rounded,
                                      size: 16,
                                      color: !_showGarment ? Colors.white : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isEn ? "3D Avatar View" : "Vue Avatar 3D",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: !_showGarment ? Colors.white : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildAvatarViewportCard(),
                    const SizedBox(height: 12),
                    _buildLiveFitCard(isEn),
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
    final isEn = LanguageService.instance.isEnglish;
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
                  isEn ? '3D Virtual Try-On' : 'Essayage Virtuel 3D',
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
                    _showGarment
                        ? (isEn ? '360° 3D View' : 'Vue 3D 360°')
                        : (isEn ? 'Studio Worn Render' : 'Rendu Porté Studio'),
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

  Widget _buildFashnLoadingView(bool isEn) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
            ),
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Color(0xFFF43F5E),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Timer pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF172554),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF172554).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  isEn ? "Elapsed: ${_fashnElapsedSeconds}s" : "Temps écoulé : ${_fashnElapsedSeconds}s",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEn ? "AI Fitting with FASHN.ai..." : "Essayage IA avec FASHN.ai...",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? "Draping ${_garment.productName} realistically onto your body silhouette..."
                : "Ajustement réaliste de ${_garment.productName} sur votre silhouette...",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _slate,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _build3DGenerationLoadingView(bool isEn) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF172554).withValues(alpha: 0.08),
            ),
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFF172554),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF172554),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF172554).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.threed_rotation_rounded, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  isEn ? "Tripo 3D Reconstruction: ${_fashnElapsedSeconds}s" : "Reconstruction 3D Tripo : ${_fashnElapsedSeconds}s",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _loadingMessage.isNotEmpty
                ? _loadingMessage
                : (isEn ? "Generative 3D Avatar Try-On..." : "Essayage Avatar 3D Génératif..."),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? "Draping ${_garment.productName} and reconstructing 360° volumetric mesh..."
                : "Ajustement de ${_garment.productName} et reconstruction du maillage 3D 360°...",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _slate,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFashnErrorView(bool isEn) {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded, size: 36, color: Color(0xFFD97706)),
          const SizedBox(height: 10),
          Text(
            isEn ? "AI Try-On Notice" : "Information Essayage IA",
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: _navy),
          ),
          const SizedBox(height: 4),
          Text(
            _fashnError ?? (isEn ? "Could not drape garment" : "Impossible d'ajuster le vêtement"),
            style: GoogleFonts.inter(fontSize: 11, color: _slate),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _triggerFashnTryOn(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(isEn ? "Retry Try-On" : "Réessayer", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFF43F5E)),
          ),
        ],
      ),
    );
  }

  // ── 3D AVATAR VIEWPORT ─────────────────────────────────────────────────────
  Widget _buildAvatarViewportCard() {
    final isEn = LanguageService.instance.isEnglish;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 440,
        color: Colors.white,
        child: Stack(
          children: [
            // Avatar Viewport: Either 3D Interactive Model or Studio Try-On
            Positioned.fill(
              child: _showGarment
                  ? Container(
                      color: Colors.white,
                      child: Center(
                        child: _fashnTryOnUrl != null
                            ? Image.network(
                                _fashnTryOnUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (ctx, err, stack) =>
                                    _buildImageWidget(_garment.productImagePath, fit: BoxFit.contain),
                              )
                            : (_is2DLoading
                                ? _buildFashnLoadingView(isEn)
                                : (_fashnError != null
                                    ? _buildFashnErrorView(isEn)
                                    : _buildImageWidget(_garment.productImagePath, fit: BoxFit.contain))),
                      ),
                    )
                  : (!_is3DActive
                      ? Container(
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF43F5E),
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : (_is3DLoading && _liveGeneratedGlbUrl == null)
                          ? _build3DGenerationLoadingView(isEn)
                          : (_avatarUrl.isNotEmpty)
                              ? ModelViewer(
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
                                )
                              : (_fashnError != null && !_is3DLoading && !_is2DLoading
                                  ? _buildFashnErrorView(isEn)
                                  : _build3DGenerationLoadingView(isEn))),
            ),
          ],
        ),
      ),
    );
  }

  // ── LIVE FIT SIZE CARD (Positioned Cleanly Below Viewport Container) ────────
  Widget _buildLiveFitCard(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, size: 15, color: _coral),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isEn ? 'LIVE FIT • SIZE $_currentSelectedSize' : 'AJUSTEMENT EN DIRECT • TAILLE $_currentSelectedSize',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: _navy, letterSpacing: 0.3),
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
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: _fitResult.categoryColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildLiveMetric(
                  isEn ? 'Chest' : 'Poitrine',
                  _deltaLabel(_fitResult.bustDeltaCm),
                  _tensionColor(_fitResult.bustTension),
                  subtext: '${_userBustCm.toInt()} cm',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLiveMetric(
                  isEn ? 'Waist' : 'Taille',
                  _deltaLabel(_fitResult.waistDeltaCm),
                  _tensionColor(_fitResult.waistTension),
                  subtext: '${_userWaistCm.toInt()} cm',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLiveMetric(
                  isEn ? 'Hips' : 'Hanches',
                  _deltaLabel(_fitResult.hipsDeltaCm),
                  _tensionColor(_fitResult.hipsTension),
                  subtext: '${_userHipsCm.toInt()} cm',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMetric(String label, String value, Color valueColor, {String? subtext}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 9.5, color: _slate, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtext != null)
                Text(
                  subtext,
                  style: GoogleFonts.inter(fontSize: 8.5, color: _slate.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 3),
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
    final isEn = LanguageService.instance.isEnglish;
    final recSize = _getRecommendedSize();
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
                        value: (displayScore / 100).clamp(0.0, 1.0),
                        strokeWidth: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          displayScore >= 88 ? const Color(0xFF4ADE80)
                              : displayScore >= 65 ? const Color(0xFFFBBF24)
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
                      isEn
                          ? (_currentSelectedSize == recSize
                              ? 'Size $recSize is recommended for your measurements'
                              : 'Size $recSize recommended (Selected: $_currentSelectedSize)')
                          : (_currentSelectedSize == recSize
                              ? 'Taille $recSize recommandée pour vos mesures'
                              : 'Taille $recSize recommandée (Sélection : $_currentSelectedSize)'),
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildBadge('${_userHeightCm.toInt()} cm', Icons.height_rounded),
                        _buildBadge('B ${_userBustCm.toInt()}', Icons.straighten_rounded),
                        _buildBadge('T ${_userWaistCm.toInt()}', Icons.radio_button_unchecked_rounded),
                        _buildBadge('H ${_userHipsCm.toInt()}', Icons.accessibility_new_rounded),
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
    final isEn = LanguageService.instance.isEnglish;
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
                      isEn ? "Personalized Morphological Advice" : "Conseil Morphologique Personnalisé",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    Text(
                      isEn ? "Analysis based on your real measurements" : "Analyse basée sur vos mensurations réelles",
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
    final isEn = LanguageService.instance.isEnglish;
    final sizes = _effectiveAvailableSizes;
    final recSize = _getRecommendedSize();
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
                  isEn ? "Adjust Size Live" : "Ajuster la Taille en Direct",
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
                isEn ? "Current: $_currentSelectedSize" : "Sélection : $_currentSelectedSize",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _coral,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: sizes.map((s) {
                final isSelected = s == _currentSelectedSize;
                final isRec = s == recSize;
                final res = FitScoreEngine.calculate(
                  size: s,
                  bustCm: _userBustCm,
                  waistCm: _userWaistCm,
                  hipsCm: _userHipsCm,
                  gender: _userGender,
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _changeSize(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      constraints: const BoxConstraints(minWidth: 54),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _navy : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? _navy : (isRec ? _coral : const Color(0xFFE2E8F0)),
                          width: isSelected ? 1.5 : (isRec ? 1.2 : 1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
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
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : (res.score >= 90 ? const Color(0xFF16A34A) : _slate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ACTION BAR ──────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isEn = LanguageService.instance.isEnglish;
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
                      isEn
                          ? 'Confirm Size $_currentSelectedSize — ${_garment.price}'
                          : 'Confirmer Taille $_currentSelectedSize — ${_garment.price}',
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
              onPressed: () async {
                final nav = Navigator.of(context);
                setState(() => _is3DActive = false);
                await Future.delayed(const Duration(milliseconds: 100));
                if (!mounted) return;
                await nav.push(MaterialPageRoute(
                  builder: (_) => LiveArMirrorScreen(
                    tryOnGlbUrl: _liveGeneratedGlbUrl ?? _garment.glbUrl ?? UserAvatarService.latestTryOnGlbNotifier.value,
                    tryOnImageUrl: _fashnTryOnUrl ?? UserAvatarService.latestTryOnImageNotifier.value,
                    product: ProductModel(
                      id: _garment.productId.isNotEmpty ? _garment.productId : 'current_tryon',
                      name: _garment.productName,
                      brand: _garment.brandName,
                      category: 'Mode',
                      subCategory: 'Prêt-à-porter',
                      gender: _userGender,
                      description: '',
                      price: double.tryParse(_garment.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 285.0,
                      isSale: false,
                      imageUrl: _fashnTryOnUrl ?? _garment.productImagePath,
                      galleryImages: [_garment.productImagePath],
                      glbModelUrl: _liveGeneratedGlbUrl ?? _garment.glbUrl ?? UserAvatarService.latestTryOnGlbNotifier.value,
                      availableSizes: _effectiveAvailableSizes,
                      availableColors: _garment.availableColors.isNotEmpty
                          ? _garment.availableColors
                          : [{'name': _garment.colorName, 'hex': '#172554'}],
                      recSize: _getRecommendedSize(),
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
                if (mounted) setState(() => _is3DActive = true);
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
                    isEn ? 'Try in AR Mirror' : 'Essayer dans le Miroir RA',
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
