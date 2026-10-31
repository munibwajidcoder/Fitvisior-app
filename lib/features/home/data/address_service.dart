import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/screens/add_shipping_address_screen.dart';

class AddressService {
  static final AddressService instance = AddressService._internal();
  AddressService._internal();

  static const String _kLocalAddressCacheKey = 'fitvisor_saved_default_address_v2';

  SupabaseClient get _client => Supabase.instance.client;

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

  /// Loads the default or most recent shipping address from cache or Supabase
  Future<ShippingAddressModel?> getDefaultAddress() async {
    // 1. Try local cache first for instant UI responsiveness
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_kLocalAddressCacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final map = jsonDecode(cachedJson) as Map<String, dynamic>;
        return ShippingAddressModel.fromJson(map);
      }
    } catch (_) {}

    // 2. Fallback to Supabase
    final userId = await getEffectiveUserId();
    try {
      final res = await _client
          .from('user_addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res != null) {
        final addr = ShippingAddressModel(
          recipientName: res['full_name'] ?? res['recipient_name'] ?? res['name'] ?? '',
          streetAddress: res['street_address'] ?? res['address'] ?? '',
          apt: res['apt_suite'] ?? '',
          city: res['city'] ?? '',
          state: res['state_region'] ?? res['state_province'] ?? res['state'] ?? '',
          zipCode: res['postal_code'] ?? res['zip_code'] ?? '',
          country: res['country'] ?? 'Pakistan',
          phone: res['phone_number'] ?? res['phone'] ?? '',
          addressType: res['address_type'] ?? 'Home',
          deliveryInstructions: '',
        );
        // Update local cache
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_kLocalAddressCacheKey, jsonEncode(addr.toJson()));
        } catch (_) {}
        return addr;
      }
    } catch (e) {
      debugPrint('[AddressService] Error loading default address: $e');
    }
    return null;
  }

  /// Saves or updates the shipping address in persistent cache & Supabase
  Future<bool> saveAddress(ShippingAddressModel address) async {
    // 1. Instantly save to local persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocalAddressCacheKey, jsonEncode(address.toJson()));
      debugPrint('[AddressService] 💾 Saved address to local storage: ${address.streetAddress}, ${address.city}');
    } catch (e) {
      debugPrint('[AddressService] Error saving local address cache: $e');
    }

    // 2. Sync to Supabase with exact columns matching user requirements:
    // full_name, phone_number, address_type, street_address, city, state_region, postal_code, country, is_default, created_at
    final userId = await getEffectiveUserId();
    try {
      try {
        await _client
            .from('user_addresses')
            .update({'is_default': false})
            .eq('user_id', userId);
      } catch (_) {}

      final effectiveType = address.addressType.isNotEmpty ? address.addressType : 'Home';

      // Exact columns matching user requirements (NO country column):
      // user_id, full_name, phone_number, address_type, street_address, city, state_region, postal_code, is_default, created_at
      Map<String, dynamic> candidate = {
        'user_id': userId,
        'full_name': address.recipientName,
        'phone_number': address.phone,
        'address_type': effectiveType,
        'street_address': address.streetAddress,
        'city': address.city,
        'state_region': address.state,
        'postal_code': address.zipCode,
        'is_default': true,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };

      // Resilient fallback in case user hasn't run the migration query yet
      bool inserted = false;
      for (int attempt = 0; attempt < 4; attempt++) {
        try {
          await _client.from('user_addresses').insert(candidate);
          debugPrint('[AddressService] ✅ Address successfully synced to Supabase: $candidate');
          inserted = true;
          break;
        } catch (err) {
          final errMsg = err.toString();
          debugPrint('[AddressService] Attempt $attempt failed: $errMsg');

          if (errMsg.contains('full_name')) {
            candidate['recipient_name'] = candidate.remove('full_name');
          } else if (errMsg.contains('state_region')) {
            candidate['state_province'] = candidate.remove('state_region');
          } else if (errMsg.contains('address_type')) {
            candidate.remove('address_type');
          } else {
            break;
          }
        }
      }

      return inserted;
    } catch (e) {
      debugPrint('[AddressService] ⚠️ Error syncing address to Supabase: $e');
      return true;
    }
  }

  /// Permanently deletes the shipping address from local cache & Supabase
  Future<bool> deleteAddress() async {
    // 1. Remove from local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLocalAddressCacheKey);
      debugPrint('[AddressService] 🗑️ Deleted address from local storage');
    } catch (e) {
      debugPrint('[AddressService] Error deleting local address cache: $e');
    }

    // 2. Remove from Supabase
    try {
      final userId = await getEffectiveUserId();
      await _client
          .from('user_addresses')
          .delete()
          .eq('user_id', userId);
      debugPrint('[AddressService] 🗑️ Deleted user addresses from Supabase');
      return true;
    } catch (e) {
      debugPrint('[AddressService] ⚠️ Error deleting address from Supabase: $e');
      return true;
    }
  }
}

