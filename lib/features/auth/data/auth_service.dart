import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart';
import 'user_avatar_service.dart';
import '../../home/data/wardrobe_service.dart';


/// ============================================================
/// FITVISOR AUTH SERVICE
/// Supabase ke zariye saari Auth operations handle karta hai
/// ============================================================

class AuthService {
  // ----------------------------------------------------------------
  // 1. SIGNUP — New user create karo
  // Supabase OTP email bhi automatically bhejta hai (verify karne ke liye)
  // ----------------------------------------------------------------
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? fitProfile, // 3D fit profile selection (Petite/Regular/Tall/Curvy)
  }) async {
    // ── STEP 1: Check if email already exists by attempting sign-in first ──
    // Supabase sometimes silently "succeeds" signUp for existing emails
    // (returns user without session) to prevent email enumeration.
    // We handle this by catching the specific Supabase behavior.
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'fit_profile': fitProfile ?? 'Regular',
        },
        emailRedirectTo: null, // OTP mode
      );

      // ── STEP 2: Detect "silent already registered" case ──────────────────
      // Supabase returns a user BUT with identities = [] when email exists
      // This is their email enumeration protection behavior
      final user = response.user;
      if (user != null) {
        final identities = user.identities;
        if (identities != null && identities.isEmpty) {
          // Empty identities = email already registered, Supabase faked success
          throw AuthException(
            'User already registered',
            statusCode: '422',
          );
        }
      }

      return response;
    } on AuthException {
      rethrow; // Let caller handle AuthException
    } catch (e) {
      rethrow;
    }
  }

  // ----------------------------------------------------------------
  // 2. VERIFY OTP — Email pe aaya hua 6-digit code verify karo
  // ----------------------------------------------------------------
  static Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await supabase.auth.verifyOTP(
      email: email.trim(),
      token: otp.trim(),
      type: OtpType.signup, // Signup OTP verify kar raha hai
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fitvisor_is_logged_in', true);
      if (response.user != null) {
        await prefs.setString('fitvisor_user_id', response.user!.id);
      }
    } catch (_) {}
    return response;
  }

  // ----------------------------------------------------------------
  // 3. RESEND OTP — OTP dobara bhejo
  // ----------------------------------------------------------------
  static Future<void> resendOtp({required String email}) async {
    await supabase.auth.resend(
      type: OtpType.signup,
      email: email.trim(),
    );
  }

  // ----------------------------------------------------------------
  // 4. LOGIN — Email + Password se login
  // ----------------------------------------------------------------
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    _localProfileCache.clear();
    UserAvatarService.clearAvatar();
    final response = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fitvisor_is_logged_in', true);
      if (response.user != null) {
        await prefs.setString('fitvisor_user_id', response.user!.id);
        UserAvatarService.loadSavedAvatar();
      }
    } catch (_) {}
    return response;
  }

  // ----------------------------------------------------------------
  // 5. SEND LOGIN OTP — directly via Supabase (same as signup OTP, 6-digit code)
  // signInWithOtp sends visible 6-digit code email (NOT a magic link)
  // ----------------------------------------------------------------
  static Future<void> sendLoginOtp({required String email}) async {
    await supabase.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: false, // Only for existing users
    );
  }

  // ----------------------------------------------------------------
  // 6. VERIFY LOGIN OTP — OtpType.email matches signInWithOtp
  // ----------------------------------------------------------------
  static Future<AuthResponse> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    _localProfileCache.clear();
    UserAvatarService.clearAvatar();
    final response = await supabase.auth.verifyOTP(
      email: email.trim(),
      token: otp.trim(),
      type: OtpType.email, // Must match signInWithOtp type
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fitvisor_is_logged_in', true);
      if (response.user != null) {
        await prefs.setString('fitvisor_user_id', response.user!.id);
        UserAvatarService.loadSavedAvatar();
      }
    } catch (_) {}
    return response;
  }

  // ----------------------------------------------------------------
  // 7. LOGOUT
  // ----------------------------------------------------------------
  static Future<void> signOut() async {
    // Clear avatar and user wardrobe immediately on logout to prevent cross-account privacy leaks
    UserAvatarService.clearAvatar();
    WardrobeService.instance.resetForNewUser();
    _localProfileCache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fitvisor_is_logged_in', false);
      await prefs.remove('fitvisor_user_id');
      await prefs.remove('fitvisor_onboarding_step');
      await prefs.remove('fitvisor_onboarding_completed');
    } catch (_) {}
    try {
      await supabase.auth.signOut(scope: SignOutScope.global);
    } catch (_) {
      try {
        await supabase.auth.signOut(scope: SignOutScope.local);
      } catch (_) {}
    }
  }

  // ----------------------------------------------------------------
  // 8. CURRENT USER — Logged in user ka data
  // ----------------------------------------------------------------
  static User? get currentUser => supabase.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static final Map<String, dynamic> _localProfileCache = {};

  static Map<String, dynamic> get cachedProfile => Map<String, dynamic>.from(_localProfileCache);

  static const Set<String> _validProfileColumns = {
    'id',
    'full_name',
    'email',
    'date_of_birth',
    'age',
    'is_minor',
    'parental_consent_given',
    'parental_consent_timestamp',
    'avatar_type',
    'height_cm',
    'weight_kg',
    'style_preferences',
    'favorite_brands',
    'preferred_colors',
    'subscription_tier',
    'terms_accepted',
    'terms_accepted_version',
    'terms_accepted_at',
    'privacy_accepted',
    'data_processing_consent',
    'mfa_enabled',
    'onboarding_completed',
    'onboarding_step',
    'fit_profile',
    'gender',
    'bust_cm',
    'waist_cm',
    'hip_cm',
    'shoulder_cm',
    'inseam_cm',
    'cup_size',
    'avatar_glb_url',
    'avatar_url',
    'scan_front_photo_url',
    'scan_side_photo_url',
    'scan_back_photo_url',
    'clothing_fit_preference',
    'virtual_tryons_count',
    'fit_precision',
  };

  // ----------------------------------------------------------------
  // 9. UPDATE PROFILE — Onboarding steps ka data save karna
  // ----------------------------------------------------------------
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    _localProfileCache.addAll(data);
    if (data.containsKey('bust_cm')) _localProfileCache['chest_cm'] = data['bust_cm'];
    if (data.containsKey('chest_cm')) _localProfileCache['bust_cm'] = data['chest_cm'];
    if (data.containsKey('hip_cm')) _localProfileCache['hips_cm'] = data['hip_cm'];
    if (data.containsKey('hips_cm')) _localProfileCache['hip_cm'] = data['hips_cm'];

    try {
      final prefs = await SharedPreferences.getInstance();
      if (data.containsKey('onboarding_step')) {
        final val = data['onboarding_step'];
        final int stepNum = (val is num) ? val.toInt() : (int.tryParse(val.toString()) ?? 0);
        await prefs.setInt('fitvisor_onboarding_step', stepNum);
      }
      if (data.containsKey('onboarding_completed')) {
        await prefs.setBool('fitvisor_onboarding_completed', data['onboarding_completed'] == true);
      }
    } catch (_) {}

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // ── Normalize aliases to exact Supabase column names ──
        final normalized = Map<String, dynamic>.from(data);
        if (normalized.containsKey('hips_cm')) {
          normalized['hip_cm'] ??= normalized['hips_cm'];
          normalized.remove('hips_cm');
        }
        if (normalized.containsKey('chest_cm')) {
          normalized['bust_cm'] ??= normalized['chest_cm'];
          normalized.remove('chest_cm');
        }
        if (normalized.containsKey('shoulders_cm')) {
          normalized['shoulder_cm'] ??= normalized['shoulders_cm'];
          normalized.remove('shoulders_cm');
        }
        if (normalized.containsKey('color_preferences')) {
          normalized['preferred_colors'] ??= normalized['color_preferences'];
          normalized.remove('color_preferences');
        }
        if (normalized.containsKey('favorite_colors')) {
          normalized['preferred_colors'] ??= normalized['favorite_colors'];
          normalized.remove('favorite_colors');
        }
        if (normalized.containsKey('fit_preference')) {
          normalized['clothing_fit_preference'] ??= normalized['fit_preference'];
          normalized.remove('fit_preference');
        }
        if (normalized.containsKey('onboarding_step')) {
          final val = normalized['onboarding_step'];
          if (val is String) {
            if (val == 'completed' || val == 'done') {
              normalized['onboarding_step'] = 6;
            } else if (val == 'avatar_done') {
              normalized['onboarding_step'] = 5;
            } else {
              normalized['onboarding_step'] = int.tryParse(val) ?? 0;
            }
          }
        }

        // ── Only send columns that actually exist in Supabase schema ──
        final payload = <String, dynamic>{};
        for (final entry in normalized.entries) {
          if (_validProfileColumns.contains(entry.key) && entry.key != 'id') {
            payload[entry.key] = entry.value;
          }
        }

        if (payload.isNotEmpty) {
          try {
            await Supabase.instance.client
                .from('profiles')
                .upsert({'id': userId, ...payload});
            debugPrint('[AuthService] Supabase profile successfully upserted: ${payload.keys.toList()}');
          } catch (e) {
            debugPrint('[AuthService] Batch upsert failed ($e). Retrying column-by-column...');
            for (final entry in payload.entries) {
              try {
                await Supabase.instance.client
                    .from('profiles')
                    .upsert({'id': userId, entry.key: entry.value});
                debugPrint('   [AuthService] Saved column: ${entry.key}');
              } catch (colErr) {
                debugPrint('   [AuthService] Failed column: ${entry.key} -> $colErr');
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase updateProfile error: $e');
    }
  }

  // ----------------------------------------------------------------
  // 10. GET PROFILE — User ka profile fetch karna
  // ----------------------------------------------------------------
  static Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) {
      _localProfileCache.clear();
      return null;
    }

    // If cache belongs to a different user, clear it immediately
    if (_localProfileCache['id'] != null && _localProfileCache['id'] != userId) {
      _localProfileCache.clear();
    }

    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _localProfileCache.addAll(response);
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase getProfile warning: $e');
    }

    _localProfileCache['id'] = userId;

    // Always merge in auth userMetadata for THIS specific user
    final meta = currentUser?.userMetadata;
    if (meta != null) {
      for (final entry in meta.entries) {
        if (entry.value != null) {
          _localProfileCache[entry.key] = entry.value;
        }
      }
    }
    if (currentUser?.email != null) {
      _localProfileCache['email'] ??= currentUser!.email;
    }
    return _localProfileCache.isNotEmpty
        ? Map<String, dynamic>.from(_localProfileCache)
        : null;
  }

  // ----------------------------------------------------------------
  // 11. FORGOT PASSWORD — Reset code email bhejo
  // ----------------------------------------------------------------
  static Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email.trim());
  }

  static Future<void> sendPasswordResetOtp({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email.trim());
  }

  // ----------------------------------------------------------------
  // 12. VERIFY RECOVERY OTP — Password reset code verify karo
  // ----------------------------------------------------------------
  static Future<AuthResponse> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    return await supabase.auth.verifyOTP(
      email: email.trim(),
      token: otp.trim(),
      type: OtpType.recovery,
    );
  }

  // ----------------------------------------------------------------
  // 13. UPDATE PASSWORD — Naya password set karo
  // ----------------------------------------------------------------
  static Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    return await supabase.auth.updateUser(
      UserAttributes(password: newPassword.trim()),
    );
  }
}
