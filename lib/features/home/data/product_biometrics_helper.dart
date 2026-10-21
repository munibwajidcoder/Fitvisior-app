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
  }) {
    // Generate deterministic variation from product id + name
    final seed = (id.hashCode ^ name.hashCode).abs();

    // 1. Fit Score
    final cleanFit = fitPercentStr.replaceAll(RegExp(r'[^0-9.]'), '');
    final score = double.tryParse(cleanFit) ?? (94.0 + (seed % 50) / 10.0);
    final clampedScore = score.clamp(88.0, 99.4);

    // 2. Subtitle
    final String subtitle;
    if (clampedScore >= 98.0) {
      subtitle = 'Ajustement Sur-Mesure';
    } else if (clampedScore >= 95.0) {
      subtitle = 'Tombé Haute Fidélité';
    } else if (clampedScore >= 92.0) {
      subtitle = 'Légère aisance poitrine';
    } else {
      subtitle = 'Ajustement Recommandé';
    }

    final catLower = category.toLowerCase();
    final nameLower = name.toLowerCase();

    // 3. Waist Measurement (Tour de Taille)
    String waistVal;
    String waistDesc;
    if (catLower.contains('pantalon') || catLower.contains('jean')) {
      final base = 66.0 + (seed % 60) / 10.0; // 66.0 to 72.0 cm
      waistVal = '${base.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = 'Taille Haute Sculptée';
    } else if (catLower.contains('robe') || nameLower.contains('robe') || nameLower.contains('dress')) {
      final base = 63.5 + (seed % 50) / 10.0; // 63.5 to 68.5 cm
      waistVal = '${base.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = 'Cintrage Anatomique';
    } else if (catLower.contains('blazer') || catLower.contains('veste') || nameLower.contains('blazer')) {
      final base = 65.5 + (seed % 45) / 10.0; // 65.5 to 70.0 cm
      waistVal = '${base.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = 'Sablier Accentué';
    } else if (catLower.contains('manteau') || nameLower.contains('manteau') || nameLower.contains('coat')) {
      final base = 71.0 + (seed % 50) / 10.0; // 71.0 to 76.0 cm
      waistVal = '${base.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = 'Aisance Manteau Double';
    } else {
      final base = 64.0 + (seed % 40) / 10.0; // 64.0 to 68.0 cm
      waistVal = '${base.toStringAsFixed(1).replaceAll('.', ',')} cm';
      waistDesc = 'Coupe Fluide Naturelle';
    }

    // 4. Fit / Length (Tombé & Longueur)
    String fitVal;
    String fitDesc;
    if (catLower.contains('robe') || nameLower.contains('robe')) {
      if (nameLower.contains('maxi') || nameLower.contains('longue')) {
        fitVal = '132,0 cm';
        fitDesc = 'Longueur Opéra / Sol';
      } else if (nameLower.contains('mini') || nameLower.contains('courte')) {
        fitVal = '88,0 cm';
        fitDesc = 'Finition Au-dessus du Genou';
      } else {
        final length = 104.0 + (seed % 120) / 10.0; // 104 to 116 cm
        fitVal = '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
        fitDesc = 'Finition Mi-Mollet Drapée';
      }
    } else if (catLower.contains('pantalon') || catLower.contains('jean')) {
      final length = 101.0 + (seed % 60) / 10.0; // 101 to 107 cm
      fitVal = '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = 'Entrejambe 82 cm (Talon 7cm)';
    } else if (catLower.contains('blazer') || catLower.contains('veste') || nameLower.contains('blazer')) {
      final length = 66.0 + (seed % 70) / 10.0; // 66 to 73 cm
      fitVal = '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = 'Finition Haut des Hanches';
    } else if (catLower.contains('manteau')) {
      final length = 115.0 + (seed % 100) / 10.0; // 115 to 125 cm
      fitVal = '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = 'Tombé Longueur Mollet';
    } else {
      final length = 58.0 + (seed % 60) / 10.0; // 58 to 64 cm
      fitVal = '${length.toStringAsFixed(1).replaceAll('.', ',')} cm';
      fitDesc = 'Coupe Bassin Ajustée';
    }

    // 5. Fabric Density (Grammage du Tissu)
    String fabricVal;
    String fabricDesc = fabric.isNotEmpty ? fabric : 'Matière Noble';
    final fabLower = fabric.toLowerCase();
    if (fabLower.contains('soie') || fabLower.contains('silk')) {
      final weight = 160 + (seed % 40);
      fabricVal = '$weight g/m²';
      fabricDesc = 'Soie & Crêpe Fluide';
    } else if (fabLower.contains('cachemire') || fabLower.contains('cashmere')) {
      final weight = 210 + (seed % 50);
      fabricVal = '$weight g/m²';
      fabricDesc = 'Cachemire Pur (Doux)';
    } else if (fabLower.contains('tweed')) {
      final weight = 320 + (seed % 60);
      fabricVal = '$weight g/m²';
      fabricDesc = 'Tweed Tissé Main (Rigide 4/5)';
    } else if (fabLower.contains('laine') || fabLower.contains('wool')) {
      final weight = 270 + (seed % 50);
      fabricVal = '$weight g/m²';
      fabricDesc = 'Laine Vierge Peignée';
    } else if (fabLower.contains('lin') || fabLower.contains('linen')) {
      final weight = 230 + (seed % 30);
      fabricVal = '$weight g/m²';
      fabricDesc = 'Lin Texturé Respirant';
    } else if (catLower.contains('manteau')) {
      final weight = 420 + (seed % 80);
      fabricVal = '$weight g/m²';
      fabricDesc = 'Drap de Laine Lourd';
    } else {
      final weight = 240 + (seed % 60);
      fabricVal = '$weight g/m²';
      fabricDesc = fabric.isNotEmpty ? fabric : 'Matière Structurée';
    }

    // 6. Versatility (Score de Polyvalence)
    final versNum = 8.8 + (seed % 10) / 10.0; // 8.8 to 9.7
    final versatilityVal = versNum.toStringAsFixed(1);
    final String versatilityDesc;
    if (versNum >= 9.4) {
      versatilityDesc = 'Jour au Soir • Capsule';
    } else if (versNum >= 9.1) {
      versatilityDesc = 'Business & Cocktail';
    } else {
      versatilityDesc = 'Occasion Spéciale';
    }

    // 7. Tension & Strain (Tension des coutures)
    String tensionInfo;
    double strainVal;
    if (clampedScore >= 97.5) {
      tensionInfo = '0,0 cm Tension (Fluide)';
      strainVal = 0.10 + (seed % 8) / 100.0;
    } else if (clampedScore >= 95.0) {
      final t = 0.2 + (seed % 4) / 10.0;
      tensionInfo = '${t.toStringAsFixed(1).replaceAll('.', ',')} cm Stretch Naturel';
      strainVal = 0.22 + (seed % 10) / 100.0;
    } else if (clampedScore >= 92.0) {
      final t = 0.8 + (seed % 6) / 10.0;
      tensionInfo = '+${t.toStringAsFixed(1).replaceAll('.', ',')} cm Résistance Poitrine';
      strainVal = 0.45 + (seed % 15) / 100.0;
    } else {
      final t = 1.4 + (seed % 8) / 10.0;
      tensionInfo = '+${t.toStringAsFixed(1).replaceAll('.', ',')} cm Maintien Ferme';
      strainVal = 0.70 + (seed % 15) / 100.0;
    }

    // 8. Silhouette Accent
    final String silhouetteAccent;
    if (catLower.contains('robe')) {
      silhouetteAccent = 'Sablier & Drapé';
    } else if (catLower.contains('blazer')) {
      silhouetteAccent = 'Cintrée Structurée';
    } else if (catLower.contains('pantalon')) {
      silhouetteAccent = 'Colonne Fuselée';
    } else {
      silhouetteAccent = 'Fluide Équilibrée';
    }

    return ProductBiometricData(
      scoreValue: clampedScore,
      matchScore: '${clampedScore.toStringAsFixed(1).replaceAll('.', ',')}% Correspondance',
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
