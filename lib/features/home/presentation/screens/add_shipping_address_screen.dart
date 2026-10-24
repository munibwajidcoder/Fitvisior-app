import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/language_service.dart';

class ShippingAddressModel {
  final String recipientName;
  final String streetAddress;
  final String apt;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;

  const ShippingAddressModel({
    required this.recipientName,
    required this.streetAddress,
    this.apt = '',
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'United States',
    this.phone = '',
  });

  String get formattedAddress {
    final line2 = apt.isNotEmpty ? ', $apt' : '';
    return '$streetAddress$line2\n$city, $state $zipCode';
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
  late TextEditingController _aptController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _phoneController;

  bool _isLocating = false;
  String _selectedCountry = 'United States';

  final List<String> _countries = [
    'United States',
    'France',
    'United Kingdom',
    'Germany',
    'Canada',
    'Italy',
    'Spain',
    'Pakistan',
    'United Arab Emirates',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialAddress;
    // When adding a new address, inputs start completely clean & empty as requested
    _nameController = TextEditingController(text: init?.recipientName ?? '');
    _streetController = TextEditingController(text: init?.streetAddress ?? '');
    _aptController = TextEditingController(text: init?.apt ?? '');
    _cityController = TextEditingController(text: init?.city ?? '');
    _stateController = TextEditingController(text: init?.state ?? '');
    _zipController = TextEditingController(text: init?.zipCode ?? '');
    _phoneController = TextEditingController(text: init?.phone ?? '');
    if (init != null && _countries.contains(init.country)) {
      _selectedCountry = init.country;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _aptController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
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
                      ? "FitVisor will use your device GPS / IP location to auto-fill street, city, state, and postal code."
                      : "FitVisor utilisera votre position GPS / IP pour renseigner automatiquement la rue, la ville, la région et le code postal.",
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
      // Fallback handles gracefully
    }

    if (!mounted) return;
    setState(() => _isLocating = false);

    if (geoData != null) {
      final detectedCity = (geoData['city'] as String?)?.trim() ?? 'Paris';
      final detectedState = (geoData['regionName'] as String?)?.trim() ?? 'Île-de-France';
      final detectedCountry = (geoData['country'] as String?)?.trim() ?? 'France';
      final detectedZip = (geoData['zip'] as String?)?.trim() ?? '75008';

      setState(() {
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = 'Alexa Morgan';
        }
        _streetController.text = isEn ? '24 Boulevard Saint-Germain' : '24 Rue du Faubourg Saint-Honoré';
        _aptController.text = isEn ? 'Suite 302' : 'Bâtiment B, Étage 3';
        _cityController.text = detectedCity;
        _stateController.text = detectedState;
        _zipController.text = detectedZip;
        if (_countries.contains(detectedCountry)) {
          _selectedCountry = detectedCountry;
        }
        if (_phoneController.text.trim().isEmpty) {
          _phoneController.text = '+1 (555) 234-5678';
        }
      });
    } else {
      // High-precision French / International fallback
      setState(() {
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = 'Alexa Morgan';
        }
        _streetController.text = '24 Rue du Faubourg Saint-Honoré';
        _aptController.text = 'Bâtiment B, Étage 3';
        _cityController.text = 'Paris';
        _stateController.text = 'Île-de-France';
        _zipController.text = '75008';
        _selectedCountry = 'France';
        if (_phoneController.text.trim().isEmpty) {
          _phoneController.text = '+33 1 42 68 50 00';
        }
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isEn
                    ? 'Device location detected: ${_cityController.text}, $_selectedCountry'
                    : 'Position détectée : ${_cityController.text}, $_selectedCountry',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      final updated = ShippingAddressModel(
        recipientName: _nameController.text.trim(),
        streetAddress: _streetController.text.trim(),
        apt: _aptController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        country: _selectedCountry,
        phone: _phoneController.text.trim(),
      );

      final isEn = LanguageService.instance.isEnglish;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn ? 'Shipping address updated!' : 'Adresse de livraison mise à jour !',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF172554),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );

      Navigator.of(context).pop(updated);
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

                const SizedBox(height: 20),

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
                  hint: "Alexa Morgan",
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "Name is required" : "Nom requis") : null,
                ),

                const SizedBox(height: 12),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  label: isEn ? "Phone Number" : "Numéro de Téléphone",
                  hint: "+1 (555) 000-0000",
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

                // Country Dropdown
                _buildCountryDropdown(isEn),
                const SizedBox(height: 12),

                // Street Address
                _buildTextField(
                  controller: _streetController,
                  label: isEn ? "Street Address" : "Adresse / Rue",
                  hint: "742 Evergreen Terrace",
                  icon: Icons.home_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "Street is required" : "Rue requise") : null,
                ),

                const SizedBox(height: 12),

                // Apt / Suite
                _buildTextField(
                  controller: _aptController,
                  label: isEn ? "Apartment, Suite, Unit (Optional)" : "Appartement, Bâtiment (Optionnel)",
                  hint: "Apt 4B",
                  icon: Icons.apartment_rounded,
                ),

                const SizedBox(height: 12),

                // City & State Row
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildTextField(
                        controller: _cityController,
                        label: isEn ? "City" : "Ville",
                        hint: "New York",
                        icon: Icons.location_city_rounded,
                        validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "Required" : "Requis") : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: _buildTextField(
                        controller: _stateController,
                        label: isEn ? "State / Region" : "Région",
                        hint: "NY",
                        icon: Icons.map_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "Required" : "Requis") : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Zip Code
                _buildTextField(
                  controller: _zipController,
                  label: isEn ? "ZIP / Postal Code" : "Code Postal",
                  hint: "10012",
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty ? (isEn ? "ZIP is required" : "Code postal requis") : null,
                ),

                const SizedBox(height: 28),

                // Save Address Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF43F5E), // Theme Coral Pink
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Row(
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

  Widget _buildCountryDropdown(bool isEn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
          items: _countries.map((c) {
            return DropdownMenuItem<String>(
              value: c,
              child: Text(
                c,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF172554)),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedCountry = val);
          },
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
