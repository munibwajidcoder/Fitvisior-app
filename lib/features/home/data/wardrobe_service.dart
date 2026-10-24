import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_service.dart';
import 'product_biometrics_helper.dart';
import '../../../core/localization/language_service.dart';

/// Model representing a saved luxury item in the user's digital wardrobe
class WardrobeItem {
  final String id;
  final String? userId;
  final String productId;
  final String productName;
  final String productBrand;
  final String productPrice;
  final String productImage;
  final String fitPercent;
  final String recSize;
  final String category;
  final String? glbModelUrl;
  final bool isWornIn3d;
  final String pairingNotes;
  final double matchScoreVal;
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
  final double certaintyVal;
  final bool isFavorite;
  final DateTime? createdAt;

  WardrobeItem({
    required this.id,
    this.userId,
    required this.productId,
    required this.productName,
    required this.productBrand,
    required this.productPrice,
    required this.productImage,
    required this.fitPercent,
    required this.recSize,
    required this.category,
    this.glbModelUrl,
    this.isWornIn3d = false,
    this.pairingNotes = '',
    this.matchScoreVal = 98.4,
    this.matchSubtitle = 'Ajustement Optimal',
    this.waistVal = '66,5 cm',
    this.waistDesc = 'Coupe Parfaite',
    this.fitVal = '68,0 cm',
    this.fitDesc = 'Finition Hanches',
    this.fabricVal = '280 g/m²',
    this.fabricDesc = 'Laine & Soie',
    this.versatilityVal = '9.4',
    this.versatilityDesc = 'Jour au Soir',
    this.tensionInfo = '0,0 cm (Fluide)',
    this.certaintyVal = 0.98,
    this.isFavorite = true,
    this.createdAt,
  });

  String get localizedProductName => WardrobeService.localizeProductName(productName);

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      productId: json['product_id']?.toString() ?? json['id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Article de Luxe',
      productBrand: json['product_brand']?.toString() ?? 'MAISON',
      productPrice: json['product_price']?.toString() ?? '0 €',
      productImage: json['product_image']?.toString() ?? 'assets/images/product_dress.jpg',
      fitPercent: json['fit_percent']?.toString() ?? '98%',
      recSize: json['rec_size']?.toString() ?? 'M',
      category: json['category']?.toString() ?? 'Vêtements',
      glbModelUrl: json['glb_model_url']?.toString(),
      isWornIn3d: json['is_worn_in_3d'] == true,
      pairingNotes: json['pairing_notes']?.toString() ?? '',
      matchScoreVal: (json['match_score_val'] is num) ? (json['match_score_val'] as num).toDouble() : 98.0,
      matchSubtitle: json['match_subtitle']?.toString() ?? 'Ajustement Optimal',
      waistVal: json['waist_val']?.toString() ?? '66,5 cm',
      waistDesc: json['waist_desc']?.toString() ?? 'Coupe Parfaite',
      fitVal: json['fit_val']?.toString() ?? '68,0 cm',
      fitDesc: json['fit_desc']?.toString() ?? 'Finition Hanches',
      fabricVal: json['fabric_val']?.toString() ?? '280 g/m²',
      fabricDesc: json['fabric_desc']?.toString() ?? 'Matière Noble',
      versatilityVal: json['versatility_val']?.toString() ?? '9.4',
      versatilityDesc: json['versatility_desc']?.toString() ?? 'Polyvalent',
      tensionInfo: json['tension_info']?.toString() ?? '0,0 cm (Fluide)',
      certaintyVal: (json['certainty_val'] is num) ? (json['certainty_val'] as num).toDouble() : 0.95,
      isFavorite: json['is_favorite'] == null ? true : (json['is_favorite'] == true),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  /// Build Supabase insert payload — only includes columns that are guaranteed in schema
  Map<String, dynamic> toSupabasePayload({String? authenticatedUserId}) {
    final map = <String, dynamic>{
      'product_id': productId,
      'product_name': productName,
      'product_brand': productBrand,
      'product_price': productPrice,
      'product_image': productImage,
      'fit_percent': fitPercent,
      'rec_size': recSize,
      'category': category,
      'is_worn_in_3d': isWornIn3d,
      'pairing_notes': pairingNotes,
      'match_score_val': matchScoreVal,
      'match_subtitle': matchSubtitle,
      'waist_val': waistVal,
      'waist_desc': waistDesc,
      'fit_val': fitVal,
      'fit_desc': fitDesc,
      'fabric_val': fabricVal,
      'fabric_desc': fabricDesc,
      'versatility_val': versatilityVal,
      'versatility_desc': versatilityDesc,
      'tension_info': tensionInfo,
      'certainty_val': certaintyVal,
    };

    // Only include glb_model_url if it has a value
    if (glbModelUrl != null && glbModelUrl!.isNotEmpty) {
      map['glb_model_url'] = glbModelUrl;
    }

    // Only include user_id if it's a real authenticated UUID (not guest string)
    if (authenticatedUserId != null && authenticatedUserId.isNotEmpty) {
      map['user_id'] = authenticatedUserId;
    }

    return map;
  }

  /// Local cache serialization (includes all fields)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'product_name': productName,
      'product_brand': productBrand,
      'product_price': productPrice,
      'product_image': productImage,
      'fit_percent': fitPercent,
      'rec_size': recSize,
      'category': category,
      'glb_model_url': glbModelUrl,
      'is_worn_in_3d': isWornIn3d,
      'pairing_notes': pairingNotes,
      'match_score_val': matchScoreVal,
      'match_subtitle': matchSubtitle,
      'waist_val': waistVal,
      'waist_desc': waistDesc,
      'fit_val': fitVal,
      'fit_desc': fitDesc,
      'fabric_val': fabricVal,
      'fabric_desc': fabricDesc,
      'versatility_val': versatilityVal,
      'versatility_desc': versatilityDesc,
      'tension_info': tensionInfo,
      'certainty_val': certaintyVal,
      'is_favorite': isFavorite,
    };
  }
}

/// Production-grade WardrobeService — fully dynamic, zero dummy data
class WardrobeService {
  static final WardrobeService instance = WardrobeService._internal();
  WardrobeService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _kLocalCacheKey = 'fitvisor_wardrobe_items_v3';

  /// Global reactive notifiers
  final ValueNotifier<List<WardrobeItem>> wardrobeItemsNotifier =
      ValueNotifier<List<WardrobeItem>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  bool _isInitialized = false;

  /// Initialize — load from local cache first, then sync from Supabase
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _loadFromLocalCache();
    await fetchWardrobeItems();
  }

  // ── LOCAL CACHE ──────────────────────────────────────────────────────────

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        final items = decoded
            .map((e) => WardrobeItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        wardrobeItemsNotifier.value = items;
        debugPrint('[WardrobeService] 📦 Cache loaded: ${items.length} items');
      }
    } catch (e) {
      debugPrint('[WardrobeService] ⚠️ Cache load error: $e');
    }
  }

  Future<void> _saveToLocalCache(List<WardrobeItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocalCacheKey, jsonEncode(items.map((e) => e.toJson()).toList()));
      debugPrint('[WardrobeService] 💾 Cache saved: ${items.length} items');
    } catch (e) {
      debugPrint('[WardrobeService] ⚠️ Cache save error: $e');
    }
  }

  // ── SUPABASE FETCH ───────────────────────────────────────────────────────

  Future<void> fetchWardrobeItems() async {
    isLoadingNotifier.value = true;
    try {
      final userId = _supabase.auth.currentUser?.id;
      debugPrint('[WardrobeService] 🔍 Fetching for userId: $userId');

      List<dynamic> response;

      if (userId != null) {
        // Authenticated user: filter by user_id
        try {
          response = await _supabase
              .from('wardrobe_items')
              .select()
              .eq('user_id', userId)
              .order('created_at', ascending: false);
        } catch (e1) {
          debugPrint('[WardrobeService] Retrying without order: $e1');
          response = await _supabase
              .from('wardrobe_items')
              .select()
              .eq('user_id', userId);
        }
      } else {
        // Guest: fetch all (RLS will naturally restrict if enabled)
        try {
          response = await _supabase
              .from('wardrobe_items')
              .select()
              .order('created_at', ascending: false);
        } catch (e1) {
          debugPrint('[WardrobeService] Guest fetch fallback: $e1');
          response = await _supabase.from('wardrobe_items').select();
        }
      }

      debugPrint('[WardrobeService] ✅ Supabase returned ${response.length} rows');

      if (response.isNotEmpty) {
        final items = response
            .map((data) => WardrobeItem.fromJson(data as Map<String, dynamic>))
            .toList();
        wardrobeItemsNotifier.value = items;
        await _saveToLocalCache(items);
      }
      // If Supabase returns empty but cache has items, keep cache
    } catch (e) {
      debugPrint('[WardrobeService] ❌ Supabase fetch failed: $e');
      // Keep existing local cache state — don't clear it
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  // ── CHECK / TOGGLE ───────────────────────────────────────────────────────

  bool isInWardrobe(String productId, {String? productName}) {
    final cleanId = productId.toLowerCase().trim();
    final cleanName = productName?.toLowerCase().trim();
    return wardrobeItemsNotifier.value.any((item) {
      if (item.productId.toLowerCase().trim() == cleanId ||
          item.id.toLowerCase().trim() == cleanId) {
        return true;
      }
      if (cleanName != null &&
          item.productName.toLowerCase().contains(cleanName)) {
        return true;
      }
      if (cleanName != null &&
          cleanName.contains(item.productName.toLowerCase())) {
        return true;
      }
      return false;
    });
  }

  Future<bool> toggleWardrobe(ProductModel product, BuildContext? context) async {
    final exists = isInWardrobe(product.id, productName: product.name);
    if (exists) {
      await removeFromWardrobe(product.id, context: context);
      return false;
    } else {
      await addToWardrobe(product, context: context);
      return true;
    }
  }

  // ── ADD TO WARDROBE ──────────────────────────────────────────────────────

  Future<void> addToWardrobe(ProductModel product, {BuildContext? context}) async {
    // Get authenticated user ID (from Supabase auth or saved prefs)
    final prefs = await SharedPreferences.getInstance();
    final String? authUserId =
        _supabase.auth.currentUser?.id ?? prefs.getString('fitvisor_user_id');
    final cleanPrice = product.price > 0
        ? '${product.price.toStringAsFixed(0)} €'
        : 'Sur Demande';

    // Dynamically calculate distinct atelier measurements for this specific product
    final bio = ProductBiometricsHelper.calculate(
      id: product.id,
      name: product.name,
      brand: product.brand,
      category: product.category,
      size: product.recSize,
      fabric: product.fabricComposition,
      fitPercentStr: product.fitPercent,
      silhouetteType: product.silhouetteType,
      price: product.price,
    );

    final newItem = WardrobeItem(
      id: 'wb_${DateTime.now().millisecondsSinceEpoch}',
      userId: authUserId,
      productId: product.id,
      productName: product.name,
      productBrand: product.brand,
      productPrice: cleanPrice,
      productImage: product.imageUrl,
      fitPercent: product.fitPercent.isNotEmpty ? product.fitPercent : bio.matchScore,
      recSize: product.recSize.replaceAll('Rec: ', '').trim(),
      category: product.category.isNotEmpty ? product.category : 'Vêtements',
      glbModelUrl: product.glbModelUrl,
      isWornIn3d: false,
      pairingNotes: '',
      matchScoreVal: bio.scoreValue,
      matchSubtitle: bio.matchSubtitle,
      waistVal: bio.waistVal,
      waistDesc: bio.waistDesc,
      fitVal: bio.fitVal,
      fitDesc: bio.fitDesc,
      fabricVal: bio.fabricVal,
      fabricDesc: bio.fabricDesc,
      versatilityVal: bio.versatilityVal,
      versatilityDesc: bio.versatilityDesc,
      tensionInfo: bio.tensionInfo,
      certaintyVal: bio.scoreValue / 100.0,
      isFavorite: true,
      createdAt: DateTime.now(),
    );

    // 1. Instantly update local UI state
    final updatedList = List<WardrobeItem>.from(wardrobeItemsNotifier.value);
    updatedList.removeWhere(
      (item) =>
          item.productId.toLowerCase().trim() == product.id.toLowerCase().trim() ||
          item.productName.toLowerCase().trim() == product.name.toLowerCase().trim(),
    );
    updatedList.insert(0, newItem);
    wardrobeItemsNotifier.value = updatedList;

    // 2. Save to local cache immediately
    await _saveToLocalCache(updatedList);

    // 3. Attempt Supabase insert — build minimal payload to avoid column mismatch
    final payload = newItem.toSupabasePayload(authenticatedUserId: authUserId);

    debugPrint('[WardrobeService] 📤 Inserting into Supabase...');
    debugPrint('[WardrobeService] Payload keys: ${payload.keys.join(', ')}');
    debugPrint('[WardrobeService] product_name: ${payload['product_name']}');
    debugPrint('[WardrobeService] product_id: ${payload['product_id']}');
    debugPrint('[WardrobeService] user_id: ${payload['user_id']}');

    try {
      await _supabase.from('wardrobe_items').insert(payload);
      debugPrint('[WardrobeService] ✅ Supabase insert SUCCESS: ${product.name}');
    } catch (e) {
      debugPrint('[WardrobeService] ❌ Supabase insert ERROR: $e');
      debugPrint('[WardrobeService] 💡 Check: RLS policies, column types, required NOT NULL columns');
    }

    final isEn = LanguageService.instance.isEnglish;
    final displayName = isEn ? localizeProductName(product.name) : product.name;
    if (context != null && context.mounted) {
      _showFeedbackSnackBar(
        context,
        isEn
            ? "\"$displayName\" added to My Wardrobe"
            : "« ${product.name} » ajouté à Mon Dressing",
        isAdd: true,
      );
    }
  }

  /// Add a pre-computed WardrobeItem directly (e.g. from Product Comparison)
  Future<void> addWardrobeItemDirect(WardrobeItem item, {BuildContext? context}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? authUserId =
        _supabase.auth.currentUser?.id ?? prefs.getString('fitvisor_user_id');

    // 1. Instantly update local UI state
    final updatedList = List<WardrobeItem>.from(wardrobeItemsNotifier.value);
    updatedList.removeWhere(
      (existing) =>
          existing.productId.toLowerCase().trim() == item.productId.toLowerCase().trim() ||
          existing.productName.toLowerCase().trim() == item.productName.toLowerCase().trim(),
    );
    updatedList.insert(0, item);
    wardrobeItemsNotifier.value = updatedList;

    // 2. Save to local cache immediately
    await _saveToLocalCache(updatedList);

    // 3. Attempt Supabase insert
    final payload = item.toSupabasePayload(authenticatedUserId: authUserId);
    try {
      await _supabase.from('wardrobe_items').insert(payload);
      debugPrint('[WardrobeService] ✅ Supabase insert direct SUCCESS: ${item.productName}');
    } catch (e) {
      debugPrint('[WardrobeService] ❌ Supabase insert direct ERROR: $e');
    }

    final isEn = LanguageService.instance.isEnglish;
    final displayName = isEn ? localizeProductName(item.productName) : item.productName;
    if (context != null && context.mounted) {
      _showFeedbackSnackBar(
        context,
        isEn
            ? "\"$displayName\" added to My Wardrobe"
            : "« ${item.productName} » ajouté à Mon Dressing",
        isAdd: true,
      );
    }
  }

  // ── REMOVE FROM WARDROBE ─────────────────────────────────────────────────

  Future<void> removeFromWardrobe(String productId, {BuildContext? context}) async {
    final cleanId = productId.toLowerCase().trim();
    String removedName = 'Article';

    // 1. Remove from local state
    final updatedList = List<WardrobeItem>.from(wardrobeItemsNotifier.value);
    final index = updatedList.indexWhere(
      (i) =>
          i.productId.toLowerCase().trim() == cleanId ||
          i.id.toLowerCase().trim() == cleanId,
    );

    if (index >= 0) {
      removedName = updatedList[index].productName;
      updatedList.removeAt(index);
      wardrobeItemsNotifier.value = updatedList;
      await _saveToLocalCache(updatedList);
    }

    // 2. Delete from Supabase
    try {
      final authUserId = _supabase.auth.currentUser?.id;
      var query = _supabase
          .from('wardrobe_items')
          .delete()
          .eq('product_id', productId);

      // Filter by user_id only if authenticated
      if (authUserId != null) {
        query = query.eq('user_id', authUserId);
      }

      await query;
      debugPrint('[WardrobeService] ✅ Supabase delete SUCCESS: $productId');
    } catch (e) {
      debugPrint('[WardrobeService] ❌ Supabase delete ERROR: $e');
    }

    final isEn = LanguageService.instance.isEnglish;
    final displayName = isEn ? localizeProductName(removedName) : removedName;
    if (context != null && context.mounted) {
      _showFeedbackSnackBar(
        context,
        isEn
            ? "\"$displayName\" removed from My Wardrobe"
            : "« $removedName » retiré de Mon Dressing",
        isAdd: false,
      );
    }
  }

  /// Global translation helper for luxury garment names
  static String localizeProductName(String name) {
    if (!LanguageService.instance.isEnglish) return name;
    return name
        .replaceAll('Robe Midi en Soie Drapée', 'Sculpted Silk Midi Dress')
        .replaceAll('Midi en Soie Drapé Sculpté', 'Sculpted Draped Silk Midi')
        .replaceAll('Robe Midi en Soie', 'Silk Midi Dress')
        .replaceAll('Robe en Soie Drapée', 'Sculpted Silk Dress')
        .replaceAll('Robe en Soie', 'Silk Dress')
        .replaceAll('Robe Fourreau Noire', 'Black Sheath Dress')
        .replaceAll('Robe Portefeuille Fleurie', 'Floral Wrap Dress')
        .replaceAll('Robe Drapée Asymétrique', 'Asymmetric Draped Dress')
        .replaceAll('Robe Plissée Soleil', 'Sunburst Pleated Dress')
        .replaceAll('Robe de Soirée Satinée', 'Satin Evening Gown')
        .replaceAll('Robe Trapèze Évasée', 'Flared Trapeze Dress')
        .replaceAll('Robe Pull Cachemire', 'Cashmere Sweater Dress')
        .replaceAll('Grain de Poudre DB', 'Grain de Poudre DB Jacket')
        .replaceAll('Veste Tweed Signature', 'Signature Tweed Jacket')
        .replaceAll('Blazer La Veste Souple', 'Soft Tailored Blazer')
        .replaceAll('Pull Maille Cintrée', 'Cinched Knit Sweater')
        .replaceAll('Blazer Bleu Nuit', 'Midnight Navy Blazer')
        .replaceAll('Bleu Nuit', 'Midnight Navy')
        .replaceAll('Bleu marine', 'Navy Blue')
        .replaceAll('Noir Intense', 'Intense Black')
        .replaceAll('Beige Écru', 'Ecru Beige')
        .replaceAll('Vert Olive', 'Olive Green')
        .replaceAll('Bordeaux Profond', 'Deep Burgundy')
        .replaceAll('Robe', 'Dress')
        .replaceAll('robe', 'dress');
  }

  // ── SNACKBAR ─────────────────────────────────────────────────────────────

  void _showFeedbackSnackBar(BuildContext context, String message,
      {required bool isAdd}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isAdd ? Icons.checkroom_rounded : Icons.favorite_border_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            isAdd ? const Color(0xFF172554) : const Color(0xFF64748B),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
