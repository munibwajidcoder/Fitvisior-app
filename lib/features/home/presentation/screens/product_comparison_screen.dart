import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'outfit_comparison_screen.dart';

// ── PRODUCT COMPARE MODEL ──────────────────────────────────────────────────
class ProductCompareItem {
  final String id;
  final String brand;
  final String title;
  final String price;
  final String imagePath;
  final String sizeBadge;
  final String matchScore;
  final String matchSubtitle;
  final double scoreValue;
  final String waistVal;
  final String waistDesc;
  final String fitVal;
  final String fitDesc;
  final String fabricVal;
  final String fabricDesc;
  final String versatilityVal;
  final String versatilityDesc;
  final String tensionInfo;
  final double strainVal;

  const ProductCompareItem({
    required this.id,
    required this.brand,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.sizeBadge,
    required this.matchScore,
    required this.matchSubtitle,
    required this.scoreValue,
    required this.waistVal,
    required this.waistDesc,
    required this.fitVal,
    required this.fitDesc,
    required this.fabricVal,
    required this.fabricDesc,
    required this.versatilityVal,
    required this.versatilityDesc,
    required this.tensionInfo,
    required this.strainVal,
  });
}

// ── CATALOG POOL FOR DYNAMIC SELECTION ──────────────────────────────────────
const List<ProductCompareItem> _catalogPool = [
  ProductCompareItem(
    id: 'balmain_01',
    brand: 'BALMAIN PARIS',
    title: 'Grain de Poudre DB',
    price: '2 190 €',
    imagePath: 'assets/images/product_suit.jpg',
    sizeBadge: 'FR 38',
    matchScore: '98,4% Correspondance',
    matchSubtitle: 'Zéro retouche',
    scoreValue: 98.4,
    waistVal: '66,5 cm',
    waistDesc: 'Sablier Accentué',
    fitVal: '68,0 cm',
    fitDesc: 'Finition Haut des Hanches',
    fabricVal: '280 g/m²',
    fabricDesc: 'Laine Vierge (Rigidité 4/5)',
    versatilityVal: '9.4',
    versatilityDesc: 'Jour au Soir',
    tensionInfo: '0,0 cm Tension (Fluide)',
    strainVal: 0.15,
  ),
  ProductCompareItem(
    id: 'saint_laurent_02',
    brand: 'SAINT LAURENT',
    title: 'Tuxedo Wool Cut',
    price: '2 450 €',
    imagePath: 'assets/images/pose_profile.jpg',
    sizeBadge: 'FR 38',
    matchScore: '92,1% Correspondance',
    matchSubtitle: 'Légère tension poitrine',
    scoreValue: 92.1,
    waistVal: '68,0 cm',
    waistDesc: 'Coupe Parisienne Droite',
    fitVal: '72,0 cm',
    fitDesc: 'Ligne Tuxedo Allongée',
    fabricVal: '310 g/m²',
    fabricDesc: 'Gabardine (Rigidité 5/5)',
    versatilityVal: '8.8',
    versatilityDesc: 'Tenue de Soirée',
    tensionInfo: '+1,8 cm Résistance',
    strainVal: 0.78,
  ),
  ProductCompareItem(
    id: 'jacquemus_03',
    brand: 'JACQUEMUS',
    title: 'Blazer La Veste Souple',
    price: '1 280 €',
    imagePath: 'assets/images/product_pants.jpg',
    sizeBadge: 'FR 36',
    matchScore: '95,8% Correspondance',
    matchSubtitle: 'Coupe ajustée naturelle',
    scoreValue: 95.8,
    waistVal: '65,0 cm',
    waistDesc: 'Cintré Souple',
    fitVal: '66,0 cm',
    fitDesc: 'Coupe Mi-Hanche',
    fabricVal: '240 g/m²',
    fabricDesc: 'Mélange Lin & Laine',
    versatilityVal: '9.1',
    versatilityDesc: 'Business Casual',
    tensionInfo: '0,2 cm Stretch',
    strainVal: 0.25,
  ),
  ProductCompareItem(
    id: 'chanel_04',
    brand: 'CHANEL PARIS',
    title: 'Veste Tweed Signature',
    price: '4 800 €',
    imagePath: 'assets/images/product_dress.jpg',
    sizeBadge: 'FR 38',
    matchScore: '94,2% Correspondance',
    matchSubtitle: 'Tombé fluide classique',
    scoreValue: 94.2,
    waistVal: '67,0 cm',
    waistDesc: 'Coupe Droite Intemporelle',
    fitVal: '70,0 cm',
    fitDesc: 'Longueur Hanche',
    fabricVal: '320 g/m²',
    fabricDesc: 'Tweed Tissé Main',
    versatilityVal: '9.0',
    versatilityDesc: 'Chic Intemporel',
    tensionInfo: '0,5 cm Souplesse',
    strainVal: 0.35,
  ),
  ProductCompareItem(
    id: 'dior_05',
    brand: 'DIOR',
    title: 'Pull Maille Cintrée',
    price: '1 600 €',
    imagePath: 'assets/images/product_sweater.jpg',
    sizeBadge: 'FR 36',
    matchScore: '96,5% Correspondance',
    matchSubtitle: 'Maille stretch seconde peau',
    scoreValue: 96.5,
    waistVal: '64,5 cm',
    waistDesc: 'Moulant Anatomique',
    fitVal: '65,0 cm',
    fitDesc: 'Coupe Courte',
    fabricVal: '190 g/m²',
    fabricDesc: 'Cachemire & Soie',
    versatilityVal: '9.3',
    versatilityDesc: 'Quotidien Luxe',
    tensionInfo: '0,0 cm Micro-fit',
    strainVal: 0.10,
  ),
];

class ProductComparisonScreen extends StatefulWidget {
  const ProductComparisonScreen({super.key});

  @override
  State<ProductComparisonScreen> createState() => _ProductComparisonScreenState();
}

class _ProductComparisonScreenState extends State<ProductComparisonScreen> {
  ProductCompareItem? _leftProduct = _catalogPool[0]; // Balmain
  ProductCompareItem? _rightProduct = _catalogPool[1]; // Saint Laurent
  int _selectedOption = 0; // 0 = Left, 1 = Right

  void _openCatalogPicker(bool isLeftSlot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isLeftSlot
                          ? "Sélectionner le Produit 1 (Gauche)"
                          : "Sélectionner le Produit 2 (Droite)",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _catalogPool.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (ctx, idx) {
                      final item = _catalogPool[idx];
                      final isAlreadySelected = (isLeftSlot
                              ? _rightProduct?.id == item.id
                              : _leftProduct?.id == item.id);

                      return ListTile(
                        enabled: !isAlreadySelected,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item.imagePath,
                            width: 44,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          item.brand,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        subtitle: Text(
                          item.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.price,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF172554),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1F2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.matchScore.split(' ').first,
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFE11D48),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isAlreadySelected
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: isAlreadySelected
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFFE11D48),
                            ),
                          ],
                        ),
                        onTap: isAlreadySelected
                            ? null
                            : () {
                                setState(() {
                                  if (isLeftSlot) {
                                    _leftProduct = item;
                                  } else {
                                    _rightProduct = item;
                                  }
                                });
                                Navigator.of(ctx).pop();
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sub-header Status Bar
              _buildStatusSubHeader(),
              const SizedBox(height: 14),

              // 2. Dual Render Comparison Cards (Dynamic Left & Right Slots)
              _buildDualProductComparisonCards(),
              const SizedBox(height: 14),

              // 3. Sub-row Attributes (Waist Accent & Silhouette) — Fixed Overflow
              _buildSubAttributesRow(),
              const SizedBox(height: 18),

              // 4. Seam Tension Differential Card
              _buildSeamTensionCard(),
              const SizedBox(height: 20),

              // 5. Anatomical Matrix Header
              _buildAnatomicalMatrixHeader(),
              const SizedBox(height: 14),

              // 6. Primary Choice Pick Selector Buttons
              _buildChoicePickButtons(),
              const SizedBox(height: 20),

              // 7. Anatomical Matrix Metric Comparison Rows
              _buildMatrixMetricRow(
                category: "AFFINEMENT DE LA TAILLE",
                icon: Icons.accessibility_new_rounded,
                leftBrand: _leftProduct?.brand ?? "PRODUIT 1",
                leftVal: _leftProduct?.waistVal ?? "--",
                leftDesc: _leftProduct?.waistDesc ?? "Aucun sélectionné",
                rightBrand: _rightProduct?.brand ?? "PRODUIT 2",
                rightVal: _rightProduct?.waistVal ?? "--",
                rightDesc: _rightProduct?.waistDesc ?? "Aucun sélectionné",
              ),
              const SizedBox(height: 14),

              _buildMatrixMetricRow(
                category: "TOMBÉ & LONGUEUR",
                icon: Icons.vertical_align_bottom_rounded,
                leftBrand: _leftProduct?.brand ?? "PRODUIT 1",
                leftVal: _leftProduct?.fitVal ?? "--",
                leftDesc: _leftProduct?.fitDesc ?? "--",
                rightBrand: _rightProduct?.brand ?? "PRODUIT 2",
                rightVal: _rightProduct?.fitVal ?? "--",
                rightDesc: _rightProduct?.fitDesc ?? "--",
              ),
              const SizedBox(height: 14),

              _buildMatrixMetricRow(
                category: "POIDS & DRAPÉ DU TISSU",
                icon: Icons.grid_4x4_rounded,
                leftBrand: _leftProduct?.brand ?? "PRODUIT 1",
                leftVal: _leftProduct?.fabricVal ?? "--",
                leftDesc: _leftProduct?.fabricDesc ?? "--",
                rightBrand: _rightProduct?.brand ?? "PRODUIT 2",
                rightVal: _rightProduct?.fabricVal ?? "--",
                rightDesc: _rightProduct?.fabricDesc ?? "--",
              ),
              const SizedBox(height: 14),

              _buildVersatilityIndexRow(),
              const SizedBox(height: 22),

              // 8. Dreskode Neural Recommendation Card
              _buildNeuralRecommendationCard(),
              const SizedBox(height: 22),

              // 9. Primary Action: Comparaison de Tenues (Outfit Comparison)
              _buildOutfitComparisonButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── 9. OUTFIT COMPARISON CTA BUTTON ────────────────────────────────────────

  Widget _buildOutfitComparisonButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const OutfitComparisonScreen(),
          ));
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Comparaison de Tenues",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF172554)),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Comparaison de Produits",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF172554),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
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

  // ── 1. STATUS SUB HEADER ─────────────────────────────────────────────────

  Widget _buildStatusSubHeader() {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFFF43F5E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            "SIMULATION SPATIALE + CAMILLE (174 CM)",
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, size: 13, color: Color(0xFFE11D48)),
            const SizedBox(width: 4),
            Text(
              "Carte de Tension Active",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF172554),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 2. DUAL PRODUCT COMPARISON CARDS ─────────────────────────────────────

  Widget _buildDualProductComparisonCards() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Slot Card
            Expanded(
              child: _leftProduct != null
                  ? _buildComparisonCard(_leftProduct!, isRight: false)
                  : _buildEmptySlotCard(isLeft: true),
            ),
            const SizedBox(width: 12),
            // Right Slot Card
            Expanded(
              child: _rightProduct != null
                  ? _buildComparisonCard(_rightProduct!, isRight: true)
                  : _buildEmptySlotCard(isLeft: false),
            ),
          ],
        ),

        // Floating Center Orbit Badge
        Positioned(
          top: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF172554).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync_rounded, size: 13, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  "Orbite Synchronisée 360°",
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── EMPTY SLOT CARD WITH '+' ICON ─────────────────────────────────────────

  Widget _buildEmptySlotCard({required bool isLeft}) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openCatalogPicker(isLeft),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Ajouter du Catalogue",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Appuyez sur + pour comparer un produit",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── FILLED COMPARISON CARD ────────────────────────────────────────────────

  Widget _buildComparisonCard(ProductCompareItem product, {required bool isRight}) {
    return Container(
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
          // Image Box
          SizedBox(
            height: 190,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.asset(
                      product.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                // Top Action Bar: Swap (+) and Remove (X)
                Positioned(
                  top: 8,
                  right: 8,
                  left: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Swap product button
                      GestureDetector(
                        onTap: () => _openCatalogPicker(!isRight),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_horiz_rounded,
                            size: 16,
                            color: Color(0xFF172554),
                          ),
                        ),
                      ),
                      // Clear slot button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!isRight) {
                              _leftProduct = null;
                            } else {
                              _rightProduct = null;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Red Tension Point Dot
                Positioned(
                  top: 60,
                  right: isRight ? 20 : null,
                  left: !isRight ? 20 : null,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Match Overlay
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF172554).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.matchScore,
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF43F5E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product.matchSubtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 8.5,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isRight ? Icons.info_outline_rounded : Icons.verified_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Product Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.sizeBadge,
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

  // ── 3. SUB ATTRIBUTES ROW (FIXED OVERFLOW BY 28 PIXELS) ───────────────────

  Widget _buildSubAttributesRow() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFF43F5E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                "Accentuation Taille : Haute",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 12, color: const Color(0xFFCBD5E1)),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                "Silhouette : Colonne",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. SEAM TENSION DIFFERENTIAL CARD ────────────────────────────────────

  Widget _buildSeamTensionCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                child: Row(
                  children: [
                    const Icon(Icons.grid_view_rounded, size: 16, color: Color(0xFFE11D48)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Différentiel de Tension des Coutures",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Carte 3D Camille",
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Left Product Strain Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${_leftProduct?.brand ?? 'Produit 1'} : Tension Taille & Poitrine",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _leftProduct?.tensionInfo ?? "--",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF43F5E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _leftProduct?.strainVal ?? 0.0,
              backgroundColor: const Color(0xFFF1F5F9),
              color: const Color(0xFFF43F5E),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),

          // Right Product Strain Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${_rightProduct?.brand ?? 'Produit 2'} : Blocage Sternum",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _rightProduct?.tensionInfo ?? "--",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFBE123C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _rightProduct?.strainVal ?? 0.0,
              backgroundColor: const Color(0xFFF1F5F9),
              color: const Color(0xFFBE123C),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. ANATOMICAL MATRIX HEADER ──────────────────────────────────────────

  Widget _buildAnatomicalMatrixHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Matrice Anatomique",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              "Châssis de Base : Camille 88–66–94",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 6. CHOICE PICK BUTTONS ───────────────────────────────────────────────

  Widget _buildChoicePickButtons() {
    final leftName = _leftProduct != null
        ? "Choisir ${_leftProduct!.brand.split(' ').first} ${_leftProduct!.sizeBadge}"
        : "Produit 1 Vide";
    final leftSub = _leftProduct != null
        ? "${_leftProduct!.price} • Coupe Parfaite"
        : "Appuyez sur +";

    final rightName = _rightProduct != null
        ? "Choisir ${_rightProduct!.brand.split(' ').first} ${_rightProduct!.sizeBadge}"
        : "Produit 2 Vide";
    final rightSub = _rightProduct != null
        ? "${_rightProduct!.price} • Ajustement"
        : "Appuyez sur +";

    return Row(
      children: [
        // Pick Left (Option 0)
        Expanded(
          child: GestureDetector(
            onTap: _leftProduct == null
                ? () => _openCatalogPicker(true)
                : () => setState(() => _selectedOption = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: _selectedOption == 0 ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedOption == 0
                      ? const Color(0xFF172554)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    leftName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _selectedOption == 0 ? Colors.white : const Color(0xFF172554),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    leftSub,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: _selectedOption == 0
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Pick Right (Option 1)
        Expanded(
          child: GestureDetector(
            onTap: _rightProduct == null
                ? () => _openCatalogPicker(false)
                : () => setState(() => _selectedOption = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: _selectedOption == 1 ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedOption == 1
                      ? const Color(0xFF172554)
                      : const Color(0xFFFECDD3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    rightName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _selectedOption == 1 ? Colors.white : const Color(0xFFBE123C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rightSub,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: _selectedOption == 1
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 7. MATRIX METRIC ROW WIDGET ──────────────────────────────────────────

  Widget _buildMatrixMetricRow({
    required String category,
    required IconData icon,
    required String leftBrand,
    required String leftVal,
    required String leftDesc,
    required String rightBrand,
    required String rightVal,
    required String rightDesc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Left Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leftBrand,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFE11D48),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leftVal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      leftDesc,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Right Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rightBrand,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rightVal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      rightDesc,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVersatilityIndexRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_outline_rounded, size: 14, color: Color(0xFF64748B)),
            const SizedBox(width: 5),
            Text(
              "INDICE DE POLYVALENCE",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            // Left Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _leftProduct?.brand ?? "PRODUIT 1",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE11D48),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _leftProduct?.versatilityVal ?? "--",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF172554),
                                ),
                              ),
                              Text(
                                "/10",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _leftProduct?.versatilityDesc ?? "--",
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF1F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded,
                          size: 15, color: Color(0xFFE11D48)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Right Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _rightProduct?.brand ?? "PRODUIT 2",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _rightProduct?.versatilityVal ?? "--",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF172554),
                                ),
                              ),
                              Text(
                                "/10",
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _rightProduct?.versatilityDesc ?? "--",
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          size: 15, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 8. DRESKODE NEURAL RECOMMENDATION CARD ───────────────────────────────

  Widget _buildNeuralRecommendationCard() {
    ProductCompareItem? bestItem;
    if (_leftProduct != null && _rightProduct != null) {
      bestItem = _leftProduct!.scoreValue >= _rightProduct!.scoreValue
          ? _leftProduct
          : _rightProduct;
    } else {
      bestItem = _leftProduct ?? _rightProduct;
    }

    final recommendedText = bestItem != null
        ? "${bestItem.brand} ${bestItem.sizeBadge} est votre idéal anatomique. Sa coupe honore parfaitement votre silhouette sablier avec ${bestItem.matchScore} et un drapes optimal sur le châssis de Camille."
        : "Veuillez sélectionner au moins un produit du catalogue pour générer la recommandation neuronale.";

    final zeroRiskText = bestItem != null
        ? "Zéro risque de retour prédit pour ${bestItem.brand}"
        : "Sélectionnez 2 produits pour comparer";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172554), Color(0xFF172554)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFFF43F5E)),
              const SizedBox(width: 6),
              Text(
                "RECOMMANDATION NEURONALE FITVISOR",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            recommendedText,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    size: 15, color: Color(0xFFF43F5E)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    zeroRiskText,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
