import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checkout_order_screen.dart';
import 'change_size_color_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _marketingConsent = false;

  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'imagePath': 'assets/images/product_dress.jpg',
      'title': 'Robe Midi en Soie',
      'brand': 'Zalando',
      'size': 'M',
      'color': 'Bleu Nuit',
      'priceNum': 59.90,
      'priceStr': '€59,90',
      'qty': 1,
    },
    {
      'id': '2',
      'imagePath': 'assets/images/product_suit.jpg',
      'title': 'Blazer en Laine',
      'brand': 'H&M',
      'size': 'M',
      'color': 'Anthracite',
      'priceNum': 79.90,
      'priceStr': '€79,90',
      'qty': 1,
    },
  ];

  double get _subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + (item['priceNum'] as double) * (item['qty'] as int));

  void _removeItem(int index) {
    final title = _cartItems[index]['title'];
    setState(() => _cartItems.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title supprimé du panier.",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF172554),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _changeQty(int index, int delta) {
    setState(() {
      final newQty = ((_cartItems[index]['qty'] as int) + delta).clamp(0, 10);
      if (newQty == 0) {
        _removeItem(index);
      } else {
        _cartItems[index]['qty'] = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final subtotalStr = '€${_subtotal.toStringAsFixed(2).replaceAll('.', ',')}';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Articles du panier
                    if (_cartItems.isEmpty)
                      _buildEmptyCart()
                    else
                      ...List.generate(_cartItems.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCartItemCard(i),
                        );
                      }),

                    const SizedBox(height: 8),

                    // Récapitulatif de la commande
                    if (_cartItems.isNotEmpty) _buildOrderSummaryCard(subtotalStr),

                    const SizedBox(height: 16),

                    // Consentement marketing
                    if (_cartItems.isNotEmpty) _buildMarketingConsent(),

                    const SizedBox(height: 12),

                    // Note de paiement
                    if (_cartItems.isNotEmpty) _buildPaymentNoteBanner(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bouton sticky bas
            if (_cartItems.isNotEmpty) _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
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
        "Panier (${_cartItems.length})",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
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
              color: const Color(0xFFF1F5F9),
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

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            const Icon(Icons.remove_shopping_cart_outlined,
                size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              "Votre panier est vide",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(int index) {
    final item = _cartItems[index];
    final qty = item['qty'] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + détails
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image produit
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  item['imagePath'] as String,
                  width: 72,
                  height: 88,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 72,
                    height: 88,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.checkroom_rounded,
                        size: 28, color: Color(0xFF94A3B8)),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Détails produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Chip marque
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['brand'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Taille : ${item['size']}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    Text(
                      "Couleur : ${item['color']}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quantité + prix
                    Row(
                      children: [
                        _qtyButton(
                          icon: Icons.remove_rounded,
                          onTap: () => _changeQty(index, -1),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$qty',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _qtyButton(
                          icon: Icons.add_rounded,
                          onTap: () => _changeQty(index, 1),
                        ),
                        const Spacer(),
                        Text(
                          item['priceStr'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF172554),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bas de carte : stock + modifier — FIXED overflow with Flexible
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "En stock",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 1,
                height: 12,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(width: 6),
              // Flexible prevents overflow
              Flexible(
                child: Text(
                  "Mis à jour il y a 5 min",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Modifier taille/couleur
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangeSizeColorScreen()),
                  );
                },
                child: Text(
                  "Modifier",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF43F5E),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }

  Widget _buildOrderSummaryCard(String subtotalStr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _summaryRow(
            label: "Sous-total",
            value: subtotalStr,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF475569),
            ),
            valueStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF172554),
            ),
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _summaryRow(
            label: "Total",
            value: subtotalStr,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
            valueStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Les prix et la disponibilité proviennent des boutiques partenaires.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required TextStyle labelStyle,
    required TextStyle valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildMarketingConsent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _marketingConsent,
            // Coral pink checkbox comme demandé
            activeColor: const Color(0xFFF43F5E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
            onChanged: (val) =>
                setState(() => _marketingConsent = val ?? false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "J'accepte de recevoir des communications marketing de FitVisor et de ses partenaires.",
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentNoteBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                size: 18, color: Color(0xFF172554)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Le paiement est effectué sur le site du partenaire ou via un prestataire de paiement. FitVisor ne conserve pas vos coordonnées bancaires.",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
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
                builder: (context) => const CheckoutOrderScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF43F5E),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            "Aller au Checkout",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
