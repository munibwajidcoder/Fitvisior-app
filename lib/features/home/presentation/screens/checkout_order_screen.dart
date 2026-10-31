import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/language_service.dart';
import '../../../../core/localization/app_strings.dart';
import '../../data/cart_service.dart';
import '../../data/address_service.dart';
import '../../data/order_service.dart';
import 'order_confirmation_screen.dart';
import 'add_shipping_address_screen.dart';

class CheckoutOrderScreen extends StatefulWidget {
  final List<CartItemModel>? cartItems;
  final double? subtotal;

  const CheckoutOrderScreen({
    super.key,
    this.cartItems,
    this.subtotal,
  });

  @override
  State<CheckoutOrderScreen> createState() => _CheckoutOrderScreenState();
}

class _CheckoutOrderScreenState extends State<CheckoutOrderScreen> {
  int _selectedPaymentMethod = 0; // 0: Apple Pay, 1: Visa, 2: Klarna
  bool _isProcessingPayment = false;
  List<CartItemModel> _items = [];

  ShippingAddressModel _shippingAddress = const ShippingAddressModel(
    recipientName: "",
    streetAddress: "",
    apt: "",
    city: "",
    state: "",
    zipCode: "",
    country: "",
    addressType: "home",
  );

  OrderModel? _placedOrder;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    if (widget.cartItems != null && widget.cartItems!.isNotEmpty) {
      _items = List.from(widget.cartItems!);
    } else if (CartService.cartItemsNotifier.value.isNotEmpty) {
      _items = List.from(CartService.cartItemsNotifier.value);
    } else {
      _items = await CartService.instance.getCartItems();
    }

    // Do NOT pre-load previous order into _placedOrder:
    // When the user opens Checkout, they intend to place a fresh order for their current cart items!
    _placedOrder = null;

    // Load saved default address from Supabase
    final defaultAddr = await AddressService.instance.getDefaultAddress();
    if (defaultAddr != null && mounted) {
      setState(() {
        _shippingAddress = defaultAddr;
      });
    }
    if (mounted) setState(() {});
  }

  double get _subtotalAmount {
    if (widget.subtotal != null && widget.subtotal! > 0) return widget.subtotal!;
    return _items.fold(0.0, (sum, i) => sum + (i.unitPrice * i.quantity));
  }

  double get _estimatedTax => _subtotalAmount * 0.05; // 5% VAT / Tax
  double get _shippingFee => 0.0; // Free express delivery
  double get _totalAmount => _subtotalAmount + _estimatedTax + _shippingFee;

  String _formatPrice(double amount) {
    return '€${amount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> _openAddAddress() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddShippingAddressScreen(initialAddress: null),
      ),
    );
    if (result == 'deleted' && mounted) {
      setState(() {
        _shippingAddress = const ShippingAddressModel(
          recipientName: '',
          streetAddress: '',
          city: '',
          state: '',
          zipCode: '',
        );
      });
    } else if (result is ShippingAddressModel && mounted) {
      setState(() => _shippingAddress = result);
    }
  }

  Future<void> _openEditAddress() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddShippingAddressScreen(
          initialAddress: _shippingAddress.streetAddress.isNotEmpty ? _shippingAddress : null,
        ),
      ),
    );
    if (result == 'deleted' && mounted) {
      setState(() {
        _shippingAddress = const ShippingAddressModel(
          recipientName: '',
          streetAddress: '',
          city: '',
          state: '',
          zipCode: '',
        );
      });
    } else if (result is ShippingAddressModel && mounted) {
      setState(() => _shippingAddress = result);
    }
  }

  Future<void> _confirmAndDeleteAddressOutside() async {
    final isEn = LanguageService.instance.isEnglish;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEn ? "Delete Address?" : "Supprimer l'Adresse ?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          isEn
              ? "Are you sure you want to delete this delivery address? It will be removed permanently."
              : "Êtes-vous sûr de vouloir supprimer cette adresse de livraison ? Elle sera supprimée définitivement.",
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    isEn ? "Cancel" : "Annuler",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: Text(
                    isEn ? "Delete" : "Supprimer",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AddressService.instance.deleteAddress();
      if (!mounted) return;
      setState(() {
        _shippingAddress = const ShippingAddressModel(
          recipientName: '',
          streetAddress: '',
          city: '',
          state: '',
          zipCode: '',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn ? "Address deleted permanently" : "Adresse supprimée définitivement",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String get _paymentMethodName {
    switch (_selectedPaymentMethod) {
      case 0:
        return 'apple_pay';
      case 1:
        return 'visa';
      case 2:
        return 'klarna';
      default:
        return 'card';
    }
  }

  void _processPaymentAndPlaceOrder() async {
    final isEn = LanguageService.instance.isEnglish;

    if (_items.isEmpty) {
      if (CartService.cartItemsNotifier.value.isNotEmpty) {
        _items = List.from(CartService.cartItemsNotifier.value);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn ? "Your cart is empty. Please add items to checkout." : "Votre panier est vide.",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    if (_shippingAddress.streetAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn ? "Please add a shipping address first" : "Veuillez d'abord ajouter une adresse de livraison",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isProcessingPayment) return;
    setState(() => _isProcessingPayment = true);

    final createdOrder = await OrderService.instance.createOrder(
      cartItems: _items,
      address: _shippingAddress,
      paymentMethod: _paymentMethodName,
      subtotal: _subtotalAmount,
      shippingFee: _shippingFee,
      totalAmount: _totalAmount,
      estimatedDelivery: '3 - 5 business days',
    );

    if (!mounted) return;
    setState(() {
      _isProcessingPayment = false;
      _placedOrder = createdOrder;
      _items = [];
    });

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          order: createdOrder,
          recipientName: _shippingAddress.recipientName,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildItemThumbnail(String? url) {
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackThumb(),
      );
    }
    if (url != null && url.isNotEmpty) {
      return Image.asset(
        url,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackThumb(),
      );
    }
    return _fallbackThumb();
  }

  Widget _fallbackThumb() {
    return Container(
      width: 50,
      height: 50,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.checkroom_rounded, size: 22, color: Color(0xFF94A3B8)),
    );
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
          if (_shippingAddress.streetAddress.isNotEmpty)
            Container(
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
                    child: GestureDetector(
                      onTap: _openEditAddress,
                      behavior: HitTestBehavior.opaque,
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
                  ),
                  const SizedBox(width: 4),
                  // Edit Action Button
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, size: 22, color: Color(0xFF2563EB)),
                    tooltip: isEn ? "Edit Address" : "Modifier l'Adresse",
                    onPressed: _openEditAddress,
                  ),
                  // Delete Action Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 21, color: Color(0xFFEF4444)),
                    tooltip: isEn ? "Delete Address" : "Supprimer l'Adresse",
                    onPressed: _confirmAndDeleteAddressOutside,
                  ),
                ],
              ),
            )
          else
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_off_rounded, color: Color(0xFFF43F5E), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEn
                          ? "No address saved. Tap 'Add Delivery Address' above."
                          : "Aucune adresse enregistrée. Cliquez sur 'Ajouter une Adresse' ci-dessus.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9F1239),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),

          // Express Courier Row
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
                          isEn
                              ? "Order Items (${_items.length})"
                              : "Articles de la Commande (${_items.length})",
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
                Text(
                  _formatPrice(_totalAmount),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Dynamic list of items
          ...List.generate(_items.length, (index) {
            final item = _items[index];
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                    child: _buildItemThumbnail(item.imageUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.translateProduct(item.title, LanguageService.instance.currentLanguage),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${item.color} • Size ${item.size} • Qty: ${item.quantity}",
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
                    _formatPrice(item.totalPrice),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 4),

          // Totals Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? "Subtotal" : "Sous-total", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text(_formatPrice(_subtotalAmount), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? "Estimated Sales Tax" : "TVA estimée", style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                    Text(_formatPrice(_estimatedTax), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))),
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
                const Divider(height: 20, color: Color(0xFFF1F5F9)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEn ? "Total Amount" : "Montant Total", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF172554))),
                    Text(_formatPrice(_totalAmount), style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF172554))),
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
                subtitle: isEn ? "Expires 08/27 • ${_shippingAddress.recipientName}" : "Expire 08/27 • ${_shippingAddress.recipientName}",
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildPaymentOption(
                index: 2,
                icon: Icons.pie_chart_outline_rounded,
                title: "FitVisor Pay / Klarna",
                subtitle: isEn
                    ? "4 bi-weekly payments of ${_formatPrice(_totalAmount / 4)}"
                    : "4 paiements bimensuels de ${_formatPrice(_totalAmount / 4)}",
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
    final hasItemsToPlace = _items.isNotEmpty;
    final isAlreadyPlaced = !hasItemsToPlace && _placedOrder != null;

    final buttonLabel = isAlreadyPlaced
        ? (isEn ? "View Active Order" : "Voir la Commande Active")
        : (isEn ? "Continue to Payment" : "Continuer vers le Paiement");

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isProcessingPayment
            ? null
            : () {
                if (isAlreadyPlaced && _placedOrder != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => OrderConfirmationScreen(
                        order: _placedOrder,
                        recipientName: _shippingAddress.recipientName,
                      ),
                    ),
                  );
                } else {
                  _processPaymentAndPlaceOrder();
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF43F5E), // Consistent theme Coral Pink
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isProcessingPayment
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAlreadyPlaced ? Icons.receipt_long_rounded : Icons.lock_outline_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      buttonLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isAlreadyPlaced && _placedOrder != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _placedOrder!.orderNumber,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
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
