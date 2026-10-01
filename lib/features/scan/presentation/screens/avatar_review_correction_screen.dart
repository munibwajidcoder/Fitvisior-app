import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/screens/home_screen.dart';
import 'body_scan_screen.dart';

class AvatarReviewCorrectionScreen extends StatefulWidget {
  const AvatarReviewCorrectionScreen({super.key});

  @override
  State<AvatarReviewCorrectionScreen> createState() =>
      _AvatarReviewCorrectionScreenState();
}

class _AvatarReviewCorrectionScreenState
    extends State<AvatarReviewCorrectionScreen> {
  // ── STATE VARIABLES ────────────────────────────────────────────────
  String _viewMode = 'Silhouette'; // 'Wireframe', 'Teint', 'Silhouette'

  // Proportions
  double _heightInches = 67.0; // 5' 7"
  double _waistInches = 27.5;
  String _shoulderTorso = 'Classique';
  final List<String> _shoulderTorsoOptions = ['Minces', 'Classique', 'Larges'];

  // Proportion Offsets
  double _torsoLengthCm = 0.0; // -5.0 to +5.0 cm
  String _waistSensitivity = 'Naturel'; // 'Droit', 'Naturel', 'Sablier'
  double _hipBreadthCm = 0.0; // -2.0 to +2.0 cm
  String _shoulderSlope = 'Standard'; // 'Athlétique', 'Standard', 'Décontracté'
  double _inseamMm = 0.0; // -30 to +30 mm

  double _rotationAngle = 0.0;

  void _resetToBaseline() {
    setState(() {
      _heightInches = 67.0;
      _waistInches = 27.5;
      _shoulderTorso = 'Classique';
      _torsoLengthCm = 0.0;
      _waistSensitivity = 'Naturel';
      _hipBreadthCm = 0.0;
      _shoulderSlope = 'Standard';
      _inseamMm = 0.0;
      _rotationAngle = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Valeurs de calibration réinitialisées au scan d'origine !",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatHeight(double inches) {
    final int feet = (inches / 12).floor();
    final int remainingInches = (inches % 12).round();
    return "$feet' $remainingInches\"";
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP APP BAR ──────────────────────────────────────────
            _buildAppBar(context),

            // ── SCROLLABLE BODY ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── TOP BIOMETRIC MATCH BADGES ───────────────────
                    _buildBiometricMatchBadges(),

                    const SizedBox(height: 12),

                    // ── 3D AVATAR RENDER CANVAS ──────────────────────
                    _buildRenderCanvas(),

                    const SizedBox(height: 18),

                    // ── FINE-TUNE PROPORTIONS CARD ───────────────────
                    _buildProportionsCard(),

                    const SizedBox(height: 18),

                    // ── PROPORTION OFFSETS CARD ──────────────────────
                    _buildOffsetsCard(),

                    const SizedBox(height: 24),

                    // ── SAVE CHANGES BUTTON ──────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.greenAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Avatar 3D mis à jour avec succès !",
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF0F172A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor:
                              const Color(0xFFF43F5E).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Enregistrer & Mettre à jour l'avatar",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── RETAKE SCAN BUTTON ───────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BodyScanScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFF43F5E), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor:
                              const Color(0xFFFFF1F2).withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Reprendre le scan",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.refresh_rounded,
                                color: Color(0xFFE11D48), size: 18),
                          ],
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
  }

  // ── APP BAR ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 6),
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
                  size: 28, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 4),
          Image.asset('assets/images/logo.png', width: 26, height: 26),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    "Correction de l'Avatar 3D",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.help_outline_rounded,
                    size: 16, color: Colors.grey.shade500),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // User Profile Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              image: const DecorationImage(
                image: AssetImage('assets/images/profile_avatar.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TOP BIOMETRIC MATCH BADGES ─────────────────────────────────────
  Widget _buildBiometricMatchBadges() {
    return Row(
      children: [
        // Left Badge
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 13, color: Color(0xFFE11D48)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "99,2% Corrélation Biométrique",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE11D48),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Right Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "Haute Précision",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 3D AVATAR RENDER CANVAS ────────────────────────────────────────
  Widget _buildRenderCanvas() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _rotationAngle += details.delta.dx * 0.5;
        });
      },
      child: Container(
        height: 380,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF0F172A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 3D Avatar Render background image with rotation transform
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_rotationAngle * 0.005),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/scan_front_pose.jpg',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // ── FLOATING TOP-RIGHT VIEW MODE PILLS ─────────────────
              Positioned(
                top: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildViewModePill("Wireframe", Icons.grid_4x4_rounded),
                    const SizedBox(height: 6),
                    _buildViewModePill("Teint", Icons.color_lens_outlined),
                    const SizedBox(height: 6),
                    _buildViewModePill("Silhouette", Icons.accessibility_rounded),
                  ],
                ),
              ),

              // ── FLOATING BOTTOM OVERLAY PILLS ──────────────────────
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sync_rounded,
                                size: 13, color: Color(0xFF0F172A)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                "360° Glisser pour pivoter",
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.zoom_in_rounded,
                                size: 13, color: Color(0xFF0F172A)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                "Pincer pour zoomer",
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewModePill(String mode, IconData icon) {
    final isSelected = mode == _viewMode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : Colors.white.withValues(alpha: 0.9)),
            const SizedBox(width: 6),
            Text(
              mode,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FINE-TUNE PROPORTIONS CARD ──────────────────────────────────────
  Widget _buildProportionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          // Header Row
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          size: 18, color: Color(0xFF475569)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ajuster les proportions",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Étalonner par rapport à la taille réelle",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Reset Button
              GestureDetector(
                onTap: _resetToBaseline,
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded,
                        size: 13, color: Color(0xFFE11D48)),
                    const SizedBox(width: 4),
                    Text(
                      "Réinitialiser",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Height Slider Box
          _buildCompactSliderBox(
            icon: Icons.height_rounded,
            title: "Taille",
            displayValue: _formatHeight(_heightInches),
            value: _heightInches,
            min: 56.0,
            max: 80.0,
            onDecrement: () {
              if (_heightInches > 56.0) setState(() => _heightInches -= 1.0);
            },
            onIncrement: () {
              if (_heightInches < 80.0) setState(() => _heightInches += 1.0);
            },
            onChanged: (v) => setState(() => _heightInches = v),
          ),

          const SizedBox(height: 12),

          // Waist Fit Slider Box
          _buildCompactSliderBox(
            icon: Icons.compress_rounded,
            title: "Ajustement de Taille",
            displayValue: "${_waistInches.toStringAsFixed(1)} in",
            value: _waistInches,
            min: 20.0,
            max: 45.0,
            onDecrement: () {
              if (_waistInches > 20.0) setState(() => _waistInches -= 0.5);
            },
            onIncrement: () {
              if (_waistInches < 45.0) setState(() => _waistInches += 0.5);
            },
            onChanged: (v) => setState(() => _waistInches = v),
          ),

          const SizedBox(height: 12),

          // Shoulders & Torso Dropdown Selector Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.open_in_full_rounded,
                          size: 18, color: Color(0xFF475569)),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          "Épaules & Torse",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final idx =
                              _shoulderTorsoOptions.indexOf(_shoulderTorso);
                          if (idx > 0) {
                            setState(() => _shoulderTorso =
                                _shoulderTorsoOptions[idx - 1]);
                          }
                        },
                        child: const Icon(Icons.chevron_left_rounded,
                            size: 18, color: Color(0xFF475569)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _shoulderTorso,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          final idx =
                              _shoulderTorsoOptions.indexOf(_shoulderTorso);
                          if (idx < _shoulderTorsoOptions.length - 1) {
                            setState(() => _shoulderTorso =
                                _shoulderTorsoOptions[idx + 1]);
                          }
                        },
                        child: const Icon(Icons.chevron_right_rounded,
                            size: 18, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PROPORTION OFFSETS CARD ────────────────────────────────────────
  Widget _buildOffsetsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Décalages des Proportions",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "Delta : ±0,0%",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Offset 1: Torso Length Slider Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Longueur du Torse",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_torsoLengthCm >= 0 ? '+' : ''}${_torsoLengthCm.toStringAsFixed(1)} cm",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStepBtn(
                      icon: Icons.remove,
                      onTap: () {
                        if (_torsoLengthCm > -5.0) {
                          setState(() => _torsoLengthCm -= 0.5);
                        }
                      }),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 5,
                        activeTrackColor: const Color(0xFFE2E8F0),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFF0F172A),
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _torsoLengthCm,
                        min: -5.0,
                        max: 5.0,
                        onChanged: (v) => setState(() => _torsoLengthCm = v),
                      ),
                    ),
                  ),
                  _buildMiniStepBtn(
                      icon: Icons.add,
                      onTap: () {
                        if (_torsoLengthCm < 5.0) {
                          setState(() => _torsoLengthCm += 0.5);
                        }
                      }),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Raccourci (-5)",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                  Text("Ligne de base",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                  Text("Allongé (+5)",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 2: Waist Contour Sensitivity Segmented Buttons Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      "Sensibilité du Contour de Taille",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Naturel (Par défaut)",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Droit', 'Naturel', 'Sablier'].map((opt) {
                  final isSelected = opt == _waistSensitivity;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _waistSensitivity = opt),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            opt,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 3: Hip Breadth Fine-Tuning Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ajustement des Hanches",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_hipBreadthCm >= 0 ? '+' : ''}${_hipBreadthCm.toStringAsFixed(1)} cm",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStepBtn(
                      icon: Icons.remove,
                      onTap: () {
                        if (_hipBreadthCm > -2.0) {
                          setState(() => _hipBreadthCm -= 0.5);
                        }
                      }),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 5,
                        activeTrackColor: const Color(0xFFE2E8F0),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFF0F172A),
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _hipBreadthCm,
                        min: -2.0,
                        max: 2.0,
                        onChanged: (v) => setState(() => _hipBreadthCm = v),
                      ),
                    ),
                  ),
                  _buildMiniStepBtn(
                      icon: Icons.add,
                      onTap: () {
                        if (_hipBreadthCm < 2.0) {
                          setState(() => _hipBreadthCm += 0.5);
                        }
                      }),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("-2,0 cm (Ajusté)",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                  Text("Pivot Scanné",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                  Text("+2,0 cm (Galbé)",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 4: Shoulder Slope Segmented Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pente des Épaules / Angle",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Standard (21°)",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: ['Athlétique', 'Standard', 'Décontracté'].map((opt) {
                  final isSelected = opt == _shoulderSlope;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _shoulderSlope = opt),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            opt,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Offset 5: Inseam Offset Ratio Slider Box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ratio de Décalage Entrejambe",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_inseamMm >= 0 ? '+' : ''}${_inseamMm.round()} mm",
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMiniStepBtn(
                      icon: Icons.remove,
                      onTap: () {
                        if (_inseamMm > -30.0) {
                          setState(() => _inseamMm -= 5.0);
                        }
                      }),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 5,
                        activeTrackColor: const Color(0xFFE2E8F0),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFF0F172A),
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _inseamMm,
                        min: -30.0,
                        max: 30.0,
                        onChanged: (v) => setState(() => _inseamMm = v),
                      ),
                    ),
                  ),
                  _buildMiniStepBtn(
                      icon: Icons.add,
                      onTap: () {
                        if (_inseamMm < 30.0) {
                          setState(() => _inseamMm += 5.0);
                        }
                      }),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("-30 mm (Petite)",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                  Text("Scan Réel",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                  Text("+30 mm (Grand)",
                      style: GoogleFonts.inter(
                          fontSize: 10, color: const Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── HELPER SLIDER BOX WIDGET ─────────────────────────────────────────
  Widget _buildCompactSliderBox({
    required IconData icon,
    required String title,
    required String displayValue,
    required double value,
    required double min,
    required double max,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: const Color(0xFF475569)),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                displayValue,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniStepBtn(icon: Icons.remove, onTap: onDecrement),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 5,
                    activeTrackColor: const Color(0xFFE2E8F0),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF0F172A),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
              _buildMiniStepBtn(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStepBtn(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}
