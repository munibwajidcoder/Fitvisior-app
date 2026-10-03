import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Lightweight product model ───────────────────────────────────────────────
class _CompareProduct {
  final String brand;
  final String name;
  final String price;
  final String imagePath;
  final String size;
  final String fit;
  final String fabric;
  final String weight;
  final double matchScore;
  final String silhouette;
  final double waist;
  final double length;

  const _CompareProduct({
    required this.brand,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.size,
    required this.fit,
    required this.fabric,
    required this.weight,
    required this.matchScore,
    required this.silhouette,
    required this.waist,
    required this.length,
  });
}

// ─── Catalog pool to pick from ────────────────────────────────────────────────
const List<_CompareProduct> _catalog = [
  _CompareProduct(
    brand: 'ATELIER BALMAIN',
    name: 'Blazer Croisé en Tweed de Laine',
    price: '340 €',
    imagePath: 'assets/images/product_suit.jpg',
    size: 'FR 38',
    fit: 'Ajustement Parfait',
    fabric: 'Tweed de Laine (280 g/m²)',
    weight: '280 g/m²',
    matchScore: 98.8,
    silhouette: 'Sablier Accentué',
    waist: 66.5,
    length: 68.0,
  ),
  _CompareProduct(
    brand: 'SAINT LAURENT',
    name: 'Tuxedo Wool Cut',
    price: '450 €',
    imagePath: 'assets/images/hero_banner.jpg',
    size: 'FR 38',
    fit: 'Légère Tension Poitrine',
    fabric: 'Gabardine (310 g/m²)',
    weight: '310 g/m²',
    matchScore: 92.1,
    silhouette: 'Colonne Parisienne',
    waist: 68.0,
    length: 72.0,
  ),
  _CompareProduct(
    brand: 'STUDIO ATELIER',
    name: 'Jupe Midi Biais en Soie Mûre',
    price: '195 €',
    imagePath: 'assets/images/product_pants.jpg',
    size: 'FR 36',
    fit: 'Drapé Naturel',
    fabric: 'Soie Pure (120 g/m²)',
    weight: '120 g/m²',
    matchScore: 99.0,
    silhouette: 'Fluide Asymétrique',
    waist: 64.0,
    length: 75.0,
  ),
  _CompareProduct(
    brand: 'STUDIO ATELIER',
    name: 'Pull Cachemire Côtelé',
    price: '160 €',
    imagePath: 'assets/images/product_dress.jpg',
    size: 'FR 38',
    fit: 'Confort Optimal',
    fabric: 'Cachemire Grade A',
    weight: '210 g/m²',
    matchScore: 97.6,
    silhouette: 'Ajusté Décontracté',
    waist: 66.0,
    length: 58.0,
  ),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────
class StyleComparisonScreen extends StatefulWidget {
  /// Optionally pre-load the first slot with a product index from [_catalog]
  final int? preloadLeftIndex;

  const StyleComparisonScreen({super.key, this.preloadLeftIndex});

  @override
  State<StyleComparisonScreen> createState() => _StyleComparisonScreenState();
}

class _StyleComparisonScreenState extends State<StyleComparisonScreen>
    with SingleTickerProviderStateMixin {
  _CompareProduct? _left;
  _CompareProduct? _right;

  static const Color _navy = Color(0xFF172554);
  static const Color _coral = Color(0xFFF43F5E);
  static const Color _red = Color(0xFFE11D48);

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    if (widget.preloadLeftIndex != null) {
      _left = _catalog[widget.preloadLeftIndex!];
    }
    if (_left != null && _right != null) _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Catalog picker bottom sheet ────────────────────────────────────────────
  Future<void> _pickProduct(bool isLeft) async {
    final picked = await showModalBottomSheet<_CompareProduct>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CatalogPickerSheet(
        catalog: _catalog,
        alreadyLeft: _left,
        alreadyRight: _right,
        isLeft: isLeft,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isLeft) {
        _left = picked;
      } else {
        _right = picked;
      }
      if (_left != null && _right != null) {
        _animCtrl.forward(from: 0);
      }
    });
  }

  void _clearSlot(bool isLeft) {
    setState(() {
      if (isLeft) _left = null;
      if (!isLeft) _right = null;
      _animCtrl.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header info
                    _buildHeaderInfo(),
                    const SizedBox(height: 18),

                    // Two product slots
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProductSlot(isLeft: true)),
                        const SizedBox(width: 12),
                        // VS badge in middle
                        Padding(
                          padding: const EdgeInsets.only(top: 70),
                          child: _buildVsBadge(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildProductSlot(isLeft: false)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Comparison table (visible only when both selected)
                    if (_left != null && _right != null)
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildComparisonTable(),
                      ),

                    if (_left == null || _right == null)
                      _buildSelectBothHint(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_left_rounded, size: 28, color: _navy),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Comparaison Côte-à-Côte',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _navy,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 12, color: _coral),
                const SizedBox(width: 4),
                Text(
                  'IA Styliste',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header Info ───────────────────────────────────────────────────────────
  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.compare_arrows_rounded,
                size: 18, color: _red),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélectionnez 2 produits à comparer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                Text(
                  'Appuyez sur + pour choisir depuis le catalogue',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── VS Badge ──────────────────────────────────────────────────────────────
  Widget _buildVsBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_coral, _red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _coral.withValues(alpha: 0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'VS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Product Slot ──────────────────────────────────────────────────────────
  Widget _buildProductSlot({required bool isLeft}) {
    final product = isLeft ? _left : _right;

    if (product == null) {
      // Empty slot — show + button
      return GestureDetector(
        onTap: () => _pickProduct(isLeft),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFE4E6), width: 2),
                ),
                child: const Icon(Icons.add_rounded, size: 26, color: _coral),
              ),
              const SizedBox(height: 10),
              Text(
                'Ajouter\ndu Catalogue',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filled slot — show product
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _coral.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _coral.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.asset(
                  product.imagePath,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => Container(
                    height: 150,
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: Icon(Icons.checkroom_rounded,
                          size: 40, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
              ),
              // Match score badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${product.matchScore}%',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Remove button
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _clearSlot(isLeft),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: _red),
                  ),
                ),
              ),
            ],
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _navy,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.size,
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
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
    );
  }

  // ── Hint when not both selected ───────────────────────────────────────────
  Widget _buildSelectBothHint() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE4E6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: _coral),
                const SizedBox(width: 8),
                Text(
                  'Sélectionnez 2 produits pour\nvoir la comparaison complète',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Comparison Table ──────────────────────────────────────────────────────
  Widget _buildComparisonTable() {
    final l = _left!;
    final r = _right!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF172554), Color(0xFF1E3A8A)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics_rounded,
                    size: 16, color: _coral),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Matrice de Comparaison Anatomique',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 120),
                Expanded(
                  child: Text(
                    l.brand.split(' ').first,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _red,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Text(
                    r.brand.split(' ').first,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Metric rows
          _metricRow(
              icon: Icons.verified_rounded,
              label: 'Correspondance',
              leftVal: '${l.matchScore}%',
              rightVal: '${r.matchScore}%',
              leftBetter: l.matchScore >= r.matchScore),
          _metricRow(
              icon: Icons.straighten_rounded,
              label: 'Tour de Taille',
              leftVal: '${l.waist} cm',
              rightVal: '${r.waist} cm',
              leftBetter: (l.waist - 66).abs() <= (r.waist - 66).abs()),
          _metricRow(
              icon: Icons.height_rounded,
              label: 'Longueur',
              leftVal: '${l.length} cm',
              rightVal: '${r.length} cm',
              leftBetter: true),
          _metricRow(
              icon: Icons.texture_rounded,
              label: 'Poids Tissu',
              leftVal: l.weight,
              rightVal: r.weight,
              leftBetter: true),
          _metricRow(
              icon: Icons.style_rounded,
              label: 'Silhouette',
              leftVal: l.silhouette,
              rightVal: r.silhouette,
              leftBetter: true),
          _metricRow(
              icon: Icons.check_circle_outline_rounded,
              label: 'Ajustement',
              leftVal: l.fit,
              rightVal: r.fit,
              leftBetter: l.matchScore >= r.matchScore,
              isLast: true),

          // Winner banner
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF172554), Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 20, color: _coral),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommandation IA',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _coral,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.matchScore >= r.matchScore
                            ? '${l.name} correspond mieux à votre silhouette avec ${l.matchScore}% de précision biométrique.'
                            : '${r.name} correspond mieux à votre silhouette avec ${r.matchScore}% de précision biométrique.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow({
    required IconData icon,
    required String label,
    required String leftVal,
    required String rightVal,
    required bool leftBetter,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: leftBetter
                    ? const Color(0xFFFFF1F2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                leftVal,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: leftBetter ? FontWeight.w700 : FontWeight.w500,
                  color: leftBetter ? _red : const Color(0xFF94A3B8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: !leftBetter
                    ? const Color(0xFFFFF1F2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rightVal,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight:
                      !leftBetter ? FontWeight.w700 : FontWeight.w500,
                  color: !leftBetter ? _red : const Color(0xFF94A3B8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Catalog Picker Bottom Sheet ──────────────────────────────────────────────
class _CatalogPickerSheet extends StatelessWidget {
  final List<_CompareProduct> catalog;
  final _CompareProduct? alreadyLeft;
  final _CompareProduct? alreadyRight;
  final bool isLeft;

  const _CatalogPickerSheet({
    required this.catalog,
    required this.alreadyLeft,
    required this.alreadyRight,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Text(
                  'Choisir depuis le Catalogue',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close_rounded,
                      size: 22, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Product list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: catalog.length,
              separatorBuilder: (context, i) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (ctx, index) {
                final p = catalog[index];
                final isAlreadyUsed = p == alreadyLeft || p == alreadyRight;
                return GestureDetector(
                  onTap: isAlreadyUsed
                      ? null
                      : () => Navigator.of(context).pop(p),
                  child: Opacity(
                    opacity: isAlreadyUsed ? 0.4 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              p.imagePath,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, e, s) => Container(
                                width: 56,
                                height: 56,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(Icons.checkroom_rounded,
                                    size: 24,
                                    color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.brand,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF94A3B8),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  p.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF172554),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${p.matchScore}% • ${p.size}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            p.price,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isAlreadyUsed)
                            const Icon(Icons.add_circle_rounded,
                                size: 22, color: Color(0xFFF43F5E)),
                          if (isAlreadyUsed)
                            const Icon(Icons.check_circle_rounded,
                                size: 22, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
