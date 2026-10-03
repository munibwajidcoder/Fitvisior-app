import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'curated_stylist_picks_screen.dart';

class QualityInformationScreen extends StatefulWidget {
  const QualityInformationScreen({super.key});

  @override
  State<QualityInformationScreen> createState() =>
      _QualityInformationScreenState();
}

class _QualityInformationScreenState extends State<QualityInformationScreen> {
  static const Color _midnightNavy = Color(0xFF172554);

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
            // ── 1. TOP APP BAR ───────────────────────────────────────
            _buildAppBar(context),

            // ── 2. SCROLLABLE BODY ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // 2A. VIEWPORT SCAN HERO CARD
                    _buildViewportScanHeroCard(),

                    const SizedBox(height: 16),

                    // 2B. MAIN QUALITY INSPECTION CARD
                    _buildMainQualityInspectionCard(context),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. TOP APP BAR ────────────────────────────────────────────────────────
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
              "Informations de Qualité",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
                letterSpacing: -0.4,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // User Avatar Profile
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

  // ── 2A. VIEWPORT SCAN HERO CARD ───────────────────────────────────────────
  Widget _buildViewportScanHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 160,
        color: const Color(0xFF0F172A),
        child: Stack(
          children: [
            // Background Image (Mannequin Render Scan)
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_banner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => Container(
                  color: const Color(0xFF172554),
                  child: const Center(
                    child: Icon(
                      Icons.checkroom_rounded,
                      size: 60,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),

            // Gradient Top & Left Overlays
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xCC000000), Color(0x33000000)],
                  ),
                ),
              ),
            ),

            // Content inside Hero Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Sub-header text
                  Text(
                    "SCAN DU VIEWPORT ACTIF",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.6,
                    ),
                  ),

                  // Middle & Right Badges Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Modèle 04 • Sergé de Laine & Soie",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
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
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF43F5E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Spatial V3",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2B. MAIN QUALITY INSPECTION CARD ──────────────────────────────────────
  Widget _buildMainQualityInspectionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Red Inspection Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 6),
                Text(
                  "INSPECTION DU DRAPÉ IA • VALIDE",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE11D48),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Circular Progress Ring / Fit Accuracy Gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 125,
                height: 125,
                child: CircularProgressIndicator(
                  value: 0.87,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(_midnightNavy),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Top Red Dot Indicator on Gauge Ring
              Positioned(
                top: 2,
                right: 36,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "87",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: _midnightNavy,
                        ),
                      ),
                      Text(
                        "%",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "PRÉCISION DU DRAPÉ",
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main Headline
          Text(
            "Ajustement Excellent avec Légères Remarques Ambiances",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _midnightNavy,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 8),

          // Main Body Description
          Text(
            "Notre moteur spatial a adapté la silhouette à vos mensurations avec une haute fidélité de drapé.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),

          const SizedBox(height: 20),

          // Lighting Advisory Box (Beige Container)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE4E6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    size: 18,
                    color: Color(0xFFE11D48),
                  ),
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
                              "Avis sur l'Éclairage",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: _midnightNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Remarque",
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "L'éclairage était légèrement faible lors du scan photo de face — la brillance du tissu et l'ombre des épaules peuvent légèrement varier en lumière naturelle.",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Engine Breakdown Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Détail du Moteur",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: _midnightNavy,
                ),
              ),
              Text(
                "Simulation en Temps Réel",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Engine Metric 1: Silhouette Alignment (96%)
          _buildEngineMetricCard(
            icon: Icons.accessibility_new_rounded,
            title: "Alignement Silhouette",
            valueText: "96% • Haute Précision",
            progress: 0.96,
            barColor: _midnightNavy,
          ),

          const SizedBox(height: 10),

          // Engine Metric 2: Fabric Tension Simulation (91%)
          _buildEngineMetricCard(
            icon: Icons.texture_rounded,
            title: "Simulation Tension Tissu",
            valueText: "91% • Aisance Précise",
            progress: 0.91,
            barColor: _midnightNavy,
          ),

          const SizedBox(height: 10),

          // Engine Metric 3: Scan Lighting & Clarity (76%)
          _buildEngineMetricCard(
            icon: Icons.wb_incandescent_outlined,
            title: "Éclairage & Clarté du Scan",
            valueText: "76% • Modéré",
            progress: 0.76,
            barColor: const Color(0xFFF43F5E),
          ),

          const SizedBox(height: 24),

          // PRIMARY CTA BUTTON: SOLID CORAL PINK (#F43F5E)
          // NAVIGATES DIRECTLY TO HOME SCREEN AS REQUESTED BY USER IN AUDIO!
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CuratedStylistPicksScreen(),
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
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "C'est Parfait, Super Look ✓",
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

          const SizedBox(height: 14),

          // Secondary Link Action: Retake photo under better light
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "Reprendre la photo sous un meilleur éclairage",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE11D48),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineMetricCard({
    required IconData icon,
    required String title,
    required String valueText,
    required double progress,
    required Color barColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: _midnightNavy),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _midnightNavy,
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
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
      ),
    );
  }
}

