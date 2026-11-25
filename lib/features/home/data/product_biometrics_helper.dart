import '../../../core/localization/language_service.dart';
import '../presentation/screens/physics_drape_screen.dart';

/// Dynamic Biometrics Calculator for FitVisor Luxury Atelier
/// Computes unique, realistic tailoring metrics for every product
class ProductBiometricData {
  final double scoreValue;
  final String matchScore;
  final String matchSubtitle;
  final String waistVal;
  final String waistDesc;
  final String fitVal;
  final String fitDesc;
  final String fabricVal;
  final String fabricDesc;
  final String versatilityVal;
  final String versatilityDesc;
  final String tensionInfo;
  final double strainVal;
  final String silhouetteAccent;

  const ProductBiometricData({
    required this.scoreValue,
    required this.matchScore,
    required this.matchSubtitle,
    required this.waistVal,
    required this.waistDesc,
    required this.fitVal,
    required this.fitDesc,
    required this.fabricVal,
    required this.fabricDesc,
    required this.versatilityVal,
    required this.versatilityDesc,
    required this.tensionInfo,
    required this.strainVal,
    required this.silhouetteAccent,
  });
}

class ProductBiometricsHelper {
  /// Compute realistic, distinct biometric measurements for any product
  static ProductBiometricData calculate({
    required String id,
    required String name,
    required String brand,
    required String category,
    required String size,
    required String fabric,
    required String fitPercentStr,
    String? silhouetteType,
    double price = 0,
    double? userBust,
    double? userWaist,
    double? userHips,
    String? userGender,
  }) {
    final isEnglish = LanguageService.instance.isEnglish;
    final seed = (id.hashCode ^ name.hashCode).abs();

    final catLower = category.toLowerCase();
    final nameLower = name.toLowerCase();
    final fabLower = fabric.toLowerCase();

    // 1. Live Fit Score Calculation via FitScoreEngine
    final double clampedScore;
    final String subtitle;
    final String tensionInfo;
    final double strainVal;

    if (userBust != null && userWaist != null && userHips != null && userBust > 0 && userWaist > 0 && userHips > 0) {
      final fit = FitScoreEngine.calculate(
        size: size,
        bustCm: userBust,
        waistCm: userWaist,
        hipsCm: userHips,
        gender: userGender ?? 'female',
      );
      clampedScore = fit.score.clamp(35.0, 99.4);

      if (fit.category == FitCategory.perfect) {
        subtitle = isEnglish ? 'Bespoke Fit' : 'Ajustement Sur-Mesure';
        tensionInfo = isEnglish ? '0.0 cm Tension (Fluid)' : '0,0 cm Tension (Fluide)';
        strainVal = 0.12 + (seed % 6) / 100.0;
      } else if (fit.category == FitCategory.tight) {
        if (fit.waistDeltaCm >= fit.bustDeltaCm && fit.waistDeltaCm >= fit.hipsDeltaCm && fit.waistDeltaCm > 0) {
          subtitle = isEnglish ? 'Waist Cinched Tension' : 'Tension Taille Cintrée';
          final t = fit.waistDeltaCm;
          tensionInfo = isEnglish
              ? '+${t.toStringAsFixed(1)} cm Waist Tension'
              : '+${t.toStringAsFixed(1).replaceAll('.', ',')} cm Tension Taille';
        } else if (fit.bustDeltaCm >= fit.hipsDeltaCm && fit.bustDeltaCm > 0) {
          subtitle = isEnglish ? 'Slight Bust Tension' : 'Légère tension poitrine';
          final t = fit.bustDeltaCm;
          tensionInfo = isEnglish
              ? '+${t.toStringAsFixed(1)} cm Bust Resistance'
              : '+${t.toStringAsFixed(1).replaceAll('.', ',')} cm Résistance Poitrine';
        } else {
          subtitle = isEnglish ? 'Fitted Snug Drape' : 'Tombé Ajusté Près du Corps';
          final t = fit.hipsDeltaCm.abs();
          tensionInfo = isEnglish
              ? '+${t.toStringAsFixed(1)} cm Hip Tension'
              : '+${t.toStringAsFixed(1).replaceAll('.', ',')} cm Tension Hanches';
        }
        strainVal = ((fit.bustTension * 0.4 + fit.waistTension * 0.4 + fit.hipsTension * 0.2)).clamp(0.20, 0.90);
      } else {
        // Loose
        subtitle = isEnglish ? 'Relaxed Comfort Fit' : 'Ajustement Fluide Confort';
        final ease = ((fit.waistDeltaCm.abs() + fit.bustDeltaCm.abs()) / 2.0).clamp(0.5, 6.0);
        tensionInfo = isEnglish
            ? '-${ease.toStringAsFixed(1)} cm Ease (Comfort)'
            : '-${ease.toStringAsFixed(1).replaceAll('.', ',')} cm Aisance Confort';
        strainVal = 0.18 + (seed % 8) / 100.0;
      }
    } else {
      // Fallback if user biometrics not available yet
      final cleanFit = fitPercentStr.replaceAll(RegExp(r'[^0-9.]'), '');
      final score = double.tryParse(cleanFit) ?? (94.0 + (seed % 50) / 10.0);
      clampedScore = score.clamp(88.0, 99.4);

      if (clampedScore >= 98.0) {
        subtitle = isEnglish ? 'Bespoke Fit' : 'Ajustement Sur-Mesure';
      } else if (clampedScore >= 95.0) {
        subtitle = isEnglish ? 'High Fidelity Drape' : 'Tombé Haute Fidélité';
      } else if (clampedScore >= 92.0) {
        subtitle = isEnglish ? 'Slight Bust Ease' : 'Légère aisance poitrine';
      } else {
        subtitle = isEnglish ? 'Recommended Fit' : 'Ajustement Recommandé';
      }

      if (clampedScore >= 97.5) {
        tensionInfo = isEnglish ? '0.0 cm Tension (Fluid)' : '0,0 cm Tension (Fluide)';
        strainVal = 0.10 + (seed % 8) / 100.0;
      } else if (clampedScore >= 95.0) {
        final t = 0.2 + (seed % 4) / 10.0;
        tensionInfo = isEnglish ? '${t.toStringAsFixed(1)} cm Natural Stretch' : '${t.toStringAsFixed(1).replaceAll('.', ',')} cm Stretch Naturel';
        strainVal = 0.22 + (seed % 10) / 100.0;
      } else if (clampedScore >= 92.0) {
        final t = 0.8 + (seed % 6) / 10.0;
        tensionInfo = isEnglish ? '+${t.toStringAsFixed(1)} cm Bust Resistance' : '+${t.toStringAsFixed(1).replaceAll('.', ',')} cm Résistance Poitrine';
        strainVal = 0.45 + (seed % 15) / 100.0;
      } else {
        final t = 1.4 + (seed % 8) / 10.0;
        tensionInfo = isEnglish ? '+${t.toStringAsFixed(1)} cm Firm Hold' : '+${t.toStringAsFixed(1).replaceAll('.', ',')} cm Maintien Ferme';
        strainVal = 0.70 + (seed % 15) / 100.0;
      }
    }

    // 2. Garment Waist Measurement (Tour de Taille)
    String waistVal;
    String waistDesc;
    final bounds = FitScoreEngine.getBoundsForSize(size, gender: userGender ?? 'female');
    final gWaistMin = bounds['waist_min']!;
    final gWaistMax = bounds['waist_max']!;
    final garmentWaist = (gWaistMin + gWaistMax) / 2.0;

    if (catLower.contains('pantalon') || catLower.contains('jean')) {
      waistVal = isEnglish ? '${garmentWaist.toStringAsFixed(1)} cm' : '${garmentWaist.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = isEnglish ? 'Sculpted High Waist' : 'Taille Haute Sculptée';
    } else if (catLower.contains('robe') || nameLower.contains('robe') || nameLower.contains('dress')) {
      waistVal = isEnglish ? '${garmentWaist.toStringAsFixed(1)} cm' : '${garmentWaist.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = isEnglish ? 'Anatomical Cinched' : 'Cintrage Anatomique';
    } else if (catLower.contains('blazer') || catLower.contains('veste') || nameLower.contains('blazer')) {
      waistVal = isEnglish ? '${garmentWaist.toStringAsFixed(1)} cm' : '${garmentWaist.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = isEnglish ? 'Hourglass Accent' : 'Sablier Accentué';
    } else if (catLower.contains('manteau') || nameLower.contains('manteau') || nameLower.contains('coat')) {
      waistVal = isEnglish ? '${garmentWaist.toStringAsFixed(1)} cm' : '${garmentWaist.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = isEnglish ? 'Double Coat Ease' : 'Aisance Manteau Double';
    } else {
      waistVal = isEnglish ? '${garmentWaist.toStringAsFixed(1)} cm' : '${garmentWaist.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = isEnglish ? 'Fluid Natural Cut' : 'Coupe Fluide Naturelle';
    }

    // 3. Fit / Length (Tombé & Longueur)
    String fitVal;
    String fitDesc;
    if (catLower.contains('robe') || nameLower.contains('robe') || nameLower.contains('dress')) {
      if (nameLower.contains('maxi') || nameLower.contains('longue')) {
        fitVal = isEnglish ? '132.0 cm' : '132,0 cm';
        fitDesc = isEnglish ? 'Floor / Opera Length' : 'Longueur Opéra / Sol';
      } else if (nameLower.contains('mini') || nameLower.contains('courte')) {
        fitVal = isEnglish ? '88.0 cm' : '88,0 cm';
        fitDesc = isEnglish ? 'Above-the-Knee Finish' : 'Finition Au-dessus du Genou';
      } else {
        final length = 104.0 + (seed % 120) / 10.0;
        fitVal = isEnglish ? '${length.toStringAsFixed(1)} cm' : '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
        fitDesc = isEnglish ? 'Draped Mid-Calf Finish' : 'Finition Mi-Mollet Drapée';
      }
    } else if (catLower.contains('pantalon') || catLower.contains('jean')) {
      final length = 101.0 + (seed % 60) / 10.0;
      fitVal = isEnglish ? '${length.toStringAsFixed(1)} cm' : '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = isEnglish ? 'Inseam 82 cm (7cm Heel)' : 'Entrejambe 82 cm (Talon 7cm)';
    } else if (catLower.contains('blazer') || catLower.contains('veste') || nameLower.contains('blazer')) {
      final length = 66.0 + (seed % 70) / 10.0;
      fitVal = isEnglish ? '${length.toStringAsFixed(1)} cm' : '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = isEnglish ? 'High-Hip Finish' : 'Finition Haut des Hanches';
    } else if (catLower.contains('manteau')) {
      final length = 115.0 + (seed % 100) / 10.0;
      fitVal = isEnglish ? '${length.toStringAsFixed(1)} cm' : '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = isEnglish ? 'Calf Length Drape' : 'Tombé Longueur Mollet';
    } else {
      final length = 58.0 + (seed % 60) / 10.0;
      fitVal = isEnglish ? '${length.toStringAsFixed(1)} cm' : '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = isEnglish ? 'Fitted Pelvis Cut' : 'Coupe Bassin Ajustée';
    }

    // 4. Fabric Density (Grammage du Tissu)
    String fabricVal;
    String fabricDesc = fabric.isNotEmpty ? fabric : (isEnglish ? 'Noble Fabric' : 'Matière Noble');
    if (fabLower.contains('soie') || fabLower.contains('silk')) {
      final weight = 160 + (seed % 40);
      fabricVal = '$weight g/m²';
      fabricDesc = isEnglish ? 'Silk & Fluid Crepe' : 'Soie & Crêpe Fluide';
    } else if (fabLower.contains('cachemire') || fabLower.contains('cashmere')) {
      final weight = 210 + (seed % 50);
      fabricVal = '$weight g/m²';
      fabricDesc = isEnglish ? 'Pure Cashmere (Soft)' : 'Cachemire Pur (Doux)';
    } else if (fabLower.contains('tweed')) {
      final weight = 320 + (seed % 60);
      fabricVal = '$weight g/m²';
      fabricDesc = isEnglish ? 'Hand-Woven Tweed (Rigid 4/5)' : 'Tweed Tissé Main (Rigide 4/5)';
    } else if (fabLower.contains('laine') || fabLower.contains('wool')) {
      final weight = 270 + (seed % 50);
      fabricVal = '$weight g/m²';
      fabricDesc = isEnglish ? 'Combed Virgin Wool' : 'Laine Vierge Peignée';
    } else if (fabLower.contains('lin') || fabLower.contains('linen')) {
      final weight = 230 + (seed % 30);
      fabricVal = '$weight g/m²';
      fabricDesc = isEnglish ? 'Breathable Textured Linen' : 'Lin Texturé Respirant';
    } else if (catLower.contains('manteau')) {
      final weight = 420 + (seed % 80);
      fabricVal = '$weight g/m²';
      fabricDesc = isEnglish ? 'Heavy Wool Fabric' : 'Drap de Laine Lourd';
    } else {
      final weight = 240 + (seed % 60);
      fabricVal = '$weight g/m²';
      fabricDesc = fabric.isNotEmpty ? fabric : (isEnglish ? 'Structured Material' : 'Matière Structurée');
    }

    // 5. Dynamic Non-Duplicate Versatility (Score de Polyvalence)
    final double baseVers;
    if (catLower.contains('blazer') || catLower.contains('veste') || nameLower.contains('blazer')) {
      baseVers = 9.5 + (seed % 4) / 10.0; // 9.5 to 9.8
    } else if (catLower.contains('pantalon') || catLower.contains('jean')) {
      baseVers = 9.1 + (seed % 4) / 10.0; // 9.1 to 9.4
    } else if (catLower.contains('manteau') || nameLower.contains('coat')) {
      baseVers = 9.3 + (seed % 4) / 10.0; // 9.3 to 9.6
    } else if (catLower.contains('robe') || nameLower.contains('dress')) {
      baseVers = 8.6 + (seed % 5) / 10.0; // 8.6 to 9.0
    } else {
      baseVers = 8.9 + (seed % 6) / 10.0; // 8.9 to 9.4
    }
    final versatilityVal = baseVers.toStringAsFixed(1);
    final String versatilityDesc;
    if (baseVers >= 9.5) {
      versatilityDesc = isEnglish ? 'Day to Night • Capsule' : 'Jour au Soir • Capsule';
    } else if (baseVers >= 9.2) {
      versatilityDesc = isEnglish ? 'Business & Cocktail' : 'Business & Cocktail';
    } else if (baseVers >= 8.9) {
      versatilityDesc = isEnglish ? 'Timeless Chic' : 'Chic Intemporel';
    } else {
      versatilityDesc = isEnglish ? 'Special Occasion' : 'Occasion Spéciale';
    }

    // 6. Silhouette Accent
    final String silhouetteAccent;
    if (catLower.contains('robe') || nameLower.contains('dress')) {
      silhouetteAccent = isEnglish ? 'Hourglass & Drape' : 'Sablier & Drapé';
    } else if (catLower.contains('blazer') || nameLower.contains('blazer')) {
      silhouetteAccent = isEnglish ? 'Structured Cinched' : 'Cintrée Structurée';
    } else if (catLower.contains('pantalon')) {
      silhouetteAccent = isEnglish ? 'Tapered Column' : 'Colonne Fuselée';
    } else {
      silhouetteAccent = isEnglish ? 'Balanced Fluid' : 'Fluide Équilibrée';
    }

    return ProductBiometricData(
      scoreValue: clampedScore,
      matchScore: isEnglish
          ? '${clampedScore.toStringAsFixed(1)}% Match'
          : '${clampedScore.toStringAsFixed(1).replaceAll('.', ',')}% Correspondance',
      matchSubtitle: subtitle,
      waistVal: waistVal,
      waistDesc: waistDesc,
      fitVal: fitVal,
      fitDesc: fitDesc,
      fabricVal: fabricVal,
      fabricDesc: fabricDesc,
      versatilityVal: versatilityVal,
      versatilityDesc: versatilityDesc,
      tensionInfo: tensionInfo,
      strainVal: strainVal,
      silhouetteAccent: silhouetteAccent,
    );
  }
}
