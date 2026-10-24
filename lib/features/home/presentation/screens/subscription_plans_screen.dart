import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_billing_screen.dart';
import '../../../../core/localization/language_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  bool _isAnnual = false; // false = Monthly, true = Annual (-20%)
  final int _selectedPlanIndex = 1; // Default selected Plan Pro

  void _subscribeToPlan(String planName, String price) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PaymentBillingScreen(
          planName: planName,
          planPrice: price,
        ),
      ),
    );

    if (result == true && mounted) {
      // Pass plan name back so AccountSettingsScreen can update member label dynamically
      Navigator.of(context).pop(planName);
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
          appBar: _buildAppBar(isEn),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Studio Pass Top Badge
                  _buildStudioPassBadge(isEn),
                  const SizedBox(height: 10),

                  // 2. Main Title & Description
                  _buildMainHeaderSection(isEn),
                  const SizedBox(height: 16),

                  // 3. Carousel Preview Row (99.4% Fit Precision)
                  _buildPreviewCarouselCard(isEn),
                  const SizedBox(height: 18),

                  // 4. Monthly / Annual Billing Toggle Switch
                  _buildBillingToggleSwitch(isEn),
                  const SizedBox(height: 22),

                  // 5. Plan 1: Offre Gratuite (Free Tier)
                  _buildFreeTierCard(isEn),
                  const SizedBox(height: 18),

                  // 6. Plan 2: Plan Pro (MOST POPULAR / LE PLUS POPULAIRE)
                  _buildProPlanCard(isEn),
                  const SizedBox(height: 18),

                  // 7. Plan 3: Atelier VIP (Family / Multi-Profile Suite)
                  _buildAtelierVipCard(isEn),
                  const SizedBox(height: 22),

                  // 8. Risk-Free Guarantee Disclaimer Box
                  _buildRiskFreeDisclaimerCard(isEn),
                  const SizedBox(height: 20),

                  // 9. Legal Terms & Restore Purchases Footer
                  _buildLegalFooterSection(isEn),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isEn) {
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
        isEn ? "Subscription Plans" : "Plans d'Abonnement",
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

  // ── 1. STUDIO PASS TOP BADGE ─────────────────────────────────────────────

  Widget _buildStudioPassBadge(bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 12, color: Color(0xFFE11D48)),
          const SizedBox(width: 5),
          Text(
            isEn ? "FITVISOR STUDIO PASS" : "PASS FITVISOR STUDIO",
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFE11D48),
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. MAIN HEADER SECTION ───────────────────────────────────────────────

  Widget _buildMainHeaderSection(bool isEn) {
    return Column(
      children: [
        Text(
          isEn ? "Elevate Your Digital Wardrobe" : "Élevez Votre Dressing Digital",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            isEn
                ? "Unlock unlimited 3D simulations, multi-garment try-on, and priority concierge returns."
                : "Débloquez les simulations 3D illimitées, l'essayage multi-vêtements et les retours concierge prioritaires.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── 3. PREVIEW CAROUSEL CARD ─────────────────────────────────────────────

  Widget _buildPreviewCarouselCard(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        children: [
          // Thumbnail 1
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/product_dress.jpg',
              width: 44,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          // Thumbnail 2
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/hero_banner.jpg',
              width: 44,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          // Thumbnail 3
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/avatar_3d.jpg',
              width: 44,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? "99.4% Fit Precision" : "99,4% Précision Fit",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  isEn
                      ? "Spatial mesh physics tailored to your body proportions..."
                      : "Physique des maillages spatiaux ajustée selon vos proportions corporelles...",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. BILLING TOGGLE SWITCH ─────────────────────────────────────────────

  Widget _buildBillingToggleSwitch(bool isEn) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_isAnnual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: !_isAnnual
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    isEn ? "Monthly" : "Mensuel",
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: !_isAnnual ? FontWeight.w800 : FontWeight.w600,
                      color: !_isAnnual ? const Color(0xFF172554) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _isAnnual ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _isAnnual
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEn ? "Annual" : "Annuel",
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: _isAnnual ? FontWeight.w800 : FontWeight.w600,
                        color: _isAnnual ? const Color(0xFF172554) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "-20%",
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. PLAN 1: OFFRE GRATUITE (FREE TIER) ────────────────────────────────

  Widget _buildFreeTierCard(bool isEn) {
    final isSelected = _selectedPlanIndex == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? const Color(0xFF172554) : const Color(0xFFF1F5F9),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? "Free Plan" : "Offre Gratuite",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  Text(
                    isEn ? "For casual style exploration" : "Pour l'exploration de style occasionnelle",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "0 €",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  Text(
                    isEn ? " / month" : " / mois",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildFeatureCheckRow(isEn ? "3 AR try-on renders per month" : "3 rendus d'essayage AR par mois"),
          const SizedBox(height: 8),
          _buildFeatureCheckRow(isEn ? "Standard 3D body calibration" : "Calibrage de silhouette 3D standard"),
          const SizedBox(height: 8),
          _buildFeatureCheckRow(isEn ? "Community style feed & discovery" : "Flux de style communautaire & découverte"),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: null, // Disabled current plan
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                disabledBackgroundColor: const Color(0xFFF1F5F9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEn ? "Current Plan" : "Plan Actuel",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 6. PLAN 2: PLAN PRO (MOST POPULAR / LE PLUS POPULAIRE) ──────────────

  Widget _buildProPlanCard(bool isEn) {
    final priceStr = _isAnnual ? "15 €" : "19 €";
    final periodStr = isEn
        ? (_isAnnual ? "Billed annually (180 €/yr)" : "Billed monthly")
        : (_isAnnual ? "Facturé annuellement (180 €/an)" : "Facturé mensuellement");

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFE11D48),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isEn ? "Pro Plan" : "Plan Pro",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF172554),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle_rounded,
                                size: 16, color: Color(0xFFE11D48)),
                          ],
                        ),
                        Text(
                          isEn ? "Complete spatial styling suite" : "Studio de style spatial complet",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              priceStr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF172554),
                              ),
                            ),
                            Text(
                              isEn ? " / mo" : " / mois",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          periodStr,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE11D48),
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                isEn ? "EVERYTHING IN FREE, PLUS:" : "TOUT CE QUI EST DANS GRATUIT, PLUS :",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE11D48),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              _buildFeatureCheckRow(isEn ? "Unlimited real-time 3D & AR try-ons" : "Essayages photo 3D & AR en temps réel illimités", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "Multi-garment outfit builder (tops, coats, jewelry)" : "Créateur de tenues multi-objets (hauts, manteaux, bijoux)", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "Drape tension & fabric physics (99%+ precision)" : "Tension de drapé & physique des tissus (99%+ précision)", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "AI stylist advice & personal live chat" : "Retours styliste IA & chat en direct personnel", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "Free postal returns & fit guarantee" : "Retours gratuits par courrier & assurance ajustement", isHighlight: true),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _subscribeToPlan(isEn ? "Pro Plan" : "Plan Pro", "$priceStr/${isEn ? 'mo' : 'mois'}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E), // Coral Pink
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          isEn ? "Subscribe Now — $priceStr/mo" : "S'abonner Maintenant — $priceStr/mois",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Top Badge: LE PLUS POPULAIRE
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFBE123C),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBE123C).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    isEn ? "MOST POPULAR" : "LE PLUS POPULAIRE",
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 7. PLAN 3: ATELIER VIP (FAMILY / MULTI-PROFILE SUITE) ────────────────

  Widget _buildAtelierVipCard(bool isEn) {
    final priceStr = _isAnnual ? "31 €" : "39 €";
    final periodStr = isEn
        ? (_isAnnual ? "Billed annually (372 €/yr)" : "Billed monthly")
        : (_isAnnual ? "Facturé annuellement (372 €/an)" : "Facturé mensuellement");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isEn ? "VIP Atelier" : "Atelier VIP",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isEn ? "Family" : "Famille",
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isEn ? "Multi-profile studio suite" : "Suite studio multi-profils",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        priceStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      Text(
                        isEn ? " / mo" : " / mois",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    periodStr,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildFeatureIconRow(Icons.shield_outlined, isEn ? "Up to 4 family 3D avatars & shared wardrobe" : "Jusqu'à 4 avatars 3D familiaux & dressing partagé"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.videocam_outlined, isEn ? "1-on-1 video consultations with a human stylist" : "Consultations vidéo 1-sur-1 avec un styliste humain"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.workspace_premium_outlined, isEn ? "Priority access to exclusive designer capsules" : "Accès prioritaire aux capsules de créateurs exclusives"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.all_inclusive_rounded, isEn ? "All Pro Plan features included for all members" : "Toutes les fonctionnalités du Plan Pro incluses pour tous"),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _subscribeToPlan(isEn ? "VIP Atelier" : "Atelier VIP", "$priceStr/${isEn ? 'mo' : 'mois'}"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isEn ? "Subscribe" : "S'abonner",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.workspace_premium_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCheckRow(String text, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isHighlight ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 12,
            color: isHighlight ? const Color(0xFFE11D48) : const Color(0xFF475569),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              color: isHighlight ? const Color(0xFF172554) : const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureIconRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF172554)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  // ── 8. RISK-FREE DISCLAIMER CARD ─────────────────────────────────────────

  Widget _buildRiskFreeDisclaimerCard(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, size: 22, color: Color(0xFF172554)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? "Risk-Free Experience" : "Expérience Sans Risque",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  isEn
                      ? "Cancel or switch plans anytime. 14-day free trial on Pro & Atelier."
                      : "Annulez ou changez de plan à tout moment. Essai gratuit de 14 jours sur Pro & Atelier.",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 9. LEGAL FOOTER SECTION ──────────────────────────────────────────────

  Widget _buildLegalFooterSection(bool isEn) {
    return Column(
      children: [
        Text(
          isEn
              ? "Payment will be charged to your iTunes or Google Play account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period."
              : "Le paiement sera débité de votre compte iTunes ou Google Play lors de la confirmation. Le réabonnement est automatique sauf annulation au moins 24 heures avant la fin de la période en cours.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            color: const Color(0xFF94A3B8),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text(
                isEn ? "Terms of Service" : "Conditions d'Utilisation",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text("  •  ", style: TextStyle(color: Color(0xFFCBD5E1))),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text(
                isEn ? "Privacy Policy" : "Politique de Confidentialité",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Text("  •  ", style: TextStyle(color: Color(0xFFCBD5E1))),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: Text(
                isEn ? "Restore Purchases" : "Restaurer les Achats",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
