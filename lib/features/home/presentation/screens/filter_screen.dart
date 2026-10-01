import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_variant_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // ── Avatar Fit Calibration ─────────────────────────────────────────
  bool _highMatchOnly = true;
  bool _hourglassWaist = true;
  bool _zeroSeamTension = false;

  // ── Catégorie ─────────────────────────────────────────────────────
  final Map<String, int> _categories = {
    'Blazers & Vestes': 12,
    'Robes de Soirée': 8,
    'Manteaux': 14,
    'Pantalons': 4,
    'Maille': 7,
  };
  final Set<String> _selectedCategories = {'Blazers & Vestes'};

  // ── Silhouette & Drapé ────────────────────────────────────────────
  final List<_SilhouetteOption> _silhouettes = [
    _SilhouetteOption(
      icon: Icons.architecture,
      title: 'Architectural',
      subtitle: 'Lignes structurées & rembourrage',
    ),
    _SilhouetteOption(
      icon: Icons.water_drop_outlined,
      title: 'Fluide & Détendu',
      subtitle: 'Drapé waterfall organique',
    ),
    _SilhouetteOption(
      icon: Icons.crop_portrait,
      title: 'Cocon Oversize',
      subtitle: 'Volume mappé ample',
    ),
    _SilhouetteOption(
      icon: Icons.accessibility_new_rounded,
      title: 'Près du Corps',
      subtitle: 'Stretch seconde peau',
    ),
  ];
  final Set<int> _selectedSilhouettes = {0, 1};

  // ── Physique du Tissu ─────────────────────────────────────────────
  final List<String> _fabrics = [
    'Laine Structurée',
    'Charmeuse de Soie',
    'Cachemire Épais',
    'Cuir Structuré',
    'Crêpe Technique',
  ];
  final Set<String> _selectedFabrics = {'Laine Structurée'};

  // ── Maisons de Couture ────────────────────────────────────────────
  final Map<String, int> _designers = {
    'Balmain': 4,
    'The Row': 6,
    'Bottega Veneta': 3,
    'Saint Laurent': 5,
  };
  final Set<String> _selectedDesigners = {'Balmain', 'The Row'};

  // ── Gamme de Prix ─────────────────────────────────────────────────
  double _minPrice = 400;
  double _maxPrice = 2500;
  final double _absoluteMin = 400;
  final double _absoluteMax = 2500;

  int get _activeFilterCount {
    int count = 0;
    if (_highMatchOnly) count++;
    if (_hourglassWaist) count++;
    if (_zeroSeamTension) count++;
    count += _selectedCategories.length;
    count += _selectedSilhouettes.length;
    count += _selectedFabrics.length;
    count += _selectedDesigners.length;
    return count;
  }

  int get _estimatedItems => 18; // Would come from backend

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ─────────────────────────────────────────────
            _buildHeader(),

            // ── ACTIVE FILTER BADGE ────────────────────────────────
            _buildActiveFilterBadge(),

            // ── SCROLLABLE FILTER SECTIONS ─────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Calibration Avatar Fit [SPATIAL]
                    _buildAvatarFitSection(),
                    const SizedBox(height: 16),

                    // 2. Catégorie
                    _buildCategorySection(),
                    const SizedBox(height: 16),

                    // 3. Silhouette & Drapé
                    _buildSilhouetteSection(),
                    const SizedBox(height: 16),

                    // 4. Physique du Tissu
                    _buildFabricSection(),
                    const SizedBox(height: 16),

                    // 5. Maisons de Couture
                    _buildDesignerSection(),
                    const SizedBox(height: 16),

                    // 6. Gamme de Prix
                    _buildPriceRangeSection(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── BOTTOM ACTION BAR ──────────────────────────────────
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Feuille de Filtres",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _resetAllFilters,
            child: Text(
              "Tout effacer",
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

  // ── ACTIVE FILTER BADGE ─────────────────────────────────────────────────

  Widget _buildActiveFilterBadge() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_alt_rounded, size: 16, color: Color(0xFF1D4ED8)),
            const SizedBox(width: 8),
            Text(
              "$_activeFilterCount FILTRES ACTIFS  •  $_estimatedItems ARTICLES TROUVÉS",
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D4ED8),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION WRAPPER ─────────────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    String? badge,
    Color? badgeColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                    letterSpacing: -0.2,
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor?.withValues(alpha: 0.1) ??
                          const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: badgeColor ?? const Color(0xFF64748B),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          // Section body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── 1. AVATAR FIT CALIBRATION SECTION ───────────────────────────────────

  Widget _buildAvatarFitSection() {
    return _buildSection(
      title: "Calibration Avatar Fit",
      badge: "SPATIAL",
      badgeColor: const Color(0xFF7C3AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Text(
            "Tension biométrique live & cartographie mesh corporelle",
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          // Avatar Fit Enable Toggle
          _buildToggleRow(
            label: "Match Élevé Uniquement (≥95% Fit)",
            sublabel: "Stricte parité de scan volumétrique",
            value: _highMatchOnly,
            onChanged: (v) => setState(() => _highMatchOnly = v),
            activeColor: const Color(0xFF1D4ED8),
          ),

          const SizedBox(height: 12),

          // Hourglass Waist Compliant
          _buildCheckRow(
            icon: Icons.straighten_rounded,
            label: "Conforme Taille Sablier",
            value: _hourglassWaist,
            onChanged: (v) => setState(() => _hourglassWaist = v ?? false),
          ),

          const SizedBox(height: 8),

          // Zero Seam Tension Guarantee
          _buildCheckRow(
            icon: Icons.bolt_rounded,
            label: "Garantie Zéro Tension de Couture",
            value: _zeroSeamTension,
            onChanged: (v) => setState(() => _zeroSeamTension = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    String? sublabel,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color activeColor = const Color(0xFFE11D48),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF172554),
                ),
              ),
              if (sublabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  sublabel,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: value ? activeColor : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF172554),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF172554) : Colors.transparent,
              border: Border.all(
                color: value ? const Color(0xFF172554) : const Color(0xFFCBD5E1),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }

  // ── 2. CATÉGORIE SECTION ─────────────────────────────────────────────────

  Widget _buildCategorySection() {
    return _buildSection(
      title: "Catégorie",
      badge: "Sélection Multiple",
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _categories.entries.map((entry) {
          final selected = _selectedCategories.contains(entry.key);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedCategories.remove(entry.key);
                } else {
                  _selectedCategories.add(entry.key);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF172554)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF172554)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${entry.value}",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : const Color(0xFF64748B),
                      ),
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

  // ── 3. SILHOUETTE & DRAPÉ SECTION ───────────────────────────────────────

  Widget _buildSilhouetteSection() {
    return _buildSection(
      title: "Silhouette & Drapé",
      badge: "${_selectedSilhouettes.length} Actifs",
      badgeColor: const Color(0xFFE11D48),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _silhouettes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          final selected = _selectedSilhouettes.contains(index);
          final s = _silhouettes[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedSilhouettes.remove(index);
                } else {
                  _selectedSilhouettes.add(index);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF172554)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF172554)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    s.icon,
                    size: 16,
                    color: selected ? Colors.white : const Color(0xFF64748B),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xFF172554),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    s.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 4. PHYSIQUE DU TISSU SECTION ─────────────────────────────────────────

  Widget _buildFabricSection() {
    return _buildSection(
      title: "Physique du Tissu",
      badge: "Simulation Temps Réel",
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _fabrics.map((fabric) {
          final selected = _selectedFabrics.contains(fabric);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedFabrics.remove(fabric);
                } else {
                  _selectedFabrics.add(fabric);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF172554)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF172554)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  Text(
                    fabric,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF334155),
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

  // ── 5. MAISONS DE COUTURE SECTION ────────────────────────────────────────

  Widget _buildDesignerSection() {
    return _buildSection(
      title: "Maisons de Couture",
      badge: "Paris & Milan",
      child: Column(
        children: _designers.entries.map((entry) {
          final selected = _selectedDesigners.contains(entry.key);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedDesigners.remove(entry.key);
                } else {
                  _selectedDesigners.add(entry.key);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF172554)
                          : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF172554)
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF172554),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF172554)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${entry.value}",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
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

  // ── 6. GAMME DE PRIX SECTION ─────────────────────────────────────────────

  Widget _buildPriceRangeSection() {
    return _buildSection(
      title: "Gamme de Prix",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price display row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Min",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "€ ${_minPrice.toInt()}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "€${_minPrice.toInt()} — €${_maxPrice.toInt()}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Max",
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    "€ ${_maxPrice.toInt()}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Range slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF172554),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF172554),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: const Color(0xFF172554).withValues(alpha: 0.12),
              trackHeight: 3,
            ),
            child: RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: _absoluteMin,
              max: _absoluteMax,
              divisions: 42,
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ACTION BAR ────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          // Reset Button
          GestureDetector(
            onTap: _resetAllFilters,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  "Réinitialiser",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Apply Filters — Pink CTA Button (Overflow-proof)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ColorVariantScreen(),
                  ),
                );
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Appliquer les Filtres",
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$_estimatedItems Articles",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────

  void _resetAllFilters() {
    setState(() {
      _highMatchOnly = false;
      _hourglassWaist = false;
      _zeroSeamTension = false;
      _selectedCategories.clear();
      _selectedSilhouettes.clear();
      _selectedFabrics.clear();
      _selectedDesigners.clear();
      _minPrice = _absoluteMin;
      _maxPrice = _absoluteMax;
    });
  }
}

// ── DATA MODELS ──────────────────────────────────────────────────────────────

class _SilhouetteOption {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SilhouetteOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
