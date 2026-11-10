import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/localization/language_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../data/store_partnership_service.dart';

class StorePartnershipsScreen extends StatefulWidget {
  final String productName;
  final String productSize;
  final String productImage;

  const StorePartnershipsScreen({
    super.key,
    required this.productName,
    required this.productSize,
    required this.productImage,
  });

  @override
  State<StorePartnershipsScreen> createState() =>
      _StorePartnershipsScreenState();
}

class _StorePartnershipsScreenState extends State<StorePartnershipsScreen> {
  String _resolveProductName(bool isEn) {
    if (widget.productName == 'Produit Démo' ||
        widget.productName == 'Demo Product') {
      return isEn ? 'Emerald Evening Gown' : 'Robe de Soirée Émeraude';
    }
    return widget.productName;
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (e) {
        if (mounted) {
          Clipboard.setData(ClipboardData(text: url));
          final isEn = LanguageService.instance.isEnglish;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEn
                  ? 'Link copied to clipboard: $url'
                  : 'Lien copié dans le presse-papier : $url'),
            ),
          );
        }
      }
    }
  }

  void _openPartnerBrand(String brandName, String url) {
    StorePartnershipService.instance.logBrandVisit(brandName: brandName, url: url);
    final isEn = LanguageService.instance.isEnglish;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
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
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brandName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        Text(
                          isEn
                              ? 'Official FitVisor Retail Partner'
                              : 'Partenaire Boutique Officiel FitVisor',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildPerkRow(
                      Icons.check_circle_rounded,
                      isEn
                          ? 'FitVisor In-Store Kiosk & Mirror Sync enabled'
                          : 'Borne & miroir connecté FitVisor synchronisés',
                    ),
                    const SizedBox(height: 8),
                    _buildPerkRow(
                      Icons.check_circle_rounded,
                      isEn
                          ? '48-hour free fitting room hold available'
                          : 'Réservation 48h gratuite en cabine disponible',
                    ),
                    const SizedBox(height: 8),
                    _buildPerkRow(
                      Icons.check_circle_rounded,
                      isEn
                          ? 'Instant 3D size recommendations on store items'
                          : 'Conseil taille 3D instantané sur les articles',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _launchExternalUrl(url);
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(
                    isEn
                        ? 'Visit $brandName Store'
                        : 'Visiter la boutique $brandName',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF172554),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerkRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  void _showRackScannerSheet(bool isEn) {
    StorePartnershipService.instance.logRackScan(
      productName: _resolveProductName(isEn),
      productSize: widget.productSize,
      productImage: widget.productImage,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _InStoreRackScannerSheet(
        productName: _resolveProductName(isEn),
        productSize: widget.productSize,
        productImage: widget.productImage,
        onReserveRequested: () {
          Navigator.pop(ctx);
          _showReserveSheet();
        },
      ),
    );
  }

  void _showExtensionSheet(bool isEn) {
    StorePartnershipService.instance
        .logExtensionActivity(action: 'viewed_extension_modal');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _BrowserExtensionSheet(
        isEn: isEn,
        onOpenStore: () {
          StorePartnershipService.instance
              .logExtensionActivity(action: 'open_chrome_store');
          _launchExternalUrl('https://chromewebstore.google.com');
        },
      ),
    );
  }

  void _showReserveSheet() {
    final isEn = LanguageService.instance.isEnglish;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReserveBottomSheet(
        productName: _resolveProductName(isEn),
        productSize: widget.productSize,
        productImage: widget.productImage,
      ),
    );
  }

  void _showKioskPassSheet(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final passCode =
        'FV-KIOSK-${(user?.id.replaceAll('-', '').substring(0, 6) ?? '892410').toUpperCase()}';
    StorePartnershipService.instance.logKioskPass(passCode: passCode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _KioskPassSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          appBar: _buildAppBar(isEn),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductStrip(isEn),
                const SizedBox(height: 24),
                Text(
                  isEn ? 'Partner Brands' : 'Marques partenaires',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 12),
                _buildPartnerBrands(),
                const SizedBox(height: 24),
                _buildScannerCard(isEn),
                const SizedBox(height: 16),
                _buildExtensionCard(isEn),
                const SizedBox(height: 16),
                _buildReserveCard(isEn),
                const SizedBox(height: 16),
                _buildQrCard(isEn),
                const SizedBox(height: 32),
                _buildFooterNote(isEn),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isEn) {
    return AppBar(
      backgroundColor: const Color(0xFFFAF9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF172554), size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              isEn ? 'Store Partnerships' : 'Partenariats Boutiques',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'PRO',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildDynamicUserAvatar(size: 34),
        ),
      ],
    );
  }

  Widget _buildProductStrip(bool isEn) {
    final displayName = _resolveProductName(isEn);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.productImage,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 44,
                height: 44,
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.checkroom_rounded,
                    size: 20, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$displayName · ${isEn ? 'Size' : 'Taille'} ${widget.productSize}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF172554),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerBrands() {
    final brands = [
      {'name': 'Zalando', 'url': 'https://www.zalando.com'},
      {'name': 'H&M', 'url': 'https://www2.hm.com'},
      {'name': 'Shein', 'url': 'https://www.shein.com'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: brands.map((b) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _openPartnerBrand(b['name']!, b['url']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      b['name']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_outward_rounded,
                        size: 13, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScannerCard(bool isEn) {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.document_scanner_outlined,
                    color: Color(0xFFF43F5E), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEn ? 'In-Store Scanner' : 'Scanner en magasin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? "AI scans clothing on the retail rack and detects in-stock sizes matching your 3D biometric profile."
                : "L'IA scanne les vêtements sur le rayon et détecte les tailles disponibles adaptées à votre morphologie 3D.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.checkroom_rounded,
                    color: Color(0xFFF43F5E), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn
                        ? "This item is available in size ${widget.productSize} and is an optimal match."
                        : "Ce vêtement est disponible en taille ${widget.productSize} et devrait vous aller.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: isEn ? 'Scan the rack' : 'Scanner le rayon',
            onTap: () => _showRackScannerSheet(isEn),
          ),
        ],
      ),
    );
  }

  Widget _buildExtensionCard(bool isEn) {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.extension_outlined,
                    color: Color(0xFFF43F5E), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEn ? 'Browser Extension' : 'Extension de navigateur',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? "On Zalando, Shein, Amazon: click any clothing and FitVisor shows how it looks on you."
                : "Sur Zalando, Shein, Amazon : cliquez sur un vêtement et FitVisor vous montre son rendu sur vous.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_rounded,
                  color: Color(0xFFF43F5E), size: 16),
              const SizedBox(width: 6),
              Text(
                isEn ? 'Available in your size' : 'Disponible dans votre taille',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF43F5E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: isEn ? "Get extension" : "Obtenir l'extension",
            isOutline: true,
            onTap: () => _showExtensionSheet(isEn),
          ),
        ],
      ),
    );
  }

  Widget _buildReserveCard(bool isEn) {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: Color(0xFFF43F5E), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEn ? 'Reserve In-Store' : 'Réserver en magasin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? "Does this item fit? Reserve it in store to try it on. Held for you in the fitting room with no upfront payment."
                : "Ce vêtement vous va-t-il ? Réservez-le en magasin pour l'essayer. Réservé en cabine d'essayage sans paiement immédiat.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: isEn ? 'Reserve in store' : 'Réserver en magasin',
            onTap: _showReserveSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(bool isEn) {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_2_rounded,
                    color: Color(0xFFF43F5E), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEn ? 'QR Code / FitVisor Kiosk' : 'Code QR / Borne FitVisor',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? "Scan this pass on smart screens and interactive mirrors in partner stores."
                : "Utilisez le code QR ou la borne FitVisor dans les magasins partenaires.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 14, color: Color(0xFF172554)),
                const SizedBox(width: 6),
                Text(
                  isEn
                      ? 'Stock and price updated 5 min ago'
                      : 'Stock et prix mis à jour il y a 5 min',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF172554),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label:
                isEn ? 'Open Digital Kiosk Pass' : 'Ouvrir Pass Borne Numérique',
            onTap: () => _showKioskPassSheet(context),
            isOutline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote(bool isEn) {
    return Center(
      child: Text(
        isEn
            ? "Purchases are finalized on partner websites or in-store."
            : "Les achats sont finalisés sur le site du partenaire ou en magasin.",
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    bool isOutline = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: isOutline
          ? OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF172554),
                side: const BorderSide(color: Color(0xFF172554), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE DYNAMIC USER AVATAR
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

// ─────────────────────────────────────────────────────────────────────────────
// IN-STORE RACK SCANNER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _InStoreRackScannerSheet extends StatefulWidget {
  final String productName;
  final String productSize;
  final String productImage;
  final VoidCallback onReserveRequested;

  const _InStoreRackScannerSheet({
    required this.productName,
    required this.productSize,
    required this.productImage,
    required this.onReserveRequested,
  });

  @override
  State<_InStoreRackScannerSheet> createState() =>
      _InStoreRackScannerSheetState();
}

class _InStoreRackScannerSheetState extends State<_InStoreRackScannerSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Auto-detect after 2 seconds
    Future.delayed(const Duration(milliseconds: 2100), () {
      if (mounted) {
        setState(() => _isScanned = true);
        _animController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.document_scanner_outlined,
                    color: Color(0xFFF43F5E), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn
                          ? 'In-Store Rack Scanner'
                          : 'Scanner de Rayon en Magasin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Text(
                      isEn
                          ? 'Point camera at any garment barcode or RFID tag'
                          : 'Pointez la caméra vers le code-barres ou antivol',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Scanner Viewfinder Area
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isScanned
                    ? const Color(0xFF10B981)
                    : const Color(0xFF3B82F6),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Image.asset(
                    widget.productImage,
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.checkroom_rounded,
                      size: 70,
                      color: Colors.white38,
                    ),
                  ),
                ),
                if (!_isScanned)
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Positioned(
                        top: 20 + (_animController.value * 150),
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF38BDF8)
                                    .withValues(alpha: 0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                Positioned(
                  bottom: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isScanned
                              ? Icons.check_circle_rounded
                              : Icons.sync_rounded,
                          size: 14,
                          color: _isScanned
                              ? const Color(0xFF34D399)
                              : const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isScanned
                              ? (isEn
                                  ? 'Garment identified'
                                  : 'Vêtement identifié')
                              : (isEn
                                  ? 'Analyzing rack item...'
                                  : 'Analyse du portant en cours...'),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isScanned) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF172554),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF7EC),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isEn ? '98% 3D Fit Match' : '98% Compatibilité 3D',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF03543F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${isEn ? "Zalando Paris Hub · Rack #4 (Aisle B)" : "Zalando Paris Hub · Portant #4 (Allée B)"}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '✨ ${isEn ? "Recommended size for your body measurements: " : "Taille recommandée pour vos mensurations : "} ${widget.productSize}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF172554),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: widget.onReserveRequested,
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: Text(
                  isEn ? 'Reserve in store' : 'Réserver en magasin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  launchUrl(Uri.parse('https://www.zalando.com'),
                      mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(
                  isEn ? 'Open Zalando Store' : 'Ouvrir sur le site Zalando',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF172554),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(color: Color(0xFFF43F5E)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BROWSER EXTENSION SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _BrowserExtensionSheet extends StatelessWidget {
  final bool isEn;
  final VoidCallback onOpenStore;

  const _BrowserExtensionSheet({
    required this.isEn,
    required this.onOpenStore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.extension_rounded,
                    color: Color(0xFFF43F5E), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn
                          ? 'FitVisor Browser Extension'
                          : 'Extension de Navigateur FitVisor',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Text(
                      isEn
                          ? 'Works on Chrome, Edge & Safari'
                          : 'Compatible Chrome, Edge et Safari',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'How it works:' : 'Comment ça fonctionne :',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 10),
                _stepRow(
                  '1',
                  isEn
                      ? 'Add the FitVisor extension to your browser.'
                      : 'Ajoutez l\'extension FitVisor à votre navigateur.',
                ),
                const SizedBox(height: 8),
                _stepRow(
                  '2',
                  isEn
                      ? 'Browse clothing on Zalando, Shein, or ASOS.'
                      : 'Parcourez vos vêtements sur Zalando, Shein ou ASOS.',
                ),
                const SizedBox(height: 8),
                _stepRow(
                  '3',
                  isEn
                      ? 'Click the FitVisor badge on any product page to see your 3D digital twin dressed in the outfit.'
                      : 'Cliquez sur le badge FitVisor pour voir votre avatar 3D porter le vêtement.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    StorePartnershipService.instance
                        .logExtensionActivity(action: 'copy_link');
                    Clipboard.setData(const ClipboardData(
                        text: 'https://fitvisor.app/extension'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEn
                            ? 'Extension link copied!'
                            : 'Lien de l\'extension copié !'),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF172554),
                    side:
                        const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isEn ? 'Copy Link' : 'Copier le lien',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpenStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF43F5E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    isEn ? 'Get Extension' : 'Installer',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF475569),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESERVE IN-STORE BOTTOM SHEET (100% STRICT LOCALIZATION & PRODUCTION READY)
// ─────────────────────────────────────────────────────────────────────────────
class ReserveBottomSheet extends StatefulWidget {
  final String productName;
  final String productSize;
  final String productImage;

  const ReserveBottomSheet({
    super.key,
    required this.productName,
    required this.productSize,
    required this.productImage,
  });

  @override
  State<ReserveBottomSheet> createState() => _ReserveBottomSheetState();
}

class _ReserveBottomSheetState extends State<ReserveBottomSheet> {
  List<PartnerStoreModel> _stores = [];
  PartnerStoreModel? _selectedStore;
  String _selectedSize = 'M';
  bool _isLoading = true;
  bool _isSubmitting = false;
  StoreReservationModel? _reservation;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.productSize.isNotEmpty ? widget.productSize : 'M';
    _loadStores();
  }

  Future<void> _loadStores() async {
    final stores = await StorePartnershipService.instance.getPartnerStores();
    if (!mounted) return;
    setState(() {
      _stores = stores;
      if (stores.isNotEmpty) {
        _selectedStore = stores.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _submitReservation() async {
    if (_selectedStore == null) return;
    setState(() => _isSubmitting = true);

    try {
      final res = await StorePartnershipService.instance.createReservation(
        storeName: _selectedStore!.storeName,
        productName: widget.productName,
        productSize: _selectedSize,
        productImage: widget.productImage,
      );

      if (mounted) {
        setState(() {
          _reservation = res;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reservation error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    final sizeOptions = _selectedStore?.availableSizes.isNotEmpty == true
        ? _selectedStore!.availableSizes
        : ['XS', 'S', 'M', 'L', 'XL'];

    if (!sizeOptions.contains(_selectedSize) && sizeOptions.isNotEmpty) {
      _selectedSize = sizeOptions.contains('M') ? 'M' : sizeOptions.first;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: Color(0xFFF43F5E), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn
                          ? 'Reserve In-Store for Try-On'
                          : 'Réserver en magasin pour essayage',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Text(
                      isEn
                          ? 'Held in fitting room for 48h · Free'
                          : 'Mis de côté en cabine 48h · Gratuit',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFF43F5E)),
              ),
            )
          else if (_reservation != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDEF7EC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF31C48D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF03543F), size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isEn
                              ? 'Reservation Confirmed for 48h!'
                              : 'Réservation Confirmée pour 48h !',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF03543F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBCF0DA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? 'PICKUP CODE' : 'CODE DE RETRAIT',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF03543F),
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _reservation!.reservationCode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF172554),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              color: Color(0xFF03543F), size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: _reservation!.reservationCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEn
                                    ? 'Code copied to clipboard!'
                                    : 'Code copié dans le presse-papier !'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '📍 ${_reservation!.storeName}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF046C4E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '👗 ${widget.productName} · ${isEn ? 'Size' : 'Taille'} ${_reservation!.productSize}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF046C4E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isEn
                          ? 'ℹ️ No advance payment charged. Pay in store only if you decide to buy.'
                          : 'ℹ️ Aucun paiement débité. Vous ne payez en caisse que si vous décidez d\'acheter.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF046C4E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEn ? 'Done' : 'Terminer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Garment preview strip
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.productImage,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 44,
                        height: 44,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.checkroom, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        Text(
                          '${isEn ? 'Target Size' : 'Taille cible'}: ${widget.productSize}',
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
            const SizedBox(height: 16),
            Text(
              isEn
                  ? 'Select a partner store'
                  : 'Sélectionner une boutique partenaire',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<PartnerStoreModel>(
                  isExpanded: true,
                  value: _selectedStore,
                  icon: const Icon(Icons.expand_more_rounded),
                  items: _stores
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.storeName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF172554),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedStore = v);
                    }
                  },
                ),
              ),
            ),
            if (_selectedStore != null) ...[
              const SizedBox(height: 6),
              Text(
                '📍 ${_selectedStore!.address}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              isEn ? 'Fitting Size' : 'Taille d\'essai',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: sizeOptions.contains(_selectedSize)
                      ? _selectedSize
                      : (sizeOptions.isNotEmpty ? sizeOptions.first : 'M'),
                  icon: const Icon(Icons.expand_more_rounded),
                  items: sizeOptions
                      .map((sz) => DropdownMenuItem(
                            value: sz,
                            child: Text(
                              '${isEn ? 'Size' : 'Taille'} $sz',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF172554),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedSize = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFFCA5A5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEn
                            ? 'Confirm In-Store Reservation'
                            : 'Confirmer la réservation',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIGITAL KIOSK PASS SHEET (DYNAMIC USER & 3D DATA)
// ─────────────────────────────────────────────────────────────────────────────
class _KioskPassSheet extends StatelessWidget {
  const _KioskPassSheet();

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name']?.toString() ??
        (user?.email != null ? user!.email!.split('@').first : null) ??
        (isEn ? 'FitVisor VIP Member' : 'Membre VIP FitVisor');
    final passCode =
        'FV-KIOSK-${(user?.id.replaceAll('-', '').substring(0, 6) ?? '892410').toUpperCase()}';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded,
                    color: Color(0xFFF43F5E), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'FitVisor Kiosk Pass' : 'Pass Borne FitVisor',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Text(
                      isEn
                          ? 'Ready for partner stores'
                          : 'Prêt pour boutiques partenaires',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stylized Pass Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildDynamicUserAvatar(
                            size: 38, borderWidth: 2), // Dynamic user picture!
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isEn
                                  ? '3D Profile Active'
                                  : 'Profil 3D Synchronisé',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'KIOSK PASS',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Real Scannable QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        alignment: Alignment.center,
                        child: Image.network(
                          'https://api.qrserver.com/v1/create-qr-code/?size=300x300&margin=4&data=${Uri.encodeComponent('https://www.zalando.com?fitvisor_pass=$passCode&user=${Uri.encodeComponent(userName)}')}',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF172554),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const _RealisticQrPlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        passCode,
                        style: GoogleFonts.spaceMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEn
                            ? 'Point any phone camera to scan'
                            : 'Scannez avec l\'appareil photo d\'un téléphone',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn
                          ? 'Valid at Zalando, H&M, Zara, Balmain'
                          : 'Valable chez Zalando, H&M, Zara, Balmain',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Test Simulate Kiosk Mirror Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                _showKioskSimulationModal(context, isEn, userName, passCode);
              },
              icon: const Icon(Icons.touch_app_rounded, size: 18),
              label: Text(
                isEn
                    ? 'Simulate In-Store Kiosk Scan (Test Mirror)'
                    : 'Tester la Borne Magasin (Simulation Miroir)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn
                        ? 'Holding your phone up to any FitVisor smart mirror or kiosk at Zalando, H&M, or Zara instantly loads your 3D biometric avatar and sizes.'
                        : 'Présentez ce QR code devant la caméra de la borne FitVisor en boutique pour charger instantanément vos mensurations 3D.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF475569),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF172554),
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEn ? 'Close' : 'Fermer',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showKioskSimulationModal(
    BuildContext context, bool isEn, String userName, String passCode) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
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
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDEF7EC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF03543F), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn
                            ? 'Zalando Kiosk Connected!'
                            : 'Borne Zalando Connectée !',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      Text(
                        isEn
                            ? 'Smart mirror synced with pass $passCode'
                            : 'Miroir connecté synchronisé avec le pass $passCode',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ZALANDO PARIS HUB · BORNE #3',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'LIVE MIRROR',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildDynamicUserAvatar(size: 48, borderWidth: 2),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isEn
                                  ? '3D Measurements Loaded (98% Match)'
                                  : 'Mensurations 3D Chargées (98% Match)',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  launchUrl(Uri.parse('https://www.zalando.com'),
                      mode: LaunchMode.externalApplication);
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(
                  isEn
                      ? 'Open Zalando Official Store'
                      : 'Ouvrir la Boutique Zalando',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF172554),
                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEn ? 'Close' : 'Fermer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
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
}

class _RealisticQrPlaceholder extends StatelessWidget {
  const _RealisticQrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      color: Colors.white,
      padding: const EdgeInsets.all(4),
      child: CustomPaint(
        painter: _QrPatternPainter(),
      ),
    );
  }
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    void drawEye(double left, double top) {
      final outer = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, 36, 36),
        const Radius.circular(5),
      );
      final innerHole = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 6, top + 6, 24, 24),
        const Radius.circular(3),
      );
      final centerDot = RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 11, top + 11, 14, 14),
        const Radius.circular(2),
      );

      final path = Path()
        ..addRRect(outer)
        ..addRRect(innerHole);
      path.fillType = PathFillType.evenOdd;
      canvas.drawPath(path, paint);
      canvas.drawRRect(centerDot, paint);
    }

    drawEye(2, 2);
    drawEye(size.width - 38, 2);
    drawEye(2, size.height - 38);

    const cellSize = 6.0;
    final cols = (size.width / cellSize).floor();
    final rows = (size.height / cellSize).floor();

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if ((r < 7 && c < 7) ||
            (r < 7 && c > cols - 8) ||
            (r > rows - 8 && c < 7)) {
          continue;
        }
        if ((r * 7 + c * 13) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize + 1, r * cellSize + 1, cellSize - 1.5,
                cellSize - 1.5),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
