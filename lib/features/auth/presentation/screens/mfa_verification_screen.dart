import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'age_eligibility_screen.dart';

class MfaVerificationScreen extends StatefulWidget {
  final String email;
  const MfaVerificationScreen({
    super.key,
    this.email = "alexa.designer@example.com",
  });

  @override
  State<MfaVerificationScreen> createState() => _MfaVerificationScreenState();
}

class _MfaVerificationScreenState extends State<MfaVerificationScreen> {
  final List<String> _otpDigits = ['', '', '', '', '', ''];
  int _currentIndex = 0;

  Timer? _timer;
  int _secondsRemaining = 42;

  @override
  void initState() {
    super.initState();
    _otpDigits[0] = '4';
    _otpDigits[1] = '8';
    _otpDigits[2] = '2';
    _currentIndex = 3;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 42;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AgeEligibilityScreen(),
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
                    onTap: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.chevron_left_rounded, size: 28,
                          color: Color(0xFF0F172A)),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/logo.png', width: 28, height: 28),
                      const SizedBox(width: 8),
                      Text(
                        "Vérification MFA",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
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
                        child: const Icon(Icons.shield_outlined, size: 26,
                            color: Color(0xFF172554)),
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
                      child: const Icon(Icons.check_rounded, size: 12,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ---- TITLE ----
              Text(
                "Vérifiez que c'est vous",
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
                "Nous avons envoyé un code à 6 chiffres à votre compte studio vérifié :",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                ),
              ),

              const SizedBox(height: 8),

              // ---- EMAIL BADGE ----
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.mail_outline_rounded, size: 14,
                        color: Color(0xFFE11D48)),
                    const SizedBox(width: 5),
                    Text(
                      widget.email,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
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
                          "CODE D'AUTHENTIFICATION",
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
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accentRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "En attente de saisie",
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
                            color: isCurrent ? Colors.white : const Color(0xFFF8FAFC),
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

                    // Resend Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 13,
                            color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          "Renvoyer dans 00:${_secondsRemaining.toString().padLeft(2, '0')} ",
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        GestureDetector(
                          onTap: _startTimer,
                          child: Text(
                            "Renvoyer maintenant",
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF43F5E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Vérifier Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _currentIndex == 6 ? _navigateToNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Vérifier et continuer",
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
                                  size: 24, color: const Color(0xFF64748B)),
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
                "Vous n'avez pas reçu l'e-mail ? Vérifiez votre dossier spam.",
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
                  const Icon(Icons.lock_outline_rounded, size: 12,
                      color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    "Protocole 256 bits chiffré de bout en bout",
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

