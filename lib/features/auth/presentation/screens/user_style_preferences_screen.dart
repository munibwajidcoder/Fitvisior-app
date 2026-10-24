import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/screens/home_screen.dart' show HomeScreen;
import '../../../scan/presentation/screens/avatar_onboarding_preview_screen.dart';
import '../../data/auth_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/widgets/language_toggle_badge.dart';

class UserStylePreferencesScreen extends StatefulWidget {
  final double? heightCm;
  final double? bustCm;
  final double? waistCm;
  final double? hipsCm;
  final double? weightKg;
  final bool isInch;
  final String? gender;
  final String? glbUrl;
  final String? userPhotoPath;

  const UserStylePreferencesScreen({
    super.key,
    this.heightCm,
    this.bustCm,
    this.waistCm,
    this.hipsCm,
    this.weightKg,
    this.isInch = false,
    this.gender,
    this.glbUrl,
    this.userPhotoPath,
  });

  @override
  State<UserStylePreferencesScreen> createState() =>
      _UserStylePreferencesScreenState();
}

class _UserStylePreferencesScreenState
    extends State<UserStylePreferencesScreen> {
  Map<String, dynamic>? _profile;
  bool _isSaving = false;

  // ── DYNAMIC PREFERENCES STATE ──
  List<String> _selectedStyles = ["Casual & Quotidien", "Minimaliste"];
  String _selectedFit = "Standard (Regular Fit)";
  List<String> _selectedColors = ["Neutres & Classiques", "Tons Froids & Marins"];
  List<String> _selectedBrands = ["Zara", "Nike", "Uniqlo"];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthService.getProfile();
      if (mounted) {
        setState(() {
          _profile = data;
          if (data?['style_preferences'] is List && (data!['style_preferences'] as List).isNotEmpty) {
            _selectedStyles = List<String>.from(data['style_preferences']);
          }
          if (data?['clothing_fit_preference'] is String && (data!['clothing_fit_preference'] as String).isNotEmpty) {
            _selectedFit = data['clothing_fit_preference'];
          }
          if (data?['preferred_colors'] is List && (data!['preferred_colors'] as List).isNotEmpty) {
            _selectedColors = List<String>.from(data['preferred_colors']);
          } else if (data?['color_preferences'] is List && (data!['color_preferences'] as List).isNotEmpty) {
            _selectedColors = List<String>.from(data['color_preferences']);
          }
          if (data?['favorite_brands'] is List && (data!['favorite_brands'] as List).isNotEmpty) {
            _selectedBrands = List<String>.from(data['favorite_brands']);
          }
        });
      }
    } catch (_) {}
  }

  // ── SAFE BACK REDIRECTION TO AVATAR ONBOARDING PREVIEW ──
  void _handleBackNavigation() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AvatarOnboardingPreviewScreen(
            glbUrl: widget.glbUrl ?? _profile?['avatar_glb_url'],
            heightCm: widget.heightCm ?? (_profile?['height_cm'] as num?)?.toDouble() ?? 174.0,
            bustCm: widget.bustCm ?? (_profile?['bust_cm'] as num?)?.toDouble() ?? 88.0,
            waistCm: widget.waistCm ?? (_profile?['waist_cm'] as num?)?.toDouble() ?? 70.0,
            hipsCm: widget.hipsCm ?? (_profile?['hip_cm'] as num?)?.toDouble() ?? 94.0,
            weightKg: widget.weightKg ?? (_profile?['weight_kg'] as num?)?.toDouble() ?? 65.0,
            gender: widget.gender ?? (_profile?['gender'] as String?) ?? 'Femme',
            isMetric: !widget.isInch,
          ),
        ),
      );
    }
  }

  // ── SAVE PREFERENCES TO SUPABASE / BACKEND ──
  Future<void> _saveAndContinue() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final updateData = <String, dynamic>{
        'style_preferences': _selectedStyles,
        'preferred_colors': _selectedColors,
        'favorite_brands': _selectedBrands,
        'clothing_fit_preference': _selectedFit,
        'onboarding_completed': true,
        'onboarding_step': 4,
      };

      if (widget.glbUrl != null && widget.glbUrl!.isNotEmpty) {
        updateData['avatar_glb_url'] = widget.glbUrl;
      }
      if (widget.heightCm != null) updateData['height_cm'] = widget.heightCm;
      if (widget.bustCm != null) updateData['bust_cm'] = widget.bustCm;
      if (widget.waistCm != null) updateData['waist_cm'] = widget.waistCm;
      if (widget.hipsCm != null) updateData['hip_cm'] = widget.hipsCm;
      if (widget.weightKg != null) updateData['weight_kg'] = widget.weightKg;
      if (widget.gender != null) updateData['gender'] = widget.gender;

      await AuthService.updateProfile(updateData);
    } catch (e) {
      debugPrint('[UserPreferences] Save warning: $e');
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  // ── GET RESOLVED VALUES (PROPS OR DB) ──
  String get _userName {
    final name = _profile?['full_name'] ??
        AuthService.currentUser?.userMetadata?['full_name'] ??
        _profile?['name'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString().trim();
    }
    return "Utilisateur FitVisor";
  }

  double? get _effHeight => widget.heightCm ?? (_profile?['height_cm'] as num?)?.toDouble();
  double? get _effBust => widget.bustCm ?? (_profile?['bust_cm'] as num?)?.toDouble();
  double? get _effWaist => widget.waistCm ?? (_profile?['waist_cm'] as num?)?.toDouble();
  double? get _effHips => widget.hipsCm ?? (_profile?['hip_cm'] as num?)?.toDouble();
  double? get _effWeight => widget.weightKg ?? (_profile?['weight_kg'] as num?)?.toDouble();
  String get _effGender => widget.gender ?? (_profile?['gender'] as String?) ?? 'Homme';

  String _formatDim(double? cmVal) {
    if (cmVal == null) return '--';
    if (widget.isInch) {
      final inch = cmVal / 2.54;
      return '${inch.toStringAsFixed(1)}"';
    }
    return '${cmVal.round()} cm';
  }

  String _formatWeight(double? kgVal) {
    if (kgVal == null) return '--';
    if (widget.isInch) {
      final lbs = kgVal * 2.20462;
      return '${lbs.round()} lbs';
    }
    return '${kgVal.toStringAsFixed(1)} kg';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBackNavigation();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FB),
            body: SafeArea(
              child: Column(
                children: [
                  // ── TOP NAVIGATION BAR ──────────────────────────────────
                  _buildTopBar(isEn),

                  // ── SCROLLABLE BODY ──────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 14),

                          // Step badge
                          _buildStepBadge(isEn),
                          const SizedBox(height: 10),

                          // Page title
                          Text(
                            isEn
                                ? "Your Style\nPreferences"
                                : "Vos Préférences\nde Style",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isEn
                                ? "Customize your style, fit, and colors for tailored 3D recommendations."
                                : "Personnalisez votre style, ajustement et couleurs pour des recommandations 3D sur-mesure.",
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── AVATAR PROFILE CARD (100% DYNAMIC) ───────────
                          _buildAvatarProfileCard(isEn),

                          const SizedBox(height: 20),

                          // ── PROFIL & MESURES SECTION ─────────────────────
                          _buildSectionHeader(
                            title: isEn
                                ? "Profile & Measurements"
                                : "Profil & Mensurations",
                            badge: isEn ? "Completed" : "Complété",
                            isCompleted: true,
                          ),
                          const SizedBox(height: 10),
                          _buildListCard(children: [
                            _buildListItem(
                              icon: Icons.accessibility_new_rounded,
                              title: isEn
                                  ? "3D Avatar Generated"
                                  : "Avatar 3D généré",
                              subtitle: isEn
                                  ? "Your 3D avatar and biometric measurements are saved."
                                  : "Votre avatar 3D et vos mensurations biométriques sont enregistrés.",
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isEn ? "Ready" : "Prêt",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                              onTap: () {
                                // Quick Info Dialog
                                _showAvatarInfoDialog();
                              },
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _buildListItem(
                              icon: Icons.tune_rounded,
                              title: isEn
                                  ? "Adjust Measurements"
                                  : "Ajuster les mensurations",
                              subtitle: isEn
                                  ? "Modify your height, bust, waist, or hips."
                                  : "Modifier votre taille, tour de poitrine, taille ou hanches.",
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  size: 20, color: Color(0xFFCBD5E1)),
                              onTap: _handleBackNavigation,
                            ),
                          ]),

                          const SizedBox(height: 22),

                          // ── STYLE PREFERENCES SECTION (DYNAMIC & INTERACTIVE) ────
                          _buildSectionHeader(
                            title: isEn
                                ? "Your Style Preferences"
                                : "Vos Préférences de Style",
                            badge: isEn ? "Step 4 of 4" : "Étape 4 sur 4",
                            isCompleted: false,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEn
                                ? "Select your preferences to calibrate our recommendation engine."
                                : "Sélectionnez vos goûts pour calibrer notre moteur de recommandation.",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildListCard(children: [
                            _buildListItem(
                              icon: Icons.checkroom_outlined,
                              title: isEn
                                  ? "Style Preferences"
                                  : "Préférences de Style",
                              subtitle: _selectedStyles.isEmpty
                                  ? (isEn
                                      ? "Select your preferred style"
                                      : "Sélectionnez votre style préféré")
                                  : _selectedStyles.join(", "),
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  size: 20, color: Color(0xFFCBD5E1)),
                              onTap: _showStylePreferencesModal,
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _buildListItem(
                              icon: Icons.people_outline_rounded,
                              title: isEn
                                  ? "Fit Preferences"
                                  : "Préférences d'Ajustement (Fit)",
                              subtitle: _selectedFit,
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  size: 20, color: Color(0xFFCBD5E1)),
                              onTap: _showFitPreferencesModal,
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _buildListItem(
                              icon: Icons.palette_outlined,
                              title: isEn
                                  ? "Preferred Color Palette"
                                  : "Palette de Couleurs Préférées",
                              subtitle: _selectedColors.isEmpty
                                  ? (isEn
                                      ? "Choose your favorite shades"
                                      : "Choisissez vos teintes préférées")
                                  : _selectedColors.join(", "),
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  size: 20, color: Color(0xFFCBD5E1)),
                              onTap: _showColorPreferencesModal,
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _buildListItem(
                              icon: Icons.local_offer_outlined,
                              title: isEn
                                  ? "Favorite Brands"
                                  : "Marques Préférées",
                              subtitle: _selectedBrands.isEmpty
                                  ? (isEn
                                      ? "Select your favorite brands"
                                      : "Sélectionnez vos marques favorites")
                                  : _selectedBrands.join(", "),
                              trailing: const Icon(Icons.chevron_right_rounded,
                                  size: 20, color: Color(0xFFCBD5E1)),
                              onTap: _showBrandsPreferencesModal,
                            ),
                          ]),

                          const SizedBox(height: 16),

                          // ── PRIVACY NOTICE ───────────────────────────────
                          _buildPrivacyNotice(isEn),

                          const SizedBox(height: 22),

                          // ── CTA BUTTON ───────────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveAndContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF43F5E),
                                disabledBackgroundColor:
                                    const Color(0xFFF43F5E).withValues(alpha: 0.5),
                                elevation: 3,
                                shadowColor: const Color(0xFFF43F5E)
                                    .withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              isEn
                                                  ? "Save & Discover Recommendations"
                                                  : "Enregistrer & Découvrir les Recommandations",
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 20),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────────────

  Widget _buildTopBar(bool isEn) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: _handleBackNavigation,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 28,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Image.asset('assets/images/logo.png', width: 26, height: 26),
          const SizedBox(width: 6),
          Text(
            "Fit Visor",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined,
                    size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  isEn ? "Secure" : "Sécurisé",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const LanguageToggleBadge(),
        ],
      ),
    );
  }

  // ── STEP BADGE ────────────────────────────────────────────────────────

  Widget _buildStepBadge(bool isEn) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFF43F5E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isEn
              ? "STEP 4 OF 4 • PROFILE & PREFERENCES"
              : "ÉTAPE 4 SUR 4  •  PROFIL & PRÉFÉRENCES",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF43F5E),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ── AVATAR PROFILE CARD (100% DYNAMIC FROM USER DATA) ────────────────

  Widget _buildAvatarProfileCard(bool isEn) {
    final customPhoto = _profile?['custom_profile_image'];
    final hasCustomPhoto = customPhoto != null && File(customPhoto).existsSync();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: User Photo / Avatar + Dynamic Name & Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: hasCustomPhoto
                          ? Image.file(
                              File(customPhoto),
                              width: 72,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/profile_avatar.jpg',
                              width: 72,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.75),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEn ? "PROFILE" : "PROFIL",
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              _userName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isEn ? "Edit" : "Modifier",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFF43F5E),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 15, color: Color(0xFFF43F5E)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_effGender.capitalizeFirst()}  •  ${_formatDim(_effHeight)}  •  ${_formatWeight(_effWeight)}",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.isInch
                              ? (isEn ? "Unit: Inches" : "Unité: Pouces (Inches)")
                              : (isEn ? "Unit: Centimeters (cm)" : "Unité: Centimètres (cm)"),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── MEASUREMENT GRID (ACCURATE INCHES / CM & WEIGHT) ───────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: _buildMeasurementCell(
                        isEn ? "HEIGHT" : "TAILLE", _formatDim(_effHeight)),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: _buildMeasurementCell(
                        isEn ? "BUST" : "BUSTE", _formatDim(_effBust)),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: _buildMeasurementCell(
                        isEn ? "WAIST" : "CEINTURE", _formatDim(_effWaist)),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: _buildMeasurementCell(
                        isEn ? "HIPS" : "HANCHES", _formatDim(_effHips)),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 72,
                    child: _buildMeasurementCell(
                        isEn ? "WEIGHT" : "POIDS", _formatWeight(_effWeight)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCell(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required String title,
    required String badge,
    required bool isCompleted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted) ...[
                const Icon(Icons.check_circle_rounded,
                    size: 13, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
              ],
              Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── WHITE LIST CARD ───────────────────────────────────────────────────

  Widget _buildListCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── LIST ITEM ROW ─────────────────────────────────────────────────────

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF475569)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF94A3B8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  // ── PRIVACY NOTICE ────────────────────────────────────────────────────

  Widget _buildPrivacyNotice(bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                size: 18, color: Color(0xFF475569)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEn
                  ? "Your biometric profile and fit preferences are encrypted and used exclusively to calibrate your 3D outfits."
                  : "Votre profil biométrique et vos préférences de coupe sont chiffrés et utilisés uniquement pour calibrer vos tenues 3D.",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. STYLE PREFERENCES BOTTOM SHEET MODAL ───────────────────────────

  void _showStylePreferencesModal() {
    final isEn = LanguageService.instance.isEnglish;
    final stylesList = isEn
        ? [
            {"name": "Casual & Everyday", "desc": "Jeans, comfortable t-shirts, sharp basics"},
            {"name": "Minimalist", "desc": "Clean lines, sustainable fabrics and understated tones"},
            {"name": "Chic & Formal", "desc": "Suits, blazers, dress shirts and tailored fits"},
            {"name": "Streetwear", "desc": "Urban silhouettes, hoodies, sneakers and oversized jackets"},
            {"name": "Sportswear & Athleisure", "desc": "Technical, breathable and dynamic athletic wear"},
            {"name": "Boho & Retro", "desc": "Natural textures, vintage pieces and distinctive prints"},
          ]
        : [
            {"name": "Casual & Quotidien", "desc": "Jeans, t-shirts confortables, basiques soignés"},
            {"name": "Minimaliste", "desc": "Lignes épurées, matières durables et tons sobres"},
            {"name": "Chic & Formel", "desc": "Costumes, blazers, chemises et coupes cintrées"},
            {"name": "Streetwear", "desc": "Silhouettes urbaines, hoodies, sneakers et vestes oversize"},
            {"name": "Sportswear & Athleisure", "desc": "Vêtements techniques, respirants et dynamiques"},
            {"name": "Bohème & Rétro", "desc": "Textures naturelles, pièces vintage et imprimés"},
          ];

    List<String> tempSelected = List<String>.from(_selectedStyles);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isEn ? "Your Clothing Styles" : "Vos Styles Vestimentaires",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? "Select one or more styles that match your everyday vibe:"
                    : "Sélectionnez un ou plusieurs styles qui vous correspondent :",
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: stylesList.map((st) {
                      final isSel = tempSelected.contains(st["name"]);
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            if (isSel) {
                              if (tempSelected.length > 1) {
                                tempSelected.remove(st["name"]);
                              }
                            } else {
                              tempSelected.add(st["name"]!);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: isSel ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      st["name"]!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSel ? const Color(0xFF0F172A) : const Color(0xFF334155),
                                      ),
                                    ),
                                    Text(
                                      st["desc"]!,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedStyles = tempSelected);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEn ? "Save my styles" : "Valider mes styles",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 2. FIT PREFERENCES BOTTOM SHEET MODAL ─────────────────────────────

  void _showFitPreferencesModal() {
    final isEn = LanguageService.instance.isEnglish;
    final fitsList = isEn
        ? [
            {
              "name": "Slim Fit",
              "badge": "Fitted",
              "desc": "Sculpted cut contouring your silhouette for a sharp, modern look."
            },
            {
              "name": "Regular Fit",
              "badge": "Classic",
              "desc": "Perfect balance between free movement and timeless elegance."
            },
            {
              "name": "Oversized / Relaxed",
              "badge": "Casual",
              "desc": "Generous, fluid cut ensuring maximum ease and relaxed comfort."
            },
          ]
        : [
            {
              "name": "Ajusté (Slim Fit)",
              "badge": "Près du corps",
              "desc": "Coupe sculptée épousant les formes pour une allure moderne et structurée."
            },
            {
              "name": "Standard (Regular Fit)",
              "badge": "Classique",
              "desc": "Équilibre parfait entre liberté de mouvement et élégance intemporelle."
            },
            {
              "name": "Ample (Oversized / Relaxed)",
              "badge": "Décontracté",
              "desc": "Coupe fluide et généreuse pour un maximum d'aisance et de confort."
            },
          ];

    String tempFit = _selectedFit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? "Your Fit Preference" : "Votre Préférence d'Ajustement",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? "Our algorithm will adapt size recommendations according to this fit:"
                    : "Notre algorithme adaptera les recommandations de taille selon cette coupe :",
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ...fitsList.map((ft) {
                final isSel = tempFit == ft["name"];
                return InkWell(
                  onTap: () {
                    setModalState(() => tempFit = ft["name"]!);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
                        width: isSel ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSel ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ft["name"]!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSel ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      ft["badge"]!,
                                      style: GoogleFonts.inter(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSel ? Colors.white : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ft["desc"]!,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedFit = tempFit);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEn ? "Confirm fit" : "Confirmer l'ajustement",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. COLOR PALETTES BOTTOM SHEET MODAL ──────────────────────────────

  void _showColorPreferencesModal() {
    final isEn = LanguageService.instance.isEnglish;
    final colorsList = isEn
        ? [
            {
              "name": "Neutrals & Classics",
              "colors": [const Color(0xFF0F172A), Colors.white, const Color(0xFF94A3B8), const Color(0xFFD4C5B9)],
              "desc": "Deep black, crisp white, charcoal grey and warm sand beige."
            },
            {
              "name": "Cool & Marine Tones",
              "colors": [const Color(0xFF1E3A8A), const Color(0xFF2E4057), const Color(0xFF475569), const Color(0xFF155E75)],
              "desc": "Royal navy blue, slate, raw indigo denim and mineral blue."
            },
            {
              "name": "Warm & Earth Tones",
              "colors": [const Color(0xFFB45309), const Color(0xFF881337), const Color(0xFF78350F), const Color(0xFFD97706)],
              "desc": "Terracotta, golden camel, deep burgundy and warm rust."
            },
            {
              "name": "Pastels & Soft Tones",
              "colors": [const Color(0xFFBAE6FD), const Color(0xFFFBCFE8), const Color(0xFFBBF7D0), const Color(0xFFFEF3C7)],
              "desc": "Sky blue, powder pink, delicate sage and soft vanilla."
            },
            {
              "name": "Bold & Vibrant",
              "colors": [const Color(0xFFE11D48), const Color(0xFF2563EB), const Color(0xFF059669), const Color(0xFFD946EF)],
              "desc": "Scarlet red, electric cobalt, emerald green and vivid magenta."
            },
          ]
        : [
            {
              "name": "Neutres & Classiques",
              "colors": [const Color(0xFF0F172A), Colors.white, const Color(0xFF94A3B8), const Color(0xFFD4C5B9)],
              "desc": "Noir profond, blanc optique, gris anthracite et beige sable."
            },
            {
              "name": "Tons Froids & Marins",
              "colors": [const Color(0xFF1E3A8A), const Color(0xFF2E4057), const Color(0xFF475569), const Color(0xFF155E75)],
              "desc": "Bleu marine royal, ardoise, denim brut et bleu minéral."
            },
            {
              "name": "Tons Chauds & Terre",
              "colors": [const Color(0xFFB45309), const Color(0xFF881337), const Color(0xFF78350F), const Color(0xFFD97706)],
              "desc": "Terracotta, camel doré, bordeaux profond et rouille chaleureux."
            },
            {
              "name": "Pastels & Douceur",
              "colors": [const Color(0xFFBAE6FD), const Color(0xFFFBCFE8), const Color(0xFFBBF7D0), const Color(0xFFFEF3C7)],
              "desc": "Bleu ciel, rose poudré, sauge délicat et vanille douce."
            },
            {
              "name": "Audacieux & Vifs",
              "colors": [const Color(0xFFE11D48), const Color(0xFF2563EB), const Color(0xFF059669), const Color(0xFFD946EF)],
              "desc": "Rouge écarlate, cobalt électrique, vert émeraude et magenta."
            },
          ];

    List<String> tempColors = List<String>.from(_selectedColors);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isEn ? "Your Color Palettes" : "Vos Palettes de Couleurs",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn
                    ? "Choose the color harmonies you love wearing:"
                    : "Choisissez les harmonies chromatiques que vous aimez porter :",
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: colorsList.map((pal) {
                      final isSel = tempColors.contains(pal["name"]);
                      final colorList = pal["colors"] as List<Color>;
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            if (isSel) {
                              if (tempColors.length > 1) {
                                tempColors.remove(pal["name"]);
                              }
                            } else {
                              tempColors.add(pal["name"] as String);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.check_circle_rounded : Icons.radio_button_off,
                                color: isSel ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          pal["name"] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const Spacer(),
                                        // Color circles
                                        Row(
                                          children: colorList.map((c) {
                                            return Container(
                                              width: 16,
                                              height: 16,
                                              margin: const EdgeInsets.only(left: 3),
                                              decoration: BoxDecoration(
                                                color: c,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.black.withValues(alpha: 0.15),
                                                  width: 1,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      pal["desc"] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedColors = tempColors);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isEn ? "Save colors" : "Valider les couleurs",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3B. BRANDS PREFERENCES BOTTOM SHEET MODAL ─────────────────────────

  void _showBrandsPreferencesModal() {
    final isEn = LanguageService.instance.isEnglish;
    final brandsList = isEn
        ? [
            {"name": "Zara", "desc": "Trending fashion, contemporary cuts & new arrivals"},
            {"name": "Nike", "desc": "Iconic streetwear, sneakers & athletic performance"},
            {"name": "Uniqlo", "desc": "Sustainable lifewear, flawless basics & textile innovations"},
            {"name": "Adidas", "desc": "Classic sportswear & urban heritage silhouettes"},
            {"name": "H&M", "desc": "Accessible essentials, casual styles & everyday fashion"},
            {"name": "Massimo Dutti", "desc": "Refined tailoring, premium fabrics & understated luxury"},
            {"name": "Levi's", "desc": "Authentic denim, timeless jeans & classic trucker jackets"},
            {"name": "Mango", "desc": "Modern Mediterranean chic & versatile seasonal edits"},
          ]
        : [
            {"name": "Zara", "desc": "Mode tendance, coupes contemporaines & nouveautés"},
            {"name": "Nike", "desc": "Streetwear iconique, sneakers & vêtements de sport"},
            {"name": "Uniqlo", "desc": "Essentiels durables, basiques parfaits & innovation textile"},
            {"name": "Adidas", "desc": "Sportswear classique & silhouettes urbaines"},
            {"name": "H&M", "desc": "Basiques accessibles, style casual & mode quotidienne"},
            {"name": "Massimo Dutti", "desc": "Élégance classique, tailleurs & matières nobles"},
            {"name": "Levi's", "desc": "Denim authentique, jeans intemporels & vestes"},
            {"name": "Mango", "desc": "Chic moderne, vestiaires féminins & masculins soignés"},
          ];

    List<String> tempBrands = List<String>.from(_selectedBrands);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? "Your Favorite Brands" : "Vos Marques Préférées",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEn
                      ? "Select the brands whose designs you love wearing:"
                      : "Sélectionnez les marques dont vous aimez porter les créations :",
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: brandsList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final br = brandsList[index];
                      final isSel = tempBrands.contains(br["name"]);
                      return InkWell(
                        onTap: () {
                          setModalState(() {
                            if (isSel) {
                              if (tempBrands.length > 1) {
                                tempBrands.remove(br["name"]);
                              }
                            } else {
                              tempBrands.add(br["name"]!);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSel ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                color: isSel ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      br["name"]!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSel ? const Color(0xFF0F172A) : const Color(0xFF334155),
                                      ),
                                    ),
                                    Text(
                                      br["desc"]!,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _selectedBrands = tempBrands);
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isEn ? "Save my brands" : "Valider mes marques",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 4. AVATAR INFO DIALOG ─────────────────────────────────────────────

  void _showAvatarInfoDialog() {
    final isEn = LanguageService.instance.isEnglish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
            const SizedBox(width: 8),
            Text(
              isEn ? "Calibrated Avatar" : "Avatar Calibré",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEn
                  ? "Your 3D avatar is perfectly synchronized with your current measurements:"
                  : "Votre avatar 3D est parfaitement synchronisé avec vos mensurations actuelles :",
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            _buildDialogRow(isEn ? "Height" : "Taille", _formatDim(_effHeight)),
            _buildDialogRow(isEn ? "Bust" : "Buste", _formatDim(_effBust)),
            _buildDialogRow(isEn ? "Waist" : "Ceinture", _formatDim(_effWaist)),
            _buildDialogRow(isEn ? "Hips" : "Hanches", _formatDim(_effHips)),
            _buildDialogRow(isEn ? "Weight" : "Poids", _formatWeight(_effWeight)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isEn ? "Close" : "Fermer",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: const Color(0xFFF43F5E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
          Text(v, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
