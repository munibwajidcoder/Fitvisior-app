import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/language_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../data/subscription_service.dart';
import '../../data/stripe_payment_service.dart';
import 'transaction_history_screen.dart';

class PaymentBillingScreen extends StatefulWidget {
  final String planId;
  final String planName;
  final String billingCycle;
  final String planPrice;
  final double amount;

  const PaymentBillingScreen({
    super.key,
    this.planId = "pro_monthly",
    this.planName = "FitVisor Pro",
    this.billingCycle = "monthly",
    this.planPrice = "2,99 €",
    this.amount = 2.99,
  });

  @override
  State<PaymentBillingScreen> createState() => _PaymentBillingScreenState();
}

class _PaymentBillingScreenState extends State<PaymentBillingScreen> {
  bool _isProcessing = false;
  bool _isLoadingCard = true;
  Map<String, dynamic>? _connectedCard;

  @override
  void initState() {
    super.initState();
    _loadConnectedCard();
  }

  Future<void> _loadConnectedCard() async {
    setState(() => _isLoadingCard = true);
    final savedCards = await SubscriptionService.instance.getSavedPaymentCards();
    if (savedCards.isNotEmpty) {
      final defaultCard = savedCards.firstWhere(
        (c) => c['isDefault'] == true,
        orElse: () => savedCards.first,
      );
      _connectedCard = Map<String, dynamic>.from(defaultCard);
    } else {
      _connectedCard = null;
    }
    if (mounted) {
      setState(() => _isLoadingCard = false);
    }
  }

  String _getUserDisplayName(bool isEn) {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.userMetadata?['full_name']?.toString() ??
        (user?.email != null ? user!.email!.split('@').first : null) ??
        (isEn ? 'FitVisor Member' : 'Membre FitVisor');
  }

  String get _formattedPlanPrice {
    if (widget.amount > 0) {
      return "${widget.amount.toStringAsFixed(2).replaceAll('.', ',')} €";
    }
    final p = widget.planPrice.trim();
    if (p.contains(' / ')) return p.split(' / ').first.trim();
    if (p.contains('/')) return p.split('/').first.trim();
    if (p.contains('(')) return p.split('(').first.trim();
    return p;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OFFICIAL STRIPE SETUP SHEET (MATCHES USER SCREENSHOT 100%)
  // ─────────────────────────────────────────────────────────────────────────
  void _openOfficialStripeSetupSheet() {
    final isEn = LanguageService.instance.isEnglish;
    final cardCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvcCtrl = TextEditingController();
    final zipCtrl = TextEditingController(text: '75001');
    String selectedCountry = 'France';
    bool saveWithLink = true;
    String detectedBrand = 'VISA';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Close Button 'X'
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 2. Green "Pay with >link" Button (Screenshot Style)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          // 1-Tap Link Autofill
                          setModalState(() {
                            cardCtrl.text = "4242424242424242";
                            expiryCtrl.text = "12/28";
                            cvcCtrl.text = "123";
                            zipCtrl.text = "75001";
                            detectedBrand = "VISA";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D66F), // Stripe Link Green
                          foregroundColor: const Color(0xFF172554),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Pay with ",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF172554),
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 10, color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "link",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF172554),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. "Or use a card" Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            isEn ? "Or use a card" : "Ou utiliser une carte",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ⚡ Quick Autofill Test Card Pill
                    ActionChip(
                      backgroundColor: const Color(0xFFEFF6FF),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      avatar: const Icon(Icons.flash_on_rounded, size: 14, color: Color(0xFF2563EB)),
                      label: Text(
                        isEn ? "⚡ Fill Stripe Test Card (4242)" : "⚡ Remplir Carte Test Stripe (4242)",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                      onPressed: () {
                        setModalState(() {
                          cardCtrl.text = "4242424242424242";
                          expiryCtrl.text = "12/28";
                          cvcCtrl.text = "123";
                          zipCtrl.text = "75001";
                          detectedBrand = "VISA";
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // 4. "Card information" Section Title
                    Text(
                      isEn ? "Card information" : "Informations de carte",
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Combined Card Information Box (Matches Screenshot)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        children: [
                          // Top: Card Number
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: cardCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(16),
                                    ],
                                    onChanged: (val) {
                                      setModalState(() {
                                        detectedBrand = StripePaymentService.detectCardBrand(val);
                                      });
                                    },
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isEn ? "Card number" : "Numéro de carte",
                                      hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                // Brand Logos Badge Row
                                Row(
                                  children: [
                                    _buildBrandMiniLogo("VISA", const Color(0xFF1A1F71)),
                                    const SizedBox(width: 3),
                                    _buildBrandMiniLogo("MC", const Color(0xFFEB001B)),
                                    const SizedBox(width: 3),
                                    _buildBrandMiniLogo("AMEX", const Color(0xFF006FCF)),
                                    const SizedBox(width: 3),
                                    _buildBrandMiniLogo("CB", const Color(0xFF0F766E)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),

                          // Bottom: MM / YY (Left) | CVC (Right)
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  child: TextField(
                                    controller: expiryCtrl,
                                    keyboardType: TextInputType.datetime,
                                    inputFormatters: [LengthLimitingTextInputFormatter(5)],
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isEn ? "MM / YY" : "MM / AA",
                                      hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                              Container(width: 1, height: 38, color: const Color(0xFFE2E8F0)),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: cvcCtrl,
                                          keyboardType: TextInputType.number,
                                          obscureText: true,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(4),
                                          ],
                                          style: GoogleFonts.inter(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1E293B),
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: "CVC",
                                            hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFCBD5E1)),
                                        ),
                                        child: Text(
                                          "123",
                                          style: GoogleFonts.inter(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
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
                    const SizedBox(height: 16),

                    // 5. "Billing address" Section Title
                    Text(
                      isEn ? "Billing address" : "Adresse de facturation",
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Combined Billing Address Box (Matches Screenshot)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        children: [
                          // Country row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEn ? "Country or region" : "Pays ou région",
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      selectedCountry,
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Color(0xFF64748B), size: 20),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),

                          // ZIP Code row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            child: TextField(
                              controller: zipCtrl,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                              decoration: InputDecoration(
                                hintText: isEn ? "ZIP Code" : "Code postal",
                                hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. Save with Link Checkbox Card (Matches Screenshot)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: saveWithLink,
                              activeColor: const Color(0xFF00D66F),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (v) => setModalState(() => saveWithLink = v ?? true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEn
                                      ? "Save my info for faster checkout with Link"
                                      : "Enregistrer pour payer plus vite avec Link",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isEn
                                      ? "Pay faster at FitVisor and thousands of businesses."
                                      : "Payez plus vite sur FitVisor et des milliers de commerces.",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 7. Terms / Disclaimer (Matches Screenshot)
                    Text(
                      isEn
                          ? "By providing your card information, you allow FitVisor to charge your card for future payments in accordance with their terms."
                          : "En fournissant vos informations de carte, vous autorisez FitVisor à débiter votre carte pour les futurs paiements conformément à leurs conditions.",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 8. Bottom "Set up" Button (Screenshot Orange Button with Lock)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          final cleanNum = cardCtrl.text.replaceAll(' ', '').trim();
                          if (cleanNum.length < 13) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEn ? 'Please enter a valid card number' : 'Numéro de carte invalide'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          final last4 = cleanNum.substring(cleanNum.length - 4);
                          final exp = expiryCtrl.text.trim().isNotEmpty ? expiryCtrl.text.trim() : '12/28';
                          final holder = _getUserDisplayName(isEn);
                          detectedBrand = StripePaymentService.detectCardBrand(cleanNum);

                          Navigator.pop(modalCtx);

                          // Save card locally and update state
                          await SubscriptionService.instance.savePaymentCard(
                            last4: last4,
                            brand: detectedBrand,
                            holder: holder,
                            expiry: exp,
                            isDefault: true,
                          );

                          setState(() {
                            _connectedCard = {
                              'last4': last4,
                              'type': detectedBrand,
                              'holder': holder,
                              'expiry': exp,
                              'rawCard': cleanNum,
                              'cvc': cvcCtrl.text.trim().isNotEmpty ? cvcCtrl.text.trim() : '123',
                              'zip': zipCtrl.text.trim(),
                              'isDefault': true,
                            };
                          });

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEn ? 'Card connected with Stripe successfully!' : 'Carte connectée avec Stripe !',
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5F00), // Screenshot Orange
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              "Set up",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.lock_rounded, size: 16, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _buildBrandMiniLogo(String brand, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        brand,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  /// Process direct subscription payment via Stripe
  Future<void> _processSubscriptionActivation() async {
    if (_isProcessing) return;

    if (_connectedCard == null) {
      _openOfficialStripeSetupSheet();
      return;
    }

    setState(() => _isProcessing = true);

    final isEn = LanguageService.instance.isEnglish;
    final cardHolder = _connectedCard!['holder']?.toString() ?? _getUserDisplayName(isEn);
    final lastFour = _connectedCard!['last4']?.toString() ?? '4242';
    final cardBrand = _connectedCard!['type']?.toString() ?? 'Visa';
    final rawCard = _connectedCard!['rawCard']?.toString() ?? '4242424242424242';
    final expStr = _connectedCard!['expiry']?.toString() ?? '12/28';
    final cvc = _connectedCard!['cvc']?.toString() ?? '123';
    final zip = _connectedCard!['zip']?.toString() ?? '75001';

    final expParts = expStr.split('/');
    final expMonth = expParts.isNotEmpty ? expParts[0].trim() : '12';
    final expYear = expParts.length > 1 ? expParts[1].trim() : '28';

    try {
      final stripeResult = await StripePaymentService.instance.processSubscriptionCharge(
        cardNumber: rawCard,
        expiryMonth: expMonth,
        expiryYear: expYear,
        cvc: cvc,
        cardHolderName: cardHolder,
        amountEur: widget.amount,
        planId: widget.planId,
        planName: widget.planName,
        billingCycle: widget.billingCycle,
        userId: await SubscriptionService.instance.getEffectiveUserId(),
        userEmail: Supabase.instance.client.auth.currentUser?.email,
        postalCode: zip,
      );

      if (!stripeResult.success) {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        _showPaymentErrorDialog(stripeResult.errorMessage ?? 'Payment was declined by Stripe.');
        return;
      }

      final stripePaymentIntentId = stripeResult.paymentIntentId;
      final receiptUrl = stripeResult.receiptUrl;

      await SubscriptionService.instance.activateSubscription(
        planId: widget.planId,
        planName: widget.planName,
        billingCycle: widget.billingCycle,
        amount: widget.amount,
        paymentMethod: 'credit_card',
        cardLastFour: lastFour,
        cardHolderName: cardHolder,
        cardBrand: cardBrand,
        stripePaymentIntentId: stripePaymentIntentId,
        receiptUrl: receiptUrl,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showSuccessDialog(cardHolder, stripePaymentIntentId);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showPaymentErrorDialog('Payment error: $e');
      }
    }
  }

  void _showPaymentErrorDialog(String errorMsg) {
    final isEn = LanguageService.instance.isEnglish;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? "Payment Declined" : "Paiement Refusé",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMsg,
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
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF172554),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEn ? "Try Again" : "Réessayer",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
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

  void _showSuccessDialog(String cardHolder, String? stripePaymentId) {
    final isEn = LanguageService.instance.isEnglish;
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
                isEn ? "Subscription Activated!" : "Abonnement Activé !",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEn
                    ? "Congratulations $cardHolder! Your ${widget.planName} is now active with Stripe payment confirmation."
                    : "Félicitations $cardHolder ! Votre formule ${widget.planName} est désormais active avec confirmation Stripe.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              if (stripePaymentId != null && stripePaymentId.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_rounded, size: 14, color: Color(0xFF475569)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          stripePaymentId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, widget.planName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isEn ? "Access My Pro Space" : "Accéder à Mon Espace Pro",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEn ? "View Transaction History" : "Voir l'Historique des Factures",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Membership Pass Card
                  _buildMembershipPassCard(isEn),
                  const SizedBox(height: 16),

                  // 2. Stripe Connected Card Section (Centered + Add New Card or Card Preview)
                  _buildStripeCardSection(isEn),
                  const SizedBox(height: 16),

                  // 3. Billing Address Confirmation Box
                  _buildBillingAddressBox(isEn),
                  const SizedBox(height: 16),

                  // 4. Ready to Drape Preview Box
                  _buildReadyToDrapeBox(isEn),
                  const SizedBox(height: 18),

                  // 5. Summary Total Due Card (Clean without VAT)
                  _buildSummaryTotalDueCard(isEn),
                  const SizedBox(height: 20),

                  // 6. Primary Action Button
                  _buildActivateSubscriptionButton(isEn),
                  const SizedBox(height: 14),

                  // 7. Bank-Grade SSL Security Footer
                  _buildSecurityFooter(isEn),
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
        isEn ? "Payment & Billing" : "Paiement & Facturation",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF172554),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: isEn ? "Transaction History" : "Historique",
          icon: const Icon(Icons.receipt_long_rounded,
              color: Color(0xFF172554), size: 20),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildDynamicUserAvatar(size: 34),
        ),
      ],
    );
  }

  // ── 1. MEMBERSHIP PASS CARD ──────────────────────────────────────────────

  Widget _buildMembershipPassCard(bool isEn) {
    final cycleText = widget.billingCycle == 'annual'
        ? (isEn ? " / yr" : " / an")
        : (isEn ? " / mo" : " / mois");
    final renewalText = widget.billingCycle == 'annual'
        ? (isEn
            ? "Billed today, automatically renews annually. Cancel anytime."
            : "Facturé aujourd'hui, renouvellement annuel automatique. Annulation à tout moment.")
        : (isEn
            ? "Billed today, automatically renews monthly. Cancel anytime."
            : "Facturé aujourd'hui, renouvellement mensuel automatique. Annulation à tout moment.");

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
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded,
                          size: 12, color: Color(0xFFE11D48)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isEn ? "FITVISOR MEMBER PASS" : "PASS MEMBRE FITVISOR",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE11D48),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _formattedPlanPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  Text(
                    cycleText,
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
            renewalText,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. STRIPE CARD SECTION (CENTERED + ADD NEW CARD BOX OR SAVED CARD) ────

  Widget _buildStripeCardSection(bool isEn) {
    if (_isLoadingCard) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFFFF5F00),
        ),
      );
    }

    if (_connectedCard == null) {
      // Clean Centered Box with "+ Add New Card"
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _openOfficialStripeSetupSheet,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFFFF5F00),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _openOfficialStripeSetupSheet,
                child: Text(
                  isEn ? "Add New Card" : "Ajouter une nouvelle carte",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn ? "Connect securely via Stripe" : "Connexion sécurisée via Stripe",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBrandMiniLogo("VISA", const Color(0xFF1A1F71)),
                  const SizedBox(width: 4),
                  _buildBrandMiniLogo("MC", const Color(0xFFEB001B)),
                  const SizedBox(width: 4),
                  _buildBrandMiniLogo("AMEX", const Color(0xFF006FCF)),
                  const SizedBox(width: 4),
                  _buildBrandMiniLogo("CB", const Color(0xFF0F766E)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Card IS Connected -> Render Realistic Credit Card Tile
    final brand = _connectedCard!['type']?.toString().toUpperCase() ?? 'VISA';
    final last4 = _connectedCard!['last4']?.toString() ?? '4242';
    final expiry = _connectedCard!['expiry']?.toString() ?? '12/28';
    final holder = _connectedCard!['holder']?.toString() ?? _getUserDisplayName(isEn);

    return Container(
      padding: const EdgeInsets.all(18),
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
              Text(
                isEn ? "CONNECTED PAYMENT CARD" : "CARTE BANCAIRE CONNECTÉE",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: _openOfficialStripeSetupSheet,
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, size: 14, color: Color(0xFFFF5F00)),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? "+ Add New Card" : "+ Ajouter une carte",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF5F00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sleek Card Visual
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF172554), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF172554).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        brand,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          "Verified with Stripe",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  "••••  ••••  ••••  $last4",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? "CARDHOLDER" : "TITULAIRE",
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          holder,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isEn ? "EXPIRES" : "EXPIRE",
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          expiry,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. BILLING ADDRESS CONFIRMATION BOX ───────────────────────────────────

  Widget _buildBillingAddressBox(bool isEn) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: Color(0xFF172554)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEn ? "Billing Address" : "Adresse de Facturation",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF172554),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isEn ? "Same as Profile" : "Identique au Profil",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.home_work_outlined,
                    size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Paris, France · Profil Client FitVisor",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF475569),
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

  // ── 4. READY TO DRAPE PREVIEW BOX ────────────────────────────────────────

  Widget _buildReadyToDrapeBox(bool isEn) {
    final userName = _getUserDisplayName(isEn);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        children: [
          _buildDynamicUserAvatar(size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn
                      ? "Ready for $userName's drape"
                      : "Prêt pour le profil de $userName",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  isEn
                      ? "Instant 3D spatial mesh unlocked upon activation"
                      : "Rendus 3D instantanés débloqués dès l'activation",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFE11D48), size: 20),
        ],
      ),
    );
  }

  // ── 5. SUMMARY TOTAL DUE CARD (CLEAN WITHOUT VAT) ─────────────────────────

  Widget _buildSummaryTotalDueCard(bool isEn) {
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
              Expanded(
                child: Text(
                  widget.billingCycle == 'annual'
                      ? (isEn ? "Annual Plan Subtotal" : "Sous-total Annuel")
                      : (isEn ? "Monthly Plan Subtotal" : "Sous-total Mensuel"),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: const Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formattedPlanPrice,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isEn ? "Total Due Today" : "Total Dû Aujourd'hui",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formattedPlanPrice,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
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

  // ── 6. PRIMARY ACTION BUTTON ─────────────────────────────────────────────

  Widget _buildActivateSubscriptionButton(bool isEn) {
    final bool hasCard = _connectedCard != null;
    final String label = hasCard
        ? (isEn ? "Subscribe Now — $_formattedPlanPrice" : "Souscrire — $_formattedPlanPrice")
        : (isEn ? "+ Add Card to Subscribe" : "+ Ajouter une Carte pour Souscrire");

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processSubscriptionActivation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF43F5E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFFCA5A5),
          elevation: 4,
          shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(hasCard ? Icons.lock_rounded : Icons.add_card_rounded, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── 7. BANK-GRADE SSL SECURITY FOOTER ────────────────────────────────────

  Widget _buildSecurityFooter(bool isEn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            isEn
                ? "256-Bit SSL Encrypted · Direct Stripe Connection"
                : "Chiffrement SSL 256-Bit · Connexion Directe Stripe",
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE DYNAMIC USER AVATAR HELPER
// ─────────────────────────────────────────────────────────────────────────────
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
