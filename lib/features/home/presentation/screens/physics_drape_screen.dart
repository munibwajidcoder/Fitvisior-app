import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'size_selection_screen.dart';
import 'live_ar_mirror_screen.dart';

class PhysicsDrapeScreen extends StatefulWidget {
  const PhysicsDrapeScreen({super.key});

  @override
  State<PhysicsDrapeScreen> createState() => _PhysicsDrapeScreenState();
}

class _PhysicsDrapeScreenState extends State<PhysicsDrapeScreen> {
  int _selectedPreset = 0; // 0 = Catwalk Stride, 1 = Seated Lounge, 2 = Urban Walk
  int _selectedSpeed = 2; // 0 = 0.25x, 1 = 0.5x, 2 = 1.0x
  bool _isPlaying = true;
  double _timelineValue = 0.56; // 01:42 out of 03:00s

  static const Color _midnightNavy = Color(0xFF172554);

  final List<String> _speeds = ['0.25x', '0.5x', '1.0x'];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP APP BAR ──────────────────────────────────────────
            _buildAppBar(context),

            // ── SCROLLABLE BODY ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Engine & Fabric Specs Row
                    _buildTopEngineSpecRow(),

                    const SizedBox(height: 12),

                    // 1. 3D CLOTH PHYSICS VIEWPORT HERO CARD
                    _buildPhysicsHeroViewportCard(),

                    const SizedBox(height: 18),

                    // 2. KINEMATIC PRESETS SECTION
                    _buildKinematicPresetsSection(),

                    const SizedBox(height: 18),

                    // 3. BIOMECHANICAL STRAIN PROFILE CARD
                    _buildBiomechanicalStrainProfileCard(),

                    const SizedBox(height: 18),

                    // 4. TIMELINE SCRUB BAR & MEDIA CONTROLS CARD
                    _buildTimelineAndMediaControlsCard(),

                    const SizedBox(height: 16),

                    // 5. SWITCH TO TENSION HEATMAP LINK BUTTON
                    _buildSwitchToHeatmapLink(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── BOTTOM ACTION BUTTON BAR ─────────────────────────────
            _buildBottomActionButton(),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back Button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 28,
                color: _midnightNavy,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Physique & Simulation du Drapé",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Profile Avatar
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

  // ── TOP ENGINE SPEC ROW ───────────────────────────────────────────────────
  Widget _buildTopEngineSpecRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  "MOTEUR HAVOK CLOTH V4.2 ACTIF",
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF475569),
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, size: 12, color: Color(0xFF475569)),
              const SizedBox(width: 4),
              Text(
                "Tissu Laine 280 GSM",
                style: GoogleFonts.inter(
                  fontSize: 10,
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

  // ── 1. 3D CLOTH PHYSICS VIEWPORT HERO CARD ─────────────────────────────────
  Widget _buildPhysicsHeroViewportCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 430,
        color: _midnightNavy,
        child: Stack(
          children: [
            // Background 3D Simulation Render Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_banner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => Container(
                  color: const Color(0xFF172554),
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 90,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),

            // Gradient Top & Bottom Overlays
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 80,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x88000000), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Top Left Badge: "SOLVEUR 60 FPS TEMPS RÉEL"
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.center_focus_strong_rounded,
                      size: 14,
                      color: Color(0xFFF43F5E),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "SOLVEUR 60 FPS TEMPS RÉEL",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Right Layers Button
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.layers_outlined,
                  size: 18,
                  color: _midnightNavy,
                ),
              ),
            ),

            // Active Radar Anchor Tag on Torso: "Tension d'Ancrage : 0.12 N"
            Positioned(
              top: 190,
              left: 110,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                      "Tension d'Ancrage : 0.12 N",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Live Stress Telemetry Card Box
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_graph_rounded,
                                size: 15,
                                color: Color(0xFFE11D48),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  "TÉLÉMÉTRIE DE CONTRAINTE EN DIRECT",
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF475569),
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "DRAPÉ OPTIMAL",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE11D48),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Metric 1: Wrinkle Recovery
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Récupération du Plissement",
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      "99.4%",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: _midnightNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        "instantanée",
                                        style: GoogleFonts.inter(
                                          fontSize: 9.5,
                                          color: const Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Metric 2: Lapel Flare Gap
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Écart d'Évasement Revers",
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      "0.0 mm",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: _midnightNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        "Ajusté",
                                        style: GoogleFonts.inter(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE11D48),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. KINEMATIC PRESETS SECTION ──────────────────────────────────────────
  Widget _buildKinematicPresetsSection() {
    final presets = [
      {
        'icon': Icons.directions_walk_rounded,
        'title': 'Foulée Catwalk',
        'sub': 'Rythme 1.2 m/s'
      },
      {
        'icon': Icons.chair_alt_rounded,
        'title': 'Salon Assis',
        'sub': 'Test de pli fauteuil'
      },
      {
        'icon': Icons.air_rounded,
        'title': 'Marche Urbaine',
        'sub': 'Test mouvement & vent'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Préréglages Kinématiques",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _midnightNavy,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "5 Simulations de Démarche",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 54,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedPreset == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedPreset = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _midnightNavy : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        presets[index]['icon'] as IconData,
                        size: 18,
                        color: isSelected
                            ? const Color(0xFFF43F5E)
                            : const Color(0xFF475569),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            presets[index]['title'] as String,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            presets[index]['sub'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 3. BIOMECHANICAL STRAIN PROFILE CARD ──────────────────────────────────
  Widget _buildBiomechanicalStrainProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Profil de Contrainte Biomécanique",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "TOLÉRANCE SÉCURISÉE",
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE11D48),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metric 1: Button Anchor Tension
          _buildStrainMetricRow(
            label: "Tension d'Ancrage du Bouton",
            valueText: "0.12 N / 0.50 N max",
            progress: 0.24,
            barColor: _midnightNavy,
          ),
          const SizedBox(height: 12),

          // Metric 2: Back Pleat Shear Load
          _buildStrainMetricRow(
            label: "Charge de Cisaillement Pli Dos",
            valueText: "18.4 kPa / 60 kPa max",
            progress: 0.31,
            barColor: const Color(0xFFF43F5E),
          ),
          const SizedBox(height: 12),

          // Metric 3: Underarm Creep Elasticity
          _buildStrainMetricRow(
            label: "Élasticité de Fluage Sous-Bras",
            valueText: "100% Conservée",
            progress: 1.0,
            barColor: _midnightNavy,
          ),
        ],
      ),
    );
  }

  Widget _buildStrainMetricRow({
    required String label,
    required String valueText,
    required double progress,
    required Color barColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF475569),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              valueText,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _midnightNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  // ── 4. TIMELINE SCRUB BAR & MEDIA CONTROLS CARD ────────────────────────────
  Widget _buildTimelineAndMediaControlsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header Timeline & Speed Pills
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "CHRONOLOGIE  01:42 / 03:00s",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF475569),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_speeds.length, (i) {
                  final isSelected = _selectedSpeed == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSpeed = i),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _midnightNavy
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _speeds[i],
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Interactive Timeline Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: _midnightNavy,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: _midnightNavy,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _timelineValue,
              onChanged: (val) => setState(() => _timelineValue = val),
            ),
          ),
          const SizedBox(height: 6),

          // Player Control Buttons Row
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded,
                      size: 22, color: _midnightNavy),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.fast_rewind_rounded,
                      size: 22, color: _midnightNavy),
                  onPressed: () {},
                ),
                // Play/Pause Main Circular Button
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _midnightNavy,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fast_forward_rounded,
                      size: 22, color: _midnightNavy),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded,
                      size: 22, color: _midnightNavy),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. SWITCH TO TENSION HEATMAP LINK BUTTON ──────────────────────────────
  Widget _buildSwitchToHeatmapLink() {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SizeSelectionScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.thermostat_rounded,
                size: 18,
                color: Color(0xFFE11D48),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Basculer vers la Carte Thermique de Tension",
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE11D48),
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

  // ── BOTTOM ACTION BUTTON BAR ──────────────────────────────────────────────
  Widget _buildBottomActionButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LiveArMirrorScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF43F5E), // Solid Coral Pink
            foregroundColor: Colors.white,
            elevation: 3,
            shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flip_camera_android_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Passer au Miroir RA en Direct",
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
}

