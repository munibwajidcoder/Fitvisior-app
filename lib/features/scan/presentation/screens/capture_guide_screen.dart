import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'body_scan_screen.dart';
import 'manual_measurements_screen.dart';

class CaptureGuideScreen extends StatefulWidget {
  const CaptureGuideScreen({super.key});

  @override
  State<CaptureGuideScreen> createState() => _CaptureGuideScreenState();
}

class _CaptureGuideScreenState extends State<CaptureGuideScreen> {
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
            _buildTopAppBar(context),

            // ── SCROLLABLE BODY ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge: Precision Fitting Engine
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFECDD3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              size: 13, color: Color(0xFFF43F5E)),
                          const SizedBox(width: 6),
                          Text(
                            "Moteur d'Ajustement de Précision",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Main Title
                    Text(
                      "Capturons votre\ncoupe exacte",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      "Suivez 3 poses simples pour que notre IA crée votre mannequin numérique 3D hyper-réaliste.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── QUICK SETUP ESSENTIALS ───────────────────────
                    Text(
                      "ESSENTIELS DE CONFIGURATION RAPIDE",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.6,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildSetupPill("☀️", "Bon éclairage"),
                          const SizedBox(width: 8),
                          _buildSetupPill("📱", "Téléphone à hauteur de taille"),
                          const SizedBox(width: 8),
                          _buildSetupPill("📏", "À 2 mètres de distance"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── POSE SEQUENCE HEADER ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "SÉQUENCE DE POSES",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          "3 ÉTAPES GUIDÉES",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── POSE 1: FRONT ────────────────────────────────
                    _buildPoseCard(
                      stepNumber: "01",
                      title: "Pose 1 : Face",
                      hasCheck: true,
                      description:
                          "Regardez la caméra naturellement avec les épaules détendues et les bras légèrement écartés du corps.",
                      imagePath: "assets/images/scan_front_pose.jpg",
                    ),

                    const SizedBox(height: 12),

                    // ── POSE 2: PROFILE ──────────────────────────────
                    _buildPoseCard(
                      stepNumber: "02",
                      title: "Pose 2 : Profil",
                      hasCheck: false,
                      description:
                          "Tournez-vous de profil à 90° avec une posture bien droite, les bras le long du corps.",
                      imagePath: "assets/images/scan_profile_pose.jpg",
                    ),

                    const SizedBox(height: 12),

                    // ── POSE 3: BACK ─────────────────────────────────
                    _buildPoseCard(
                      stepNumber: "03",
                      title: "Pose 3 : Dos",
                      hasCheck: false,
                      description:
                          "Tournez-vous de dos face à la caméra, les mains éloignées des hanches.",
                      imagePath: "assets/images/scan_back_pose.jpg",
                    ),

                    const SizedBox(height: 18),

                    // ── WARDROBE PRO TIP CARD ────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.lightbulb_outline_rounded,
                                size: 18, color: Color(0xFFF43F5E)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Conseil Pro Mon Dressing",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Portez des vêtements près du corps pour une précision maximale — maillots de bain, tenues de sport ou basiques ajustés.",
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
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

                    const SizedBox(height: 12),

                    // ── SUB-MILLIMETER ACCURACY CARD ─────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0), width: 1),
                            ),
                            child: const Icon(Icons.center_focus_strong_rounded,
                                size: 22, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "Précision sous-millimétrique",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "IA 3D",
                                        style: GoogleFonts.inter(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF6366F1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Capture 48 nœuds de mesure anatomiques de manière transparente.",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── PRIMARY BUTTON: DÉMARRER LE SCAN ──────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BodyScanScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Démarrer le scan 3D",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── MANUAL MEASUREMENT LINK ───────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManualMeasurementsScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "Vous préférez saisir ? ",
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                            children: [
                              TextSpan(
                                text: "Entrez vos mensurations manuellement",
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── SECURITY FOOTER NOTE ─────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded,
                            size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Vos photos de scan sont chiffrées et ne sont jamais stockées publiquement.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
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
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_rounded,
                  size: 24, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 6),
          Image.asset('assets/images/logo.png', width: 26, height: 26),
          const SizedBox(width: 8),
          Text(
            "Guide de Capture",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          // Help icon
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline_rounded,
                size: 18, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 8),
          // User profile avatar
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Image.asset(
                'assets/images/profile_avatar.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SETUP PILL WIDGET ──────────────────────────────────────────────
  Widget _buildSetupPill(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // ── POSE CARD WIDGET ───────────────────────────────────────────────
  Widget _buildPoseCard({
    required String stepNumber,
    required String title,
    required bool hasCheck,
    required String description,
    required String imagePath,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Step image container with step number badge
          Stack(
            children: [
              Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF1F5F9),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stepNumber,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (hasCheck) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: Color(0xFFF43F5E)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

