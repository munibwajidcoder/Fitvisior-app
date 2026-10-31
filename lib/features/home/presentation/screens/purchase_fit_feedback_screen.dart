import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';
import 'home_screen.dart';
import '../../data/order_service.dart';

class PurchaseFitFeedbackScreen extends StatefulWidget {
  final String? orderId;
  final String? orderNumber;
  final OrderItemModel? firstProduct;

  const PurchaseFitFeedbackScreen({
    super.key,
    this.orderId,
    this.orderNumber,
    this.firstProduct,
  });

  @override
  State<PurchaseFitFeedbackScreen> createState() => _PurchaseFitFeedbackScreenState();
}

class _PurchaseFitFeedbackScreenState extends State<PurchaseFitFeedbackScreen> {
  int _selectedFit = 1; // 0 = Too Small (too_tight), 1 = Perfect Fit (perfect), 2 = Too Big (too_loose)
  bool _isSubmitting = false;
  double _confidenceScore = 98.4; // Interactive 0-100% confidence rating

  final Set<String> _selectedAreaKeys = {
    'waist',
    'shoulders',
    'bust',
    'hem',
  };

  final List<String> _allAreaKeys = [
    'waist',
    'shoulders',
    'bust',
    'hem',
    'hips',
  ];

  String _getAreaLabel(String key, bool isEn) {
    switch (key) {
      case 'waist':
        return isEn ? 'Waist Drape' : 'Drapé Taille';
      case 'shoulders':
        return isEn ? 'Shoulders' : 'Épaules';
      case 'bust':
        return isEn ? 'Chest / Bust' : 'Poitrine / Buste';
      case 'hem':
        return isEn ? 'Hem Length' : 'Longueur Ourlet';
      case 'hips':
        return isEn ? 'Hips' : 'Hanches';
      default:
        return key;
    }
  }

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
    final isEn = LanguageService.instance.isEnglish;
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
        isEn ? "Purchase Fit Feedback" : "Avis d'Ajustement d'Achat",
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
          child: ValueListenableBuilder<File?>(
            valueListenable: UserAvatarService.avatarNotifier,
            builder: (context, avatarFile, _) {
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarFile != null
                      ? Image.file(
                          avatarFile,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFFEFF6FF),
                          child: const Center(
                            child: Icon(Icons.person_rounded, size: 20, color: Color(0xFF2563EB)),
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 1. TOP PURCHASED ITEM SUMMARY CARD ───────────────────────────────────

  Widget _buildTopItemCard() {
    final isEn = LanguageService.instance.isEnglish;
    final item = widget.firstProduct;
    final itemTitle = item != null
        ? AppStrings.translateProduct(item.title, LanguageService.instance.currentLanguage)
        : (isEn ? "Sibem Cashmere Cocoon Coat" : "Manteau Cocon en Cachemire Sibem");
    final itemPrice = item != null ? item.unitPrice : 2490.0;
    final itemSize = item?.size ?? "M";
    final itemDateOrNumber = widget.orderNumber ?? (isEn ? "Oct 31" : "31 Oct");
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
                child: item != null && item.imageUrl != null && item.imageUrl!.startsWith('http')
                    ? Image.network(
                        item.imageUrl!,
                        width: 58,
                        height: 70,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/hero_banner.jpg',
                          width: 58,
                          height: 70,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      )
                    : Image.asset(
                        item?.imageUrl != null && item!.imageUrl!.isNotEmpty && !item.imageUrl!.startsWith('http')
                            ? item.imageUrl!
                            : 'assets/images/hero_banner.jpg',
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
                            itemTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                            itemDateOrNumber,
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
                          "€${itemPrice.toStringAsFixed(2)} • Size $itemSize",
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
                            isEn ? "DELIVERED" : "LIVRÉ",
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
                      isEn ? "Avatar Model: Aura-3D v2.4" : "Modèle Avatar: Aura-3D v2.4",
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
                    isEn
                        ? "Help calibrate your 3D avatar for even more precise drape and silhouette simulations."
                        : "Aidez à étalonner votre avatar 3D pour des simulations de drapé encore plus précises.",
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
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? "How was the fit?" : "Comment était l'ajustement ?",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isEn
              ? "Compare real-life fit to your 3D digital simulation."
              : "Comparez la réalité à votre simulation virtuelle 3D.",
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),

        // Option 0: Too Small
        _buildFitOptionCard(
          index: 0,
          icon: Icons.unfold_less_rounded,
          title: isEn ? "Too Small" : "Trop Petit",
          subtitle: isEn ? "Felt tighter than the 3D simulation" : "Semblait plus serré que la simulation 3D",
        ),
        const SizedBox(height: 10),

        // Option 1: Perfect Fit (99% Match)
        _buildFitOptionCard(
          index: 1,
          icon: Icons.check_circle_rounded,
          title: isEn ? "Perfect Fit" : "Ajustement Parfait",
          subtitle: isEn ? "Matched my 3D avatar exactly" : "Correspond exactement à mon avatar 3D",
          badgeText: "99% Match",
          isHighlighted: true,
        ),
        const SizedBox(height: 10),

        // Option 2: Too Big
        _buildFitOptionCard(
          index: 2,
          icon: Icons.unfold_more_rounded,
          title: isEn ? "Too Big" : "Trop Grand",
          subtitle: isEn ? "Felt looser than the simulation" : "Semblait plus ample que la simulation",
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
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isEn ? "Which areas were most accurate?" : "Quelles zones étaient les plus précises ?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              isEn ? "Tap to refine" : "Appuyez pour affiner",
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
          children: _allAreaKeys.map((key) {
            final isSelected = _selectedAreaKeys.contains(key);
            final label = _getAreaLabel(key, isEn);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAreaKeys.remove(key);
                  } else {
                    _selectedAreaKeys.add(key);
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
                      label,
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

  // ── 4. AVATAR CONFIDENCE SCORE INTERACTIVE CARD ────────────────────────

  Widget _buildAvatarConfidenceCard() {
    final isEn = LanguageService.instance.isEnglish;
    final scoreFormatted = "${_confidenceScore.toStringAsFixed(1)}%";
    final deltaText = "+${((_confidenceScore - 50.0) * 0.035).clamp(0.5, 2.5).toStringAsFixed(1)}% ${isEn ? 'this review' : 'cet avis'}";

    String matchLabel;
    Color matchColor;
    if (_confidenceScore >= 95.0) {
      matchLabel = isEn ? "High Match • Precision Silhouette" : "Correspondance Élevée • Silhouette Précise";
      matchColor = const Color(0xFF16A34A);
    } else if (_confidenceScore >= 85.0) {
      matchLabel = isEn ? "Good Match • Calibrated Fit" : "Bonne Correspondance • Ajustement Calibré";
      matchColor = const Color(0xFF2563EB);
    } else {
      matchLabel = isEn ? "Mesh Recalibration Needed" : "Réétalonnage Recommandé";
      matchColor = const Color(0xFFEA580C);
    }

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
              Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 14, color: Color(0xFFBE123C)),
                  const SizedBox(width: 5),
                  Text(
                    isEn ? "AVATAR CONFIDENCE SCORE" : "SCORE DE CONFIANCE AVATAR",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFBE123C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scoreFormatted,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFBE123C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Interactive Slider (allows user to score high/low directly)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF43F5E),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFFBE123C),
              overlayColor: const Color(0xFFF43F5E).withValues(alpha: 0.18),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _confidenceScore,
              min: 50.0,
              max: 100.0,
              divisions: 50,
              onChanged: (val) {
                setState(() => _confidenceScore = val);
              },
            ),
          ),

          // Quick +/- buttons & Status label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Step down button
              InkWell(
                onTap: () {
                  setState(() {
                    _confidenceScore = (_confidenceScore - 5.0).clamp(50.0, 100.0);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.remove_rounded, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 2),
                      Text("5%", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),

              // Match Status Badge
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    matchLabel,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: matchColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Step up button
              InkWell(
                onTap: () {
                  setState(() {
                    _confidenceScore = (_confidenceScore + 5.0).clamp(50.0, 100.0);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 13, color: Color(0xFFBE123C)),
                      const SizedBox(width: 2),
                      Text("5%", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFBE123C))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEn ? "Mesh Calibration Engine" : "Moteur d'Étalonnage Mesh",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                deltaText,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFBE123C),
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
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn
              ? "Any remarks on fabric movement? (Optional)"
              : "Des remarques sur le tissu ou le mouvement ? (Optionnel)",
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
                  hintText: isEn
                      ? "e.g. Fabric moves fluidly and naturally, fits comfortably around the waist!"
                      : "ex. Le tissu bouge avec fluidité et naturel, ajustement confortable à la taille !",
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
                        isEn ? "Voice note" : "Note vocale",
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
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      children: [
        // Primary Submit Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    setState(() => _isSubmitting = true);

                    // Map to exact database check constraint: 'too_tight', 'perfect', 'too_loose'
                    String fitString = 'perfect';
                    if (_selectedFit == 0) fitString = 'too_tight';
                    if (_selectedFit == 2) fitString = 'too_loose';

                    final effectiveOrderId = widget.orderId ??
                        OrderService.latestPlacedOrder?.id ??
                        '';

                    final effectiveProductId = widget.firstProduct?.productId ??
                        OrderService.latestPlacedOrder?.items.firstOrNull?.productId;

                    final userNote = _notesController.text.trim();
                    final finalRemarks = userNote.isNotEmpty
                        ? "$userNote (Avatar Confidence: ${_confidenceScore.toStringAsFixed(1)}%)"
                        : "Avatar Confidence Score: ${_confidenceScore.toStringAsFixed(1)}%";

                    await OrderService.instance.submitFitFeedback(
                      orderId: effectiveOrderId,
                      productId: effectiveProductId,
                      overallFit: fitString,
                      accurateAreas: _selectedAreaKeys.toList(),
                      comments: finalRemarks,
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isEn
                                    ? "Fit feedback submitted! 3D avatar calibrated."
                                    : "Avis d'ajustement soumis ! Avatar 3D étalonné.",
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

                    // Redirects directly to Home Page (index 0)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E), // Exact Coral Pink theme color
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFF43F5E).withValues(alpha: 0.6),
              elevation: 4,
              shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isEn ? "Submit Fit Feedback" : "Envoyer mon Évaluation",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
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
                builder: (context) => const HomeScreen(initialIndex: 0),
              ),
              (route) => false,
            );
          },
          child: Text(
            isEn ? "Skip for now" : "Ignorer pour le moment",
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
    final isEn = LanguageService.instance.isEnglish;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            isEn
                ? "Your feedback automatically refines the FitVisor 3D silhouette engine."
                : "Vos commentaires affinent automatiquement le moteur de silhouette 3D FitVisor.",
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
