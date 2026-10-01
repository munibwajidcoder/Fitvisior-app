import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'neural_mesh_processing_screen.dart';

class ManualMeasurementsScreen extends StatefulWidget {
  const ManualMeasurementsScreen({super.key});

  @override
  State<ManualMeasurementsScreen> createState() =>
      _ManualMeasurementsScreenState();
}

class _ManualMeasurementsScreenState extends State<ManualMeasurementsScreen> {
  // Unit toggle: false = Imperial (in), true = Metric (cm)
  bool _isMetric = false;

  // Measurements in inches (base state)
  double _heightInches = 67.0; // 5'7"
  double _shouldersInches = 16.5;
  double _bustInches = 34.0;
  double _waistInches = 27.5;
  double _hipsInches = 38.0;
  double _inseamInches = 30.0;

  String _selectedCup = '34B';
  final List<String> _cupOptions = ['32B', '34B', '34C', '36A'];

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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Estimations du scan IA restaurées avec succès !",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _saveMeasurements() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              "Mensurations enregistrées avec succès !",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => const NeuralMeshProcessingScreen()),
    );
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
                      "Saisissez vos mensurations personnalisées ou affinez les dimensions estimées pour votre avatar 3D.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Adaptive 3D Rig Status Card
                    _build3DRigCard(),

                    const SizedBox(height: 12),

                    // Help Card
                    _buildHelpCard(),

                    const SizedBox(height: 18),

                    // ── MEASUREMENT CARDS ────────────────────────────

                    // 1. Height Card
                    _buildHeightCard(),

                    const SizedBox(height: 14),

                    // 2. Shoulders Card
                    _buildSliderCard(
                      icon: Icons.border_clear_rounded,
                      title: "Épaules",
                      subtitle: "Largeur biacromiale",
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
                      title: "Taille",
                      titleBadge: "Naturel",
                      subtitle: "Section la plus étroite du torse",
                      value: _waistInches,
                      min: 20.0,
                      max: 45.0,
                      onChanged: (val) => setState(() => _waistInches = val),
                    ),

                    const SizedBox(height: 14),

                    // 5. Hips Card
                    _buildSliderCard(
                      icon: Icons.crop_square_rounded,
                      title: "Hanches",
                      subtitle: "Ligne de contour la plus large",
                      value: _hipsInches,
                      min: 25.0,
                      max: 55.0,
                      onChanged: (val) => setState(() => _hipsInches = val),
                    ),

                    const SizedBox(height: 14),

                    // 6. Inseam Card
                    _buildSliderCard(
                      icon: Icons.straighten_rounded,
                      title: "Entrejambe",
                      subtitle: "Entrejambe à la cheville",
                      value: _inseamInches,
                      min: 22.0,
                      max: 40.0,
                      onChanged: (val) => setState(() => _inseamInches = val),
                    ),

                    const SizedBox(height: 24),

                    // ── SAVE BUTTON ──────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _saveMeasurements,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Enregistrer les mensurations",
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
                                "Restaurer les estimations de l'IA",
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
  }

  // ── APP BAR ────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
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
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    "Mensurations Manuelles",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
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
          // Profile Avatar Icon
          Container(
            width: 32,
            height: 32,
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

  // ── HEADER ROW (LABEL + IN/CM SWITCH) ───────────────────────────────
  Widget _buildHeaderRow() {
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
                  "AJUSTEMENT DE PRÉCISION",
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
              _buildUnitTab(label: "in", active: !_isMetric, onTap: () => setState(() => _isMetric = false)),
              _buildUnitTab(label: "cm", active: _isMetric, onTap: () => setState(() => _isMetric = true)),
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
          color: active ? const Color(0xFF1E293B) : Colors.transparent,
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
                      "Rig 3D Adaptatif",
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
                        "Confiance 94%",
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
                  "Synchronisé avec le scanner neural DresKode",
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
                  "Besoin d'aide pour mesurer ?",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Appuyez sur n'importe quelle zone corporelle pour lancer le guide visuel avec repères RA.",
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
                        "Taille",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        "De la tête aux pieds",
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
                  if (!_isMetric)
                    Text(
                      "(${_heightInches.round()} in)",
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
                    thumbColor: const Color(0xFF1E293B),
                    overlayColor: const Color(0xFF1E293B).withValues(alpha: 0.1),
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

          // Min / Avg / Max Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isMetric ? "142 cm" : "4' 8\" (56\")",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                "Moyenne d'ajustement standard",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              Text(
                _isMetric ? "203 cm" : "6' 8\" (80\")",
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

  // ── BUST / CHEST CARD WITH CUP SELECTOR ─────────────────────────────
  Widget _buildBustCard() {
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
                        "Poitrine / Buste",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        "Circonférence de l'apex",
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
                "Bonnet :",
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
                            ? const Color(0xFF1E293B)
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
                    thumbColor: const Color(0xFF1E293B),
                    overlayColor: const Color(0xFF1E293B).withValues(alpha: 0.1),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
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
                    trackHeight: 6,
                    activeTrackColor: const Color(0xFFE2E8F0),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    thumbColor: const Color(0xFF1E293B),
                    overlayColor: const Color(0xFF1E293B).withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
}
