import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../auth/data/user_avatar_service.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../data/cart_service.dart';
import '../../data/order_service.dart';
import 'checkout_order_screen.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _marketingConsent = false;
  bool _isLoading = true;
  List<CartItemModel> _cartItems = [];
  List<OrderModel> _activeOrders = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    final items = await CartService.instance.getCartItems();
    final orders = await OrderService.instance.getActiveOrders();
    if (mounted) {
      setState(() {
        _cartItems = items;
        _activeOrders = orders;
        _isLoading = false;
      });
    }
  }

  double get _subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));

  void _removeItem(CartItemModel item) async {
    final isEn = LanguageService.instance.isEnglish;
    final title = item.title;
    await CartService.instance.removeItem(item.id);
    await _loadCart();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEn ? "$title removed from cart." : "$title supprimé du panier.",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF172554),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _changeQty(CartItemModel item, int delta) async {
    final newQty = item.quantity + delta;
    if (newQty <= 0) {
      _removeItem(item);
    } else {
      await CartService.instance.updateQuantity(item.id, newQty);
      await _loadCart();
    }
  }

  void _openEditSheet(CartItemModel item) {
    final isEn = LanguageService.instance.isEnglish;
    String selectedSize = item.size;
    String selectedColor = item.color;
    final sizes = ['XS', 'S', 'M', 'L', 'XL'];
    final colors = [
      {'name': 'Noir', 'color': Colors.black},
      {'name': 'Bleu Nuit', 'color': const Color(0xFF1E3A8A)},
      {'name': 'Anthracite', 'color': const Color(0xFF475569)},
      {'name': 'Crème', 'color': const Color(0xFFF1F5F9)},
      {'name': 'Bordeaux', 'color': const Color(0xFF881337)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEn ? "Edit Size & Color" : "Modifier Taille & Couleur",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isEn ? "Select Size" : "Sélectionner la Taille",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: sizes.map((s) {
                      final isSelected = selectedSize == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: isSelected,
                        selectedColor: const Color(0xFFF43F5E),
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF172554),
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedSize = s);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEn ? "Select Color" : "Sélectionner la Couleur",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: colors.map((c) {
                      final name = c['name'] as String;
                      final isSelected = selectedColor == name;
                      return ChoiceChip(
                        avatar: CircleAvatar(
                          backgroundColor: c['color'] as Color,
                          radius: 7,
                        ),
                        label: Text(name),
                        selected: isSelected,
                        selectedColor: const Color(0xFF172554),
                        labelStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF172554),
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => selectedColor = name);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await CartService.instance.updateVariant(
                          item.id,
                          newSize: selectedSize,
                          newColor: selectedColor,
                        );
                        await _loadCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF43F5E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isEn ? "Save & Update Item" : "Enregistrer la Modification",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatPrice(double amount) {
    return '€${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Widget _buildProductThumbnail(String? url) {
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        width: 72,
        height: 88,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(),
      );
    }
    if (url != null && url.isNotEmpty) {
      return Image.asset(
        url,
        width: 72,
        height: 88,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Container(
      width: 72,
      height: 88,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.checkroom_rounded, size: 28, color: Color(0xFF94A3B8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final subtotalStr = _formatPrice(_subtotal);

    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          appBar: _buildAppBar(),
          body: SafeArea(
            top: false,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF43F5E)))
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. ACTIVE ORDERS SECTION (Shows all in-progress orders at the top!)
                              if (_activeOrders.isNotEmpty) ...[
                                _buildActiveOrdersSection(),
                                const SizedBox(height: 18),
                              ],

                              // 2. Articles du panier
                              if (_cartItems.isEmpty)
                                _buildEmptyCart()
                              else
                                ...List.generate(_cartItems.length, (i) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildCartItemCard(_cartItems[i]),
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

                      // Bouton sticky bas — ENABLED ONLY WHEN CONSENT ACCEPTED
                      if (_cartItems.isNotEmpty) _buildBottomButton(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isEn = LanguageService.instance.isEnglish;
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
        isEn ? "Cart (${_cartItems.length})" : "Panier (${_cartItems.length})",
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

  Widget _buildActiveOrdersSection() {
    final isEn = LanguageService.instance.isEnglish;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isEn
                      ? "Orders in Progress (${_activeOrders.length})"
                      : "Commandes en Cours (${_activeOrders.length})",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ],
            ),
            Text(
              isEn ? "Live Tracking" : "Suivi en direct",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF16A34A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._activeOrders.map((order) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActiveOrderCard(order),
            )),
      ],
    );
  }

  Widget _buildActiveOrderCard(OrderModel order) {
    final isEn = LanguageService.instance.isEnglish;
    final recipient = order.shippingAddressSnapshot['recipient_name']?.toString() ?? 'Alexa';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
                    const SizedBox(width: 5),
                    Text(
                      isEn ? "ORDER IN PROGRESS" : "COMMANDE EN COURS",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF15803D),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.orderNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items Preview snippet
          if (order.items.isNotEmpty) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: order.items.first.imageUrl != null && order.items.first.imageUrl!.startsWith('http')
                      ? Image.network(
                          order.items.first.imageUrl!,
                          width: 44,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 44,
                            height: 52,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.checkroom_rounded, size: 20, color: Color(0xFF94A3B8)),
                          ),
                        )
                      : Image.asset(
                          order.items.first.imageUrl ?? 'assets/images/product_dress.jpg',
                          width: 44,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 44,
                            height: 52,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.checkroom_rounded, size: 20, color: Color(0xFF94A3B8)),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.translateProduct(order.items.first.title, LanguageService.instance.currentLanguage),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${order.items.first.brand} • €${order.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}${order.items.length > 1 ? ' (+${order.items.length - 1} more)' : ''}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
          ],

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
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${order.estimatedDeliveryDate} • Express Direct",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "€${order.totalAmount.toStringAsFixed(2).replaceAll('.', ',')}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFBE123C),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrderConfirmationScreen(
                      order: order,
                      recipientName: recipient,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.local_shipping_outlined, size: 16),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isEn ? "Track Order Details" : "Suivre les Détails de la Commande",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
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
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    final isEn = LanguageService.instance.isEnglish;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 42, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 10),
            Text(
              isEn ? "Your cart has no pending items" : "Votre panier n'a aucun article en attente",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEn
                  ? "Explore curated 3D styles or customize your silhouette."
                  : "Découvrez nos styles 3D sur-mesure ou personnalisez votre silhouette.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                isEn ? "Continue Shopping" : "Continuer mes Achats",
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172554),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(CartItemModel item) {
    final isEn = LanguageService.instance.isEnglish;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildProductThumbnail(item.imageUrl),
              ),
              const SizedBox(width: 14),
              // Détails produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.translateProduct(item.title, LanguageService.instance.currentLanguage),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Chip marque
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.brand,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEn ? "Size : ${item.size}" : "Taille : ${item.size}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    Text(
                      isEn ? "Colour : ${item.color}" : "Couleur : ${item.color}",
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
                          onTap: () => _changeQty(item, -1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.quantity}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _qtyButton(
                          icon: Icons.add_rounded,
                          onTap: () => _changeQty(item, 1),
                        ),
                        const SizedBox(width: 8),
                        const Spacer(),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatPrice(item.totalPrice),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF172554),
                              ),
                            ),
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

          // Bas de carte : stock + modifier
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
                isEn ? "In stock" : "En stock",
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
              Flexible(
                child: Text(
                  isEn ? "Updated just now" : "Mis à jour à l'instant",
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
                onTap: () => _openEditSheet(item),
                child: Text(
                  isEn ? "Edit" : "Modifier",
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
    final isEn = LanguageService.instance.isEnglish;
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
            label: isEn ? "Subtotal" : "Sous-total",
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
            label: isEn ? "Total" : "Total",
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
            isEn
                ? "Prices and availability are sourced from partner boutiques."
                : "Les prix et la disponibilité proviennent des boutiques partenaires.",
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
        Expanded(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: valueStyle),
      ],
    );
  }

  Widget _buildMarketingConsent() {
    final isEn = LanguageService.instance.isEnglish;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _marketingConsent,
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
          child: GestureDetector(
            onTap: () => setState(() => _marketingConsent = !_marketingConsent),
            child: Text(
              isEn
                  ? "I agree to receive marketing communications from FitVisor and its partner boutiques."
                  : "J'accepte de recevoir des communications marketing de FitVisor et de ses partenaires.",
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: const Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentNoteBanner() {
    final isEn = LanguageService.instance.isEnglish;
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
              isEn
                  ? "Payment is processed on the partner website or via an authorized payment provider. FitVisor never stores your banking details."
                  : "Le paiement est effectué sur le site du partenaire ou via un prestataire de paiement. FitVisor ne conserve pas vos coordonnées bancaires.",
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
    final isEn = LanguageService.instance.isEnglish;
    final isEnabled = _marketingConsent;

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
          onPressed: isEnabled
              ? () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CheckoutOrderScreen(
                        cartItems: _cartItems,
                        subtotal: _subtotal,
                      ),
                    ),
                  );
                  _loadCart();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEnabled ? const Color(0xFFF43F5E) : const Color(0xFFCBD5E1),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            disabledForegroundColor: const Color(0xFF94A3B8),
            elevation: isEnabled ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            isEn ? "Proceed to Checkout" : "Aller au Checkout",
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
