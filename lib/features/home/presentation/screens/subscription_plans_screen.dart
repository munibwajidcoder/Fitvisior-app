import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'payment_billing_screen.dart';
import '../../../../core/localization/language_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../data/subscription_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  bool _isAnnual = false; // false = Monthly, true = Annual (-20%)
  final int _selectedPlanIndex = 1; // Default selected Plan Pro

  @override
  void initState() {
    super.initState();
    SubscriptionService.instance.loadActiveSubscription();
  }

  void _subscribeToPlan(
      String planId, String planName, String price, double amount) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => PaymentBillingScreen(
          planId: planId,
          planName: planName,
          billingCycle: _isAnnual ? 'annual' : 'monthly',
          planPrice: price,
          amount: amount,
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      // Pass plan name back so AccountSettingsScreen can update member label dynamically
      Navigator.of(context).pop(result);
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
          child: _buildDynamicUserAvatar(size: 34),
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
      constraints: const BoxConstraints(maxWidth: 320),
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
                        "-17%",
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

  // ── 5. PLAN 1: PLAN GRATUIT (FREE TIER) ──────────────────────────────────

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? "Free Plan" : "Plan Gratuit",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEn ? "To discover the FitVisor experience" : "Pour découvrir l'expérience FitVisor",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
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

          _buildFeatureCheckRow(isEn ? "Limited to 2 virtual try-ons" : "Limité à 2 essayages virtuels"),
          const SizedBox(height: 8),
          _buildFeatureCheckRow(isEn ? "Wardrobe limited to 10 items" : "Dressing limité à 10 articles"),
          const SizedBox(height: 8),
          _buildFeatureCheckRow(isEn ? "Includes advertising pop-ups" : "Inclut des pop-ups publicitaires"),
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

  // ── 6. PLAN 2: PLAN PRO (€2.99/MO - 1ST MONTH FREE - FULL FEATURES) ──────

  Widget _buildProPlanCard(bool isEn) {
    final priceStr = _isAnnual ? "29,99 €" : "2,99 €";
    final unitStr = isEn
        ? (_isAnnual ? " / yr" : " / mo")
        : (_isAnnual ? " / an" : " / mois");

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isEn ? "Pro Plan" : "Plan Pro",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF172554),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle_rounded,
                                size: 16, color: Color(0xFFE11D48)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEn ? "Full features included" : "Toutes fonctionnalités incluses",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            priceStr,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                          ),
                          Text(
                            unitStr,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isEn
                            ? (_isAnnual ? "Single payment" : "1st month free")
                            : (_isAnnual ? "Paiement unique" : "1er mois offert"),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                isEn ? "INCLUDES FULL FEATURES:" : "INCLUT TOUTES LES FONCTIONNALITÉS :",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE11D48),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              _buildFeatureCheckRow(isEn ? "1st month 100% free with full features" : "1er mois offert — toutes fonctionnalités incluses", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "Unlimited 3D & AR virtual try-ons" : "Essayages virtuels 3D & AR illimités", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "Unlimited digital wardrobe (no 10-item cap)" : "Dressing digital illimité (sans limite de 10 pièces)", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "100% Ad-free experience (zero pop-ups)" : "Expérience 100% sans publicité (zéro pop-up)", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "Multi-garment styling & 3D drape physics (99%+ precision)" : "Créateur de tenues & physique de drapé 3D (99%+ précision)", isHighlight: true),
              const SizedBox(height: 8),
              _buildFeatureCheckRow(isEn ? "Priority AI stylist & concierge support" : "Conseils de styliste prioritaires & conciergerie VIP", isHighlight: true),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final planId = _isAnnual ? 'pro_annual' : 'pro_monthly';
                    final amount = _isAnnual ? 29.99 : 2.99;
                    final displayPrice = _isAnnual ? "29,99 €" : "2,99 €";
                    _subscribeToPlan(
                      planId,
                      isEn ? "FitVisor Pro" : "FitVisor Pro",
                      displayPrice,
                      amount,
                    );
                  },
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
                    children: [
                      Flexible(
                        child: Text(
                          _isAnnual
                              ? (isEn ? "Subscribe — €29.99 / year" : "Souscrire — 29,99 € / an")
                              : (isEn ? "Subscribe — €2.99 / month" : "Souscrire — 2,99 € / mois"),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
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

        // Floating Top Badge: LE PLUS POPULAIRE • 1ER MOIS OFFERT
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
                    isEn ? "MOST POPULAR • 1ST MONTH FREE" : "LE PLUS POPULAIRE • 1ER MOIS OFFERT",
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

  // ── 7. PLAN 3: PLAN FAMILLE (UP TO 5 MEMBERS - €9.99/MO OR €99.99/YR) ────

  Widget _buildAtelierVipCard(bool isEn) {
    final priceStr = _isAnnual ? "99,99 €" : "9,99 €";
    final unitStr = isEn
        ? (_isAnnual ? " / yr" : " / mo")
        : (_isAnnual ? " / an" : " / mois");

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isEn ? "Family Plan" : "Plan Famille",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isEn ? "5 members" : "5 membres",
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isEn ? "Multi-profile suite" : "Suite multi-profils",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                        unitStr,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isEn
                        ? (_isAnnual ? "Single payment" : "Billed monthly")
                        : (_isAnnual ? "Paiement unique" : "Facturé par mois"),
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

          _buildFeatureIconRow(Icons.group_outlined, isEn ? "Family access: up to 5 members included" : "Accès familial : jusqu'à 5 membres inclus"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.all_inclusive_rounded, isEn ? "Full features included for each member" : "Toutes les fonctionnalités complètes pour chaque membre"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.accessibility_new_rounded, isEn ? "5 distinct 3D body avatars & shared wardrobe" : "5 avatars 3D distincts & dressing partagé"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.check_circle_outline_rounded, isEn ? "Unlimited virtual try-ons for the whole family" : "Essayages virtuels illimités pour toute la famille"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.block_rounded, isEn ? "100% Ad-free experience for all members" : "100% sans aucune publicité pour tous les membres"),
          const SizedBox(height: 8),
          _buildFeatureIconRow(Icons.workspace_premium_outlined, isEn ? "Priority VIP family concierge support" : "Support conciergerie VIP familiale prioritaire"),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final planId = _isAnnual ? 'family_annual' : 'family_monthly';
                final amount = _isAnnual ? 99.99 : 9.99;
                final displayPrice = _isAnnual ? "99,99 €" : "9,99 €";
                _subscribeToPlan(
                  planId,
                  isEn ? "FitVisor Family" : "FitVisor Famille",
                  displayPrice,
                  amount,
                );
              },
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
                  Flexible(
                    child: Text(
                      _isAnnual
                          ? (isEn
                              ? "Subscribe — €99.99 / year"
                              : "Souscrire — 99,99 € / an")
                          : (isEn
                              ? "Subscribe — €9.99 / month"
                              : "Souscrire — 9,99 € / mois"),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      ? "Cancel or switch plans anytime. 1st month free on Pro. 100% secure payment."
                      : "Annulez ou changez de plan à tout moment. 1er mois offert sur le Plan Pro. Paiement 100% sécurisé.",
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

  Widget _buildDynamicUserAvatar({double size = 34, double borderWidth = 1.5}) {
    return ValueListenableBuilder<File?>(
      valueListenable: UserAvatarService.avatarNotifier,
      builder: (context, avatarFile, _) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: const Color(0xFFE2E8F0), width: borderWidth),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: avatarFile != null
                ? Image.file(avatarFile, fit: BoxFit.cover)
                : Image.asset(
                    'assets/images/profile_avatar.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFEFF6FF),
                      child: Icon(Icons.person_rounded,
                          size: size * 0.6, color: const Color(0xFF2563EB)),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
