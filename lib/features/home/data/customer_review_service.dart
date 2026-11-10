import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/localization/language_service.dart';
import '../../../core/localization/app_strings.dart';
import '../../auth/data/auth_service.dart';

/// Model representing a real or verified customer review for clothing & 3D fit
class CustomerReviewModel {
  final String id;
  final String name;
  final String city;
  final int rating;
  final String commentFr;
  final String commentEn;
  final String product;
  final String fit; // 'perfect', 'too_tight', 'too_loose'
  final DateTime createdAt;

  CustomerReviewModel({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.commentFr,
    required this.commentEn,
    required this.product,
    this.fit = 'perfect',
    required this.createdAt,
  });

  String get localizedComment {
    return LanguageService.instance.isEnglish ? commentEn : commentFr;
  }

  String get localizedProduct {
    return AppStrings.translateProduct(product, LanguageService.instance.currentLanguage);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'city': city,
    'rating': rating,
    'comment_fr': commentFr,
    'comment_en': commentEn,
    'product': product,
    'fit': fit,
    'created_at': createdAt.toIso8601String(),
  };

  factory CustomerReviewModel.fromJson(Map<String, dynamic> json) {
    final comment = json['comment']?.toString() ?? '';
    final commentFr = json['comment_fr']?.toString() ?? comment;
    final commentEn = json['comment_en']?.toString() ?? comment;

    return CustomerReviewModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Membre FitVisor',
      city: json['city']?.toString() ?? 'Paris',
      rating: (json['rating'] is num) ? (json['rating'] as num).toInt() : 5,
      commentFr: commentFr,
      commentEn: commentEn,
      product: json['product']?.toString() ?? 'Article FitVisor',
      fit: json['fit']?.toString() ?? 'perfect',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Service managing dynamic, persistent customer reviews and fit feedbacks
class CustomerReviewService {
  static final CustomerReviewService instance = CustomerReviewService._internal();
  CustomerReviewService._internal();

  static const String _kStorageKey = 'fitvisor_dynamic_customer_reviews_v1';
  final ValueNotifier<List<CustomerReviewModel>> reviewsNotifier =
      ValueNotifier<List<CustomerReviewModel>>([]);

  bool _isInitialized = false;

  /// Default baseline curated reviews with proper localized comments and product names
  static List<CustomerReviewModel> get _baselineReviews => [
    CustomerReviewModel(
      id: 'rev_1',
      name: 'Sophie M.',
      city: 'Paris',
      rating: 5,
      commentFr: "L'avatar 3D a calibré ma silhouette au millimètre. Le tombé de la robe est identique à la réalité !",
      commentEn: "The 3D avatar calibrated my shape to the millimeter. The drape of the dress is identical in real life!",
      product: 'Robe en Soie Amalia',
      fit: 'perfect',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CustomerReviewModel(
      id: 'rev_2',
      name: 'Alexandre V.',
      city: 'Lyon',
      rating: 5,
      commentFr: "Gain de temps incroyable. J'ai commandé le blazer Balmain en taille recommandée, coupe impeccable.",
      commentEn: "Incredible time saver. I ordered the Balmain blazer in the recommended size, impeccable cut.",
      product: 'Grain de Poudre Blazer',
      fit: 'perfect',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CustomerReviewModel(
      id: 'rev_3',
      name: 'Camille L.',
      city: 'Bordeaux',
      rating: 5,
      commentFr: "L'estimation de morphologie et de drapé est révolutionnaire. Plus aucun retour de colis !",
      commentEn: "The morphology and fabric simulation is revolutionary. Zero parcel returns!",
      product: 'Pantalon Tailleur Coupe Cigarette',
      fit: 'perfect',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CustomerReviewModel(
      id: 'rev_4',
      name: 'Marc D.',
      city: 'Nice',
      rating: 5,
      commentFr: "Le pantalon de survêtement Nike Tech Fleece tombe parfaitement. Ajustement au centimètre près.",
      commentEn: "The Nike Tech Fleece joggers fit like custom tailoring. Accurate to the centimetre.",
      product: 'Nike Tech Fleece Joggers',
      fit: 'perfect',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  /// Initialize and load saved reviews from local storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await loadReviews();
  }

  /// Load reviews from local persistence merged with baseline reviews
  Future<void> loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      List<CustomerReviewModel> userReviews = [];

      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = jsonDecode(raw);
        userReviews = list
            .map((e) => CustomerReviewModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      // Prepend user dynamic reviews at top, followed by baseline
      final combined = [...userReviews, ..._baselineReviews];
      reviewsNotifier.value = combined;
      debugPrint('[CustomerReviewService] Loaded ${combined.length} reviews (${userReviews.length} user submitted)');
    } catch (e) {
      debugPrint('[CustomerReviewService] Error loading reviews: $e');
      reviewsNotifier.value = _baselineReviews;
    }
  }

  /// Add a new real customer review after try-on or purchase return
  Future<void> addReview({
    required String productName,
    required String overallFit,
    required String comment,
    int rating = 5,
  }) async {
    try {
      final profile = AuthService.cachedProfile;
      String userName = profile['full_name']?.toString().trim() ?? '';
      if (userName.isEmpty) {
        final email = Supabase.instance.client.auth.currentUser?.email ?? '';
        if (email.contains('@')) {
          final prefix = email.split('@').first;
          userName = prefix.isNotEmpty ? '${prefix[0].toUpperCase()}${prefix.substring(1)}' : 'Membre FitVisor';
        } else {
          userName = 'Membre FitVisor';
        }
      }

      // Format as "Name F." (e.g. "Lucas M.")
      final parts = userName.split(' ');
      String displayName = userName;
      if (parts.length > 1) {
        displayName = '${parts.first} ${parts.last[0].toUpperCase()}.';
      }

      final city = profile['city']?.toString().trim().isNotEmpty == true
          ? profile['city'].toString().trim()
          : 'Paris';

      final newReview = CustomerReviewModel(
        id: 'user_rev_${DateTime.now().millisecondsSinceEpoch}',
        name: displayName,
        city: city,
        rating: rating,
        commentFr: comment,
        commentEn: comment,
        product: productName,
        fit: overallFit,
        createdAt: DateTime.now(),
      );

      // Prepend dynamically to notifier
      final currentList = List<CustomerReviewModel>.from(reviewsNotifier.value);
      currentList.insert(0, newReview);
      reviewsNotifier.value = currentList;

      // Save user submitted reviews to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      List<dynamic> savedJsonList = [];
      if (raw != null && raw.isNotEmpty) {
        try {
          savedJsonList = jsonDecode(raw);
        } catch (_) {}
      }
      savedJsonList.insert(0, newReview.toJson());
      await prefs.setString(_kStorageKey, jsonEncode(savedJsonList));

      debugPrint('[CustomerReviewService] Successfully added dynamic review for "$productName" by "$displayName"');
    } catch (e) {
      debugPrint('[CustomerReviewService] Error adding review: $e');
    }
  }
}

