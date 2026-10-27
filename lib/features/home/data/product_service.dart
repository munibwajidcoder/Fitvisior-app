import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String subCategory;
  final String gender;
  final String description;
  final double price;
  final double? oldPrice;
  final String? discountTag;
  final bool isSale;
  final String imageUrl;
  final List<String> galleryImages;
  final String? glbModelUrl;
  final List<String> availableSizes;
  final List<Map<String, dynamic>> availableColors;
  final String recSize;
  final String fitPercent;
  final String fabricComposition;
  final String silhouetteType;
  final String careInstructions;
  final bool isFeatured;
  final bool isTrending;
  final bool isNewArrival;
  final String? bannerTag;
  final String triedCountText;
  final String badge;
  final String badgeColor;
  final String badgeBg;
  final bool inStock;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final String partnerStoreName;
  final String partnerStoreUrl;
  final bool storeReservationAvailable;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subCategory,
    required this.gender,
    required this.description,
    required this.price,
    this.oldPrice,
    this.discountTag,
    required this.isSale,
    required this.imageUrl,
    required this.galleryImages,
    this.glbModelUrl,
    required this.availableSizes,
    required this.availableColors,
    required this.recSize,
    required this.fitPercent,
    required this.fabricComposition,
    required this.silhouetteType,
    required this.careInstructions,
    required this.isFeatured,
    required this.isTrending,
    required this.isNewArrival,
    this.bannerTag,
    required this.triedCountText,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.inStock,
    required this.stockQuantity,
    this.rating = 4.5,
    this.reviewCount = 0,
    required this.partnerStoreName,
    required this.partnerStoreUrl,
    required this.storeReservationAvailable,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      subCategory: map['sub_category']?.toString() ?? map['subcategory']?.toString() ?? 'Robes',
      gender: map['gender']?.toString() ?? 'Femme',
      description: map['description']?.toString() ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      oldPrice: (map['old_price'] is num) ? (map['old_price'] as num).toDouble() : (map['old_price'] != null ? double.tryParse(map['old_price'].toString()) : null),
      discountTag: map['discount_tag']?.toString(),
      isSale: map['is_sale'] == true,
      imageUrl: map['image_url']?.toString() ?? 'assets/images/product_dress.jpg',
      galleryImages: (map['gallery_images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      glbModelUrl: map['glb_model_url']?.toString(),
      availableSizes: (map['available_sizes'] as List?)?.map((e) => e.toString()).toList() ?? ['XS', 'S', 'M', 'L', 'XL'],
      availableColors: (map['available_colors'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [
        {'name': 'Bleu Nuit', 'hex': '#172554'}
      ],
      recSize: map['rec_size']?.toString() ?? 'Rec: FR 36',
      fitPercent: map['fit_percentage']?.toString() ?? map['fit_percent']?.toString() ?? '98% Fit',
      fabricComposition: map['fabric_composition']?.toString() ?? 'Laine Structurée',
      silhouetteType: map['silhouette_type']?.toString() ?? 'Architectural',
      careInstructions: map['care_instructions']?.toString() ?? 'Nettoyage à sec',
      isFeatured: map['is_featured'] == true,
      isTrending: map['is_trending'] == true,
      isNewArrival: map['is_new_arrival'] == true,
      bannerTag: map['banner_tag']?.toString(),
      triedCountText: map['tried_count_text']?.toString() ?? (map['tried_count'] != null ? "${map['tried_count']} essayés aujourd'hui" : "412 essayés aujourd'hui"),
      badge: map['badge']?.toString() ?? '98% Ajusté',
      badgeColor: map['badge_color']?.toString() ?? '#16A34A',
      badgeBg: map['badge_bg']?.toString() ?? '#ECFDF5',
      inStock: map['in_stock'] != false,
      stockQuantity: (map['stock_quantity'] is num) ? (map['stock_quantity'] as num).toInt() : 15,
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 4.5,
      reviewCount: (map['review_count'] is num) ? (map['review_count'] as num).toInt() : 0,
      partnerStoreName: map['partner_store_name']?.toString() ?? 'Boutique Saint-Honoré Paris',
      partnerStoreUrl: map['partner_store_url']?.toString() ?? 'https://www.balmain.com',
      storeReservationAvailable: (map['store_reservation_available'] ?? map['reservation_available']) != false,
    );
  }

  String get displayName {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateProduct(name, 'en');
    }
    return name;
  }

  String get displayCategory {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateCategory(category, 'en');
    }
    return category;
  }

  String get displaySilhouette {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateSilhouette(silhouetteType, 'en');
    }
    return silhouetteType;
  }

  String get displayBadge {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateBadge(badge, 'en');
    }
    return badge;
  }

  String get displayTriedCountText {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateTriedCount(triedCountText, 'en');
    }
    return triedCountText;
  }

  String displayBannerTag([String? fallback]) {
    final t = bannerTag ?? fallback ?? '';
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateBannerTag(t, 'en');
    }
    return t;
  }

  String get displayDescription {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateDescription(description, 'en');
    }
    return description;
  }

  String get displayFabricComposition {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateFabric(fabricComposition, 'en');
    }
    return fabricComposition;
  }

  String get displayCareInstructions {
    if (LanguageService.instance.isEnglish) {
      return AppStrings.translateCare(careInstructions, 'en');
    }
    return careInstructions;
  }

  String get displayRecSize {
    if (LanguageService.instance.isEnglish) {
      return recSize
          .replaceAll('Taille conseillée : ', 'Rec: ')
          .replaceAll('Taille conseillée: ', 'Rec: ')
          .replaceAll('Taille cons. : ', 'Rec: ')
          .replaceAll('Taille cons.: ', 'Rec: ');
    } else {
      return recSize
          .replaceAll('Rec: ', 'Taille cons.: ')
          .replaceAll('Rec : ', 'Taille cons.: ');
    }
  }

  List<Map<String, dynamic>> get displayAvailableColors {
    if (!LanguageService.instance.isEnglish) return availableColors;
    return availableColors.map((c) {
      final orig = c['name']?.toString() ?? '';
      return {
        ...c,
        'name': AppStrings.translateColor(orig, 'en'),
      };
    }).toList();
  }
}

class ProductService {
  static final ProductService instance = ProductService._internal();
  ProductService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// Fetch products with optional dynamic filters
  Future<List<ProductModel>> getProducts({
    String? category,
    String? subCategory,
    String? searchQuery,
    bool? isFeatured,
    bool? isTrending,
    bool? isNewArrival,
    bool? isSale,
    double? minPrice,
    double? maxPrice,
    List<String>? selectedSilhouettes,
    List<String>? selectedFabrics,
    List<String>? selectedDesigners,
  }) async {
    try {
      var query = _client.from('products').select();

      if (category != null && category.isNotEmpty && category != 'Tout') {
        query = query.eq('category', category);
      }

      dynamic response;
      try {
        response = await query.order('created_at', ascending: false);
      } catch (orderErr) {
        debugPrint('[ProductService] order(created_at) fallback: $orderErr');
        response = await query;
      }
      final List data = response as List;

      var products = data.map((item) => ProductModel.fromMap(item as Map<String, dynamic>)).toList();

      if (subCategory != null && subCategory.isNotEmpty && subCategory != 'Tout') {
        final sub = subCategory.toLowerCase().trim();
        products = products.where((p) => p.subCategory.toLowerCase().trim() == sub).toList();
      }

      // In-memory advanced filter for search & multi-tags if needed
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        products = products.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.subCategory.toLowerCase().contains(q)
        ).toList();
      }

      if (selectedSilhouettes != null && selectedSilhouettes.isNotEmpty) {
        products = products.where((p) => selectedSilhouettes.contains(p.silhouetteType)).toList();
      }

      if (selectedFabrics != null && selectedFabrics.isNotEmpty) {
        products = products.where((p) => selectedFabrics.contains(p.fabricComposition)).toList();
      }

      if (selectedDesigners != null && selectedDesigners.isNotEmpty) {
        products = products.where((p) => selectedDesigners.contains(p.brand)).toList();
      }

      return products;
    } catch (e) {
      debugPrint('[ProductService] Error fetching products: $e');
      return _getFallbackProducts();
    }
  }

  List<ProductModel> get fallbackProducts => _getFallbackProducts();

  /// Fallback dummy products if network is unavailable or table is loading
  List<ProductModel> _getFallbackProducts() {
    return [
      // ── BALMAIN (4 items) ────────────────────────────────────────────────
      ProductModel(
        id: '1',
        name: 'Grain de Poudre Blazer',
        brand: 'Balmain',
        category: 'Blazers & Vestes',
        subCategory: 'Costumes',
        gender: 'Femme',
        description: 'Veste de tailleur iconique aux épaules structurées et boutons dorés blasonnés.',
        price: 2190.0,
        isSale: false,
        imageUrl: 'assets/images/product_suit.jpg',
        galleryImages: ['assets/images/product_suit.jpg'],
        glbModelUrl: 'https://oifklsdxmpmdfbnaazso.supabase.co/storage/v1/object/public/avatars/avatar_blazer_v31_detailed.glb',
        availableSizes: ['FR 34', 'FR 36', 'FR 38', 'FR 40'],
        availableColors: [{'name': 'Bleu Nuit', 'hex': '#172554'}],
        recSize: 'Rec: FR 36',
        fitPercent: '98% Fit',
        fabricComposition: 'Laine Structurée',
        silhouetteType: 'Architectural',
        careInstructions: 'Nettoyage à sec',
        isFeatured: true,
        isTrending: true,
        isNewArrival: false,
        bannerTag: 'NOUVELLE COLLECTION',
        triedCountText: "412 essayés aujourd'hui",
        badge: 'Ajust. exact',
        badgeColor: '#E11D48',
        badgeBg: '#FFF1F2',
        inStock: true,
        stockQuantity: 10,
        partnerStoreName: 'Balmain Flagship Paris',
        partnerStoreUrl: 'https://www.balmain.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '1b',
        name: 'Veste Courte en Tweed Monogramme',
        brand: 'Balmain',
        category: 'Blazers & Vestes',
        subCategory: 'Vestes',
        gender: 'Femme',
        description: 'Veste ajustée en tweed noir et or tissé main.',
        price: 2450.0,
        isSale: false,
        imageUrl: 'assets/images/product_suit.jpg',
        galleryImages: ['assets/images/product_suit.jpg'],
        availableSizes: ['FR 36', 'FR 38', 'FR 40'],
        availableColors: [{'name': 'Noir / Or', 'hex': '#000000'}],
        recSize: 'Rec: FR 38',
        fitPercent: '97% Fit',
        fabricComposition: 'Laine Structurée',
        silhouetteType: 'Architectural',
        careInstructions: 'Nettoyage à sec',
        isFeatured: false,
        isTrending: true,
        isNewArrival: true,
        triedCountText: "310 essayés aujourd'hui",
        badge: '97% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 7,
        partnerStoreName: 'Balmain Flagship Paris',
        partnerStoreUrl: 'https://www.balmain.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '1c',
        name: 'Robe Fourreau Drapée Balmain',
        brand: 'Balmain',
        category: 'Robes & Soirée',
        subCategory: 'Robes',
        gender: 'Femme',
        description: 'Robe de cocktail sculptée asymétrique.',
        price: 1950.0,
        isSale: false,
        imageUrl: 'assets/images/product_dress.jpg',
        galleryImages: ['assets/images/product_dress.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38'],
        availableColors: [{'name': 'Noir Intemporel', 'hex': '#0F172A'}],
        recSize: 'Rec: FR 36',
        fitPercent: '96% Fit',
        fabricComposition: 'Crêpe Technique',
        silhouetteType: 'Près du Corps',
        careInstructions: 'Nettoyage à sec',
        isFeatured: false,
        isTrending: false,
        isNewArrival: true,
        triedCountText: "195 essayés aujourd'hui",
        badge: 'Coup de Cœur',
        badgeColor: '#EA580C',
        badgeBg: '#FFF7ED',
        inStock: true,
        stockQuantity: 4,
        partnerStoreName: 'Balmain Flagship Paris',
        partnerStoreUrl: 'https://www.balmain.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '1d',
        name: 'Pantalon Tailleur Coupe Cigarette',
        brand: 'Balmain',
        category: 'Pantalons & Denim',
        subCategory: 'Pantalons',
        gender: 'Femme',
        description: 'Pantalon à taille haute plissé en grain de poudre.',
        price: 990.0,
        isSale: true,
        oldPrice: 1250.0,
        discountTag: '-20%',
        imageUrl: 'assets/images/product_pants.jpg',
        galleryImages: ['assets/images/product_pants.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38', 'FR 40'],
        availableColors: [{'name': 'Bleu Nuit', 'hex': '#172554'}],
        recSize: 'Rec: FR 36',
        fitPercent: '99% Fit',
        fabricComposition: 'Laine Structurée',
        silhouetteType: 'Architectural',
        careInstructions: 'Nettoyage à sec',
        isFeatured: false,
        isTrending: false,
        isNewArrival: false,
        triedCountText: "240 essayés aujourd'hui",
        badge: '99% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 9,
        partnerStoreName: 'Balmain Flagship Paris',
        partnerStoreUrl: 'https://www.balmain.com',
        storeReservationAvailable: true,
      ),

      // ── THE ROW (3 items) ────────────────────────────────────────────────
      ProductModel(
        id: '2',
        name: 'Robe en Soie Amalia',
        brand: 'The Row',
        category: 'Robes & Soirée',
        subCategory: 'Robes',
        gender: 'Femme',
        description: 'Robe fluide en crêpe de soie pure à tombé naturel.',
        price: 1850.0,
        isSale: false,
        imageUrl: 'assets/images/product_dress.jpg',
        galleryImages: ['assets/images/product_dress.jpg'],
        availableSizes: ['XS', 'S', 'M', 'L'],
        availableColors: [{'name': 'Noir Ébène', 'hex': '#000000'}],
        recSize: 'Rec: S',
        fitPercent: '99% Fit',
        fabricComposition: 'Charmeuse de Soie',
        silhouetteType: 'Fluide & Détendu',
        careInstructions: 'Lavage délicat à la main',
        isFeatured: true,
        isTrending: false,
        isNewArrival: true,
        bannerTag: 'SÉLECTION STYLISTE',
        triedCountText: "285 essayés aujourd'hui",
        badge: '98% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 8,
        partnerStoreName: 'The Row Boutique',
        partnerStoreUrl: 'https://www.therow.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '2b',
        name: 'Manteau Cocon en Cachemire Sibem',
        brand: 'The Row',
        category: 'Manteaux',
        subCategory: 'Manteaux',
        gender: 'Femme',
        description: 'Manteau enveloppant oversize en double cachemire.',
        price: 2490.0,
        isSale: false,
        imageUrl: 'assets/images/hero_banner.jpg',
        galleryImages: ['assets/images/hero_banner.jpg'],
        availableSizes: ['S', 'M', 'L'],
        availableColors: [{'name': 'Beige Avoine', 'hex': '#E5E5E5'}],
        recSize: 'Rec: M',
        fitPercent: '96% Fit',
        fabricComposition: 'Cachemire Épais',
        silhouetteType: 'Cocon Oversize',
        careInstructions: 'Nettoyage à sec spécialisé',
        isFeatured: true,
        isTrending: true,
        isNewArrival: true,
        triedCountText: "370 essayés aujourd'hui",
        badge: '96% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 5,
        partnerStoreName: 'The Row Boutique',
        partnerStoreUrl: 'https://www.therow.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '2c',
        name: 'Pull Col Roulé Cachemire Barely',
        brand: 'The Row',
        category: 'Maille',
        subCategory: 'Pulls',
        gender: 'Femme',
        description: 'Tricot fin en cachemire vierge peigné.',
        price: 1150.0,
        isSale: false,
        imageUrl: 'assets/images/product_sweater.jpg',
        galleryImages: ['assets/images/product_sweater.jpg'],
        availableSizes: ['XS', 'S', 'M'],
        availableColors: [{'name': 'Gris Souris', 'hex': '#64748B'}],
        recSize: 'Rec: S',
        fitPercent: '95% Fit',
        fabricComposition: 'Cachemire Épais',
        silhouetteType: 'Fluide & Détendu',
        careInstructions: 'Lavage main à froid',
        isFeatured: false,
        isTrending: false,
        isNewArrival: false,
        triedCountText: "215 essayés aujourd'hui",
        badge: '95% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 11,
        partnerStoreName: 'The Row Boutique',
        partnerStoreUrl: 'https://www.therow.com',
        storeReservationAvailable: true,
      ),

      // ── BOTTEGA VENETA (3 items) ─────────────────────────────────────────
      ProductModel(
        id: '3',
        name: 'Flanelle Plissée Pantalon',
        brand: 'Bottega Veneta',
        category: 'Pantalons & Denim',
        subCategory: 'Pantalons',
        gender: 'Femme',
        description: 'Pantalon masculin en flanelle de laine vierge plissée.',
        price: 1200.0,
        isSale: false,
        imageUrl: 'assets/images/product_pants.jpg',
        galleryImages: ['assets/images/product_pants.jpg'],
        availableSizes: ['IT 38', 'IT 40', 'IT 42'],
        availableColors: [{'name': 'Gris Anthracite', 'hex': '#374151'}],
        recSize: 'Rec: IT 40',
        fitPercent: '96% Fit',
        fabricComposition: 'Laine Structurée',
        silhouetteType: 'Cocon Oversize',
        careInstructions: 'Nettoyage à sec',
        isFeatured: false,
        isTrending: false,
        isNewArrival: true,
        triedCountText: "190 essayés aujourd'hui",
        badge: 'Vrai ajust.',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 12,
        partnerStoreName: 'Bottega Veneta Vendôme',
        partnerStoreUrl: 'https://www.bottegaveneta.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '3b',
        name: 'Veste Cuir Nappa Intrecciato',
        brand: 'Bottega Veneta',
        category: 'Blazers & Vestes',
        subCategory: 'Vestes',
        gender: 'Femme',
        description: 'Veste structurée en cuir d’agneau nappa plongé.',
        price: 2400.0,
        isSale: false,
        imageUrl: 'assets/images/product_suit.jpg',
        galleryImages: ['assets/images/product_suit.jpg'],
        availableSizes: ['IT 38', 'IT 40', 'IT 42'],
        availableColors: [{'name': 'Bordeaux Fondant', 'hex': '#881337'}],
        recSize: 'Rec: IT 40',
        fitPercent: '98% Fit',
        fabricComposition: 'Cuir Structuré',
        silhouetteType: 'Architectural',
        careInstructions: 'Nettoyage par spécialiste cuir',
        isFeatured: true,
        isTrending: true,
        isNewArrival: false,
        triedCountText: "440 essayés aujourd'hui",
        badge: '98% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 4,
        partnerStoreName: 'Bottega Veneta Vendôme',
        partnerStoreUrl: 'https://www.bottegaveneta.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '3c',
        name: 'Robe en Maille Torsadée Asymétrique',
        brand: 'Bottega Veneta',
        category: 'Robes & Soirée',
        subCategory: 'Robes',
        gender: 'Femme',
        description: 'Robe sculptante en maille côtelée stretch.',
        price: 1650.0,
        isSale: false,
        imageUrl: 'assets/images/product_dress.jpg',
        galleryImages: ['assets/images/product_dress.jpg'],
        availableSizes: ['IT 38', 'IT 40'],
        availableColors: [{'name': 'Vert Parakeet', 'hex': '#15803D'}],
        recSize: 'Rec: IT 38',
        fitPercent: '97% Fit',
        fabricComposition: 'Crêpe Technique',
        silhouetteType: 'Près du Corps',
        careInstructions: 'Nettoyage à sec',
        isFeatured: false,
        isTrending: false,
        isNewArrival: true,
        triedCountText: "180 essayés aujourd'hui",
        badge: '97% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 6,
        partnerStoreName: 'Bottega Veneta Vendôme',
        partnerStoreUrl: 'https://www.bottegaveneta.com',
        storeReservationAvailable: true,
      ),

      // ── SAINT LAURENT (3 items) ──────────────────────────────────────────
      ProductModel(
        id: '5',
        name: 'Trench Ceinturé en Vinyle Laqué',
        brand: 'Saint Laurent',
        category: 'Manteaux',
        subCategory: 'Manteaux',
        gender: 'Femme',
        description: 'Trench iconique à double boutonnage et épaulettes marquées.',
        price: 2480.0,
        isSale: false,
        imageUrl: 'assets/images/product_suit.jpg',
        galleryImages: ['assets/images/product_suit.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38'],
        availableColors: [{'name': 'Noir Miroir', 'hex': '#000000'}],
        recSize: 'Rec: FR 36',
        fitPercent: '95% Fit',
        fabricComposition: 'Cuir Structuré',
        silhouetteType: 'Architectural',
        careInstructions: 'Chiffon doux uniquement',
        isFeatured: true,
        isTrending: true,
        isNewArrival: true,
        triedCountText: "412 essayés aujourd'hui",
        badge: 'Tendance RA',
        badgeColor: '#E11D48',
        badgeBg: '#FFF1F2',
        inStock: true,
        stockQuantity: 5,
        partnerStoreName: 'Saint Laurent Rive Droite',
        partnerStoreUrl: 'https://www.ysl.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '5b',
        name: 'Veste Smoking Le Smoking Grain de Poudre',
        brand: 'Saint Laurent',
        category: 'Blazers & Vestes',
        subCategory: 'Costumes',
        gender: 'Femme',
        description: 'Le mythique smoking Yves Saint Laurent réinterprété.',
        price: 2390.0,
        isSale: false,
        imageUrl: 'assets/images/product_suit.jpg',
        galleryImages: ['assets/images/product_suit.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38', 'FR 40'],
        availableColors: [{'name': 'Noir Profond', 'hex': '#000000'}],
        recSize: 'Rec: FR 36',
        fitPercent: '99% Fit',
        fabricComposition: 'Laine Structurée',
        silhouetteType: 'Architectural',
        careInstructions: 'Nettoyage à sec',
        isFeatured: true,
        isTrending: true,
        isNewArrival: false,
        triedCountText: "560 essayés aujourd'hui",
        badge: '99% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 8,
        partnerStoreName: 'Saint Laurent Rive Droite',
        partnerStoreUrl: 'https://www.ysl.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '5c',
        name: 'Chemise Lavallière en Mousseline de Soie',
        brand: 'Saint Laurent',
        category: 'Robes & Soirée',
        subCategory: 'Chemises',
        gender: 'Femme',
        description: 'Chemisier vaporeux à col lavallière fluide.',
        price: 990.0,
        isSale: false,
        imageUrl: 'assets/images/product_dress.jpg',
        galleryImages: ['assets/images/product_dress.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38'],
        availableColors: [{'name': 'Ivoire Pur', 'hex': '#FFFFFF'}],
        recSize: 'Rec: FR 36',
        fitPercent: '97% Fit',
        fabricComposition: 'Charmeuse de Soie',
        silhouetteType: 'Fluide & Détendu',
        careInstructions: 'Nettoyage à sec délicat',
        isFeatured: false,
        isTrending: false,
        isNewArrival: true,
        triedCountText: "230 essayés aujourd'hui",
        badge: '97% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 10,
        partnerStoreName: 'Saint Laurent Rive Droite',
        partnerStoreUrl: 'https://www.ysl.com',
        storeReservationAvailable: true,
      ),

      // ── JACQUEMUS (2 items) ──────────────────────────────────────────────
      ProductModel(
        id: '4',
        name: 'La Robe Bahia',
        brand: 'Jacquemus',
        category: 'Robes & Soirée',
        subCategory: 'Robes',
        gender: 'Femme',
        description: 'Robe drapée emblématique boutonnée asymétrique.',
        price: 690.0,
        oldPrice: 890.0,
        discountTag: '-22%',
        isSale: true,
        imageUrl: 'assets/images/product_sweater.jpg',
        galleryImages: ['assets/images/product_sweater.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38'],
        availableColors: [{'name': 'Blanc Cassé', 'hex': '#F8FAFC'}],
        recSize: 'Rec: FR 36',
        fitPercent: '97% Fit',
        fabricComposition: 'Crêpe Technique',
        silhouetteType: 'Près du Corps',
        careInstructions: 'Lavage machine 30°C',
        isFeatured: false,
        isTrending: true,
        isNewArrival: false,
        bannerTag: 'OFFRE SPÉCIALE',
        triedCountText: "530 essayés aujourd'hui",
        badge: 'Coup de Cœur',
        badgeColor: '#EA580C',
        badgeBg: '#FFF7ED',
        inStock: true,
        stockQuantity: 5,
        partnerStoreName: 'Jacquemus Montaigne',
        partnerStoreUrl: 'https://www.jacquemus.com',
        storeReservationAvailable: true,
      ),
      ProductModel(
        id: '4b',
        name: 'Le Gilet Noué en Maille Côtelée',
        brand: 'Jacquemus',
        category: 'Maille',
        subCategory: 'Tricot',
        gender: 'Femme',
        description: 'Cardigan court fermé par une bride logotypée en métal doré.',
        price: 450.0,
        isSale: false,
        imageUrl: 'assets/images/product_dress.jpg',
        galleryImages: ['assets/images/product_dress.jpg'],
        availableSizes: ['FR 34', 'FR 36', 'FR 38'],
        availableColors: [{'name': 'Rose Poudré', 'hex': '#FDA4AF'}],
        recSize: 'Rec: FR 36',
        fitPercent: '98% Fit',
        fabricComposition: 'Crêpe Technique',
        silhouetteType: 'Près du Corps',
        careInstructions: 'Lavage main à froid',
        isFeatured: false,
        isTrending: true,
        isNewArrival: true,
        triedCountText: "390 essayés aujourd'hui",
        badge: '98% Ajusté',
        badgeColor: '#16A34A',
        badgeBg: '#ECFDF5',
        inStock: true,
        stockQuantity: 7,
        partnerStoreName: 'Jacquemus Montaigne',
        partnerStoreUrl: 'https://www.jacquemus.com',
        storeReservationAvailable: true,
      ),
    ];
  }
}
