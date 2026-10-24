import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/utils/email_validator.dart';
import '../../../../core/widgets/language_toggle_badge.dart';
import '../../data/auth_service.dart';
import 'mfa_verification_screen.dart';
import 'welcome_back_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  String _selectedFitProfile = 'Regular';

  // ── Inline field error states ──
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  // ✅ REAL SUPABASE SIGNUP
  Future<void> _handleSignUp() async {
    final isEn = LanguageService.instance.isEnglish;
    // ── Clear previous errors ──
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
    });

    // ── Local validations ──
    bool hasError = false;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = isEn ? 'Please enter your full name.' : 'Veuillez entrer votre nom complet.');
      hasError = true;
    }
    final emailErr = EmailValidator.validate(_emailController.text);
    if (emailErr != null) {
      setState(() => _emailError = isEn ? 'Invalid email format.' : emailErr);
      hasError = true;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = isEn ? 'Password is required.' : 'Le mot de passe est obligatoire.');
      hasError = true;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = isEn ? 'Password too short (minimum 6 characters).' : 'Mot de passe trop court (minimum 6 caractères).');
      hasError = true;
    }
    if (!_agreeToTerms) {
      _showSnackError(isEn ? 'Please accept the terms of use.' : 'Veuillez accepter les conditions d\'utilisation.');
      return;
    }
    if (hasError) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        fitProfile: _selectedFitProfile,
      );

      if (response.user != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MfaVerificationScreen(
              email: _emailController.text.trim(),
              isSignUp: true,
              fitProfile: _selectedFitProfile,
            ),
          ),
        );
      } else if (mounted) {
        _showSnackError(isEn ? 'Sign up failed. Please try again.' : 'Inscription échouée. Veuillez réessayer.');
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('already been registered') || e.statusCode == '422') {
        // ── Email already registered ── Show prominent dialog with login redirect
        if (mounted) _showAlreadyRegisteredDialog(_emailController.text.trim());
      } else if (msg.contains('invalid email') || msg.contains('email')) {
        setState(() => _emailError = isEn ? 'Invalid email address.' : 'Adresse e-mail invalide.');
      } else if (msg.contains('weak password') || msg.contains('password')) {
        setState(() => _passwordError = isEn ? 'Password too weak. Use at least 6 characters.' : 'Mot de passe trop faible. Utilisez au moins 6 caractères.');
      } else {
        _showSnackError(isEn ? 'Sign up error. Please check your information.' : 'Erreur lors de l\'inscription. Veuillez vérifier vos informations.');
      }
    } catch (e) {
      _showSnackError(isEn ? 'An unexpected error occurred. Please try again.' : 'Une erreur inattendue est survenue. Veuillez réessayer.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Already Registered — prominent dialog with login button ──
  void _showAlreadyRegisteredDialog(String email) {
    final isEn = LanguageService.instance.isEnglish;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_rounded,
                    color: Color(0xFFF43F5E), size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Account Already Exists' : 'Compte déjà existant',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEn ? 'The email address' : 'L’adresse e-mail',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? 'is already associated with a Fitvisor account.\nSign in to continue.'
                    : 'est déjà associée à un compte Fitvisor.\nConnectez-vous pour continuer.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 24),
              // ── Se connecter button ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Navigate to login screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => WelcomeBackScreen(initialEmail: email)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEn ? 'Sign In' : 'Se connecter',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // ── Dismiss ──
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  isEn ? 'Cancel' : 'Annuler',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Simple snackbar for non-field errors ──
  void _showSnackError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 6),

                    // ---------------- TOP APP BAR ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button -> Go to Welcome Back Screen
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const WelcomeBackScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 28,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),

                        // Center Logo & Title
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Fit Visor",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        // Language Toggle Badge
                        const LanguageToggleBadge(),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ---------------- LOGO & HEADER SECTION ----------------
                    Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Text(
                      isEn
                          ? "Start your style journey"
                          : "Commencez votre voyage de style",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.6,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle
                    Text(
                      isEn
                          ? "Create your 3D fitting profile and try on curated outfits instantly."
                          : "Créez votre profil d'essayage 3D et essayez des tenues sélectionnées instantanément.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---------------- MAIN FORM CARD ----------------
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 18,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Full Name Field ---
                          Text(
                            isEn ? "Full Name" : "Nom complet",
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: _nameError != null
                                  ? const Color(0xFFFFF1F2)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: _nameError != null
                                  ? Border.all(
                                      color: const Color(0xFFE11D48), width: 1.2)
                                  : null,
                            ),
                            child: TextField(
                              controller: _nameController,
                              onChanged: (_) {
                                if (_nameError != null) {
                                  setState(() => _nameError = null);
                                }
                              },
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF334155),
                              ),
                              decoration: InputDecoration(
                                hintText: "ex. Alexa Morgan",
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF94A3B8),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: _nameError != null
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF64748B),
                                  size: 19,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          if (_nameError != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 13, color: Color(0xFFE11D48)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _nameError!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: const Color(0xFFE11D48),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 14),

                          // --- Email Address Field ---
                          Text(
                            isEn ? "Email Address" : "Adresse e-mail",
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: _emailError != null
                                  ? const Color(0xFFFFF1F2)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: _emailError != null
                                  ? Border.all(
                                      color: const Color(0xFFE11D48), width: 1.2)
                                  : null,
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() => _emailError = null);
                                }
                              },
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF334155),
                              ),
                              decoration: InputDecoration(
                                hintText: isEn
                                    ? "name@example.com"
                                    : "nom@exemple.com",
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF94A3B8),
                                ),
                                prefixIcon: Icon(
                                  Icons.mail_outline_rounded,
                                  color: _emailError != null
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF64748B),
                                  size: 19,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          if (_emailError != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 13, color: Color(0xFFE11D48)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _emailError!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: const Color(0xFFE11D48),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 14),

                          // --- Create Password Field ---
                          Text(
                            isEn
                                ? "Create Password"
                                : "Créer un mot de passe",
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: _passwordError != null
                                  ? const Color(0xFFFFF1F2)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: _passwordError != null
                                  ? Border.all(
                                      color: const Color(0xFFE11D48), width: 1.2)
                                  : null,
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onChanged: (_) {
                                if (_passwordError != null) {
                                  setState(() => _passwordError = null);
                                }
                              },
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF334155),
                              ),
                              decoration: InputDecoration(
                                hintText: isEn
                                    ? "At least 6 characters"
                                    : "Au moins 6 caractères",
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF94A3B8),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: _passwordError != null
                                      ? const Color(0xFFE11D48)
                                      : const Color(0xFF64748B),
                                  size: 19,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: const Color(0xFF64748B),
                                    size: 19,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          if (_passwordError != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 13, color: Color(0xFFE11D48)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    _passwordError!,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: const Color(0xFFE11D48),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 16),

                          // --- Initial 3D Fit Profile Selector ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.accessibility_new_rounded,
                                    size: 16,
                                    color: Color(0xFFE11D48),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isEn
                                        ? "Initial 3D Fit Profile"
                                        : "Profil d'essayage 3D initial",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                isEn ? "AR Adjustable" : "Ajustable en RA",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // 4 Fit Option Cards
                          Row(
                            children: [
                              _buildFitOption(
                                id: 'Petite',
                                title: isEn ? 'Petite' : 'Petit',
                                subtitle: '< 5\'3"',
                              ),
                              const SizedBox(width: 8),
                              _buildFitOption(
                                id: 'Regular',
                                title: isEn ? 'Regular' : 'Régulier',
                                subtitle: '5\'4"-5\'7"',
                              ),
                              const SizedBox(width: 8),
                              _buildFitOption(
                                id: 'Tall',
                                title: isEn ? 'Tall' : 'Grand',
                                subtitle: '> 5\'8"',
                              ),
                              const SizedBox(width: 8),
                              _buildFitOption(
                                id: 'Curvy',
                                title: isEn ? 'Curvy' : 'Galbé',
                                subtitle: isEn ? 'Hourglass' : 'Sablier',
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // --- Terms & Privacy Checkbox ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: Checkbox(
                                  value: _agreeToTerms,
                                  activeColor: const Color(0xFFE11D48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _agreeToTerms = val ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: isEn ? "I agree to the " : "J'accepte les ",
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: isEn
                                            ? "Terms of Service"
                                            : "Conditions d'utilisation",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF172554),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: isEn ? " and the " : " et la "),
                                      TextSpan(
                                        text: isEn
                                            ? "Spatial Privacy Policy"
                                            : "Politique de confidentialité spatiale",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF172554),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(
                                          text: isEn
                                              ? " of Fitvisor."
                                              : " de Fitvisor."),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // --- Primary Button: Create an account → REAL SUPABASE SIGNUP ---
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF43F5E),
                                disabledBackgroundColor: const Color(0xFFF43F5E)
                                    .withValues(alpha: 0.6),
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
                                              ? "Create an Account"
                                              : "Créer un compte",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --- Already have an account? Sign in ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isEn
                                    ? "Already have an account? "
                                    : "Vous avez déjà un compte ? ",
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const WelcomeBackScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  isEn ? "Sign In" : "Se connecter",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE11D48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- FOOTER SECURITY BADGE ----------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isEn
                              ? "256-bit Encryption • Private 3D Avatar Try-on"
                              : "Chiffrement 256 bits • Essayage d'avatar 3D privé",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFitOption({
    required String id,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedFitProfile == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFitProfile = id;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF172554) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF172554)
                  : const Color(0xFFF1F5F9),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF172554).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

