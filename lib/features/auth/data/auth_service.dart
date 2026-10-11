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
  }) async {
    final response = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(), // Trigger ke zariye profiles table me jayega
      },
      emailRedirectTo: null, // OTP mode use karenge (link nahi)
    );
    return response;
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
  // 5. LOGIN WITH OTP (Magic Link / Passwordless)
  // ----------------------------------------------------------------
  static Future<void> signInWithOtp({required String email}) async {
    await supabase.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: false, // Sirf existing users ke liye
    );
  }

  // ----------------------------------------------------------------
  // 6. VERIFY LOGIN OTP
  // ----------------------------------------------------------------
  static Future<AuthResponse> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final response = await supabase.auth.verifyOTP(
      email: email.trim(),
      token: otp.trim(),
      type: OtpType.email, // Login OTP type
    );
    return response;
  }

  // ----------------------------------------------------------------
  // 7. LOGOUT
  // ----------------------------------------------------------------
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // ----------------------------------------------------------------
  // 8. CURRENT USER — Logged in user ka data
  // ----------------------------------------------------------------
  static User? get currentUser => supabase.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  // ----------------------------------------------------------------
  // 9. UPDATE PROFILE — Onboarding steps ka data save karna
  // ----------------------------------------------------------------
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception("L'utilisateur n'est pas connecté. Veuillez vérifier votre email ou désactiver 'Confirm Email' dans Supabase.");
    }

    await supabase
        .from('profiles')
        .update(data)
        .eq('id', userId);
  }

  // ----------------------------------------------------------------
  // 10. GET PROFILE — User ka profile fetch karna
  // ----------------------------------------------------------------
  static Future<Map<String, dynamic>?> getProfile() async {
    final userId = currentUser?.id;
    if (userId == null) return null;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return response;
  }

  // ----------------------------------------------------------------
  // 11. FORGOT PASSWORD — Reset email bhejo
  // ----------------------------------------------------------------
  static Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email.trim());
  }
}
