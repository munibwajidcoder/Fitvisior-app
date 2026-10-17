import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart';


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
    final response = await supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
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
    final response = await supabase.auth.verifyOTP(
      email: email.trim(),
      token: otp.trim(),
      type: OtpType.email, // Must match signInWithOtp type
    );
    return response;
  }

  // ----------------------------------------------------------------
  // 7. LOGOUT
  // ----------------------------------------------------------------
  static Future<void> signOut() async {
    _localProfileCache.clear();
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
    'clothing_fit_preference',
  };

  // ----------------------------------------------------------------
  // 9. UPDATE PROFILE — Onboarding steps ka data save karna
  // ----------------------------------------------------------------
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    _localProfileCache.addAll(data);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        // ── Normalize aliases to exact Supabase column names ──
        final normalized = Map<String, dynamic>.from(data);
        if (normalized.containsKey('hips_cm')) {
          normalized['hip_cm'] ??= normalized['hips_cm'];
          normalized.remove('hips_cm');
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
              normalized['onboarding_step'] = 4;
            } else if (val == 'avatar_done') {
              normalized['onboarding_step'] = 3;
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
                .update(payload)
                .eq('id', userId);
            debugPrint('[AuthService] Supabase profile successfully updated: ${payload.keys.toList()}');
          } catch (e) {
            debugPrint('[AuthService] Batch update failed ($e). Retrying column-by-column...');
            for (final entry in payload.entries) {
              try {
                await Supabase.instance.client
                    .from('profiles')
                    .update({entry.key: entry.value})
                    .eq('id', userId);
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
    try {
      final userId = currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (response != null) {
          _localProfileCache.addAll(response);
          return Map<String, dynamic>.from(_localProfileCache);
        }
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase getProfile warning: $e');
    }
    return _localProfileCache.isNotEmpty ? Map<String, dynamic>.from(_localProfileCache) : null;
  }

  // ----------------------------------------------------------------
  // 11. FORGOT PASSWORD — Reset email bhejo
  // ----------------------------------------------------------------
  static Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email.trim());
  }
}
