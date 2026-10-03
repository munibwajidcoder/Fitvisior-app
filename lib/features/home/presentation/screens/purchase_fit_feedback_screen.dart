import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class PurchaseFitFeedbackScreen extends StatefulWidget {
  const PurchaseFitFeedbackScreen({super.key});

  @override
  State<PurchaseFitFeedbackScreen> createState() => _PurchaseFitFeedbackScreenState();
}

class _PurchaseFitFeedbackScreenState extends State<PurchaseFitFeedbackScreen> {
  int _selectedFit = 1; // 0 = Too Small, 1 = Perfect Fit (Default), 2 = Too Big

  final Set<String> _selectedAreas = {
    'Drapé Taille',
    'Épaules',
    'Poitrine / Buste',
    'Longueur Ourlet',
  };

  final List<String> _allAreas = [
    'Drapé Taille',
    'Épaules',
    'Poitrine / Buste',
    'Longueur Ourlet',
    'Hanches',
  ];

  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Purchased Item Summary Card
              _buildTopItemCard(),
              const SizedBox(height: 20),

              // 2. Question 1: How did it fit? (3 Cards)
              _buildFitQuestionSection(),
              const SizedBox(height: 20),

              // 3. Question 2: Which areas were most accurate? (Chips)
              _buildAccurateAreasSection(),
              const SizedBox(height: 18),

              // 4. Avatar Confidence Score Progress Bar Card
              _buildAvatarConfidenceCard(),
              const SizedBox(height: 20),

              // 5. Question 3: Optional Notes & Voice Note
              _buildOptionalNotesSection(),
              const SizedBox(height: 24),

              // 6. Submit Button & Skip Link (Redirects to Wardrobe)
              _buildActionButtons(),
              const SizedBox(height: 16),

              // 7. Footer Disclaimer
              _buildFooterDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAF9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF172554)),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Avis d'Ajustement d'Achat",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF172554),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
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
        ),
      ],
    );
  }

  // ── 1. TOP PURCHASED ITEM SUMMARY CARD ───────────────────────────────────

  Widget _buildTopItemCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/product_dress.jpg',
                  width: 58,
                  height: 70,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
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
                            "Sculpted Drape Silk Midi",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "Oct 31",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          "285,00 € • Taille M",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "LIVRÉ",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Modèle Avatar: Aura-3D v2.4",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Sparkle Info Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 15, color: Color(0xFFE11D48)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Aidez à étalonner votre avatar 3D pour des simulations de drapé encore plus précises.",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. QUESTION 1: HOW DID IT FIT? (3 CARDS) ─────────────────────────────

  Widget _buildFitQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Comment était l'ajustement ?",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "Comparez la réalité à votre simulation virtuelle 3D.",
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // Option 0: Trop Petit
        _buildFitOptionCard(
          index: 0,
          icon: Icons.unfold_less_rounded,
          title: "Trop Petit",
          subtitle: "Semblait plus serré que la simulation 3D",
        ),
        const SizedBox(height: 10),

        // Option 1: Ajustement Parfait (99% Match)
        _buildFitOptionCard(
          index: 1,
          icon: Icons.check_circle_rounded,
          title: "Ajustement Parfait",
          subtitle: "Correspond exactement à mon avatar 3D",
          badgeText: "99% Match",
          isHighlighted: true,
        ),
        const SizedBox(height: 10),

        // Option 2: Trop Grand
        _buildFitOptionCard(
          index: 2,
          icon: Icons.unfold_more_rounded,
          title: "Trop Grand",
          subtitle: "Semblait plus ample que la simulation",
        ),
      ],
    );
  }

  Widget _buildFitOptionCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    bool isHighlighted = false,
  }) {
    final isSelected = _selectedFit == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFit = index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isHighlighted ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC))
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE11D48)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected && isHighlighted
              ? [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isHighlighted ? const Color(0xFFBE123C) : const Color(0xFF172554))
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBE123C),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: isSelected && isHighlighted
                          ? const Color(0xFFBE123C)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFCBD5E1),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. QUESTION 2: ACCURATE AREAS CHIPS ──────────────────────────────────

  Widget _buildAccurateAreasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Quelles zones étaient les plus précises ?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              "Appuyez pour affiner",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allAreas.map((area) {
            final isSelected = _selectedAreas.contains(area);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAreas.remove(area);
                  } else {
                    _selectedAreas.add(area);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF172554) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF172554)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      area,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isSelected ? Icons.check_rounded : Icons.add_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 4. AVATAR CONFIDENCE SCORE PROGRESS BAR CARD ────────────────────────

  Widget _buildAvatarConfidenceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SCORE DE CONFIANCE AVATAR",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                "98.4%",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.984,
              backgroundColor: Color(0xFFE2E8F0),
              color: Color(0xFFE11D48),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Étalonnage Mesh",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                "+1.2% cet avis",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE11D48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. QUESTION 3: OPTIONAL NOTES & VOICE NOTE ─────────────────────────

  Widget _buildOptionalNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Des remarques sur le tissu ou le mouvement ? (Optionnel)",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF172554)),
                decoration: InputDecoration(
                  hintText:
                      "ex. Le biais drapait comme de l'eau, aucun pliement à la taille !",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mic_none_rounded,
                          size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        "Note vocale",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "0/150",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 6. SUBMIT BUTTON & SKIP LINK (REDIRECTS TO WARDROBE) ─────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Avis d'ajustement soumis ! Avatar 3D étalonné.",
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF172554),
                  behavior: SnackBarBehavior.floating,
                ),
              );

              // Redirects directly to Wardrobe Tab in HomeScreen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(initialIndex: 3),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E), // Exact Coral Pink theme color
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Soumettre l'Avis d'Ajustement",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Skip link -> Redirects to Wardrobe
        TextButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(initialIndex: 3),
              ),
              (route) => false,
            );
          },
          child: Text(
            "Ignorer pour le moment",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  // ── 7. FOOTER DISCLAIMER ──────────────────────────────────────────────────

  Widget _buildFooterDisclaimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "Vos commentaires affinent automatiquement le moteur de silhouette 3D FitVisor.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }
}
