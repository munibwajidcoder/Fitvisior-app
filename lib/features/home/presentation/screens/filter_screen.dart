import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/product_service.dart';
import '../../../../core/localization/language_service.dart';

class FilterCriteria {
  final Set<String> categories;
  final Set<String> silhouettes;
  final Set<String> fabrics;
  final Set<String> designers;
  final double minPrice;
  final double maxPrice;
  final bool highMatchOnly;
  // New simple filters
  final Set<String> brands;
  final Set<String> sizes;
  final Set<String> colours;
  final String fitLevel; // '', '90', '95', '98'

  const FilterCriteria({
    this.categories = const {},
    this.silhouettes = const {},
    this.fabrics = const {},
    this.designers = const {},
    this.minPrice = 0,
    this.maxPrice = 99999,
    this.highMatchOnly = false,
    this.brands = const {},
    this.sizes = const {},
    this.colours = const {},
    this.fitLevel = '',
  });

  bool get isEmpty =>
      categories.isEmpty &&
      silhouettes.isEmpty &&
      fabrics.isEmpty &&
      designers.isEmpty &&
      brands.isEmpty &&
      sizes.isEmpty &&
      colours.isEmpty &&
      fitLevel.isEmpty &&
      !highMatchOnly;
}

class FilterScreen extends StatefulWidget {
  final FilterCriteria? initialFilters;
  final List<ProductModel>? allProducts;
  const FilterScreen({super.key, this.initialFilters, this.allProducts});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // ── Brand ─────────────────────────────────────────────────────────
  final List<String> _brandsList = [
    'Balmain',
    'The Row',
    'Bottega Veneta',
    'Saint Laurent',
    'Jacquemus',
    'Loewe',
    'Valentino',
    'Celine',
  ];
  final Set<String> _selectedBrands = {};

  // ── Size ──────────────────────────────────────────────────────────
  final List<String> _sizesList = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final Set<String> _selectedSizes = {};

  // ── Colour ────────────────────────────────────────────────────────
  final List<_ColourOption> _coloursList = [
    _ColourOption(name: 'Noir', color: const Color(0xFF1C1C1E)),
    _ColourOption(name: 'Blanc', color: const Color(0xFFF5F5F5)),
    _ColourOption(name: 'Beige', color: const Color(0xFFD4B896)),
    _ColourOption(name: 'Bleu marine', color: const Color(0xFF172554)),
    _ColourOption(name: 'Rouge', color: const Color(0xFFE11D48)),
    _ColourOption(name: 'Marron', color: const Color(0xFF92400E)),
    _ColourOption(name: 'Vert', color: const Color(0xFF166534)),
    _ColourOption(name: 'Gris', color: const Color(0xFF94A3B8)),
    _ColourOption(name: 'Camel', color: const Color(0xFFC8924D)),
    _ColourOption(name: 'Rose', color: const Color(0xFFFDA4AF)),
  ];
  final Set<String> _selectedColours = {};

  // ── Fit ───────────────────────────────────────────────────────────
  String _selectedFit = ''; // '', '90', '95', '98'
  final List<_FitOption> _fitOptions = [
    _FitOption(label: 'Tout ajustement', value: '', subtitle: 'Afficher tous les articles'),
    _FitOption(label: 'Ajustement 90%+', value: '90', subtitle: 'Bonne correspondance morphologique'),
    _FitOption(label: 'Ajustement 95%+', value: '95', subtitle: 'Très haute précision'),
    _FitOption(label: 'Ajustement 98%+', value: '98', subtitle: 'Ajustement sur-mesure parfait'),
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilters;
    if (f != null) {
      _selectedBrands.addAll(f.brands);
      _selectedSizes.addAll(f.sizes);
      _selectedColours.addAll(f.colours);
      _selectedFit = f.fitLevel;
    }
  }

  int get _activeCount =>
      _selectedBrands.length +
      _selectedSizes.length +
      _selectedColours.length +
      (_selectedFit.isEmpty ? 0 : 1);

  FilterCriteria _buildCriteria() {
    return FilterCriteria(
      brands: Set.from(_selectedBrands),
      sizes: Set.from(_selectedSizes),
      colours: Set.from(_selectedColours),
      fitLevel: _selectedFit,
      highMatchOnly: _selectedFit == '95' || _selectedFit == '98',
    );
  }

  void _resetAll() {
    setState(() {
      _selectedBrands.clear();
      _selectedSizes.clear();
      _selectedColours.clear();
      _selectedFit = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ───────────────────────────────────────────────
            _buildTopBar(),

            // ── ACTIVE FILTER CHIP ────────────────────────────────────
            if (_activeCount > 0) _buildActiveChip(),

            // ── FILTER SECTIONS (scrollable) ──────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionTitle(tr('filters_section_brand')),
                  _buildBrandSection(),
                  _buildDivider(),
                  _buildSectionTitle(tr('filters_section_size')),
                  _buildSizeSection(),
                  _buildDivider(),
                  _buildSectionTitle(tr('filters_section_colour')),
                  _buildColourSection(),
                  _buildDivider(),
                  _buildSectionTitle(tr('filters_section_fit')),
                  _buildFitSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      // ── BOTTOM APPLY BUTTON ───────────────────────────────────────
      bottomNavigationBar: _buildApplyBar(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF172554)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            tr('filters_title'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _resetAll,
            child: Text(
              tr('filters_clear_all'),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFE11D48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveChip() {
    final isFr = LanguageService.instance.isFrench;
    final text = isFr
        ? '$_activeCount filtre${_activeCount > 1 ? 's' : ''} actif${_activeCount > 1 ? 's' : ''}'
        : '$_activeCount active filter${_activeCount > 1 ? 's' : ''}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFEFF6FF),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_rounded, size: 14, color: Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF172554),
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
    );
  }

  // ── BRAND ─────────────────────────────────────────────────────────
  Widget _buildBrandSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _brandsList.map((brand) {
          final selected = _selectedBrands.contains(brand);
          return GestureDetector(
            onTap: () => setState(() {
              if (selected) {
                _selectedBrands.remove(brand);
              } else {
                _selectedBrands.add(brand);
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF172554)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: selected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Text(
                brand,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── SIZE ──────────────────────────────────────────────────────────
  Widget _buildSizeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _sizesList.map((size) {
          final selected = _selectedSizes.contains(size);
          return GestureDetector(
            onTap: () => setState(() {
              if (selected) {
                _selectedSizes.remove(size);
              } else {
                _selectedSizes.add(size);
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              height: 46,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF172554)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(
                  size,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── COLOUR ────────────────────────────────────────────────────────
  Widget _buildColourSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _coloursList.map((opt) {
          final selected = _selectedColours.contains(opt.name);
          return GestureDetector(
            onTap: () => setState(() {
              if (selected) {
                _selectedColours.remove(opt.name);
              } else {
                _selectedColours.add(opt.name);
              }
            }),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: opt.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFE11D48)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  opt.name,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? const Color(0xFF172554)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── FIT ───────────────────────────────────────────────────────────
  Widget _buildFitSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _fitOptions.map((opt) {
          final selected = _selectedFit == opt.value;
          return GestureDetector(
            onTap: () => setState(() => _selectedFit = opt.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF172554)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: selected
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.label,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF172554),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          opt.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: selected
                                ? Colors.white.withValues(alpha: 0.7)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle_rounded,
                        size: 20, color: Color(0xFFE11D48))
                  else
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── APPLY BAR ─────────────────────────────────────────────────────
  Widget _buildApplyBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context, _buildCriteria()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE11D48),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            LanguageService.instance.isFrench
                ? (_activeCount == 0
                    ? 'Appliquer les filtres'
                    : 'Appliquer les filtres ($_activeCount actif${_activeCount > 1 ? 's' : ''})')
                : (_activeCount == 0
                    ? 'Apply filters'
                    : 'Apply filters ($_activeCount active)'),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColourOption {
  final String name;
  final Color color;
  const _ColourOption({required this.name, required this.color});
}

class _FitOption {
  final String label;
  final String value;
  final String subtitle;
  const _FitOption(
      {required this.label, required this.value, required this.subtitle});
}
