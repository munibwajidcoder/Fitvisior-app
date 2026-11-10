import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class UserSubscriptionModel {
  final String id;
  final String userId;
  final String planId;
  final String planName;
  final String billingCycle; // 'monthly' | 'annual'
  final double amount;
  final String currency;
  final String status; // 'active' | 'cancelled' | 'expired'
  final String paymentMethod; // 'credit_card' | 'apple_pay' | 'google_pay'
  final String cardLastFour;
  final String cardHolderName;
  final DateTime startedAt;
  final DateTime expiresAt;
  final bool autoRenew;
  final DateTime createdAt;

  UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.billingCycle,
    required this.amount,
    this.currency = 'EUR',
    this.status = 'active',
    this.paymentMethod = 'credit_card',
    this.cardLastFour = '4242',
    this.cardHolderName = '',
    required this.startedAt,
    required this.expiresAt,
    this.autoRenew = true,
    required this.createdAt,
  });

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());

  factory UserSubscriptionModel.fromMap(Map<String, dynamic> map) {
    return UserSubscriptionModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      planId: map['plan_id']?.toString() ?? 'pro_monthly',
      planName: map['plan_name']?.toString() ?? 'FitVisor Pro',
      billingCycle: map['billing_cycle']?.toString() ?? 'monthly',
      amount: (map['amount'] as num?)?.toDouble() ?? 2.99,
      currency: map['currency']?.toString() ?? 'EUR',
      status: map['status']?.toString() ?? 'active',
      paymentMethod: map['payment_method']?.toString() ?? 'credit_card',
      cardLastFour: map['card_last_four']?.toString() ?? '4242',
      cardHolderName: map['card_holder_name']?.toString() ?? '',
      startedAt: DateTime.tryParse(map['started_at']?.toString() ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(map['expires_at']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      autoRenew: map['auto_renew'] != false,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'plan_name': planName,
      'billing_cycle': billingCycle,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'card_last_four': cardLastFour,
      'card_holder_name': cardHolderName,
      'started_at': startedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'auto_renew': autoRenew,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SubscriptionService {
  static final SubscriptionService instance = SubscriptionService._internal();
  SubscriptionService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  static const String _kLocalSubscriptionKey = 'fitvisor_active_subscription_v1';
  static const String _kLocalTransactionsKey = 'fitvisor_sub_transactions_v1';
  static const String _kLocalSavedCardsKey = 'fitvisor_saved_cards_v1';

  final ValueNotifier<UserSubscriptionModel?> currentSubscriptionNotifier =
      ValueNotifier<UserSubscriptionModel?>(null);

  UserSubscriptionModel? get currentSubscription =>
      currentSubscriptionNotifier.value;

  /// Plan tier helpers
  bool get isProOrHigher => currentSubscription != null && currentSubscription!.isActive;
  bool get isFamily => isProOrHigher && currentSubscription!.planId.toLowerCase().contains('family');
  int get maxVirtualTryOns => isProOrHigher ? -1 : 2; // -1 = Unlimited
  int get maxWardrobeItems => isProOrHigher ? -1 : 10; // -1 = Unlimited
  bool get hasAds => !isProOrHigher;

  /// Guaranteed valid UUID format for user_id (never crashes Postgres UUID types)
  Future<String> getEffectiveUserId() async {
    final authId = _client.auth.currentUser?.id;
    if (authId != null && authId.isNotEmpty) return authId;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('fitvisor_user_id');
      if (savedId != null && savedId.isNotEmpty) return savedId;
      final guestCartId = prefs.getString('fitvisor_guest_cart_uuid');
      if (guestCartId != null && guestCartId.isNotEmpty) return guestCartId;

      // Generate a persistent RFC4122 v4 UUID
      final rng = Random();
      final bytes = List<int>.generate(16, (i) => rng.nextInt(256));
      bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
      bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant RFC4122
      final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      final validUuid = '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
      await prefs.setString('fitvisor_user_id', validUuid);
      return validUuid;
    } catch (_) {}

    return '00000000-0000-0000-0000-000000000001';
  }

  /// Initialize and load active subscription on startup
  Future<UserSubscriptionModel?> loadActiveSubscription() async {
    final userId = await getEffectiveUserId();

    // 1. Try Supabase
    try {
      final res = await _client
          .from('user_subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res != null) {
        final sub = UserSubscriptionModel.fromMap(res);
        currentSubscriptionNotifier.value = sub;
        await _saveLocalSubscription(sub);
        return sub;
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Supabase fetch subscription note: $e');
    }

    // 2. Fallback to local cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalSubscriptionKey);
      if (raw != null && raw.isNotEmpty) {
        final sub = UserSubscriptionModel.fromMap(jsonDecode(raw));
        if (sub.isActive) {
          currentSubscriptionNotifier.value = sub;
          return sub;
        }
      }
    } catch (_) {}

    currentSubscriptionNotifier.value = null;
    return null;
  }

  /// Activate a new plan and persist across Supabase & local storage
  Future<UserSubscriptionModel> activateSubscription({
    required String planId,
    required String planName,
    required String billingCycle,
    required double amount,
    String paymentMethod = 'credit_card',
    String cardLastFour = '4242',
    String cardHolderName = 'Member',
    String? cardBrand,
    String? stripePaymentIntentId,
    String? receiptUrl,
  }) async {
    final userId = await getEffectiveUserId();
    final now = DateTime.now().toUtc();
    final durationDays = billingCycle == 'annual' ? 365 : 30;
    final expiresAt = now.add(Duration(days: durationDays));

    final Map<String, dynamic> payload = {
      'user_id': userId,
      'plan_id': planId,
      'plan_name': planName,
      'billing_cycle': billingCycle,
      'amount': amount,
      'currency': 'EUR',
      'status': 'active',
      'payment_method': paymentMethod,
      'card_last_four': cardLastFour,
      'card_holder_name': cardHolderName,
      'started_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'auto_renew': true,
      'created_at': now.toIso8601String(),
    };

    UserSubscriptionModel created;

    // 1. Insert into Supabase user_subscriptions
    try {
      final res = await _client
          .from('user_subscriptions')
          .insert(payload)
          .select()
          .single();

      created = UserSubscriptionModel.fromMap(res);
      debugPrint('🎉 [SubscriptionService] Subscription created in Supabase: ${created.id}');
    } catch (e) {
      debugPrint('⚠️ [SubscriptionService] Supabase subscription insert fallback: $e');
      created = UserSubscriptionModel(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        planId: planId,
        planName: planName,
        billingCycle: billingCycle,
        amount: amount,
        currency: 'EUR',
        status: 'active',
        paymentMethod: paymentMethod,
        cardLastFour: cardLastFour,
        cardHolderName: cardHolderName,
        startedAt: now,
        expiresAt: expiresAt,
        autoRenew: true,
        createdAt: now,
      );
    }

    // 2. Insert Transaction Record into Supabase subscription_transactions
    final rng = Random();
    final txnNumber = (stripePaymentIntentId != null && stripePaymentIntentId.isNotEmpty)
        ? stripePaymentIntentId
        : 'TXN-FV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${100 + rng.nextInt(900)}';
    
    final formattedPaymentMethod = cardBrand != null && cardBrand.isNotEmpty
        ? '$paymentMethod ($cardBrand)'
        : paymentMethod;

    // Matches the exact columns of public.subscription_transactions in Supabase
    final txnPayload = {
      'user_id': userId,
      'transaction_number': txnNumber,
      'plan_name': planName,
      'billing_cycle': billingCycle,
      'amount': amount,
      'currency': 'EUR',
      'status': 'paid',
      'payment_method': formattedPaymentMethod,
      'card_last_four': cardLastFour,
      'created_at': now.toIso8601String(),
    };

    try {
      await _client.from('subscription_transactions').insert(txnPayload);
      debugPrint('🎉 [SubscriptionService] Transaction logged in Supabase: $txnNumber');
    } catch (txnErr) {
      debugPrint('ℹ️ [SubscriptionService] Transaction log note: $txnErr');
    }

    // Include receipt_url and brand in local transaction cache for rich UI rendering
    final localTxnPayload = Map<String, dynamic>.from(txnPayload);
    localTxnPayload['card_brand'] = cardBrand ?? 'Visa';
    localTxnPayload['receipt_url'] = receiptUrl ?? '';

    // 3. Update local cache & notifier
    currentSubscriptionNotifier.value = created;
    await _saveLocalSubscription(created);
    await _saveLocalTransaction(localTxnPayload);

    // Save card if credit_card
    if (paymentMethod == 'credit_card' && cardLastFour.isNotEmpty) {
      await savePaymentCard(
        last4: cardLastFour,
        brand: cardBrand ?? 'Visa',
        holder: cardHolderName,
        expiry: '${now.month.toString().padLeft(2, '0')}/${(now.year + 3).toString().substring(2)}',
        isDefault: true,
      );
    }

    // 4. Send bilingual subscription activation notification
    try {
      final isAnnual = billingCycle.toLowerCase() == 'annual';
      final cycleFr = isAnnual ? 'annuel' : 'mensuel';
      final cycleEn = isAnnual ? 'annual' : 'monthly';
      final formattedAmount = '${amount.toStringAsFixed(2).replaceAll('.', ',')} €';
      await NotificationService.addIncomingNotification(
        title: 'FitVisor $planName Activated! 🎉',
        titleFr: 'Abonnement $planName Activé ! 🎉',
        body: 'Your $planName ($cycleEn - $formattedAmount) is now active via Stripe. Enjoy your personalized 3D try-on experience.',
        bodyFr: 'Votre formule $planName ($cycleFr - $formattedAmount) est désormais active via Stripe. Profitez de vos essayages 3D personnalisés.',
        category: 'system',
        actionRoute: '/subscriptions',
      );
    } catch (notifErr) {
      debugPrint('ℹ️ [SubscriptionService] Notification trigger warning: $notifErr');
    }

    return created;
  }

  /// Fetch all real transactions for active user from Supabase and local cache
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final userId = await getEffectiveUserId();
    final List<Map<String, dynamic>> results = [];

    // 1. Try Supabase
    try {
      final res = await _client
          .from('subscription_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (res.isNotEmpty) {
        for (final item in res) {
          results.add(Map<String, dynamic>.from(item));
        }
        return results;
      }
    } catch (e) {
      debugPrint('ℹ️ [SubscriptionService] Error loading transactions from Supabase: $e');
    }

    // 2. Fallback to local transactions
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kLocalTransactionsKey) ?? [];
      for (final raw in list) {
        try {
          results.add(jsonDecode(raw) as Map<String, dynamic>);
        } catch (_) {}
      }
    } catch (_) {}

    return results;
  }

  /// Get user saved cards (dynamic across session & local storage)
  Future<List<Map<String, dynamic>>> getSavedPaymentCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_kLocalSavedCardsKey);
      if (raw != null && raw.isNotEmpty) {
        return raw
            .map((item) => jsonDecode(item) as Map<String, dynamic>)
            .toList();
      }
    } catch (_) {}

    // If no saved cards yet, return empty list (user must tap + Add New Card)
    return [];
  }

  /// Save or update a card in user's saved methods
  Future<void> savePaymentCard({
    required String last4,
    required String brand,
    required String holder,
    required String expiry,
    bool isDefault = true,
  }) async {
    try {
      final cards = await getSavedPaymentCards();
      if (isDefault) {
        for (var c in cards) {
          c['isDefault'] = false;
        }
      }
      // Check if already exists
      final existingIndex = cards.indexWhere((c) => c['last4'] == last4);
      final newCard = {
        'type': brand,
        'last4': last4,
        'expiry': expiry,
        'holder': holder,
        'isDefault': isDefault,
      };

      if (existingIndex >= 0) {
        cards[existingIndex] = newCard;
      } else {
        cards.insert(0, newCard);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _kLocalSavedCardsKey,
        cards.map((c) => jsonEncode(c)).toList(),
      );
    } catch (e) {
      debugPrint('ℹ️ [SubscriptionService] Error saving card: $e');
    }
  }

  /// Delete a card
  Future<void> deletePaymentCard(String last4) async {
    try {
      final cards = await getSavedPaymentCards();
      cards.removeWhere((c) => c['last4'] == last4);
      if (cards.isNotEmpty && !cards.any((c) => c['isDefault'] == true)) {
        cards.first['isDefault'] = true;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _kLocalSavedCardsKey,
        cards.map((c) => jsonEncode(c)).toList(),
      );
    } catch (_) {}
  }

  Future<void> _saveLocalSubscription(UserSubscriptionModel sub) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocalSubscriptionKey, jsonEncode(sub.toMap()));
    } catch (_) {}
  }

  Future<void> _saveLocalTransaction(Map<String, dynamic> txn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kLocalTransactionsKey) ?? [];
      list.insert(0, jsonEncode(txn));
      await prefs.setStringList(_kLocalTransactionsKey, list);
    } catch (_) {}
  }

  /// Cancel current active subscription
  Future<bool> cancelSubscription() async {
    final current = currentSubscriptionNotifier.value;
    if (current == null) return false;

    try {
      await _client
          .from('user_subscriptions')
          .update({'status': 'cancelled', 'auto_renew': false})
          .eq('id', current.id);
    } catch (e) {
      debugPrint('[SubscriptionService] Supabase cancel subscription: $e');
    }

    final updated = UserSubscriptionModel(
      id: current.id,
      userId: current.userId,
      planId: current.planId,
      planName: current.planName,
      billingCycle: current.billingCycle,
      amount: current.amount,
      currency: current.currency,
      status: 'cancelled',
      paymentMethod: current.paymentMethod,
      cardLastFour: current.cardLastFour,
      cardHolderName: current.cardHolderName,
      startedAt: current.startedAt,
      expiresAt: current.expiresAt,
      autoRenew: false,
      createdAt: current.createdAt,
    );

    currentSubscriptionNotifier.value = updated;
    await _saveLocalSubscription(updated);
    return true;
  }
}

