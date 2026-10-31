import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../data/order_service.dart';
import 'home_screen.dart';
import 'purchase_fit_feedback_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final OrderModel? order;
  final String? recipientName;

  const OrderConfirmationScreen({
    super.key,
    this.order,
    this.recipientName,
  });

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  OrderModel? get _order => widget.order;

  String get _name {
    if (widget.recipientName != null && widget.recipientName!.isNotEmpty) {
      return widget.recipientName!;
    }
    final snapName = _order?.shippingAddressSnapshot['recipient_name']?.toString();
    if (snapName != null && snapName.isNotEmpty) return snapName;
    return 'Alexa';
  }

  String get _orderNum => _order?.orderNumber ?? '#DK-984210';

  String get _deliveryDate => _order?.estimatedDeliveryDate ?? 'Thu, Oct 31 • Express';

  String get _paymentInfo {
    if (_order == null) return 'Apple Pay • €668,75';
    final method = _order!.paymentMethod == 'apple_pay'
        ? 'Apple Pay'
        : (_order!.paymentMethod == 'visa' ? 'Visa' : 'Klarna');
    final total = '€${_order!.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}';
    return '$method • $total';
  }

  String get _addressText {
    if (_order == null) return '742 Evergreen Terrace, New York, NY 10001';
    final formatted = _order!.shippingAddressSnapshot['formatted']?.toString();
    if (formatted != null && formatted.isNotEmpty) {
      return formatted.replaceAll('\n', ', ');
    }
    final street = _order!.shippingAddressSnapshot['street_address']?.toString() ?? '';
    final city = _order!.shippingAddressSnapshot['city']?.toString() ?? '';
    return '$street, $city';
  }

  Widget _buildGarmentThumbnail(String? url) {
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        width: 54,
        height: 66,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => _fallbackGarmentThumb(),
      );
    }
    if (url != null && url.isNotEmpty) {
      return Image.asset(
        url,
        width: 54,
        height: 66,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => _fallbackGarmentThumb(),
      );
    }
    return _fallbackGarmentThumb();
  }

  Widget _fallbackGarmentThumb() {
    return Container(
      width: 54,
      height: 66,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.checkroom_rounded, size: 24, color: Color(0xFF94A3B8)),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Top Confirmation Header (Red Check Icon + Badge + Title)
              _buildTopHeader(),
              const SizedBox(height: 20),

              // 2. Order Identifier Card (#DK-XXXXXX)
              _buildOrderIdentifierCard(),
              const SizedBox(height: 20),

              // 3. Garments Confirmed List
              _buildGarmentsConfirmedSection(),
              const SizedBox(height: 20),

              // 4. Fulfillment Timeline
              _buildFulfillmentTimelineSection(),
              const SizedBox(height: 24),

              // 5. Action Buttons (Continue to Feedback & Return Home)
              _buildActionButtons(),
              const SizedBox(height: 16),

              // 6. Bottom Delivery Ping Banner
              _buildBottomPingBanner(),
            ],
          ),
        ),
      ),
    );
  }

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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ValueListenableBuilder<File?>(
            valueListenable: UserAvatarService.avatarNotifier,
            builder: (context, avatarFile, _) {
              return Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: ClipOval(
                  child: avatarFile != null
                      ? Image.file(avatarFile, fit: BoxFit.cover)
                      : const Icon(Icons.person_rounded, size: 20, color: Color(0xFF2563EB)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      children: [
        // Glowing Red Check Icon Circle
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 14),

        // Pill Badge: COMMANDE BOUTIQUE PLACÉE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, size: 13, color: Color(0xFFE11D48)),
              const SizedBox(width: 5),
              Text(
                isEn ? "BOUTIQUE ORDER PLACED" : "COMMANDE BOUTIQUE PLACÉE",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFBE123C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Main Greeting Title (Dynamic Name)
        Text(
          isEn ? "You're all set, $_name!" : "Vous êtes tous prêts, $_name !",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            isEn
                ? "Your tailored order is confirmed and in production at Atelier FitVisor."
                : "Votre commande sur-mesure est confirmée et en cours de préparation par Atelier FitVisor.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderIdentifierCard() {
    final isEn = LanguageService.instance.isEnglish;
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
          // Order ID Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? "ORDER IDENTIFIER" : "IDENTIFIANT DE COMMANDE",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _orderNum,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                  ],
                ),
              ),
              // Copy Button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _orderNum));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEn ? "Identifier copied!" : "Identifiant copié !",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF172554),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.copy_rounded, size: 13, color: Color(0xFF475569)),
                      const SizedBox(width: 4),
                      Text(
                        isEn ? "Copy" : "Copier",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inner Details Gray Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? "Estimated Delivery" : "Livraison Estimée",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _deliveryDate,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? "Payment Method" : "Mode de Paiement",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _paymentInfo,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFE11D48)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _addressText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildGarmentsConfirmedSection() {
    final isEn = LanguageService.instance.isEnglish;
    final items = _order?.items ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isEn ? "Confirmed Garments (${items.length})" : "Vêtements Confirmés (${items.length})",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                const Icon(Icons.fit_screen_rounded, size: 13, color: Color(0xFFE11D48)),
                const SizedBox(width: 4),
                Text(
                  isEn ? "3D Digital Twin Ready" : "3D Digital Twin Prêt",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (items.isNotEmpty)
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildGarmentItemCard(
                  imageUrl: item.imageUrl,
                  sizeBadge: isEn ? 'Size ${item.size}' : 'Taille ${item.size}',
                  title: AppStrings.translateProduct(item.title, LanguageService.instance.currentLanguage),
                  subtitle: '${item.brand} • €${item.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                ),
              ))
        else ...[
          _buildGarmentItemCard(
            imageUrl: 'assets/images/hero_banner.jpg',
            sizeBadge: isEn ? 'Size M' : 'Taille M',
            title: isEn ? 'Sibem Cashmere Cocoon Coat' : 'Manteau Cocon en Cachemire Sibem',
            subtitle: isEn ? 'The Row • €2.490,00' : 'The Row • 2.490,00 €',
          ),
        ],
      ],
    );
  }

  Widget _buildGarmentItemCard({
    String? imageUrl,
    required String sizeBadge,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildGarmentThumbnail(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, size: 11, color: Color(0xFFE11D48)),
                          const SizedBox(width: 3),
                          Text(
                            "Fit Synced",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sizeBadge,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentTimelineSection() {
    final isEn = LanguageService.instance.isEnglish;
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
          Text(
            isEn ? "Fulfillment Timeline" : "Chronologie d'Exécution",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 14),

          // Timeline Step 1 (Completed)
          _buildTimelineStep(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFFE11D48),
            title: isEn ? "Order Confirmed" : "Commande Confirmée",
            subtitle: isEn
                ? "Payment captured & biometric silhouette matched"
                : "Paiement capturé & silhouette biométrique associée",
            isDone: true,
            hasLineBelow: true,
          ),

          // Timeline Step 2 (Active)
          _buildTimelineStep(
            icon: Icons.auto_awesome_rounded,
            iconColor: const Color(0xFF172554),
            title: isEn ? "Atelier Tailoring & Verification" : "Confection Atelier & Contrôle Qualité",
            subtitle: isEn
                ? "3D pattern precision verified by Atelier FitVisor studio"
                : "Précision du patron 3D vérifiée par l'Atelier FitVisor",
            isActive: true,
            hasLineBelow: true,
          ),

          // Timeline Step 3 (Pending - Dispatch Info)
          _buildTimelineStep(
            icon: Icons.local_shipping_outlined,
            iconColor: const Color(0xFF94A3B8),
            title: isEn ? "Express Courier Dispatch" : "Expédition Courrier Express",
            subtitle: isEn
                ? "Dispatches within 24–48 hours • Tracking number will be emailed"
                : "Expédié sous 24–48h • Numéro de suivi envoyé par e-mail",
            isDone: false,
            hasLineBelow: true,
          ),

          // Timeline Step 4 (Pending - Delivery)
          _buildTimelineStep(
            icon: Icons.home_rounded,
            iconColor: const Color(0xFF94A3B8),
            title: isEn ? "Estimated Delivery" : "Livraison Prévue",
            subtitle: isEn
                ? "Expected within 3–5 business days"
                : "Livraison prévue sous 3–5 jours ouvrés",
            isDone: false,
            hasLineBelow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isDone = false,
    bool isActive = false,
    bool hasLineBelow = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF172554)
                    : (isDone ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : iconColor,
              ),
            ),
            if (hasLineBelow)
              Container(
                width: 2,
                height: 34,
                color: const Color(0xFFE2E8F0),
              ),
          ],
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
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
                      ),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        LanguageService.instance.isEnglish ? "Active" : "Actif",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
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
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isEn = LanguageService.instance.isEnglish;
    return Column(
      children: [
        // Button 1: Continue to Fit Feedback
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PurchaseFitFeedbackScreen(
                    orderId: _order?.id,
                    orderNumber: _order?.orderNumber,
                    firstProduct: _order?.items.isNotEmpty == true ? _order!.items.first : null,
                  ),
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
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isEn ? "Continue to Fit Feedback" : "Continuer vers les Commentaires",
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
        ),
        const SizedBox(height: 12),

        // Button 2: Return to Home (100% direct home screen)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFBE123C),
              elevation: 0,
              side: const BorderSide(color: Color(0xFFFECDD3), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? "Return to Home" : "Retour à l'Accueil",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
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

  Widget _buildBottomPingBanner() {
    final isEn = LanguageService.instance.isEnglish;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active_outlined, size: 14, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isEn
                  ? "You will receive real-time push pings at each fulfillment milestone."
                  : "Vous recevrez des notifications en direct à chaque étape de livraison.",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
