import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PartnerStoreModel {
  final String id;
  final String brandName;
  final String storeName;
  final String address;
  final String city;
  final String distanceText;
  final List<String> availableSizes;
  final bool hasKiosk;
  final String websiteUrl;

  PartnerStoreModel({
    required this.id,
    required this.brandName,
    required this.storeName,
    required this.address,
    required this.city,
    required this.distanceText,
    required this.availableSizes,
    required this.hasKiosk,
    required this.websiteUrl,
  });

  factory PartnerStoreModel.fromMap(Map<String, dynamic> map) {
    return PartnerStoreModel(
      id: map['id']?.toString() ?? '',
      brandName: map['brand_name']?.toString() ?? 'Partner',
      storeName: map['store_name']?.toString() ?? 'Boutique Partenaire',
      address: map['address_line']?.toString() ?? 'Paris, France',
      city: map['city']?.toString() ?? 'Paris',
      distanceText: map['distance_text']?.toString() ?? '2.4 km',
      availableSizes: (map['available_sizes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['XS', 'S', 'M', 'L', 'XL'],
      hasKiosk: map['has_kiosk_borne'] == true,
      websiteUrl: map['website_url']?.toString() ?? 'https://www.fitvisor.app',
    );
  }
}

class StoreReservationModel {
  final String id;
  final String userId;
  final String activityType;
  final String brandName;
  final String storeName;
  final String productName;
  final String productSize;
  final String productImage;
  final String reservationCode;
  final String status;
  final int fitMatchPercent;
  final String notes;
  final DateTime expiresAt;
  final DateTime createdAt;

  StoreReservationModel({
    required this.id,
    required this.userId,
    this.activityType = 'reservation',
    this.brandName = 'Partner',
    required this.storeName,
    required this.productName,
    required this.productSize,
    required this.productImage,
    required this.reservationCode,
    required this.status,
    this.fitMatchPercent = 98,
    this.notes = '',
    required this.expiresAt,
    required this.createdAt,
  });

  factory StoreReservationModel.fromMap(Map<String, dynamic> map) {
    return StoreReservationModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      activityType: map['activity_type']?.toString() ?? 'reservation',
      brandName: map['brand_name']?.toString() ?? 'Partner',
      storeName: map['store_name']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      productSize: map['product_size']?.toString() ?? 'M',
      productImage: map['product_image']?.toString() ?? '',
      reservationCode: map['reservation_code']?.toString() ?? 'RES-1000',
      status: map['status']?.toString() ?? 'confirmed',
      fitMatchPercent: (map['fit_match_percent'] as num?)?.toInt() ?? 98,
      notes: map['notes']?.toString() ?? '',
      expiresAt: DateTime.tryParse(map['expires_at']?.toString() ?? '') ??
          DateTime.now().add(const Duration(hours: 48)),
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType,
      'brand_name': brandName,
      'store_name': storeName,
      'product_name': productName,
      'product_size': productSize,
      'product_image': productImage,
      'reservation_code': reservationCode,
      'status': status,
      'fit_match_percent': fitMatchPercent,
      'notes': notes,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class StorePartnershipService {
  static final StorePartnershipService instance =
      StorePartnershipService._internal();
  StorePartnershipService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  static const String _localReservationsKey =
      'fitvisor_local_store_reservations';

  /// Default fallback stores
  static final List<PartnerStoreModel> defaultStores = [
    PartnerStoreModel(
      id: 'store_zalando_paris',
      brandName: 'Zalando',
      storeName: 'Zalando Paris Hub (2.4 km)',
      address: '14 Rue de Rivoli, 75004 Paris',
      city: 'Paris',
      distanceText: '2.4 km',
      availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
      hasKiosk: true,
      websiteUrl: 'https://www.zalando.com',
    ),
    PartnerStoreModel(
      id: 'store_hm_champs',
      brandName: 'H&M',
      storeName: 'H&M Champs-Élysées (3.1 km)',
      address: '88 Avenue des Champs-Élysées, 75008 Paris',
      city: 'Paris',
      distanceText: '3.1 km',
      availableSizes: ['XS', 'S', 'M', 'L', 'XL'],
      hasKiosk: true,
      websiteUrl: 'https://www2.hm.com',
    ),
    PartnerStoreModel(
      id: 'store_zara_opera',
      brandName: 'Zara',
      storeName: 'Zara Opéra (3.8 km)',
      address: '2 Boulevard des Capucines, 75009 Paris',
      city: 'Paris',
      distanceText: '3.8 km',
      availableSizes: ['S', 'M', 'L'],
      hasKiosk: true,
      websiteUrl: 'https://www.zara.com',
    ),
    PartnerStoreModel(
      id: 'store_shein_pop_up',
      brandName: 'Shein',
      storeName: 'Shein Paris Pop-Up (4.0 km)',
      address: '40 Rue de Richelieu, 75001 Paris',
      city: 'Paris',
      distanceText: '4.0 km',
      availableSizes: ['XS', 'S', 'M', 'L'],
      hasKiosk: true,
      websiteUrl: 'https://www.shein.com',
    ),
  ];

  /// Get a guaranteed valid UUID format for user_id (never crashes UUID columns)
  Future<String> getEffectiveUserId() async {
    final authId = _client.auth.currentUser?.id;
    if (authId != null && authId.isNotEmpty) return authId;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('fitvisor_user_id');
      if (savedId != null && savedId.isNotEmpty) return savedId;
      final guestCartId = prefs.getString('fitvisor_guest_cart_uuid');
      if (guestCartId != null && guestCartId.isNotEmpty) return guestCartId;
    } catch (_) {}

    // Solid standard default UUID fallback
    return '00000000-0000-0000-0000-000000000001';
  }

  /// Fetch partner stores dynamically from Supabase
  Future<List<PartnerStoreModel>> getPartnerStores() async {
    try {
      final res = await _client
          .from('partner_stores')
          .select()
          .order('distance_text', ascending: true);

      final list =
          (res as List).map((row) => PartnerStoreModel.fromMap(row)).toList();
      if (list.isNotEmpty) {
        debugPrint(
            '✅ [StorePartnershipService] Loaded ${list.length} stores from Supabase partner_stores');
        return list;
      }
      return defaultStores;
    } catch (e) {
      debugPrint(
          'ℹ️ [StorePartnershipService] Supabase partner_stores fetch: $e');
      return defaultStores;
    }
  }

  /// Robust unified activity inserter for Supabase
  Future<Map<String, dynamic>?> _insertIntoSupabase(
      Map<String, dynamic> payload) async {
    debugPrint(
        '🚀 [StorePartnershipService] Sending payload to Supabase "store_reservations": $payload');
    try {
      final res = await _client
          .from('store_reservations')
          .insert(payload)
          .select()
          .maybeSingle();

      debugPrint(
          '🎉 [StorePartnershipService] Successfully saved to Supabase! Row: $res');
      return res;
    } catch (e) {
      debugPrint(
          '⚠️ [StorePartnershipService] Full payload insert error: $e');

      // If error was about extra columns not existing in user's older table, try with core columns
      try {
        final corePayload = {
          'user_id': payload['user_id'],
          'store_name': payload['store_name'] ?? 'Boutique',
          'product_name': payload['product_name'] ?? 'Vêtement',
          'product_size': payload['product_size'] ?? 'M',
          'product_image': payload['product_image'] ?? '',
          'reservation_code': payload['reservation_code'] ??
              'CODE-${DateTime.now().millisecondsSinceEpoch}',
          'status': payload['status'] ?? 'confirmed',
          'expires_at': payload['expires_at'] ??
              DateTime.now()
                  .add(const Duration(hours: 48))
                  .toUtc()
                  .toIso8601String(),
          'created_at':
              payload['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
        };

        debugPrint(
            '🔄 [StorePartnershipService] Retrying with core columns: $corePayload');
        final res = await _client
            .from('store_reservations')
            .insert(corePayload)
            .select()
            .maybeSingle();

        debugPrint(
            '🎉 [StorePartnershipService] Core columns insert succeeded: $res');
        return res;
      } catch (retryErr) {
        debugPrint(
            '🚨 [StorePartnershipService] Core columns retry failed: $retryErr');
        return null;
      }
    }
  }

  /// 1. CREATE IN-STORE RESERVATION
  Future<StoreReservationModel> createReservation({
    required String storeName,
    required String productName,
    required String productSize,
    required String productImage,
  }) async {
    final userId = await getEffectiveUserId();
    final randomDigits = (100000 + Random().nextInt(900000)).toString();
    final reservationCode = 'RES-$randomDigits';
    final now = DateTime.now().toUtc();
    final expiry = now.add(const Duration(hours: 48));

    final Map<String, dynamic> payload = {
      'user_id': userId,
      'activity_type': 'reservation',
      'brand_name': storeName.split(' ').first,
      'store_name': storeName,
      'product_name': productName,
      'product_size': productSize,
      'product_image': productImage,
      'reservation_code': reservationCode,
      'status': 'confirmed',
      'fit_match_percent': 98,
      'notes': '48h fitting room hold placed from app',
      'expires_at': expiry.toIso8601String(),
      'created_at': now.toIso8601String(),
    };

    final savedRow = await _insertIntoSupabase(payload);
    StoreReservationModel created;

    if (savedRow != null) {
      created = StoreReservationModel.fromMap(savedRow);
    } else {
      created = StoreReservationModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        activityType: 'reservation',
        brandName: storeName.split(' ').first,
        storeName: storeName,
        productName: productName,
        productSize: productSize,
        productImage: productImage,
        reservationCode: reservationCode,
        status: 'confirmed',
        fitMatchPercent: 98,
        notes: 'Local fallback',
        expiresAt: expiry,
        createdAt: now,
      );
    }

    await _saveLocalReservation(created);
    return created;
  }

  /// 2. LOG RACK SCAN (Scan the rack in-store)
  Future<void> logRackScan({
    required String productName,
    required String productSize,
    required String productImage,
    String storeName = 'Zalando Paris Hub (2.4 km)',
    int fitMatchPercent = 98,
  }) async {
    final userId = await getEffectiveUserId();
    final randomDigits = (100000 + Random().nextInt(900000)).toString();
    final now = DateTime.now().toUtc();

    final payload = {
      'user_id': userId,
      'activity_type': 'rack_scan',
      'brand_name': storeName.split(' ').first,
      'store_name': storeName,
      'product_name': productName,
      'product_size': productSize,
      'product_image': productImage,
      'reservation_code': 'SCAN-$randomDigits',
      'status': 'scanned',
      'fit_match_percent': fitMatchPercent,
      'notes': 'Retail rack barcode scanned via In-Store Scanner',
      'expires_at': now.add(const Duration(hours: 48)).toIso8601String(),
      'created_at': now.toIso8601String(),
    };

    await _insertIntoSupabase(payload);
  }

  /// 3. LOG DIGITAL KIOSK PASS GENERATION / OPEN
  Future<void> logKioskPass({
    required String passCode,
    String storeName = 'FitVisor Kiosk Partner Network',
  }) async {
    final userId = await getEffectiveUserId();
    final now = DateTime.now().toUtc();

    final payload = {
      'user_id': userId,
      'activity_type': 'kiosk_pass',
      'brand_name': 'FitVisor',
      'store_name': storeName,
      'product_name': 'Digital Kiosk VIP Pass',
      'product_size': '3D Synced',
      'product_image': 'assets/images/profile_avatar.jpg',
      'reservation_code': passCode,
      'status': 'pass_active',
      'fit_match_percent': 100,
      'notes': 'Digital Kiosk Pass opened for in-store smart mirror sync',
      'expires_at': now.add(const Duration(days: 30)).toIso8601String(),
      'created_at': now.toIso8601String(),
    };

    await _insertIntoSupabase(payload);
  }

  /// 4. LOG BROWSER EXTENSION ACTIVITY
  Future<void> logExtensionActivity({
    required String action, // e.g. 'copy_link' or 'open_store'
  }) async {
    final userId = await getEffectiveUserId();
    final randomDigits = (100000 + Random().nextInt(900000)).toString();
    final now = DateTime.now().toUtc();

    final payload = {
      'user_id': userId,
      'activity_type': 'extension_click',
      'brand_name': 'BrowserExtension',
      'store_name': 'Chrome/Safari Extension',
      'product_name': 'FitVisor 3D Extension ($action)',
      'product_size': 'ALL',
      'product_image': '',
      'reservation_code': 'EXT-$randomDigits',
      'status': action,
      'fit_match_percent': 100,
      'notes': 'User interacted with browser extension ($action)',
      'expires_at': now.add(const Duration(days: 365)).toIso8601String(),
      'created_at': now.toIso8601String(),
    };

    await _insertIntoSupabase(payload);
  }

  /// 5. LOG PARTNER BRAND VISIT (Zalando, H&M, Shein)
  Future<void> logBrandVisit({
    required String brandName,
    required String url,
  }) async {
    final userId = await getEffectiveUserId();
    final randomDigits = (100000 + Random().nextInt(900000)).toString();
    final now = DateTime.now().toUtc();

    final payload = {
      'user_id': userId,
      'activity_type': 'brand_visit',
      'brand_name': brandName,
      'store_name': '$brandName Official Store',
      'product_name': 'Direct Store Visit ($brandName)',
      'product_size': 'N/A',
      'product_image': '',
      'reservation_code': 'VISIT-$randomDigits',
      'status': 'visited',
      'fit_match_percent': 100,
      'notes': 'Clicked partner brand $brandName ($url)',
      'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
      'created_at': now.toIso8601String(),
    };

    await _insertIntoSupabase(payload);
  }

  Future<void> _saveLocalReservation(StoreReservationModel item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_localReservationsKey) ?? [];
      listJson.insert(0, jsonEncode(item.toMap()));
      await prefs.setStringList(_localReservationsKey, listJson);
    } catch (_) {}
  }

  /// Fetch user's reservations from Supabase or local cache
  Future<List<StoreReservationModel>> getUserReservations() async {
    final userId = await getEffectiveUserId();
    try {
      final res = await _client
          .from('store_reservations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final list = (res as List)
          .map((row) => StoreReservationModel.fromMap(row))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (e) {
      debugPrint('[StorePartnershipService] Supabase fetch reservations: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getStringList(_localReservationsKey) ?? [];
      return listJson
          .map((str) => StoreReservationModel.fromMap(jsonDecode(str)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
