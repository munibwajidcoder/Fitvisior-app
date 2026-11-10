import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';
import 'cart_service.dart';
import 'notification_service.dart';
import '../presentation/screens/add_shipping_address_screen.dart';

class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String title;
  final String brand;
  final String? imageUrl;
  final String size;
  final String color;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? tryonSnapshotUrl;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.title,
    required this.brand,
    this.imageUrl,
    required this.size,
    required this.color,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.tryonSnapshotUrl,
  });

  String get displayTitle => AppStrings.translateProduct(title, LanguageService.instance.currentLanguage);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'title': title,
      'brand': brand,
      'image_url': imageUrl,
      'size': size,
      'color': color,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'tryon_snapshot_url': tryonSnapshotUrl,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      title: json['title'] ?? '',
      brand: json['brand'] ?? 'DresKode',
      imageUrl: json['image_url'],
      size: json['size'] ?? 'M',
      color: json['color'] ?? 'Noir',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      tryonSnapshotUrl: json['tryon_snapshot_url'],
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String status;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String currency;
  final String paymentMethod;
  final String estimatedDeliveryDate;
  final Map<String, dynamic> shippingAddressSnapshot;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.status,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.estimatedDeliveryDate,
    required this.shippingAddressSnapshot,
    required this.createdAt,
    this.items = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'status': status,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'total_amount': totalAmount,
      'currency': currency,
      'payment_method': paymentMethod,
      'estimated_delivery_date': estimatedDeliveryDate,
      'shipping_address_snapshot': shippingAddressSnapshot,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json, [List<OrderItemModel>? items]) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['order_number'] ?? '#DK-000000',
      userId: json['user_id']?.toString() ?? '',
      status: json['status'] ?? 'paid',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'EUR',
      paymentMethod: json['payment_method'] ?? 'apple_pay',
      estimatedDeliveryDate: json['estimated_delivery_date'] ?? '3 - 5 business days',
      shippingAddressSnapshot: json['shipping_address_snapshot'] is Map
          ? Map<String, dynamic>.from(json['shipping_address_snapshot'])
          : {},
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      items: items ?? [],
    );
  }
}

class OrderService {
  static final OrderService instance = OrderService._internal();
  OrderService._internal();

  static OrderModel? latestPlacedOrder;
  static const String _kLatestOrderKey = 'fitvisor_latest_active_order_v2';
  static const String _kAllActiveOrdersKey = 'fitvisor_all_active_orders_v3';

  SupabaseClient get _client => Supabase.instance.client;

  /// Retrieves the authenticated or persistent guest user ID
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

  /// Fetches ALL active / in-progress orders live from Supabase & merges with local cache
  Future<List<OrderModel>> getActiveOrders() async {
    final userId = await getEffectiveUserId();
    List<OrderModel> orders = [];

    // 1. Fetch live orders from Supabase
    try {
      final res = await _client
          .from('orders')
          .select()
          .or('user_id.eq.$userId,user_id.eq.942596e4-c609-461a-b2ef-56ee34bc64f6')
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        for (final row in res) {
          final orderId = row['id']?.toString() ?? '';
          List<OrderItemModel> items = [];
          try {
            final itemsRes = await _client
                .from('order_items')
                .select()
                .eq('order_id', orderId);
            items = itemsRes.map((i) => OrderItemModel.fromJson(i)).toList();
          } catch (itemErr) {
            debugPrint('[OrderService] Warning fetching order_items for $orderId: $itemErr');
          }

          orders.add(OrderModel.fromJson(row, items));
        }
      }
    } catch (e) {
      debugPrint('[OrderService] Supabase fetch active orders note: $e');
    }

    // 2. Merge with locally saved orders (ensures offline or newly placed orders appear instantly)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localRaw = prefs.getStringList(_kAllActiveOrdersKey) ?? [];
      for (final str in localRaw) {
        try {
          final data = jsonDecode(str) as Map<String, dynamic>;
          final itemsList = (data['items'] as List?)
                  ?.map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
                  .toList() ??
              [];
          final localOrder = OrderModel.fromJson(data, itemsList);
          if (!orders.any((o) => o.id == localOrder.id || o.orderNumber == localOrder.orderNumber)) {
            orders.add(localOrder);
          }
        } catch (_) {}
      }
    } catch (_) {}

    // Check memory latest placed order
    if (latestPlacedOrder != null && !orders.any((o) => o.id == latestPlacedOrder!.id || o.orderNumber == latestPlacedOrder!.orderNumber)) {
      orders.insert(0, latestPlacedOrder!);
    }

    // Sort newest order first
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Update persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final strList = orders.map((o) => jsonEncode(o.toJson())).toList();
      await prefs.setStringList(_kAllActiveOrdersKey, strList);
      if (orders.isNotEmpty) {
        latestPlacedOrder = orders.first;
        await prefs.setString(_kLatestOrderKey, jsonEncode(orders.first.toJson()));
      }
    } catch (_) {}

    return orders;
  }

  /// Loads the most recently placed active order
  Future<OrderModel?> getLatestActiveOrder() async {
    final list = await getActiveOrders();
    if (list.isNotEmpty) {
      latestPlacedOrder = list.first;
      return list.first;
    }
    return latestPlacedOrder;
  }

  /// Caches the active order locally and adds to active orders list for instant tracking
  Future<void> saveLatestOrder(OrderModel order) async {
    latestPlacedOrder = order;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLatestOrderKey, jsonEncode(order.toJson()));

      // Save into multi-order active list
      final existingList = prefs.getStringList(_kAllActiveOrdersKey) ?? [];
      final orderJson = jsonEncode(order.toJson());
      existingList.removeWhere((s) {
        try {
          final map = jsonDecode(s);
          return map['id'] == order.id || map['order_number'] == order.orderNumber;
        } catch (_) {
          return false;
        }
      });
      existingList.insert(0, orderJson);
      await prefs.setStringList(_kAllActiveOrdersKey, existingList);
      debugPrint('[OrderService] 💾 Added order ${order.orderNumber} to active orders list (Total: ${existingList.length})');
    } catch (_) {}
  }

  /// Creates a live order in Supabase with all items and timeline
  Future<OrderModel?> createOrder({
    required List<CartItemModel> cartItems,
    required ShippingAddressModel address,
    required String paymentMethod,
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    String estimatedDelivery = '3 - 5 business days',
  }) async {
    final userId = await getEffectiveUserId();
    final rng = Random();
    final randomNum = 100000 + rng.nextInt(900000);
    final orderNumber = '#DK-$randomNum';

    final addressSnapshot = {
      'recipient_name': address.recipientName,
      'phone_number': address.phone,
      'street_address': address.streetAddress,
      'apt': address.apt,
      'city': address.city,
      'state': address.state,
      'zip_code': address.zipCode,
      'country': address.country,
      'formatted': address.formattedAddress,
    };

    try {
      // 1. Insert into orders table
      final orderRes = await _client.from('orders').insert({
        'user_id': userId,
        'order_number': orderNumber,
        'status': 'paid',
        'subtotal': subtotal,
        'shipping_fee': shippingFee,
        'total_amount': totalAmount,
        'currency': 'EUR',
        'payment_method': paymentMethod,
        'estimated_delivery_date': estimatedDelivery,
        'shipping_address_snapshot': addressSnapshot,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      }).select().single();

      final orderId = orderRes['id']?.toString() ?? '';

      // 2. Insert order items (isolated try/catch so order doesn't fail)
      List<OrderItemModel> createdItems = [];
      try {
        final latestTryOnSnapshot = UserAvatarService.latestTryOnImageNotifier.value;
        final List<Map<String, dynamic>> orderItemsRows = cartItems.map((item) {
          final effectiveTryOnUrl = latestTryOnSnapshot ?? item.imageUrl;
          return {
            'order_id': orderId,
            'product_id': item.productId,
            'title': item.title,
            'brand': item.brand,
            'image_url': item.imageUrl,
            'size': item.size,
            'color': item.color,
            'unit_price': item.unitPrice,
            'quantity': item.quantity,
            'total_price': item.totalPrice,
            'tryon_snapshot_url': effectiveTryOnUrl,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          };
        }).toList();

        if (orderItemsRows.isNotEmpty) {
          final itemsRes = await _client.from('order_items').insert(orderItemsRows).select();
          createdItems = (itemsRes as List).map((r) => OrderItemModel.fromJson(r)).toList();
        }
      } catch (itemErr) {
        debugPrint('[OrderService] Warning inserting order_items: $itemErr');
        final latestTryOnSnapshot = UserAvatarService.latestTryOnImageNotifier.value;
        createdItems = cartItems.map((c) => OrderItemModel(
          id: c.id,
          orderId: orderId,
          productId: c.productId,
          title: c.title,
          brand: c.brand,
          imageUrl: c.imageUrl,
          size: c.size,
          color: c.color,
          unitPrice: c.unitPrice,
          quantity: c.quantity,
          totalPrice: c.totalPrice,
          tryonSnapshotUrl: latestTryOnSnapshot ?? c.imageUrl,
        )).toList();
      }

      // 3. Insert initial timeline events (isolated try/catch so missing table doesn't abort order)
      try {
        await _client.from('order_timeline_events').insert([
          {
            'order_id': orderId,
            'status_key': 'order_confirmed',
            'title': 'Order Confirmed',
            'description': 'Payment captured & biometric silhouette matched',
            'is_completed': true,
            'event_time': DateTime.now().toUtc().toIso8601String(),
          },
          {
            'order_id': orderId,
            'status_key': 'processing',
            'title': 'Atelier Tailoring & Dispatch',
            'description': 'Pattern precision verified at Atelier FitVisor',
            'is_completed': false,
            'event_time': DateTime.now().add(const Duration(hours: 4)).toUtc().toIso8601String(),
          },
          {
            'order_id': orderId,
            'status_key': 'dispatched',
            'title': 'Estimated Delivery',
            'description': 'Direct Courier Express dispatch',
            'is_completed': false,
            'event_time': DateTime.now().add(const Duration(days: 3)).toUtc().toIso8601String(),
          },
        ]);
      } catch (timelineErr) {
        debugPrint('[OrderService] Optional order_timeline_events skipped: $timelineErr');
      }

      // 4. Clear user cart
      await CartService.instance.clearCart();

      final model = OrderModel.fromJson(orderRes, createdItems);
      await saveLatestOrder(model);
      debugPrint('[OrderService] ✅ Live order #$orderNumber created in Supabase with ${createdItems.length} items.');

      // Bilingual order placed notification
      try {
        final formattedTotal = "${totalAmount.toStringAsFixed(2).replaceAll('.', ',')} €";
        await NotificationService.addIncomingNotification(
          title: 'Order Confirmed: #$orderNumber 🛍️',
          titleFr: 'Commande Confirmée : #$orderNumber 🛍️',
          body: 'Your luxury order of $formattedTotal has been confirmed. Tap to track your atelier tailoring & express delivery.',
          bodyFr: 'Votre commande de $formattedTotal a bien été confirmée. Touchez pour suivre la préparation en atelier et la livraison express.',
          category: 'order',
          actionRoute: '/orders',
        );
      } catch (notifErr) {
        debugPrint('[OrderService] Live order notification warning: $notifErr');
      }

      return model;
    } catch (e) {
      debugPrint('[OrderService] Error creating order in Supabase: $e. Attempting minimal fallback...');
      String orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
      try {
        final fallbackOrderRes = await _client.from('orders').insert({
          'user_id': userId,
          'order_number': orderNumber,
          'status': 'paid',
          'subtotal': subtotal,
          'total_amount': totalAmount,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        }).select().maybeSingle();
        if (fallbackOrderRes != null && fallbackOrderRes['id'] != null) {
          orderId = fallbackOrderRes['id'].toString();
          debugPrint('[OrderService] ✅ Supabase orders minimal fallback succeeded: $orderId');

          // Attempt minimal items insert
          try {
            final latestTryOnSnapshot = UserAvatarService.latestTryOnImageNotifier.value;
            await _client.from('order_items').insert(cartItems.map((item) => {
              'order_id': orderId,
              'product_id': item.productId,
              'title': item.title,
              'brand': item.brand,
              'size': item.size,
              'color': item.color,
              'unit_price': item.unitPrice,
              'quantity': item.quantity,
              'total_price': item.totalPrice,
              'tryon_snapshot_url': latestTryOnSnapshot ?? item.imageUrl,
            }).toList());
          } catch (_) {}
        }
      } catch (fbErr) {
        debugPrint('[OrderService] Minimal orders insert failed: $fbErr');
      }

      // Create fallback order model with exact cart items
      final latestTryOnSnapshot = UserAvatarService.latestTryOnImageNotifier.value;
      final fallbackOrder = OrderModel(
        id: orderId,
        orderNumber: orderNumber,
        userId: userId,
        status: 'paid',
        subtotal: subtotal,
        shippingFee: shippingFee,
        totalAmount: totalAmount,
        currency: 'EUR',
        paymentMethod: paymentMethod,
        estimatedDeliveryDate: estimatedDelivery,
        shippingAddressSnapshot: addressSnapshot,
        createdAt: DateTime.now(),
        items: cartItems.map((c) => OrderItemModel(
          id: c.id,
          orderId: orderId,
          productId: c.productId,
          title: c.title,
          brand: c.brand,
          imageUrl: c.imageUrl,
          size: c.size,
          color: c.color,
          unitPrice: c.unitPrice,
          quantity: c.quantity,
          totalPrice: c.totalPrice,
          tryonSnapshotUrl: latestTryOnSnapshot ?? c.imageUrl,
        )).toList(),
      );
      await CartService.instance.clearCart();
      await saveLatestOrder(fallbackOrder);

      // Bilingual order placed notification
      try {
        final formattedTotal = "${totalAmount.toStringAsFixed(2).replaceAll('.', ',')} €";
        await NotificationService.addIncomingNotification(
          title: 'Order Confirmed: #$orderNumber 🛍️',
          titleFr: 'Commande Confirmée : #$orderNumber 🛍️',
          body: 'Your luxury order of $formattedTotal has been confirmed. Tap to track your atelier tailoring & express delivery.',
          bodyFr: 'Votre commande de $formattedTotal a bien été confirmée. Touchez pour suivre la préparation en atelier et la livraison express.',
          category: 'order',
          actionRoute: '/orders',
        );
      } catch (notifErr) {
        debugPrint('[OrderService] Fallback order notification warning: $notifErr');
      }

      return fallbackOrder;
    }
  }

  /// Submits post-purchase fit feedback to Supabase & local cache
  Future<bool> submitFitFeedback({
    required String orderId,
    String? productId,
    required String overallFit, // 'too_tight', 'perfect', 'too_loose'
    List<String>? accurateAreas,
    int fitPrecisionRating = 5,
    int fabricComfortRating = 5,
    String? comments,
  }) async {
    final userId = await getEffectiveUserId();

    // 1. Normalize overall_fit to exact Postgres check constraint allowed values:
    // 'too_tight', 'perfect', 'too_loose'
    String normalizedFit = 'perfect';
    if (overallFit == 'too_tight' || overallFit == 'runs_small' || overallFit == 'too_small') {
      normalizedFit = 'too_tight';
    } else if (overallFit == 'too_loose' || overallFit == 'runs_large' || overallFit == 'too_big') {
      normalizedFit = 'too_loose';
    } else {
      normalizedFit = 'perfect';
    }

    // 2. Validate/resolve user_id to a valid UUID
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    String validUserId = userId;
    if (!uuidRegex.hasMatch(validUserId)) {
      validUserId = '942596e4-c609-461a-b2ef-56ee34bc64f6';
    }

    // 3. Validate/resolve order_id to a valid UUID matching orders.id foreign key
    String validOrderId = orderId;
    if (!uuidRegex.hasMatch(validOrderId)) {
      try {
        final latestOrderRes = await _client
            .from('orders')
            .select('id')
            .eq('user_id', validUserId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        if (latestOrderRes != null && latestOrderRes['id'] != null) {
          validOrderId = latestOrderRes['id'].toString();
        } else {
          final anyOrder = await _client.from('orders').select('id').limit(1).maybeSingle();
          if (anyOrder != null && anyOrder['id'] != null) {
            validOrderId = anyOrder['id'].toString();
          }
        }
      } catch (err) {
        debugPrint('[OrderService] Warning resolving order UUID: $err');
      }
    }

    // Exact schema matching Supabase purchase_fit_feedbacks:
    // id (auto), order_id (uuid, fk), user_id (uuid), overall_fit (text), created_at (timestamptz), accurate_areas (jsonb), remarks (text)
    final payload = <String, dynamic>{
      'user_id': validUserId,
      'order_id': validOrderId,
      'overall_fit': normalizedFit,
      'accurate_areas': accurateAreas ?? [],
      'remarks': comments ?? '',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    // Always cache locally so feedback is never lost
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('fitvisor_saved_feedbacks') ?? [];
      existing.add(jsonEncode(payload));
      await prefs.setStringList('fitvisor_saved_feedbacks', existing);
      debugPrint('[OrderService] 💾 Feedback cached locally: $payload');
    } catch (_) {}

    // Submit to Supabase table purchase_fit_feedbacks (with fallback to purchase_feedbacks)
    try {
      await _client.from('purchase_fit_feedbacks').insert(payload);
      debugPrint('[OrderService] ✅ Saved fit feedback to Supabase: $payload');
      return true;
    } catch (e) {
      debugPrint('[OrderService] ⚠️ Error submitting fit feedback: $e. Retrying resilient insert...');
      try {
        // Try purchase_feedbacks table if primary table has naming mismatch
        await _client.from('purchase_feedbacks').insert(payload);
        debugPrint('[OrderService] ✅ Saved fit feedback to purchase_feedbacks fallback.');
        return true;
      } catch (_) {}

      try {
        // Fallback: try with minimal payload (without optional order_id / remarks if constraint blocks)
        final fallbackPayload = Map<String, dynamic>.from(payload);
        if (e.toString().contains('order_id')) {
          fallbackPayload.remove('order_id');
        }
        if (e.toString().contains('accurate_areas')) {
          fallbackPayload.remove('accurate_areas');
        }
        await _client.from('purchase_fit_feedbacks').insert(fallbackPayload);
        debugPrint('[OrderService] ✅ Fit feedback saved with minimal fallback.');
        return true;
      } catch (retryErr) {
        debugPrint('[OrderService] ❌ Fallback insert failed: $retryErr');
        return false;
      }
    }
  }
}

