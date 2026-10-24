import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'transaction_history_screen.dart';
import '../../../../core/localization/language_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _savedCards = [
    {
      'type': 'Visa',
      'last4': '4242',
      'expiry': '08/27',
      'holder': 'Alexa Morgan',
      'color1': const Color(0xFF172554),
      'color2': const Color(0xFF1E3A8A),
      'isDefault': true,
    },
    {
      'type': 'Mastercard',
      'last4': '8371',
      'expiry': '03/26',
      'holder': 'Alexa Morgan',
      'color1': const Color(0xFF7C3AED),
      'color2': const Color(0xFF4C1D95),
      'isDefault': false,
    },
  ];

  void _showAddCardBottomSheet() {
    final isEn = LanguageService.instance.isEnglish;
    final cardNumberCtrl = TextEditingController();
    final cardNameCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEn ? 'Add a New Card' : 'Ajouter une Nouvelle Carte',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isEn ? 'Your data is 256-bit SSL encrypted' : 'Vos données sont chiffrées SSL 256-bit',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 20),
              _buildCardField(
                controller: cardNumberCtrl,
                label: isEn ? 'Card Number' : 'Numéro de Carte',
                hint: '1234  5678  9012  3456',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              const SizedBox(height: 12),
              _buildCardField(
                controller: cardNameCtrl,
                label: isEn ? 'Cardholder Name' : 'Nom du Titulaire',
                hint: 'ALEXA MORGAN',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                inputFormatters: [],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCardField(
                      controller: expiryCtrl,
                      label: isEn ? 'Expiration' : 'Expiration',
                      hint: isEn ? 'MM/YY' : 'MM/AA',
                      icon: Icons.calendar_today_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(5)],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCardField(
                      controller: cvvCtrl,
                      label: 'CVV',
                      hint: '•••',
                      icon: Icons.lock_outline_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _savedCards.add({
                        'type': 'Visa',
                        'last4': cardNumberCtrl.text.length >= 4
                            ? cardNumberCtrl.text
                                .substring(cardNumberCtrl.text.length - 4)
                            : '0000',
                        'expiry': expiryCtrl.text.isNotEmpty
                            ? expiryCtrl.text
                            : '12/28',
                        'holder': cardNameCtrl.text.isNotEmpty
                            ? cardNameCtrl.text.toUpperCase()
                            : 'ALEXA MORGAN',
                        'color1': const Color(0xFF0F766E),
                        'color2': const Color(0xFF134E4A),
                        'isDefault': false,
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEn ? 'Card added successfully!' : 'Carte ajoutée avec succès !',
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFFF43F5E),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor:
                        const Color(0xFFF43F5E).withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_card_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEn ? 'Save Card' : 'Enregistrer la Carte',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B))),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF172554)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFFCBD5E1)),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                    color: Color(0xFFF43F5E), width: 1.5)),
          ),
        ),
      ],
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
          appBar: AppBar(
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
              isEn ? 'Payment Methods' : 'Moyens de Paiement',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
                letterSpacing: -0.3,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(isEn ? 'PAYMENT METHODS' : 'MOYENS DE PAIEMENT'),
                  const SizedBox(height: 14),

                  ..._savedCards.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildSavedCardTile(entry.value, entry.key, isEn),
                    );
                  }),

                  _buildAddNewCardButton(isEn),
                  const SizedBox(height: 28),

                  _buildSectionLabel(isEn ? 'OTHER OPTIONS' : 'AUTRES OPTIONS'),
                  const SizedBox(height: 14),

                  _buildOtherOptionsCard(isEn),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF172554),
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _buildSavedCardTile(Map<String, dynamic> card, int index, bool isEn) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [card['color1'] as Color, card['color2'] as Color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (card['color1'] as Color).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  card['type'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  if (card['isDefault'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isEn ? 'DEFAULT' : 'PAR DÉFAUT',
                        style: GoogleFonts.inter(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _savedCards.removeAt(index)),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '••••  ••••  ••••  ${card['last4']}',
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
                    isEn ? 'CARDHOLDER' : 'TITULAIRE',
                    style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.5),
                  ),
                  Text(
                    card['holder'] as String,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isEn ? 'EXPIRES' : 'EXPIRE',
                    style: GoogleFonts.inter(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.5),
                  ),
                  Text(
                    card['expiry'] as String,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCardButton(bool isEn) {
    return GestureDetector(
      onTap: _showAddCardBottomSheet,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  size: 22, color: Color(0xFFF43F5E)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'Add New Card' : 'Ajouter une Nouvelle Carte',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554)),
                  ),
                  Text(
                    isEn ? 'Visa, Mastercard, Amex accepted' : 'Visa, Mastercard, Amex acceptés',
                    style: GoogleFonts.inter(
                        fontSize: 10.5, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherOptionsCard(bool isEn) {
    return Container(
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
        children: [
          _buildOptionTile(
            icon: Icons.receipt_long_rounded,
            iconBg: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF16A34A),
            title: isEn ? 'Transaction History' : 'Historique des Transactions',
            subtitle: isEn ? 'View all your past transactions' : 'Voir toutes vos transactions passées',
            badgeText: null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen()),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.apple_rounded,
            iconBg: const Color(0xFFF8FAFC),
            iconColor: const Color(0xFF1E293B),
            title: 'Apple Pay',
            subtitle: isEn ? 'Link your Apple Pay account' : 'Lier votre compte Apple Pay',
            badgeText: isEn ? 'LINK' : 'LIER',
            badgeColor: const Color(0xFF172554),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isEn ? 'Apple Pay — Coming soon!' : 'Apple Pay — Bientôt disponible !',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            )),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.g_mobiledata_rounded,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA4335),
            title: 'Google Pay',
            subtitle: isEn ? 'Link your Google Pay account' : 'Lier votre compte Google Pay',
            badgeText: isEn ? 'LINK' : 'LIER',
            badgeColor: const Color(0xFFEA4335),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isEn ? 'Google Pay — Coming soon!' : 'Google Pay — Bientôt disponible !',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFFEA4335),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            )),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildOptionTile(
            icon: Icons.description_outlined,
            iconBg: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4F46E5),
            title: isEn ? 'Purchase Order (PO)' : 'Bon de Commande (POH)',
            subtitle: isEn ? 'Purchase Order — B2B payment' : 'Purchase Order — paiement B2B',
            badgeText: 'PO',
            badgeColor: const Color(0xFF4F46E5),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(isEn ? 'Purchase Order — Contact enterprise support.' : 'Bon de Commande — Contactez le support entreprise.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF4F46E5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: iconBg, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 22, color: iconColor),
      ),
      title: Text(title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF172554))),
      subtitle: Text(subtitle,
          style: GoogleFonts.inter(
              fontSize: 10.5, color: const Color(0xFF64748B))),
      trailing: badgeText != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (badgeColor ?? const Color(0xFF172554))
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: (badgeColor ?? const Color(0xFF172554))
                        .withValues(alpha: 0.3)),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: badgeColor ?? const Color(0xFF172554),
                    letterSpacing: 0.4),
              ),
            )
          : const Icon(Icons.chevron_right_rounded,
              size: 18, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }
}
