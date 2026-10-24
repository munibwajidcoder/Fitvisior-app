import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/widgets/language_toggle_badge.dart';
import 'capture_guide_screen.dart';
import 'neural_mesh_processing_screen.dart';

class ManualMeasurementsScreen extends StatefulWidget {
  final String avatarType;
  final bool initialMetric;

  const ManualMeasurementsScreen({
    super.key,
    this.avatarType = 'realistic',
    this.initialMetric = true, // Default to Metric (cm) as requested
  });

  @override
  State<ManualMeasurementsScreen> createState() =>
      _ManualMeasurementsScreenState();
}

class _ManualMeasurementsScreenState extends State<ManualMeasurementsScreen> {

  // Gender selection: 'Femme' or 'Homme' — saved to Supabase profiles
  String _selectedGender = 'Femme';

  // Unit toggle: false = Imperial (in), true = Metric (cm)
  late bool _isMetric;

  // Measurements in inches (base internal representation)
  double _heightInches = 67.0; // 5'7" (~170 cm)
  double _shouldersInches = 16.5;
  double _bustInches = 34.0;
  double _waistInches = 27.5;
  double _hipsInches = 38.0;
  double _inseamInches = 30.0;

  // Weight in kg (always kg, not affected by unit toggle)
  double _weightKg = 60.0;

  String _selectedCup = '34B';
  final List<String> _cupOptions = ['32B', '34B', '34C', '36A'];

  @override
  void initState() {
    super.initState();
    _isMetric = widget.initialMetric;
    _loadExistingProfile();
  }

  void _loadExistingProfile() async {
    try {
      final profile = await AuthService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          if (profile['gender'] != null) {
            _selectedGender = profile['gender'] as String;
          }
          if (profile['height_cm'] != null) {
            final double h = (profile['height_cm'] as num).toDouble();
            if (h > 0) _heightInches = h / 2.54;
          }
          if (profile['bust_cm'] != null) {
            final double b = (profile['bust_cm'] as num).toDouble();
            if (b > 0) _bustInches = b / 2.54;
          }
          if (profile['waist_cm'] != null) {
            final double w = (profile['waist_cm'] as num).toDouble();
            if (w > 0) _waistInches = w / 2.54;
          }
          if (profile['hip_cm'] != null) {
            final double hips = (profile['hip_cm'] as num).toDouble();
            if (hips > 0) _hipsInches = hips / 2.54;
          }
          if (profile['shoulder_cm'] != null) {
            final double s = (profile['shoulder_cm'] as num).toDouble();
            if (s > 0) _shouldersInches = s / 2.54;
          }
          if (profile['inseam_cm'] != null) {
            final double ins = (profile['inseam_cm'] as num).toDouble();
            if (ins > 0) _inseamInches = ins / 2.54;
          }
          if (profile['weight_kg'] != null) {
            final double wt = (profile['weight_kg'] as num).toDouble();
            if (wt > 0) _weightKg = wt;
          }
          if (profile['cup_size'] != null) {
            _selectedCup = profile['cup_size'] as String;
          }
        });
      }
    } catch (_) {}
  }

  // Conversion helpers
  double _inToCm(double inches) => inches * 2.54;

  String _formatHeight(double inches) {
    if (_isMetric) {
      return "${_inToCm(inches).round()} cm";
    }
    final int feet = (inches / 12).floor();
    final int remainingInches = (inches % 12).round();
    return "$feet' $remainingInches\"";
  }

  String _formatValue(double inches) {
    if (_isMetric) {
      return _inToCm(inches).toStringAsFixed(1);
    }
    return inches.toStringAsFixed(1);
  }

  String _unitLabel() => _isMetric ? "cm" : "in";

  void _restoreDefaults() {
    setState(() {
      _heightInches = 67.0;
      _shouldersInches = 16.5;
      _bustInches = 34.0;
      _waistInches = 27.5;
      _hipsInches = 38.0;
      _inseamInches = 30.0;
      _selectedCup = '34B';
      _weightKg = 60.0;
    });

    final isEn = LanguageService.instance.isEnglish;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn
              ? "AI scan estimates restored successfully!"
              : "Estimations du scan IA restaurées avec succès !",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _updateWeight(double val) {
    setState(() {
      _weightKg = double.parse(val.toStringAsFixed(1));
      final double bulk = math.sqrt(_weightKg / 65.0);
      _waistInches = double.parse((27.5 * bulk).clamp(22.0, 52.0).toStringAsFixed(1));
      _bustInches = double.parse((34.0 * math.pow(bulk, 0.75)).clamp(28.0, 56.0).toStringAsFixed(1));
      _hipsInches = double.parse((38.0 * math.pow(bulk, 0.80)).clamp(30.0, 58.0).toStringAsFixed(1));
    });
  }

  bool _isSaving = false;

  Future<void> _saveMeasurements() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final isEn = LanguageService.instance.isEnglish;
    final double h = _inToCm(_heightInches);
    final double b = _inToCm(_bustInches);
    final double w = _inToCm(_waistInches);
    final double hips = _inToCm(_hipsInches);
    final double shoulders = _inToCm(_shouldersInches);
    final double inseam = _inToCm(_inseamInches);

    // ── SAVE ALL MEASUREMENTS TO SUPABASE ────────────────────────────
    try {
      await AuthService.updateProfile({
        'gender': _selectedGender,           // Genre: Femme / Homme
        'height_cm': h,                      // Height in cm
        'bust_cm': b,                        // Bust/chest in cm
        'waist_cm': w,                       // Waist in cm
        'hip_cm': hips,                      // Hips in cm
        'shoulder_cm': shoulders,            // Shoulder width in cm
        'inseam_cm': inseam,                 // Inseam in cm
        'cup_size': _selectedCup,            // Bra cup size (e.g. 34B)
        'weight_kg': _weightKg,              // Weight in kg
        'avatar_type': widget.avatarType,    // 'anonymous' or 'realistic'
      });
    } catch (e) {
      // DB save failed — show warning but still continue the flow
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn
                  ? "Warning: data not saved (${e.toString().replaceAll('Exception: ', '')})"
                  : "Avertissement: données non sauvegardées (${e.toString().replaceAll('Exception: ', '')})",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Show success toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.avatarType == 'anonymous'
                    ? (isEn
                        ? "Measurements saved! Generating mannequin..."
                        : "Mensurations enregistrées ! Génération du mannequin...")
                    : (isEn
                        ? "Measurements saved successfully!"
                        : "Mensurations enregistrées avec succès !"),
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (widget.avatarType == 'anonymous') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NeuralMeshProcessingScreen(
            gender: _selectedGender,
            heightCm: h,
            weightKg: _weightKg,
            bustCm: b,
            waistCm: w,
            hipsCm: hips,
            isMetric: _isMetric,
            capturedImagePaths: null,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CaptureGuideScreen(
            gender: _selectedGender,
            heightCm: h,
            bustCm: b,
            waistCm: w,
            hipsCm: hips,
            isMetric: _isMetric,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          body: SafeArea(
            child: Column(
              children: [
                // ── TOP APP BAR ──────────────────────────────────────────
                _buildAppBar(context),

                // ── SCROLLABLE CONTENT ───────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Precision Fit & Unit Switcher Row
                        _buildHeaderRow(),

                        const SizedBox(height: 8),

                        // Intro Subtitle Text
                        Text(
                          isEn
                              ? "Enter your personalized measurements or fine-tune estimated dimensions for your 3D avatar."
                              : "Saisissez vos mensurations personnalisées ou affinez les dimensions estimées pour votre avatar 3D.",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── GENDER CARD (TOP) ─────────────────────────────
                        _buildGenderCard(),

                        const SizedBox(height: 12),

                        // Adaptive 3D Rig Status Card
                        _build3DRigCard(),

                        const SizedBox(height: 12),

                        // Help Card
                        _buildHelpCard(),

                        const SizedBox(height: 18),

                        // ── MEASUREMENT CARDS ────────────────────────────

                        // 0. Height Card
                        _buildHeightCard(),

                        const SizedBox(height: 14),

                        // 2. Shoulders Card
                        _buildSliderCard(
                          icon: Icons.border_clear_rounded,
                          title: isEn ? "Shoulders" : "Épaules",
                          subtitle: isEn ? "Biacromial width" : "Largeur biacromiale",
                          value: _shouldersInches,
                          min: 12.0,
                          max: 24.0,
                          onChanged: (val) => setState(() => _shouldersInches = val),
                        ),

                        const SizedBox(height: 14),

                        // 3. Bust / Chest Card with Cup Selection
                        _buildBustCard(),

                        const SizedBox(height: 14),

                        // 4. Waist Card
                        _buildSliderCard(
                          icon: Icons.compress_rounded,
                          title: isEn ? "Waist" : "Ceinture",
                          titleBadge: isEn ? "Natural" : "Naturel",
                          subtitle: isEn
                              ? "Narrowest section of torso"
                              : "Section la plus étroite du torse",
                          value: _waistInches,
                          min: 20.0,
                          max: 45.0,
                          onChanged: (val) => setState(() => _waistInches = val),
                        ),

                        const SizedBox(height: 14),

                        // 5. Hips Card
                        _buildSliderCard(
                          icon: Icons.crop_square_rounded,
                          title: isEn ? "Hips" : "Hanches",
                          subtitle: isEn
                              ? "Widest contour line"
                              : "Ligne de contour la plus large",
                          value: _hipsInches,
                          min: 25.0,
                          max: 55.0,
                          onChanged: (val) => setState(() => _hipsInches = val),
                        ),

                        const SizedBox(height: 14),

                        // 6. Inseam Card
                        _buildSliderCard(
                          icon: Icons.straighten_rounded,
                          title: isEn ? "Inseam" : "Entrejambe",
                          subtitle: isEn
                              ? "Crotch to ankle"
                              : "Entrejambe à la cheville",
                          value: _inseamInches,
                          min: 22.0,
                          max: 40.0,
                          onChanged: (val) => setState(() => _inseamInches = val),
                        ),

                        const SizedBox(height: 14),

                        // 7. Weight Card (always in kg)
                        _buildWeightCard(),

                        const SizedBox(height: 24),

                        // ── SAVE BUTTON ──────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveMeasurements,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF43F5E),
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.4),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.avatarType == 'anonymous'
                                            ? (isEn
                                                ? "Generate my 3D Mannequin"
                                                : "Générer mon Mannequin 3D")
                                            : (isEn
                                                ? "Continue to Scan Guide"
                                                : "Continuer vers le Guide de Scan"),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, size: 20),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── RESTORE AI SCAN ESTIMATES BUTTON ─────────────
                        Center(
                          child: GestureDetector(
                            onTap: _restoreDefaults,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.refresh_rounded,
                                      size: 18, color: Color(0xFFBE123C)),
                                  const SizedBox(width: 6),
                                  Text(
                                    isEn
                                        ? "Restore AI scan estimates"
                                        : "Restaurer les estimations de l'IA",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFBE123C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 14, 6),
      color: const Color(0xFFFAF9FB),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.chevron_left_rounded,
                  size: 26, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 4),
          Image.asset('assets/images/logo.png', width: 24, height: 24),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isEn ? "Measurements" : "Mensurations",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const LanguageToggleBadge(),
          const SizedBox(width: 8),
          // Profile Avatar Icon (Dynamic)
          ValueListenableBuilder<File?>(
            valueListenable: UserAvatarService.avatarNotifier,
            builder: (context, avatarFile, _) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: ClipOval(
                  child: avatarFile != null
                      ? Image.file(avatarFile, fit: BoxFit.cover)
                      : const Icon(Icons.person_rounded, size: 18, color: Color(0xFF94A3B8)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // \u2500\u2500 GENDER SELECTION CARD \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Widget _buildGenderCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wc_rounded,
                    size: 18, color: Color(0xFFE11D48)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? "Morphological Gender" : "Genre morphologique",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      isEn
                          ? "3D Template — saved to your profile"
                          : "Gabarit 3D — enregistré dans votre profil",
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  label: isEn ? "Woman" : "Femme",
                  icon: Icons.female_rounded,
                  selected: _selectedGender == 'Femme',
                  onTap: () => setState(() => _selectedGender = 'Femme'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildGenderOption(
                  label: isEn ? "Man" : "Homme",
                  icon: Icons.male_rounded,
                  selected: _selectedGender == 'Homme',
                  onTap: () => setState(() => _selectedGender = 'Homme'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? const Color(0xFFE11D48) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // \u2500\u2500 HEADER ROW (LABEL + IN/CM SWITCH) \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  Widget _buildHeaderRow() {
    final isEn = LanguageService.instance.isEnglish;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Precision Fit Label
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.straighten_rounded,
                    size: 15, color: Color(0xFFE11D48)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isEn ? "PRECISION FIT" : "AJUSTEMENT DE PRÉCISION",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Unit Switcher Toggle (in / cm)
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _buildUnitTab(label: "cm", active: _isMetric, onTap: () => setState(() => _isMetric = true)),
              _buildUnitTab(label: "in", active: !_isMetric, onTap: () => setState(() => _isMetric = false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitTab({required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF172554) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ── ADAPTIVE 3D RIG CARD ────────────────────────────────────────────
  Widget _build3DRigCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mannequin Icon Container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: const Icon(Icons.accessibility_new_rounded,
                size: 28, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 12),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      isEn ? "Adaptive 3D Rig" : "Rig 3D Adaptatif",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isEn ? "Confidence 94%" : "Confiance 94%",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isEn
                      ? "Synchronized with Fitvisor neural scanner"
                      : "Synchronisé avec le scanner neural Fitvisor",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Scan Viewfinder Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.crop_free_rounded,
                size: 20, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  // ── NEED HELP MEASURING CARD ────────────────────────────────────────
  Widget _buildHelpCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded,
                size: 20, color: Color(0xFFF43F5E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? "Need help measuring?" : "Besoin d'aide pour mesurer ?",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEn
                      ? "Tap any body region to launch the visual AR guide."
                      : "Appuyez sur n'importe quelle zone corporelle pour lancer le guide visuel avec repères RA.",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  // ── HEIGHT CARD ────────────────────────────────────────────────────
  Widget _buildHeightCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.height_rounded,
                        size: 20, color: Color(0xFF475569)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? "Height" : "Taille",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isEn ? "Head to toe" : "De la tête aux pieds",
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Height Display Value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatHeight(_heightInches),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (_isMetric)
                    Text(
                      "(${(_heightInches / 12).floor()}' ${(_heightInches % 12).round()}\")",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      "(${_inToCm(_heightInches).round()} cm)",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Slider Row with - and +
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                onTap: () {
                  if (_heightInches > 56.0) {
                    setState(() => _heightInches -= 1.0);
                  }
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: const Color(0xFFE2E8F0),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF172554),
                    overlayColor: const Color(0xFF172554).withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _heightInches,
                    min: 56.0,
                    max: 80.0,
                    onChanged: (val) => setState(() => _heightInches = val),
                  ),
                ),
              ),
              _buildStepButton(
                icon: Icons.add,
                onTap: () {
                  if (_heightInches < 80.0) {
                    setState(() => _heightInches += 1.0);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Min / Max Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isMetric ? "Min : 142 cm" : "Min : 4' 8\"",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  _isMetric ? "Max : 203 cm" : "Max : 6' 8\"",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BUST / CHEST CARD WITH CUP SELECTOR ─────────────────────────────
  Widget _buildBustCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.favorite_outline_rounded,
                        size: 20, color: Color(0xFFE11D48)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? "Bust / Chest" : "Poitrine / Buste",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isEn ? "Apex circumference" : "Circonférence de l'apex",
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatValue(_bustInches),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _unitLabel(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Cup Selector Row
          Row(
            children: [
              Text(
                isEn ? "Cup :" : "Bonnet :",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 10),
              Wrap(
                spacing: 6,
                children: _cupOptions.map((cup) {
                  final isSelected = cup == _selectedCup;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCup = cup),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF172554)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        cup,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Slider Row
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                onTap: () {
                  if (_bustInches > 24.0) {
                    setState(() => _bustInches -= 0.5);
                  }
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: const Color(0xFFE2E8F0),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF172554),
                    overlayColor: const Color(0xFF172554).withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _bustInches,
                    min: 24.0,
                    max: 50.0,
                    onChanged: (val) => setState(() => _bustInches = val),
                  ),
                ),
              ),
              _buildStepButton(
                icon: Icons.add,
                onTap: () {
                  if (_bustInches < 50.0) {
                    setState(() => _bustInches += 0.5);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isMetric ? "Min : ${_inToCm(24.0).round()} cm" : "Min : 24.0 in",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  _isMetric ? "Max : ${_inToCm(50.0).round()} cm" : "Max : 50.0 in",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── GENERIC SLIDER CARD ─────────────────────────────────────────────
  Widget _buildSliderCard({
    required IconData icon,
    required String title,
    String? titleBadge,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LEFT: Icon + Title + Subtitle (Expanded to take available space)
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Icon(icon, size: 20, color: const Color(0xFF475569)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (titleBadge != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    titleBadge,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // RIGHT: Value + Unit (fixed, no overflow)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formatValue(value),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _unitLabel(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Slider Row
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                onTap: () {
                  if (value > min) {
                    onChanged(value - 0.5);
                  }
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 5,
                    activeTrackColor: const Color(0xFFE2E8F0),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF172554),
                    overlayColor: const Color(0xFF172554).withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 11,
                      elevation: 3,
                      pressedElevation: 6,
                    ),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
              _buildStepButton(
                icon: Icons.add,
                onTap: () {
                  if (value < max) {
                    onChanged(value + 0.5);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isMetric ? "Min : ${_inToCm(min).round()} cm" : "Min : ${min.toStringAsFixed(1)} in",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  _isMetric ? "Max : ${_inToCm(max).round()} cm" : "Max : ${max.toStringAsFixed(1)} in",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP BUTTON (- / +) ──────────────────────────────────────────────
  Widget _buildStepButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF475569)),
      ),
    );
  }

  // ── WEIGHT CARD (always in kg) ──────────────────────────────────────
  Widget _buildWeightCard() {
    final isEn = LanguageService.instance.isEnglish;
    // Dark blue theme constant for icon
    const darkBlue = Color(0xFF1E3A8A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Subtle dark blue gradient background
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF0F7FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBlue.withValues(alpha: 0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.monitor_weight_outlined,
                        size: 20, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? "Weight" : "Poids",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isEn ? "Body mass" : "Masse corporelle",
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _weightKg.toStringAsFixed(1),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    "kg",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: darkBlue.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Slider Row with - and +
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                onTap: () {
                  if (_weightKg > 30.0) {
                    _updateWeight(_weightKg - 1.0);
                  }
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 5,
                    activeTrackColor: const Color(0xFFE2E8F0),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF172554),
                    overlayColor: const Color(0xFF172554).withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 11,
                      elevation: 3,
                      pressedElevation: 6,
                    ),
                  ),
                  child: Slider(
                    value: _weightKg,
                    min: 30.0,
                    max: 150.0,
                    onChanged: (val) => _updateWeight(val),
                  ),
                ),
              ),
              _buildStepButton(
                icon: Icons.add,
                onTap: () {
                  if (_weightKg < 150.0) {
                    _updateWeight(_weightKg + 1.0);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Min / Max Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "30 kg",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                "Poids de référence standard",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                "150 kg",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

