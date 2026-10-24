import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/language_service.dart';
import 'order_confirmation_screen.dart';
import 'add_shipping_address_screen.dart';

class CheckoutOrderScreen extends StatefulWidget {
  const CheckoutOrderScreen({super.key});

  @override
  State<CheckoutOrderScreen> createState() => _CheckoutOrderScreenState();
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  int _selectedPaymentMethod = 0; // 0: Apple Pay, 1: Visa, 2: Klarna

  ShippingAddressModel _shippingAddress = const ShippingAddressModel(
    recipientName: "Alexa Morgan",
    streetAddress: "742 Evergreen Terrace",
    apt: "Apt 4B",
    city: "New York",
    state: "NY",
    zipCode: "10012",
    country: "United States",
  );

  Future<void> _openAddAddress() async {
    final updated = await Navigator.of(context).push<ShippingAddressModel>(
      MaterialPageRoute(
        builder: (context) => const AddShippingAddressScreen(initialAddress: null),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _shippingAddress = updated);
    }
  }

  Future<void> _openEditAddress() async {
    final updated = await Navigator.of(context).push<ShippingAddressModel>(
      MaterialPageRoute(
        builder: (context) => AddShippingAddressScreen(initialAddress: _shippingAddress),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _shippingAddress = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBoutiqueCard(),
              const SizedBox(height: 16),
              _buildShippingAddressCard(),
              const SizedBox(height: 16),
              _buildOrderItemsCard(),
              const SizedBox(height: 16),
              _buildSelectPaymentCard(),
              const SizedBox(height: 24),
              _buildSecurityFooter(),
              const SizedBox(height: 16),
              _buildContinueButton(),
              const SizedBox(height: 16),
              _buildReturnLink(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isEn = LanguageService.instance.isEnglish;
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
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
        isEn ? "Checkout" : "Paiement de la Commande",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF172554),
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 32,
            height: 32,
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

  Widget _buildBoutiqueCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 10,
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
                isEn ? "VERIFIED PARTNER NETWORK" : "RÉSEAU PARTENAIRE VÉRIFIÉ",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF43F5E),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEn ? "Atelier FitVisor Official Boutique" : "Boutique Officielle Atelier FitVisor",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? "You will be securely routed to fulfill this order with direct boutique inventory. Your tailored 3D sizing specs are synced automatically."
                : "Vous serez redirigé en toute sécurité pour finaliser cette commande avec l'inventaire direct de la boutique. Vos mensurations 3D sont synchronisées automatiquement.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.center_focus_weak_rounded, size: 14, color: Color(0xFFF43F5E)),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? "Synced: Size M • 99.2% Fit Confidence" : "Synchronisé : Taille M • 99.2% Ajustement",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (without edit button, as requested)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.local_shipping_outlined, size: 18, color: Color(0xFF1E293B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn ? "Shipping Address" : "Adresse de Livraison",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Prominent "Add Address" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _openAddAddress,
                icon: const Icon(Icons.add_location_alt_outlined, size: 17),
                label: Text(
                  isEn ? "Add Delivery Address" : "Ajouter une Adresse",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF172554),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tappable Existing Address Card to Edit
          GestureDetector(
            onTap: _openEditAddress,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _shippingAddress.recipientName.isNotEmpty
                                  ? _shippingAddress.recipientName
                                  : (isEn ? "Unnamed Recipient" : "Destinataire"),
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isEn ? "Tap to edit" : "Modifier",
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _shippingAddress.formattedAddress,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit_note_rounded, size: 22, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Express Courier Row (non-overflowing)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF43F5E)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isEn ? "Express Courier (2–3 business days)" : "Courrier Express (2–3 jours ouvrés)",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF475569),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isEn ? "FREE" : "GRATUIT",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF1E293B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEn ? "Order Items (2)" : "Articles de la Commande (2)",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "€668,75",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                  ],
                ),
              ],
            ),
          ),
          
          // Item 1
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/product_dress.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? "Sculpted Silk Midi Dress" : "Robe Midi en Soie Sculptée",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn ? "Midnight Navy • Size M" : "Bleu Nuit • Taille M",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEn ? "99.2% Digital Fit Match" : "99.2% Précision Ajustement",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF43F5E),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "€285,00",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Item 2
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/product_suit.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? "Tailored Structured Blazer" : "Blazer Structuré sur-mesure",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isEn ? "Obsidian Black • Size M" : "Noir Obsidienne • Taille M",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEn ? "98.8% Digital Fit Match" : "98.8% Précision Ajustement",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF43F5E),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "€340,00",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Totals
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? "Subtotal" : "Sous-total", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text("€625,00", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? "Estimated Sales Tax" : "TVA estimée", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text("€43,75", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? "Shipping & Handling" : "Frais de livraison", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text(isEn ? "Free" : "Gratuit", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFFF43F5E))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSelectPaymentCard() {
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payments_outlined, size: 18, color: Color(0xFF1E293B)),
            const SizedBox(width: 8),
            Text(
              isEn ? "Select Payment Method" : "Sélectionner le Mode de Paiement",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            children: [
              _buildPaymentOption(
                index: 0,
                icon: Icons.account_balance_wallet_rounded,
                title: isEn ? "Apple Pay / One-Tap" : "Apple Pay / 1-Clic",
                subtitle: isEn ? "Instant biometric confirmation" : "Confirmation biométrique instantanée",
                isDefault: true,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildPaymentOption(
                index: 1,
                icon: Icons.credit_card_rounded,
                title: isEn ? "Visa ending in •••• 4821" : "Visa se terminant par •••• 4821",
                subtitle: isEn ? "Expires 08/27 • Alexa Morgan" : "Expire 08/27 • Alexa Morgan",
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildPaymentOption(
                index: 2,
                icon: Icons.pie_chart_outline_rounded,
                title: "FitVisor Pay / Klarna",
                subtitle: isEn ? "4 bi-weekly payments of €167,18" : "4 paiements bimensuels de 167,18 €",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDefault = false,
  }) {
    final isEn = LanguageService.instance.isEnglish;
    final isSelected = _selectedPaymentMethod == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFFCBD5E1),
              size: 22,
            ),
            const SizedBox(width: 12),
            Icon(icon, size: 24, color: const Color(0xFF475569)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isEn ? "Default" : "Défaut",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    final isEn = LanguageService.instance.isEnglish;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(
          isEn
              ? "256-Bit SSL Encrypted • Direct Boutique Fulfillment"
              : "Chiffré SSL 256-Bit • Traitement Direct Boutique",
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    final isEn = LanguageService.instance.isEnglish;
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
          shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isEn ? "Continue to Payment" : "Continuer vers le Paiement",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnLink() {
    final isEn = LanguageService.instance.isEnglish;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Text(
        isEn ? "Return to Cart" : "Retour au Panier",
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }
}
