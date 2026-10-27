import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/wardrobe_service.dart';
import '../../data/product_service.dart';
import '../../data/product_biometrics_helper.dart';
import 'outfit_comparison_screen.dart';
import '../../../../core/localization/language_service.dart';

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

  String get localizedTitle {
    return WardrobeService.localizeProductName(title);
  }

  String get localizedMatchScore {
    final isEn = LanguageService.instance.isEnglish;
    if (isEn) {
      return matchScore
          .replaceAll('Correspondance', 'Match')
          .replaceAll(',', '.');
    } else {
      return matchScore
          .replaceAll('Match', 'Correspondance')
          .replaceAll('.', ',');
    }
  }

  String get localizedMatchSubtitle {
    final isEn = LanguageService.instance.isEnglish;
    if (!isEn) return matchSubtitle;
    switch (matchSubtitle) {
      case 'Zéro retouche': return 'Zero alteration';
      case 'Légère tension poitrine': return 'Slight bust tension';
      case 'Coupe ajustée naturelle': return 'Natural tailored cut';
      case 'Tombé fluide classique': return 'Classic fluid drape';
      case 'Maille stretch seconde peau': return 'Second-skin stretch knit';
      case 'Ajustement Sur-Mesure': return 'Bespoke Fit';
      case 'Tombé Haute Fidélité': return 'High Fidelity Drape';
      case 'Légère aisance poitrine': return 'Slight bust ease';
      case 'Ajustement Recommandé': return 'Recommended Fit';
      case 'Zéro collision': return 'Zero collision';
      case 'Prêt à Couper': return 'Ready to Tailor';
      default: return matchSubtitle;
    }
  }

  String get localizedWaistDesc {
    final isEn = LanguageService.instance.isEnglish;
    if (!isEn) return waistDesc;
    switch (waistDesc) {
      case 'Sablier Accentué': return 'Hourglass Accent';
      case 'Taille Haute Sculptée': return 'Sculpted High Waist';
      case 'Cintrage Anatomique': return 'Anatomical Cinched';
      case 'Aisance Manteau Double': return 'Double Coat Ease';
      case 'Coupe Fluide Naturelle': return 'Fluid Natural Cut';
      case 'Coupe Parisienne Droite': return 'Straight Parisian Cut';
      case 'Cintré Souple': return 'Supple Cinched';
      case 'Coupe Droite Intemporelle': return 'Timeless Straight Cut';
      case 'Moulant Anatomique': return 'Anatomical Form-fitting';
      case 'Colonne': return 'Column';
      default: return waistDesc;
    }
  }

  String get localizedFitDesc {
    final isEn = LanguageService.instance.isEnglish;
    if (!isEn) return fitDesc;
    switch (fitDesc) {
      case 'Finition Haut des Hanches': return 'High-Hip Finish';
      case 'Longueur Opéra / Sol': return 'Floor / Opera Length';
      case 'Finition Au-dessus du Genou': return 'Above-the-Knee Finish';
      case 'Finition Mi-Mollet Drapée': return 'Draped Mid-Calf Finish';
      case 'Entrejambe 82 cm (Talon 7cm)': return 'Inseam 82 cm (7cm Heel)';
      case 'Tombé Longueur Mollet': return 'Calf Length Drape';
      case 'Coupe Bassin Ajustée': return 'Fitted Pelvis Cut';
      case 'Ligne Tuxedo Allongée': return 'Elongated Tuxedo Line';
      case 'Coupe Mi-Hanche': return 'Mid-Hip Cut';
      case 'Longueur Hanche': return 'Hip Length';
      case 'Coupe Courte': return 'Short Cut';
      case 'Drapé équilibré': return 'Balanced Drape';
      default: return fitDesc;
    }
  }

  String get localizedFabricDesc {
    final isEn = LanguageService.instance.isEnglish;
    if (!isEn) return fabricDesc;
    switch (fabricDesc) {
      case 'Laine Vierge (Rigidité 4/5)': return 'Virgin Wool (Rigidity 4/5)';
      case 'Gabardine (Rigidité 5/5)': return 'Gabardine (Rigidity 5/5)';
      case 'Mélange Lin & Laine': return 'Linen & Wool Blend';
      case 'Tweed Tissé Main': return 'Hand-Woven Tweed';
      case 'Tweed Tissé Main (Rigide 4/5)': return 'Hand-Woven Tweed (Rigid 4/5)';
      case 'Cachemire & Soie': return 'Cashmere & Silk';
      case 'Matière Noble': return 'Noble Fabric';
      case 'Soie & Crêpe Fluide': return 'Silk & Fluid Crepe';
      case 'Cachemire Pur (Doux)': return 'Pure Cashmere (Soft)';
      case 'Laine Vierge Peignée': return 'Combed Virgin Wool';
      case 'Lin Texturé Respirant': return 'Breathable Textured Linen';
      case 'Drap de Laine Lourd': return 'Heavy Wool Fabric';
      case 'Matière Structurée': return 'Structured Material';
      default: return fabricDesc;
    }
  }

  String get localizedVersatilityDesc {
    final isEn = LanguageService.instance.isEnglish;
    if (!isEn) return versatilityDesc;
    switch (versatilityDesc) {
      case 'Jour au Soir': return 'Day to Night';
      case 'Jour au Soir • Capsule': return 'Day to Night • Capsule';
      case 'Tenue de Soirée': return 'Evening Wear';
      case 'Business Casual': return 'Business Casual';
      case 'Business & Cocktail': return 'Business & Cocktail';
      case 'Chic Intemporel': return 'Timeless Chic';
      case 'Quotidien Luxe': return 'Luxury Everyday';
      case 'Occasion Spéciale': return 'Special Occasion';
      default: return versatilityDesc;
    }
  }

  String get localizedTensionInfo {
    final isEn = LanguageService.instance.isEnglish;
    if (!isEn) return tensionInfo;
    return tensionInfo
        .replaceAll('0,0 cm Tension (Fluide)', '0.0 cm Tension (Fluid)')
        .replaceAll('+1,8 cm Résistance', '+1.8 cm Resistance')
        .replaceAll('0,2 cm Stretch', '0.2 cm Stretch')
        .replaceAll('0,5 cm Souplesse', '0.5 cm Suppleness')
        .replaceAll('0,0 cm Micro-fit', '0.0 cm Micro-fit')
        .replaceAll('Stretch Naturel', 'Natural Stretch')
        .replaceAll('Résistance Poitrine', 'Bust Resistance')
        .replaceAll('Maintien Ferme', 'Firm Hold')
        .replaceAll(',', '.');
  }

  factory ProductCompareItem.fromProductModel(ProductModel p) {
    final isEn = LanguageService.instance.isEnglish;
    final bio = ProductBiometricsHelper.calculate(
      id: p.id,
      name: p.name,
      brand: p.brand,
      category: p.category,
      size: p.recSize,
      fabric: p.fabricComposition,
      fitPercentStr: p.fitPercent,
      silhouetteType: p.silhouetteType,
      price: p.price,
    );
    return ProductCompareItem(
      id: p.id,
      brand: p.brand.toUpperCase(),
      title: p.name,
      price: p.price > 0 ? '${p.price.toStringAsFixed(0)} €' : (isEn ? 'On Request' : 'Sur Demande'),
      imagePath: p.imageUrl,
      sizeBadge: p.recSize.replaceAll('Rec: ', '').trim(),
      matchScore: bio.matchScore,
      matchSubtitle: bio.matchSubtitle,
      scoreValue: bio.scoreValue,
      waistVal: bio.waistVal,
      waistDesc: bio.waistDesc,
      fitVal: bio.fitVal,
      fitDesc: bio.fitDesc,
      fabricVal: bio.fabricVal,
      fabricDesc: bio.fabricDesc,
      versatilityVal: bio.versatilityVal,
      versatilityDesc: bio.versatilityDesc,
      tensionInfo: bio.tensionInfo,
      strainVal: bio.strainVal,
    );
  }

  factory ProductCompareItem.fromWardrobe(WardrobeItem item) {
    // If the wardrobe item was saved with old identical defaults, recalculate dynamically
    final bio = ProductBiometricsHelper.calculate(
      id: item.productId.isNotEmpty ? item.productId : item.id,
      name: item.productName,
      brand: item.productBrand,
      category: item.category,
      size: item.recSize,
      fabric: item.fabricDesc,
      fitPercentStr: item.fitPercent,
    );

    final bool isOldIdenticalDefault = (item.waistVal == '66,5 cm' && item.fitVal == '68,0 cm' && item.fabricVal == '260 g/m²');

    return ProductCompareItem(
      id: item.productId.isNotEmpty ? item.productId : item.id,
      brand: item.productBrand,
      title: item.productName,
      price: item.productPrice,
      imagePath: item.productImage,
      sizeBadge: item.recSize,
      matchScore: item.fitPercent,
      matchSubtitle: isOldIdenticalDefault ? bio.matchSubtitle : item.matchSubtitle,
      scoreValue: item.matchScoreVal,
      waistVal: isOldIdenticalDefault ? bio.waistVal : item.waistVal,
      waistDesc: isOldIdenticalDefault ? bio.waistDesc : item.waistDesc,
      fitVal: isOldIdenticalDefault ? bio.fitVal : item.fitVal,
      fitDesc: isOldIdenticalDefault ? bio.fitDesc : item.fitDesc,
      fabricVal: isOldIdenticalDefault ? bio.fabricVal : item.fabricVal,
      fabricDesc: item.fabricDesc.isNotEmpty ? item.fabricDesc : bio.fabricDesc,
      versatilityVal: isOldIdenticalDefault ? bio.versatilityVal : item.versatilityVal,
      versatilityDesc: isOldIdenticalDefault ? bio.versatilityDesc : item.versatilityDesc,
      tensionInfo: isOldIdenticalDefault ? bio.tensionInfo : item.tensionInfo,
      strainVal: isOldIdenticalDefault ? bio.strainVal : (1.0 - (item.certaintyVal.clamp(0.0, 1.0))),
    );
  }

  WardrobeItem toWardrobeItem() {
    return WardrobeItem(
      id: 'wb_${DateTime.now().millisecondsSinceEpoch}',
      productId: id,
      productName: localizedTitle,
      productBrand: brand,
      productPrice: price,
      productImage: imagePath,
      fitPercent: localizedMatchScore,
      recSize: sizeBadge,
      category: 'Vêtements',
      matchScoreVal: scoreValue,
      matchSubtitle: localizedMatchSubtitle,
      waistVal: waistVal,
      waistDesc: localizedWaistDesc,
      fitVal: fitVal,
      fitDesc: localizedFitDesc,
      fabricVal: fabricVal,
      fabricDesc: localizedFabricDesc,
      versatilityVal: versatilityVal,
      versatilityDesc: localizedVersatilityDesc,
      tensionInfo: localizedTensionInfo,
      certaintyVal: scoreValue / 100.0,
      isFavorite: true,
      createdAt: DateTime.now(),
    );
  }
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
    imagePath: 'assets/images/product_dress.jpg',
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
  final ProductCompareItem? initialLeftProduct;
  final ProductCompareItem? initialRightProduct;

  const ProductComparisonScreen({
    super.key,
    this.initialLeftProduct,
    this.initialRightProduct,
  });

  @override
  State<ProductComparisonScreen> createState() => _ProductComparisonScreenState();
}

class _ProductComparisonScreenState extends State<ProductComparisonScreen> {
  ProductCompareItem? _leftProduct;
  ProductCompareItem? _rightProduct;
  int _selectedOption = 0; // 0 = Left, 1 = Right
  List<ProductCompareItem> _catalogProducts = [];

  @override
  void initState() {
    super.initState();
    _leftProduct = widget.initialLeftProduct;
    _rightProduct = widget.initialRightProduct;
    _loadCatalogAndInit();
  }

  Future<void> _loadCatalogAndInit() async {
    try {
      final prods = await ProductService.instance.getProducts();
      if (mounted) {
        setState(() {
          _catalogProducts = prods.map((p) => ProductCompareItem.fromProductModel(p)).toList();
        });
      }
    } catch (_) {}
  }

  List<ProductCompareItem> get _availablePool {
    final List<ProductCompareItem> list = [];
    final wardrobe = WardrobeService.instance.wardrobeItemsNotifier.value;
    for (final w in wardrobe) {
      list.add(ProductCompareItem.fromWardrobe(w));
    }
    for (final cat in _catalogProducts) {
      if (!list.any((item) => item.id == cat.id || item.title.toLowerCase() == cat.title.toLowerCase())) {
        list.add(cat);
      }
    }
    for (final fallback in _catalogPool) {
      if (!list.any((item) => item.id == fallback.id || item.title.toLowerCase() == fallback.title.toLowerCase())) {
        list.add(fallback);
      }
    }
    return list;
  }

  Widget _buildProductThumbnail(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 44,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/product_dress.jpg',
          width: 44,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      path,
      width: 44,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/product_dress.jpg',
        width: 44,
        height: 56,
        fit: BoxFit.cover,
      ),
    );
  }

  void _openCatalogPicker(bool isLeftSlot) {
    String searchQuery = '';
    int filterTab = 0; // 0 = Tous, 1 = Mon Dressing, 2 = Catalogue

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final wardrobe = WardrobeService.instance.wardrobeItemsNotifier.value
                .map((w) => ProductCompareItem.fromWardrobe(w))
                .toList();

            List<ProductCompareItem> filteredList;
            if (filterTab == 1) {
              filteredList = wardrobe;
            } else if (filterTab == 2) {
              filteredList = _catalogProducts.isNotEmpty ? _catalogProducts : _catalogPool;
            } else {
              filteredList = _availablePool;
            }

            if (searchQuery.trim().isNotEmpty) {
              final q = searchQuery.toLowerCase().trim();
              filteredList = filteredList.where((item) =>
                  item.title.toLowerCase().contains(q) ||
                  item.localizedTitle.toLowerCase().contains(q) ||
                  item.brand.toLowerCase().contains(q)).toList();
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(modalCtx).size.height * 0.75,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isLeftSlot
                                  ? (LanguageService.instance.isEnglish ? "Product 1 (Left)" : "Produit 1 (Gauche)")
                                  : (LanguageService.instance.isEnglish ? "Product 2 (Right)" : "Produit 2 (Droite)"),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF172554),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Search Field
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          onChanged: (val) => setModalState(() => searchQuery = val),
                          decoration: InputDecoration(
                            hintText: LanguageService.instance.isEnglish ? "Search by brand or model..." : "Rechercher par marque ou modèle...",
                            hintStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Filter Chips Row
                      Row(
                        children: [
                          ChoiceChip(
                            label: Text(LanguageService.instance.isEnglish ? "All (${_availablePool.length})" : "Tous (${_availablePool.length})"),
                            selected: filterTab == 0,
                            selectedColor: const Color(0xFF172554),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: filterTab == 0 ? Colors.white : const Color(0xFF475569),
                            ),
                            onSelected: (_) => setModalState(() => filterTab = 0),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(LanguageService.instance.isEnglish ? "My Wardrobe (${wardrobe.length})" : "Mon Dressing (${wardrobe.length})"),
                            selected: filterTab == 1,
                            selectedColor: const Color(0xFF172554),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: filterTab == 1 ? Colors.white : const Color(0xFF475569),
                            ),
                            onSelected: (_) => setModalState(() => filterTab = 1),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(LanguageService.instance.isEnglish ? "Catalogue" : "Catalogue"),
                            selected: filterTab == 2,
                            selectedColor: const Color(0xFF172554),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: filterTab == 2 ? Colors.white : const Color(0xFF475569),
                            ),
                            onSelected: (_) => setModalState(() => filterTab = 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Flexible(
                        child: filteredList.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    LanguageService.instance.isEnglish ? "No products found" : "Aucun produit trouvé",
                                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filteredList.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                itemBuilder: (ctx, idx) {
                                  final item = filteredList[idx];
                                  final isAlreadySelected = (isLeftSlot
                                          ? _rightProduct?.id == item.id
                                          : _leftProduct?.id == item.id);

                                  return ListTile(
                                    enabled: !isAlreadySelected,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildProductThumbnail(item.imagePath),
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
                                      item.localizedTitle,
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
              ),
            );
          },
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
              const SizedBox(height: 18),

              if (_leftProduct != null && _rightProduct != null) ...[
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
                  category: LanguageService.instance.isEnglish ? "WAIST ACCENTUATION" : "AFFINEMENT DE LA TAILLE",
                  icon: Icons.accessibility_new_rounded,
                  leftBrand: _leftProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 1" : "PRODUIT 1"),
                  leftVal: _leftProduct?.waistVal ?? "--",
                  leftDesc: _leftProduct?.localizedWaistDesc ?? (LanguageService.instance.isEnglish ? "None selected" : "Aucun sélectionné"),
                  rightBrand: _rightProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 2" : "PRODUIT 2"),
                  rightVal: _rightProduct?.waistVal ?? "--",
                  rightDesc: _rightProduct?.localizedWaistDesc ?? (LanguageService.instance.isEnglish ? "None selected" : "Aucun sélectionné"),
                ),
                const SizedBox(height: 14),

                _buildMatrixMetricRow(
                  category: LanguageService.instance.isEnglish ? "DRAPE & LENGTH" : "TOMBÉ & LONGUEUR",
                  icon: Icons.vertical_align_bottom_rounded,
                  leftBrand: _leftProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 1" : "PRODUIT 1"),
                  leftVal: _leftProduct?.fitVal ?? "--",
                  leftDesc: _leftProduct?.localizedFitDesc ?? "--",
                  rightBrand: _rightProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 2" : "PRODUIT 2"),
                  rightVal: _rightProduct?.fitVal ?? "--",
                  rightDesc: _rightProduct?.localizedFitDesc ?? "--",
                ),
                const SizedBox(height: 14),

                _buildMatrixMetricRow(
                  category: LanguageService.instance.isEnglish ? "FABRIC WEIGHT & DRAPE" : "POIDS & DRAPÉ DU TISSU",
                  icon: Icons.grid_4x4_rounded,
                  leftBrand: _leftProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 1" : "PRODUIT 1"),
                  leftVal: _leftProduct?.fabricVal ?? "--",
                  leftDesc: _leftProduct?.localizedFabricDesc ?? "--",
                  rightBrand: _rightProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 2" : "PRODUIT 2"),
                  rightVal: _rightProduct?.fabricVal ?? "--",
                  rightDesc: _rightProduct?.localizedFabricDesc ?? "--",
                ),
                const SizedBox(height: 14),

                _buildVersatilityIndexRow(),
                const SizedBox(height: 22),

                // 8. Dreskode Neural Recommendation Card
                _buildNeuralRecommendationCard(),
                const SizedBox(height: 22),

                // 9. Primary Action: Comparaison de Tenues (Outfit Comparison)
                _buildOutfitComparisonButton(enabled: true),
              ] else ...[
                // Empty state when slots are not both selected
                _buildEmptyComparisonStateCard(),
                const SizedBox(height: 18),
                _buildOutfitComparisonButton(enabled: false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── EMPTY STATE WHEN SLOTS ARE PENDING ───────────────────────────────────

  Widget _buildEmptyComparisonStateCard() {
    final isEn = LanguageService.instance.isEnglish;
    final wardrobe = WardrobeService.instance.wardrobeItemsNotifier.value;
    final hasOne = (_leftProduct != null) ^ (_rightProduct != null);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: Color(0xFFF43F5E),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasOne
                ? (isEn ? "Select Second Piece to Compare" : "Sélectionnez la 2e pièce à comparer")
                : (isEn ? "Live Biometric Comparison" : "Comparaison Biométrique en Direct"),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              hasOne
                  ? (isEn
                      ? "Tap '+' on the empty slot above or pick from your wardrobe below to compare drape, fit, and tension."
                      : "Appuyez sur '+' sur l'emplacement vide ci-dessus ou choisissez dans votre dressing ci-dessous pour lancer la comparaison.")
                  : (isEn
                      ? "Add two garments using the '+' buttons above or tap pieces from your wardrobe below to calculate tension, cut, and fit differential."
                      : "Ajoutez deux vêtements avec les boutons '+' ci-dessus ou touchez des pièces de votre dressing ci-dessous pour calculer le différentiel de coupe, tombé et tension."),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ),
          if (wardrobe.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(Icons.checkroom_rounded, size: 15, color: Color(0xFFE11D48)),
                  const SizedBox(width: 6),
                  Text(
                    isEn ? "Quick Pick from Your Wardrobe:" : "Sélection rapide depuis votre Dressing :",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172554),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: wardrobe.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, idx) {
                  final w = wardrobe[idx];
                  final item = ProductCompareItem.fromWardrobe(w);
                  final isAlreadyInLeft = _leftProduct?.id == item.id;
                  final isAlreadyInRight = _rightProduct?.id == item.id;
                  final isSelected = isAlreadyInLeft || isAlreadyInRight;

                  return GestureDetector(
                    onTap: isSelected
                        ? null
                        : () {
                            setState(() {
                              if (_leftProduct == null) {
                                _leftProduct = item;
                              } else {
                                _rightProduct ??= item;
                              }
                            });
                          },
                    child: Container(
                      width: 165,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF1F5F9) : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildProductThumbnail(item.imagePath),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.brand,
                                  style: GoogleFonts.inter(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item.localizedTitle,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF172554),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSelected
                                      ? (isEn ? "✓ Selected" : "✓ Sélectionné")
                                      : (isEn ? "+ Tap to Add" : "+ Ajouter"),
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── 9. OUTFIT COMPARISON CTA BUTTON ────────────────────────────────────────

  Widget _buildOutfitComparisonButton({required bool enabled}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OutfitComparisonScreen(
                    leftProduct: _leftProduct,
                    rightProduct: _rightProduct,
                  ),
                ));
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
          foregroundColor: enabled ? Colors.white : const Color(0xFF94A3B8),
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          disabledForegroundColor: const Color(0xFF94A3B8),
          elevation: enabled ? 4 : 0,
          shadowColor: enabled ? const Color(0xFFF43F5E).withValues(alpha: 0.35) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              enabled
                  ? (LanguageService.instance.isEnglish ? "Outfit Comparison" : "Comparaison de Tenues")
                  : (LanguageService.instance.isEnglish ? "Select 2 Products to Compare" : "Sélectionnez 2 produits pour comparer"),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20, color: enabled ? Colors.white : const Color(0xFF94A3B8)),
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
        LanguageService.instance.isEnglish ? "Product Comparison" : "Comparaison de Produits",
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
            LanguageService.instance.isEnglish
                ? "SPATIAL SIMULATION + CAMILLE (174 CM)"
                : "SIMULATION SPATIALE + CAMILLE (174 CM)",
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
              LanguageService.instance.isEnglish
                  ? "Active Tension Map"
                  : "Carte de Tension Active",
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
                  LanguageService.instance.isEnglish
                      ? "360° Synchronized Orbit"
                      : "Orbite Synchronisée 360°",
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
                isLeft
                    ? (LanguageService.instance.isEnglish ? "Product 1 (Left)" : "Produit 1 (Gauche)")
                    : (LanguageService.instance.isEnglish ? "Product 2 (Right)" : "Produit 2 (Droite)"),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  LanguageService.instance.isEnglish
                      ? "Tap + to add from wardrobe or catalog"
                      : "Appuyez sur + pour ajouter (Dressing ou Catalogue)",
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
                    child: product.imagePath.startsWith('http')
                        ? Image.network(
                            product.imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, error, stack) => Image.asset(
                              'assets/images/product_dress.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          )
                        : Image.asset(
                            product.imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, error, stack) => Image.asset(
                              'assets/images/product_dress.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
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
                                product.localizedMatchScore,
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF43F5E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                product.localizedMatchSubtitle,
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
                  product.localizedTitle,
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

  // ── 3. SUB ATTRIBUTES ROW (DYNAMIC PRODUCT PROFILES) ─────────────────────
  Widget _buildSubAttributesRow() {
    final isEn = LanguageService.instance.isEnglish;
    final leftDesc = _leftProduct != null
        ? "${_leftProduct!.brand.split(' ').first} : ${_leftProduct!.localizedWaistDesc}"
        : (isEn ? "Product 1 : None selected" : "Produit 1 : Non sélectionné");
    final rightDesc = _rightProduct != null
        ? "${_rightProduct!.brand.split(' ').first} : ${_rightProduct!.localizedWaistDesc}"
        : (isEn ? "Product 2 : None selected" : "Produit 2 : Non sélectionné");

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
                leftDesc,
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
                rightDesc,
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
                        LanguageService.instance.isEnglish
                            ? "Seam Tension Differential"
                            : "Différentiel de Tension des Coutures",
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
                  LanguageService.instance.isEnglish
                      ? "Camille 3D Map"
                      : "Carte 3D Camille",
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
                  "${_leftProduct?.brand ?? (LanguageService.instance.isEnglish ? 'Product 1' : 'Produit 1')} : ${LanguageService.instance.isEnglish ? 'Waist & Bust Tension' : 'Tension Taille & Poitrine'}",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _leftProduct?.localizedTensionInfo ?? "--",
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
                  "${_rightProduct?.brand ?? (LanguageService.instance.isEnglish ? 'Product 2' : 'Produit 2')} : ${LanguageService.instance.isEnglish ? 'Sternum Clearance' : 'Blocage Sternum'}",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _rightProduct?.localizedTensionInfo ?? "--",
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
            LanguageService.instance.isEnglish
                ? "Anatomical Matrix"
                : "Matrice Anatomique",
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
              LanguageService.instance.isEnglish
                  ? "Base Chassis: Camille 88–66–94"
                  : "Châssis de Base : Camille 88–66–94",
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
    final isEn = LanguageService.instance.isEnglish;
    final leftName = _leftProduct != null
        ? "${isEn ? 'Choose' : 'Choisir'} ${_leftProduct!.brand.split(' ').first} ${_leftProduct!.sizeBadge}"
        : (isEn ? "Product 1 Empty" : "Produit 1 Vide");
    final leftSub = _leftProduct != null
        ? "${_leftProduct!.price} • ${isEn ? 'Perfect Fit' : 'Coupe Parfaite'}"
        : (isEn ? "Tap +" : "Appuyez sur +");

    final rightName = _rightProduct != null
        ? "${isEn ? 'Choose' : 'Choisir'} ${_rightProduct!.brand.split(' ').first} ${_rightProduct!.sizeBadge}"
        : (isEn ? "Product 2 Empty" : "Produit 2 Vide");
    final rightSub = _rightProduct != null
        ? "${_rightProduct!.price} • ${isEn ? 'Adjustment' : 'Ajustement'}"
        : (isEn ? "Tap +" : "Appuyez sur +");

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
              LanguageService.instance.isEnglish
                  ? "VERSATILITY INDEX"
                  : "INDICE DE POLYVALENCE",
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
                            _leftProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 1" : "PRODUIT 1"),
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
                            _leftProduct?.localizedVersatilityDesc ?? "--",
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
                            _rightProduct?.brand ?? (LanguageService.instance.isEnglish ? "PRODUCT 2" : "PRODUIT 2"),
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
                            _rightProduct?.localizedVersatilityDesc ?? "--",
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

    final isEn = LanguageService.instance.isEnglish;
    final recommendedText = bestItem != null
        ? (isEn
            ? "${bestItem.brand} ${bestItem.sizeBadge} is your anatomical ideal. Its cut perfectly honors your hourglass silhouette with ${bestItem.localizedMatchScore} and optimal drape on Camille's frame."
            : "${bestItem.brand} ${bestItem.sizeBadge} est votre idéal anatomique. Sa coupe honore parfaitement votre silhouette sablier avec ${bestItem.localizedMatchScore} et un drapé optimal sur le châssis de Camille.")
        : (isEn
            ? "Please select at least one product from the catalog to generate the neural recommendation."
            : "Veuillez sélectionner au moins un produit du catalogue pour générer la recommandation neuronale.");

    final zeroRiskText = bestItem != null
        ? (isEn
            ? "Zero return risk predicted for ${bestItem.brand}"
            : "Zéro risque de retour prédit pour ${bestItem.brand}")
        : (isEn
            ? "Select 2 products to compare"
            : "Sélectionnez 2 produits pour comparer");

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
                isEn
                    ? "FITVISOR NEURAL RECOMMENDATION"
                    : "RECOMMANDATION NEURONALE FITVISOR",
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
