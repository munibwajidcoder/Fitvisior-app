import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/language_service.dart';
import '../../data/address_service.dart';

class ShippingAddressModel {
  final String recipientName;
  final String streetAddress;
  final String apt;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;
  final String addressType; // 'home', 'office', 'other'
  final String deliveryInstructions;

  const ShippingAddressModel({
    required this.recipientName,
    required this.streetAddress,
    this.apt = '',
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = '',
    this.phone = '',
    this.addressType = 'home',
    this.deliveryInstructions = '',
  });

  String get formattedAddress {
    final line2 = apt.isNotEmpty ? ', $apt' : '';
    final countryPart = country.isNotEmpty ? ', $country' : '';
    final line1 = '$streetAddress$line2'.trim();
    final line2Text = '$zipCode $city$countryPart'.trim();
    if (line1.isEmpty) return line2Text;
    if (line2Text.isEmpty) return line1;
    return '$line1\n$line2Text';
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient_name': recipientName,
      'street_address': streetAddress,
      'apt_suite': apt,
      'city': city,
      'state_province': state,
      'postal_code': zipCode,
      'country': country,
      'phone_number': phone,
      'address_type': addressType,
      'delivery_instructions': deliveryInstructions,
    };
  }

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      recipientName: json['recipient_name'] ?? '',
      streetAddress: json['street_address'] ?? '',
      apt: json['apt_suite'] ?? json['apt'] ?? '',
      city: json['city'] ?? '',
      state: json['state_province'] ?? json['state'] ?? '',
      zipCode: json['postal_code'] ?? json['zipCode'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone_number'] ?? json['phone'] ?? '',
      addressType: json['address_type'] ?? 'home',
      deliveryInstructions: json['delivery_instructions'] ?? '',
    );
  }
}

class AddShippingAddressScreen extends StatefulWidget {
  final ShippingAddressModel? initialAddress;

  const AddShippingAddressScreen({super.key, this.initialAddress});

  @override
  State<AddShippingAddressScreen> createState() => _AddShippingAddressScreenState();
}

class _AddShippingAddressScreenState extends State<AddShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _phoneController;
  late TextEditingController _addressTypeController;

  bool _isLocating = false;
  bool _isSaving = false;
  String _selectedCountry = '';

  @override
  void initState() {
    super.initState();
    final init = widget.initialAddress;
    // Fields start completely clean and empty as requested
    _nameController = TextEditingController(text: init?.recipientName ?? '');
    _streetController = TextEditingController(text: init?.streetAddress ?? '');
    _cityController = TextEditingController(text: init?.city ?? '');
    _stateController = TextEditingController(text: init?.state ?? '');
    _zipController = TextEditingController(text: init?.zipCode ?? '');
    _phoneController = TextEditingController(text: init?.phone ?? '');
    _addressTypeController = TextEditingController(text: init?.addressType ?? '');
    _selectedCountry = init?.country ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _addressTypeController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveLocation() async {
    final isEn = LanguageService.instance.isEnglish;

    // Mobile device location permission & activation prompt
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Color(0xFFF43F5E), size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  isEn ? "Turn On Device Location?" : "Activer la Localisation de l'Appareil ?",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? "FitVisor will detect your location to automatically fill your street address, city, state, and postal code."
                      : "FitVisor détectera votre position pour renseigner automatiquement votre adresse, ville, région et code postal.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isEn ? "Cancel" : "Annuler",
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF172554),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isEn ? "Turn On & Detect" : "Activer & Détecter",
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLocating = true);

    Map<String, dynamic>? geoData;
    String? streetFound;

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final req = await client.getUrl(Uri.parse('http://ip-api.com/json'));
      final resp = await req.close();
      if (resp.statusCode == 200) {
        final body = await resp.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['status'] == 'success') {
          geoData = json;
        }
      }
    } catch (_) {
      // Graceful fallback
    }

    // Precise reverse geocode using lat/lon from detected position
    if (geoData != null && geoData['lat'] != null && geoData['lon'] != null) {
      try {
        final lat = geoData['lat'];
        final lon = geoData['lon'];
        final geoClient = HttpClient();
        geoClient.connectionTimeout = const Duration(seconds: 4);
        final geoReq = await geoClient.getUrl(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=18&addressdetails=1',
        ));
        geoReq.headers.set('User-Agent', 'FitVisorApp/1.0 (fitness@fitvisor.com)');
        final geoResp = await geoReq.close();
        if (geoResp.statusCode == 200) {
          final geoBody = await geoResp.transform(utf8.decoder).join();
          final parsed = jsonDecode(geoBody) as Map<String, dynamic>;
          final addr = parsed['address'] as Map<String, dynamic>?;
          if (addr != null) {
            final road = addr['road'] as String?;
            final houseNumber = addr['house_number'] as String?;
            final suburb = (addr['suburb'] ?? addr['neighbourhood'] ?? addr['residential'] ?? addr['quarter'] ?? addr['city_district']) as String?;
            final parts = [houseNumber, road, suburb].where((p) => p != null && p.trim().isNotEmpty).toList();
            if (parts.isNotEmpty) {
              streetFound = parts.join(', ');
            }
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _isLocating = false);

    // Auto-fill fields with detected location
    setState(() {
      final city = (geoData?['city'] as String?)?.trim();
      final region = (geoData?['regionName'] as String?)?.trim();
      final zip = (geoData?['zip'] as String?)?.trim();
      final country = (geoData?['country'] as String?)?.trim();

      _addressTypeController.text = isEn ? 'Home' : 'Domicile';

      if (streetFound != null && streetFound.trim().isNotEmpty) {
        _streetController.text = streetFound;
      } else if (city != null && city.isNotEmpty) {
        _streetController.text = 'Main Street, $city';
      }

      if (city != null && city.isNotEmpty) {
        _cityController.text = city;
      }
      if (region != null && region.isNotEmpty) {
        _stateController.text = region;
      }
      if (zip != null && zip.isNotEmpty) {
        _zipController.text = zip;
      }
      if (country != null && country.isNotEmpty) {
        _selectedCountry = country;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEn
                    ? 'Location detected successfully!'
                    : 'Position détectée avec succès !',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveAddress() async {
    if (_isSaving) return;
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      try {
        final isEn = LanguageService.instance.isEnglish;
        final typeText = _addressTypeController.text.trim();
        final effectiveType = typeText.isEmpty ? (isEn ? 'Home' : 'Domicile') : typeText;

        final updated = ShippingAddressModel(
          recipientName: _nameController.text.trim(),
          streetAddress: _streetController.text.trim(),
          apt: '',
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipCode: _zipController.text.trim(),
          country: _selectedCountry.isNotEmpty ? _selectedCountry : 'Pakistan',
          phone: _phoneController.text.trim(),
          addressType: effectiveType,
          deliveryInstructions: '',
        );

        await AddressService.instance.saveAddress(updated);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn ? 'Shipping address saved!' : 'Adresse de livraison enregistrée !',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF172554),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pop(updated);
      } catch (_) {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmAndDeleteAddress() async {
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
      Navigator.of(context).pop('deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageService.instance.isEnglish;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF172554)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.initialAddress == null
              ? (isEn ? "Add Delivery Address" : "Ajouter une Adresse")
              : (isEn ? "Edit Shipping Address" : "Modifier l'Adresse"),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.initialAddress != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
              tooltip: isEn ? "Delete Address" : "Supprimer l'Adresse",
              onPressed: _confirmAndDeleteAddress,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Geo-location Action Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLocating
                            ? const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Color(0xFFF43F5E),
                                  ),
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, color: Color(0xFFF43F5E), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? "Use Current Location" : "Utiliser la Position Actuelle",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF172554),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isEn ? "Auto-fill address using GPS" : "Remplir l'adresse via GPS",
                              style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isLocating ? null : _fetchLiveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF172554),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isEn ? "Detect" : "Détecter",
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  isEn ? "Contact Information" : "Coordonnées",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 10),

                // Full Name
                _buildTextField(
                  controller: _nameController,
                  label: isEn ? "Full Name" : "Nom Complet",
                  hint: isEn ? "e.g. Marie Laurent" : "Ex. Marie Laurent",
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "Name is required" : "Nom requis") : null,
                ),

                const SizedBox(height: 12),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  label: isEn ? "Phone Number" : "Numéro de Téléphone",
                  hint: "+33 6 12 34 56 78",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 20),

                Text(
                  isEn ? "Delivery Address" : "Adresse de Livraison",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 10),

                // Address Type / Title
                _buildTextField(
                  controller: _addressTypeController,
                  label: isEn ? "Address Type" : "Type d'Adresse",
                  hint: isEn ? "e.g. Home or Office" : "Ex. Domicile ou Bureau",
                  icon: Icons.bookmark_border_rounded,
                ),

                const SizedBox(height: 12),

                // Street Address
                _buildTextField(
                  controller: _streetController,
                  label: isEn ? "Street Address" : "Adresse de la Rue",
                  hint: isEn ? "Enter Street Address" : "Entrez l'adresse de la rue",
                  icon: Icons.home_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "Street is required" : "Rue requise") : null,
                ),

                const SizedBox(height: 12),

                // City
                _buildTextField(
                  controller: _cityController,
                  label: isEn ? "City" : "Ville",
                  hint: isEn ? "Enter City" : "Entrez la ville",
                  icon: Icons.location_city_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "City is required" : "Ville requise") : null,
                ),

                const SizedBox(height: 12),

                // State
                _buildTextField(
                  controller: _stateController,
                  label: isEn ? "State / Region" : "Région / État",
                  hint: isEn ? "Enter State" : "Entrez la région / état",
                  icon: Icons.map_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "State is required" : "Région requise") : null,
                ),

                const SizedBox(height: 12),

                // Zip Code
                _buildTextField(
                  controller: _zipController,
                  label: isEn ? "Zip Code" : "Code Postal",
                  hint: isEn ? "Enter Zip Code" : "Entrez le code postal",
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "Zip code is required" : "Code postal requis") : null,
                ),

                const SizedBox(height: 28),

                // Save Address Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF43F5E), // Theme Coral Pink
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFFDA4AF),
                      elevation: 3,
                      shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isEn ? "Save & Use Address" : "Enregistrer et Utiliser l'Adresse",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF172554)),
        decoration: InputDecoration(
          icon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B)),
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E1)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
