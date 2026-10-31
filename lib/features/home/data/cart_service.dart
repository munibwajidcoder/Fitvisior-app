import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';
import 'product_service.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String title;
  final String brand;
  final String? imageUrl;
  final String size;
  final String color;
  final double unitPrice;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool inStock;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.brand,
    this.imageUrl,
    required this.size,
    required this.color,
    required this.unitPrice,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.inStock = true,
  });

  double get totalPrice => unitPrice * quantity;

  String get displayTitle => AppStrings.translateProduct(title, LanguageService.instance.currentLanguage);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      title: json['title'] ?? 'Product',
      brand: json['brand'] ?? 'DresKode',
      imageUrl: json['image_url'],
      size: json['size'] ?? 'M',
      color: json['color'] ?? 'Noir',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      inStock: true,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'brand': brand,
      'image_url': imageUrl,
      'size': size,
      'color': color,
      'unit_price': unitPrice,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'in_stock': inStock,
    };
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'product_id': productId,
      'title': title,
      'brand': brand,
      'image_url': imageUrl,
      'size': size,
      'color': color,
      'unit_price': unitPrice,
      'quantity': quantity,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

class CartService {
  static final CartService instance = CartService._internal();
  CartService._internal();

  static const String _kLocalCartCacheKey = 'fitvisor_cart_items_v2';

  static final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<List<CartItemModel>> cartItemsNotifier =
      ValueNotifier<List<CartItemModel>>([]);

  SupabaseClient get _client => Supabase.instance.client;

  /// Returns active Supabase User ID, cached fitvisor_user_id, or default guest UUID
  Future<String> getEffectiveUserId() async {
    final authId = _client.auth.currentUser?.id;
    if (authId != null && authId.isNotEmpty) return authId;
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('fitvisor_user_id');
    if (savedId != null && savedId.isNotEmpty) return savedId;
    String? guestUuid = prefs.getString('fitvisor_guest_cart_uuid');
    if (guestUuid == null || guestUuid.isEmpty) {
      guestUuid = '00000000-0000-0000-0000-000000000001';
      await prefs.setString('fitvisor_guest_cart_uuid', guestUuid);
    }
    return guestUuid;
  }

  bool _isInitialized = false;

  /// Initialize local storage cache and sync with Supabase
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await _loadFromLocalCache();
    await getCartItems();
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalCartCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        final items = decoded.map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
        cartItemsNotifier.value = items;
        cartCountNotifier.value = items.fold(0, (sum, i) => sum + i.quantity);
        debugPrint('[CartService] 📦 Loaded ${items.length} items from local cache (Count: ${cartCountNotifier.value})');
      }
    } catch (e) {
      debugPrint('[CartService] ⚠️ Error loading local cart cache: $e');
    }
  }

  Future<void> _saveToLocalCache(List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(items.map((e) => e.toLocalJson()).toList());
      await prefs.setString(_kLocalCartCacheKey, jsonStr);
      cartItemsNotifier.value = items;
      cartCountNotifier.value = items.fold(0, (sum, i) => sum + i.quantity);
      debugPrint('[CartService] 💾 Saved ${items.length} items to local storage. Total quantity badge: ${cartCountNotifier.value}');
    } catch (e) {
      debugPrint('[CartService] ⚠️ Error saving local cart cache: $e');
    }
  }

  /// Fetch all cart items from Supabase or fallback to local cache
  Future<List<CartItemModel>> getCartItems() async {
    if (!_isInitialized) {
      await initialize();
      return cartItemsNotifier.value;
    }

    final userId = await getEffectiveUserId();
    debugPrint('[CartService] 🔍 getCartItems() called. Current UserId: $userId');

    try {
      debugPrint('[CartService] 🌐 Fetching from Supabase table cart_items for user: $userId');
      final res = await _client
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final remoteItems = (res as List).map((row) => CartItemModel.fromJson(row)).toList();
      debugPrint('[CartService] ✅ Supabase returned ${remoteItems.length} items.');

      if (remoteItems.isNotEmpty) {
        await _saveToLocalCache(remoteItems);
        return remoteItems;
      } else if (cartItemsNotifier.value.isNotEmpty) {
        debugPrint('[CartService] ℹ️ Keeping ${cartItemsNotifier.value.length} local items since remote returned empty.');
        return cartItemsNotifier.value;
      } else {
        await _saveToLocalCache([]);
        return [];
      }
    } catch (e) {
      debugPrint('[CartService] ⚠️ Error fetching from Supabase (RLS or Network): $e');
      debugPrint('[CartService] ℹ️ Falling back to ${cartItemsNotifier.value.length} items in local cache.');
      return cartItemsNotifier.value;
    }
  }

  /// Add a product to the cart or increment quantity if already present
  Future<bool> addToCart({
    required ProductModel product,
    String? selectedSize,
    String? selectedColor,
    int quantity = 1,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final size = selectedSize ?? (product.availableSizes.isNotEmpty ? product.availableSizes.first : 'M');
    final color = selectedColor ?? (product.availableColors.isNotEmpty ? product.availableColors.first['name'] ?? 'Noir' : 'Noir');
    final price = product.price;

    debugPrint('[CartService] 🛒 addToCart called: "${product.name}" (id: ${product.id}), size: $size, color: $color, qty: $quantity, price: €$price');

    // 1. Instantly update local list and persistent cache
    final currentList = List<CartItemModel>.from(cartItemsNotifier.value);
    final existingIndex = currentList.indexWhere(
      (i) => i.productId == product.id && i.size == size && i.color == color,
    );

    String assignedId = DateTime.now().millisecondsSinceEpoch.toString();
    if (existingIndex >= 0) {
      final existing = currentList[existingIndex];
      assignedId = existing.id;
      currentList[existingIndex] = CartItemModel(
        id: existing.id,
        productId: existing.productId,
        title: existing.title,
        brand: existing.brand,
        imageUrl: existing.imageUrl,
        size: existing.size,
        color: existing.color,
        unitPrice: existing.unitPrice,
        quantity: existing.quantity + quantity,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        inStock: existing.inStock,
      );
      debugPrint('[CartService] 🔄 Incremented quantity in local cache to ${currentList[existingIndex].quantity}');
    } else {
      final newItem = CartItemModel(
        id: assignedId,
        productId: product.id,
        title: product.name,
        brand: product.brand,
        imageUrl: product.imageUrl,
        size: size,
        color: color,
        unitPrice: price,
        quantity: quantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        inStock: true,
      );
      currentList.insert(0, newItem);
      debugPrint('[CartService] ➕ Inserted new item into local cache: "${newItem.title}"');
    }

    await _saveToLocalCache(currentList);

    // 2. Sync to Supabase in the background
    final userId = await getEffectiveUserId();
    debugPrint('[CartService] 👤 Syncing to Supabase (User ID: $userId)');

    try {
      final existing = await _client
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .eq('product_id', product.id)
          .eq('size', size)
          .eq('color', color)
          .maybeSingle();

      if (existing != null) {
        final currentQty = (existing['quantity'] as num).toInt();
        await _client.from('cart_items').update({
          'quantity': currentQty + quantity,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', existing['id']);
        debugPrint('[CartService] ✅ Supabase cart item updated successfully.');
      } else {
        try {
          final inserted = await _client.from('cart_items').insert({
            'user_id': userId,
            'product_id': product.id,
            'title': product.name,
            'brand': product.brand,
            'image_url': product.imageUrl,
            'size': size,
            'color': color,
            'unit_price': price,
            'quantity': quantity,
            'created_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }).select().maybeSingle();
          debugPrint('[CartService] ✅ Supabase cart item inserted successfully: $inserted');
        } catch (firstErr) {
          debugPrint('[CartService] ⚠️ Standard insert failed: $firstErr. Retrying resilient insert...');
          await _client.from('cart_items').insert({
            'user_id': userId,
            'product_id': product.id,
            'title': product.name,
            'brand': product.brand,
            'image_url': product.imageUrl,
            'size': size,
            'color': color,
            'unit_price': price,
            'quantity': quantity,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
          debugPrint('[CartService] ✅ Supabase cart item inserted via fallback.');
        }
      }
    } catch (e) {
      debugPrint('[CartService] ⚠️ Supabase sync error: $e');
      debugPrint('[CartService] ℹ️ Safe: Item is persisted locally, cart is NOT empty!');
    }

    return true;
  }

  /// Change quantity (+1 / -1)
  Future<void> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    final currentList = List<CartItemModel>.from(cartItemsNotifier.value);
    final idx = currentList.indexWhere((i) => i.id == cartItemId);
    if (idx >= 0) {
      final item = currentList[idx];
      currentList[idx] = CartItemModel(
        id: item.id,
        productId: item.productId,
        title: item.title,
        brand: item.brand,
        imageUrl: item.imageUrl,
        size: item.size,
        color: item.color,
        unitPrice: item.unitPrice,
        quantity: newQuantity,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
        inStock: item.inStock,
      );
      await _saveToLocalCache(currentList);
    }

    final userId = await getEffectiveUserId();
    try {
      await _client.from('cart_items').update({
        'quantity': newQuantity,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', cartItemId).eq('user_id', userId);
      debugPrint('[CartService] ✅ Supabase quantity updated.');
    } catch (e) {
      debugPrint('[CartService] ⚠️ Supabase update error: $e');
    }
  }

  /// Update item variant (e.g. from Change Size & Color Screen)
  Future<void> updateVariant(String cartItemId, {required String newSize, required String newColor}) async {
    final currentList = List<CartItemModel>.from(cartItemsNotifier.value);
    final idx = currentList.indexWhere((i) => i.id == cartItemId);
    if (idx >= 0) {
      final item = currentList[idx];
      currentList[idx] = CartItemModel(
        id: item.id,
        productId: item.productId,
        title: item.title,
        brand: item.brand,
        imageUrl: item.imageUrl,
        size: newSize,
        color: newColor,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
        createdAt: item.createdAt,
        updatedAt: DateTime.now(),
        inStock: item.inStock,
      );
      await _saveToLocalCache(currentList);
    }

    final userId = await getEffectiveUserId();
    try {
      await _client.from('cart_items').update({
        'size': newSize,
        'color': newColor,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', cartItemId).eq('user_id', userId);
      debugPrint('[CartService] ✅ Supabase variant updated.');
    } catch (e) {
      debugPrint('[CartService] ⚠️ Supabase variant update error: $e');
    }
  }

  /// Remove item from cart
  Future<void> removeItem(String cartItemId) async {
    final currentList = List<CartItemModel>.from(cartItemsNotifier.value);
    currentList.removeWhere((i) => i.id == cartItemId);
    await _saveToLocalCache(currentList);

    final userId = await getEffectiveUserId();
    try {
      await _client.from('cart_items').delete().eq('id', cartItemId).eq('user_id', userId);
      debugPrint('[CartService] ✅ Removed item from Supabase.');
    } catch (e) {
      debugPrint('[CartService] ⚠️ Supabase remove error: $e');
    }
  }

  /// Clear user's cart upon order completion
  Future<void> clearCart() async {
    await _saveToLocalCache([]);
    cartItemsNotifier.value = [];
    cartCountNotifier.value = 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLocalCartCacheKey);
    } catch (_) {}

    final userId = await getEffectiveUserId();
    try {
      await _client.from('cart_items').delete().eq('user_id', userId);
      debugPrint('[CartService] ✅ Cleared Supabase cart items for user $userId.');
    } catch (e) {
      debugPrint('[CartService] ⚠️ Supabase clear cart error: $e');
    }
  }
}

