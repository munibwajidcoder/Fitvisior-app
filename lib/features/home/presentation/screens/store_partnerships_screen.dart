import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'live_ar_mirror_screen.dart';
import '../../../../core/localization/language_service.dart';

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
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showReserveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ReserveBottomSheet(),
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

  Widget _buildProductStrip(bool isEn) {
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
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 40,
                height: 40,
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.checkroom_rounded,
                    size: 20, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${widget.productName} · ${isEn ? 'Size' : 'Taille'} ${widget.productSize}',
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
              onTap: () => _launchUrl(b['url']!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                alignment: Alignment.center,
                child: Text(
                  b['name']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
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
                ? "AI scans clothing on the rack and shows you what fits."
                : "L'IA scanne les vêtements sur le rayon et vous montre ce qui vous va.",
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
                        ? "This item is available in size ${widget.productSize} and should fit you."
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveArMirrorScreen()),
              );
            },
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
            onTap: () => _launchUrl('https://fitvisor.app/extension'),
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
                ? "Does this item fit? Reserve it in store to try it on. Express delivery if the item doesn't suit you."
                : "Ce vêtement vous va-t-il ? Réservez-le en magasin pour l'essayer. Livraison express si l'article ne vous convient pas.",
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
                ? "Use the QR code or FitVisor kiosk in partner stores."
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
                  isEn ? 'Stock and price updated 5 min ago' : 'Stock et prix mis à jour il y a 5 min',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF172554),
                  ),
                ),
              ],
            ),
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

class ReserveBottomSheet extends StatefulWidget {
  const ReserveBottomSheet({super.key});

  @override
  State<ReserveBottomSheet> createState() => _ReserveBottomSheetState();
}

class _ReserveBottomSheetState extends State<ReserveBottomSheet> {
  String _selectedStore = 'Zalando Paris (2.4 km)';
  String _selectedSize = 'Taille M';
  bool _reserved = false;

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;
    final sizeOptions = isEn
        ? ['Size S', 'Size M', 'Size L']
        : ['Taille S', 'Taille M', 'Taille L'];
    if (!_selectedSize.contains(isEn ? 'Size' : 'Taille')) {
      _selectedSize = isEn ? 'Size M' : 'Taille M';
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
          Text(
            isEn ? 'Reserve In-Store' : 'Réserver en magasin',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 24),
          if (_reserved) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDEF7EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF31C48D)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF03543F), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEn ? 'Reserved. Try it on in-store.' : 'Réservé. Essayez-le en magasin.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF03543F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                  isEn ? 'Close' : 'Fermer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              isEn ? 'Select a store' : 'Sélectionner un magasin',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedStore,
                  icon: const Icon(Icons.expand_more_rounded),
                  items: ['Zalando Paris (2.4 km)', 'H&M Champs-Élysées (3.1 km)']
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: GoogleFonts.inter(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStore = v!),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEn ? 'Size' : 'Taille',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: sizeOptions.contains(_selectedSize) ? _selectedSize : sizeOptions[1],
                  icon: const Icon(Icons.expand_more_rounded),
                  items: sizeOptions
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e,
                                style: GoogleFonts.inter(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSize = v!),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => setState(() => _reserved = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEn ? 'Confirm Reservation' : 'Confirmer la réservation',
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
