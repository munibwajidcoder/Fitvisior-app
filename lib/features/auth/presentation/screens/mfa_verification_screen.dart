import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_toggle_badge.dart';
import '../../data/auth_service.dart';
import '../../data/user_avatar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'age_eligibility_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

class MfaVerificationScreen extends StatefulWidget {
  final String email;
  final bool isSignUp;   // true = signup OTP, false = login OTP
  final String? fitProfile; // passed from SignUpScreen, saved after OTP
  const MfaVerificationScreen({
    super.key,
    this.email = "alexa.designer@example.com",
    this.isSignUp = true,
    this.fitProfile,
  });

  @override
  State<MfaVerificationScreen> createState() => _MfaVerificationScreenState();
}

class _MfaVerificationScreenState extends State<MfaVerificationScreen> {
  final List<String> _otpDigits = ['', '', '', '', '', ''];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isResending = false;

  Timer? _timer;
  int _secondsRemaining = 600; // 10 minutes

  @override
  void initState() {
    super.initState();
    // OTP digits start empty (real OTP user type karega)
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendOtpCode() async {
    final isEn = LanguageService.instance.isEnglish;
    setState(() => _isResending = true);
    _startTimer();
    try {
      if (widget.isSignUp) {
        await AuthService.resendOtp(email: widget.email);
      } else {
        // Login OTP resend — use direct Supabase signInWithOtp
        await AuthService.sendLoginOtp(email: widget.email);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn
                  ? 'A new code has been sent to your email address.'
                  : 'Un nouveau code a été envoyé à votre adresse e-mail.',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(isEn
            ? 'Failed to resend code. Please try again.'
            : 'Échec du renvoi du code. Veuillez réessayer.');
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ✅ REAL SUPABASE OTP VERIFY — no auto-bypass, user must enter the code!
  Future<void> _navigateToNext() async {
    final isEn = LanguageService.instance.isEnglish;
    final otp = _otpDigits.join();
    if (otp.length < 6) return;

    setState(() => _isLoading = true);

    try {
      AuthResponse response;

      if (widget.isSignUp) {
        // Signup OTP verify
        response = await AuthService.verifyOtp(
          email: widget.email,
          otp: otp,
        );
      } else {
        // Login OTP verify — NO fallback bypass allowed!
        response = await AuthService.verifyLoginOtp(
          email: widget.email,
          otp: otp,
        );
      }

      if (response.user != null && mounted) {
        if (widget.isSignUp) {
          // ✅ Save fit_profile NOW (session exists after OTP verification)
          if (widget.fitProfile != null) {
            try {
              await AuthService.updateProfile({
                'fit_profile': widget.fitProfile,
              });
            } catch (_) {
              // Silent fail — profile will be updated during onboarding
            }
          }
          // Signup → Onboarding
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AgeEligibilityScreen()),
              (route) => false,
            );
          }
        } else {
          // ── LOGIN (Existing user from Welcome Back screen) ──
          // Never send an existing user to AgeEligibilityScreen!
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('fitvisor_is_logged_in', true);
            await prefs.setString('fitvisor_user_id', response.user!.id);
          } catch (_) {}

          // Ensure profile knows onboarding is complete
          try {
            await AuthService.updateProfile({
              'onboarding_completed': true,
              'onboarding_step': 4,
            });
          } catch (_) {}

          // Load user's saved 3D Avatar & profile picture from cloud/storage
          await UserAvatarService.loadSavedAvatar();

          // DIRECTLY GO TO HOME SCREEN!
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        }
      }
    } on AuthException catch (e) {
      final lower = e.message.toLowerCase();
      String msg = isEn
          ? 'Invalid or expired security code.'
          : 'Code de sécurité invalide ou expiré.';
      if (lower.contains('expired')) {
        msg = isEn
            ? 'This code has expired. Please request a new code.'
            : 'Ce code a expiré. Veuillez demander un nouveau code.';
      } else if (lower.contains('rate limit') || lower.contains('too many')) {
        msg = isEn
            ? 'Too many attempts. Please wait before trying again.'
            : 'Trop de tentatives. Veuillez patienter avant de réessayer.';
      }
      _showError(msg);
      // Wrong OTP → reset digits
      setState(() {
        for (int i = 0; i < 6; i++) {
          _otpDigits[i] = '';
        }
        _currentIndex = 0;
      });
    } catch (e) {
      _showError(isEn
          ? 'Invalid code. Please try again.'
          : 'Code invalide. Veuillez réessayer.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _handleKeyPress(String val) {
    if (val == 'backspace') {
      if (_currentIndex > 0) {
        setState(() {
          _currentIndex--;
          _otpDigits[_currentIndex] = '';
        });
      }
    } else {
      if (_currentIndex < 6) {
        setState(() {
          _otpDigits[_currentIndex] = val;
          _currentIndex++;
        });
        // Auto-navigate when all 6 digits filled
        if (_currentIndex == 6) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _navigateToNext();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          // Clamp keypad so nothing overflows when keyboard shows
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 6),

                  // ---- TOP APP BAR ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(Icons.chevron_left_rounded,
                              size: 28, color: Color(0xFF0F172A)),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/images/logo.png',
                              width: 28, height: 28),
                          const SizedBox(width: 8),
                          Text(
                            isEn ? "MFA Verification" : "Vérification MFA",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const LanguageToggleBadge(),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ---- SHIELD ICON WITH CHECKMARK ----
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCE7F3).withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shield_outlined,
                                size: 26, color: Color(0xFF172554)),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.check_rounded,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ---- TITLE ----
                  Text(
                    isEn ? "Verify it's you" : "Vérifiez que c'est vous",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    isEn
                        ? "We sent a 6-digit code to your verified studio account:"
                        : "Nous avons envoyé un code à 6 chiffres à votre compte studio vérifié :",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ---- EMAIL BADGE WITH QUICK EDIT OPTION ----
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mail_outline_rounded,
                            size: 14, color: Color(0xFFE11D48)),
                        const SizedBox(width: 6),
                        Text(
                          widget.email,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit_outlined,
                                    size: 11, color: Color(0xFFE11D48)),
                                const SizedBox(width: 3),
                                Text(
                                  isEn ? "Edit" : "Modifier",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- AUTHENTICATION CARD ----
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn
                                  ? "AUTHENTICATION CODE"
                                  : "CODE D'AUTHENTIFICATION",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.4,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.accentRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isEn ? "Awaiting input" : "En attente de saisie",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // 6 OTP Digit Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            final bool isFilled = _otpDigits[index].isNotEmpty;
                            final bool isCurrent = index == _currentIndex;
                            return Container(
                              width: 40,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrent
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFFF1F5F9),
                                  width: isCurrent ? 1.8 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: isCurrent
                                    ? Container(
                                        width: 2,
                                        height: 20,
                                        color: const Color(0xFFF43F5E),
                                      )
                                    : Text(
                                        isFilled ? _otpDigits[index] : "•",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: isFilled ? 18 : 14,
                                          fontWeight: FontWeight.w800,
                                          color: isFilled
                                              ? const Color(0xFF0F172A)
                                              : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 10),

                        // Resend OTP Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: TextButton.icon(
                            onPressed: (_isResending || _isLoading)
                                ? null
                                : _resendOtpCode,
                            icon: _isResending
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFE11D48),
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded,
                                    size: 16, color: Color(0xFFE11D48)),
                            label: Text(
                              _isResending
                                  ? (isEn ? "Sending..." : "Envoi en cours...")
                                  : (_secondsRemaining > 0
                                      ? (isEn
                                          ? "Resend code (${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')})"
                                          : "Renvoyer le code (${(_secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(_secondsRemaining % 60).toString().padLeft(2, '0')})")
                                      : (isEn
                                          ? "Resend a new code"
                                          : "Renvoyer un nouveau code")),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF1F2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side:
                                    const BorderSide(color: Color(0xFFFECDD3)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (_currentIndex == 6 && !_isLoading)
                                ? _navigateToNext
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF43F5E),
                              disabledBackgroundColor:
                                  const Color(0xFFF43F5E).withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isEn
                                            ? "Verify and continue"
                                            : "Vérifier et continuer",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded,
                                          color: Colors.white, size: 17),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ---- CUSTOM NUMERIC KEYPAD ----
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _keyRow(["1", "2", "3"]),
                        _keyRow(["4", "5", "6"]),
                        _keyRow(["7", "8", "9"]),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: Center(
                                  child: Icon(Icons.fingerprint_rounded,
                                      size: 24,
                                      color: const Color(0xFF64748B)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _singleKeyButton("0"),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () => _handleKeyPress('backspace'),
                                  borderRadius: BorderRadius.circular(12),
                                  child: const SizedBox(
                                    height: 46,
                                    child: Center(
                                      child: Icon(Icons.backspace_outlined,
                                          size: 19, color: Color(0xFF334155)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ---- FOOTER ----
                  Text(
                    isEn
                        ? "Didn't receive the email? Check your spam folder."
                        : "Vous n'avez pas reçu l'e-mail ? Vérifiez votre dossier spam.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        isEn
                            ? "256-bit End-to-End Encrypted Protocol"
                            : "Protocole 256 bits chiffré de bout en bout",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _keyRow(List<String> digits) {
    return Row(
      children: digits.asMap().entries.map((e) {
        return [
          if (e.key > 0) const SizedBox(width: 10),
          _singleKeyButton(e.value),
        ];
      }).expand((x) => x).toList(),
    );
  }

  Widget _singleKeyButton(String digit) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _handleKeyPress(digit),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 46,
            child: Center(
              child: Text(
                digit,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

