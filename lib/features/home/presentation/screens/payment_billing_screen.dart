import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentBillingScreen extends StatefulWidget {
  final String planName;
  final String planPrice;

  const PaymentBillingScreen({
    super.key,
    this.planName = "FitVisor Pro",
    this.planPrice = "19,00 €",
  });

  @override
  State<PaymentBillingScreen> createState() => _PaymentBillingScreenState();
}

class _PaymentBillingScreenState extends State<PaymentBillingScreen> {
  bool _saveCardForFuture = true;
  bool _billingSameAsShipping = true;

  void _processSubscriptionActivation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Abonnement Activé !",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Félicitations Alexa ! Votre statut Membre ${widget.planName} est désormais actif. Profitez des rendus 3D AR illimités.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context, true); // Return to previous screen with success flag
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E), // Coral Pink theme
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Accéder à Mon Espace Pro",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Membership Pass Card (No 14-day badge as requested)
              _buildMembershipPassCard(),
              const SizedBox(height: 16),

              // 2. Express Payment Buttons (Apple Pay, Google Pay, Stripe)
              _buildExpressPaymentButtons(),
              const SizedBox(height: 18),

              // Divider: OR PAY WITH CARD
              _buildDividerWithLabel("OU PAYER PAR CARTE"),
              const SizedBox(height: 18),

              // 3. Card Form Inputs Card
              _buildCardDetailsFormCard(),
              const SizedBox(height: 16),

              // 4. Billing Address Confirmation Box
              _buildBillingAddressBox(),
              const SizedBox(height: 16),

              // 5. Ready to Drape Preview Box
              _buildReadyToDrapeBox(),
              const SizedBox(height: 18),

              // 6. Summary Total Due Card
              _buildSummaryTotalDueCard(),
              const SizedBox(height: 20),

              // 7. Primary Action Button (Start 14-Day Free Trial / Subscribe Now)
              _buildActivateSubscriptionButton(),
              const SizedBox(height: 14),

              // 8. Bank-Grade SSL Security Footer
              _buildSecurityFooter(),
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
        "Paiement & Facturation",
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

  // ── 1. MEMBERSHIP PASS CARD ──────────────────────────────────────────────

  Widget _buildMembershipPassCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        size: 12, color: Color(0xFFE11D48)),
                    const SizedBox(width: 4),
                    Text(
                      "PASS MEMBRE FITVISOR",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE11D48),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.planPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  Text(
                    " / mois",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            widget.planName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Facturé aujourd'hui, renouvellement mensuel automatique. Annulation à tout moment en un tap.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Feature Badge (Notice: 14-day free trial badge removed as requested in audio!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: Color(0xFF172554)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Drapés 3D AR Illimités & Créateur de Tenues Studio",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF172554),
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

  // ── 2. EXPRESS PAYMENT BUTTONS ───────────────────────────────────────────

  Widget _buildExpressPaymentButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _processSubscriptionActivation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E), // Coral Pink Apple Pay style
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple_rounded, size: 22),
                const SizedBox(width: 6),
                Text(
                  "Pay",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _processSubscriptionActivation,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "G ",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF4285F4),
                        ),
                      ),
                      Text(
                        "Pay",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: _processSubscriptionActivation,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Stripe / PayPal",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF003087),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDividerWithLabel(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  // ── 3. CARD DETAILS FORM CARD ────────────────────────────────────────────

  Widget _buildCardDetailsFormCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          // Name on Card
          Text(
            "Nom sur la Carte",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Alexa Morgan",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                ),
                const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Card Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Numéro de Carte",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Row(
                children: [
                  _buildCardBrandBadge("VISA"),
                  const SizedBox(width: 4),
                  _buildCardBrandBadge("MC"),
                  const SizedBox(width: 4),
                  _buildCardBrandBadge("AMEX"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.credit_card_rounded, size: 18, color: Color(0xFF172554)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "••••  ••••  ••••  4821",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172554),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Expiry & CVV Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date d'Expiration",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Text(
                        "08 / 27",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF172554),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Code CVV",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const Icon(Icons.help_outline_rounded,
                            size: 13, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "842",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF172554),
                            ),
                          ),
                          const Icon(Icons.lock_outline_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Postal / ZIP Code
          Text(
            "Code Postal / ZIP",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "10012",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  "SoHo, NYC",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Save card switch
          Row(
            children: [
              const Icon(Icons.bookmark_outline_rounded, size: 16, color: Color(0xFF172554)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enregistrer la carte pour les futures capsules",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Text(
                      "Paiement instantané en 1 tap pour les créations AR",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _saveCardForFuture,
                activeThumbColor: const Color(0xFF172554),
                onChanged: (val) => setState(() => _saveCardForFuture = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBrandBadge(String brand) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        brand,
        style: GoogleFonts.inter(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }

  // ── 4. BILLING ADDRESS CONFIRMATION BOX ──────────────────────────────────

  Widget _buildBillingAddressBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _billingSameAsShipping,
            activeColor: const Color(0xFF172554),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) => setState(() => _billingSameAsShipping = val ?? true),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "L'adresse de facturation correspond à la livraison",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  "742 Evergreen Terrace, New York, NY 10012",
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
    );
  }

  // ── 5. READY TO DRAPE PREVIEW BOX ────────────────────────────────────────

  Widget _buildReadyToDrapeBox() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/profile_avatar.jpg',
              width: 42,
              height: 42,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Prêt pour le drapé d'Alexa Morgan",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  "Accès instantané débloqué lors de l'abonnement",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFE11D48), size: 20),
        ],
      ),
    );
  }

  // ── 6. SUMMARY TOTAL DUE CARD ────────────────────────────────────────────

  Widget _buildSummaryTotalDueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sous-total Mensuel",
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
              Text(
                widget.planPrice,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF172554)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.card_giftcard_rounded, size: 14, color: Color(0xFFE11D48)),
                  const SizedBox(width: 4),
                  Text(
                    "Remise Spéciale FitVisor",
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFE11D48)),
                  ),
                ],
              ),
              Text(
                "- ${widget.planPrice}",
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFFE11D48)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Dû Aujourd'hui",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  Text(
                    "Première facturation : 14 Nov 2026",
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Text(
                "0,00 €",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 7. PRIMARY SUBSCRIBE / ACTIVATE BUTTON ────────────────────────────────

  Widget _buildActivateSubscriptionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _processSubscriptionActivation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF43F5E), // Coral Pink
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
              "S'abonner Maintenant",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // ── 8. BANK-GRADE SSL SECURITY FOOTER ─────────────────────────────────────

  Widget _buildSecurityFooter() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                "Cryptage SSL 256-bit de Niveau Bancaire",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "Paiement sécurisé traité via Stripe • Zéro risque, annulation à tout moment",
            style: GoogleFonts.inter(
              fontSize: 9.5,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
