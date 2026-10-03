import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0; // 0 = Apple Pay / Stripe, 1 = Visa, 2 = FitVisor Pay / Cash

  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'imagePath': 'assets/images/product_dress.jpg',
      'title': 'Sculpted Silk Midi',
      'details': 'Midnight Navy • Taille M',
      'priceNum': 285.00,
      'priceStr': '285,00 €',
      'matchScore': '99,2% Correspondance Numérique',
    },
    {
      'id': '2',
      'imagePath': 'assets/images/product_suit.jpg',
      'title': 'Tailored Structured Blazer',
      'details': 'Obsidian Black • Taille M',
      'priceNum': 340.00,
      'priceStr': '340,00 €',
      'matchScore': '98,8% Correspondance Numérique',
    },
  ];

  double get _subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + (item['priceNum'] as double));

  double get _tax => _subtotal * 0.07;

  double get _total => _subtotal + _tax;

  void _removeItem(int index) {
    final removedItemTitle = _cartItems[index]['title'];
    setState(() {
      _cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$removedItemTitle supprimé du panier.",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF172554),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
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
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Verified Partner Network Card (FitVisor Official Boutique)
              _buildVerifiedPartnerCard(),
              const SizedBox(height: 16),

              // 2. Shipping Address Card
              _buildShippingAddressCard(),
              const SizedBox(height: 16),

              // 3. Order Items Summary Card
              _buildOrderItemsCard(),
              const SizedBox(height: 20),

              // 4. Select Payment Method
              if (_cartItems.isNotEmpty) ...[
                _buildSelectPaymentCard(),
                const SizedBox(height: 20),
                _buildSecurityDisclaimer(),
                const SizedBox(height: 16),
                _buildContinuePaymentButton(),
                const SizedBox(height: 12),
              ],

              // 5. Secondary Action Link: Retour au Panier / Boutique
              _buildReturnToCartLink(),
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
        "Commandes & Caisse",
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

  // ── 1. VERIFIED PARTNER NETWORK CARD ─────────────────────────────────────

  Widget _buildVerifiedPartnerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172554), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 14, color: Color(0xFFF43F5E)),
              const SizedBox(width: 6),
              Text(
                "RÉSEAU PARTENAIRE VÉRIFIÉ",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF43F5E),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Atelier FitVisor Official Boutique",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Vous serez redirigé en toute sécurité pour exécuter cette commande avec le stock direct de la boutique. Vos mesures d'ajustement 3D sont synchronisées automatiquement.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fit_screen_rounded, size: 13, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "Synchronisé : Taille M • 99,2% Confiance Ajustement",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  // ── 2. SHIPPING ADDRESS CARD ─────────────────────────────────────────────

  Widget _buildShippingAddressCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 16, color: Color(0xFF172554)),
                  const SizedBox(width: 8),
                  Text(
                    "Adresse de Livraison",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Alexa Morgan",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "742 Evergreen Terrace, Apt 4B\nNew York, NY 10012",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFF43F5E)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Livraison Express (2–3 jours ouvrés)",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "GRATUIT",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
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

  // ── 3. ORDER ITEMS CARD ──────────────────────────────────────────────────

  Widget _buildOrderItemsCard() {
    final formattedTotalStr = "${_total.toStringAsFixed(2).replaceAll('.', ',')} €";
    final formattedSubtotalStr = "${_subtotal.toStringAsFixed(2).replaceAll('.', ',')} €";
    final formattedTaxStr = "${_tax.toStringAsFixed(2).replaceAll('.', ',')} €";

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 16, color: Color(0xFF172554)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Articles de la Commande (${_cartItems.length})",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formattedTotalStr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_cartItems.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.remove_shopping_cart_outlined,
                        size: 36, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 8),
                    Text(
                      "Votre panier est vide",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cartItems.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return _buildOrderItemRow(
                  index: index,
                  imagePath: item['imagePath'] as String,
                  title: item['title'] as String,
                  details: item['details'] as String,
                  price: item['priceStr'] as String,
                  matchScore: item['matchScore'] as String,
                );
              },
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Price Breakdown Summary
            _buildSummaryPriceRow("Sous-total", formattedSubtotalStr),
            const SizedBox(height: 4),
            _buildSummaryPriceRow("TVA Estimée", formattedTaxStr),
            const SizedBox(height: 4),
            _buildSummaryPriceRow("Frais de Port", "Gratuit", isHighlight: true),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemRow({
    required int index,
    required String imagePath,
    required String title,
    required String details,
    required String price,
    required String matchScore,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 50,
              height: 62,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  details,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  matchScore,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF43F5E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _removeItem(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPriceRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight ? const Color(0xFFF43F5E) : const Color(0xFF172554),
          ),
        ),
      ],
    );
  }

  // ── 4. SELECT PAYMENT METHOD ─────────────────────────────────────────────

  Widget _buildSelectPaymentCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded,
                  size: 16, color: Color(0xFF172554)),
              const SizedBox(width: 8),
              Text(
                "Mode de Paiement",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Option 0: Apple Pay / Stripe One-Tap
          _buildPaymentOption(
            index: 0,
            icon: Icons.account_balance_wallet_rounded,
            title: "Apple Pay / One-Tap",
            subtitle: "Confirmation biométrique instantanée",
            hasDefaultBadge: true,
          ),
          const SizedBox(height: 8),

          // Option 1: Visa ending in 4821
          _buildPaymentOption(
            index: 1,
            icon: Icons.credit_card_rounded,
            title: "Visa terminaison •••• 4821",
            subtitle: "Expire 08/27 • Alexa Morgan",
          ),
          const SizedBox(height: 8),

          // Option 2: FitVisor Pay / Klarna / Cash on Delivery
          _buildPaymentOption(
            index: 2,
            icon: Icons.payments_outlined,
            title: "FitVisor Pay / Klarna",
            subtitle: "4 mensualités • Paiement à la livraison",
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasDefaultBadge = false,
  }) {
    final isSelected = _selectedPayment == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF172554) : const Color(0xFFF1F5F9),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF172554) : const Color(0xFFCBD5E1),
              size: 20,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 20, color: const Color(0xFF172554)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (hasDefaultBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Par défaut",
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 5. SECURITY DISCLAIMER ──────────────────────────────────────────────

  Widget _buildSecurityDisclaimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          "Cryptage 256-Bit SSL • Expédition Directe Boutique",
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  // ── 6. PRIMARY CONTINUE PAYMENT BUTTON ───────────────────────────────────

  Widget _buildContinuePaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const OrderConfirmationScreen(),
            ),
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
              "Continuer vers le Paiement",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // ── 7. RETURN TO CART LINK ───────────────────────────────────────────────

  Widget _buildReturnToCartLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
        child: Text(
          "Retour au Panier",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
