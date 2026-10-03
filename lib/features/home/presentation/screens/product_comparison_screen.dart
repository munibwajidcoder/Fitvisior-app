import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductComparisonScreen extends StatefulWidget {
  const ProductComparisonScreen({super.key});

  @override
  State<ProductComparisonScreen> createState() => _ProductComparisonScreenState();
}

class _ProductComparisonScreenState extends State<ProductComparisonScreen> {
  int _selectedOption = 0; // 0 = Balmain, 1 = Saint Laurent

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

              // 2. Dual Render Comparison Cards (Balmain vs Saint Laurent)
              _buildDualProductComparisonCards(),
              const SizedBox(height: 14),

              // 3. Sub-row Attributes (Waist Accent & Silhouette)
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
                leftBrand: "BALMAIN",
                leftVal: "66,5 cm",
                leftDesc: "Sablier Accentué",
                rightBrand: "SAINT LAURENT",
                rightVal: "68,0 cm",
                rightDesc: "Coupe Parisienne Droite",
              ),
              const SizedBox(height: 14),

              _buildMatrixMetricRow(
                category: "TOMBÉ & LONGUEUR",
                icon: Icons.vertical_align_bottom_rounded,
                leftBrand: "BALMAIN",
                leftVal: "68,0 cm",
                leftDesc: "Finition Haut des Hanches",
                rightBrand: "SAINT LAURENT",
                rightVal: "72,0 cm",
                rightDesc: "Ligne Tuxedo Allongée",
              ),
              const SizedBox(height: 14),

              _buildMatrixMetricRow(
                category: "POIDS & DRAPÉ DU TISSU",
                icon: Icons.grid_4x4_rounded,
                leftBrand: "BALMAIN",
                leftVal: "280 g/m²",
                leftDesc: "Laine Vierge (Rigidité 4/5)",
                rightBrand: "SAINT LAURENT",
                rightVal: "310 g/m²",
                rightDesc: "Gabardine (Rigidité 5/5)",
              ),
              const SizedBox(height: 14),

              _buildVersatilityIndexRow(),
              const SizedBox(height: 22),

              // 8. Dreskode Neural Recommendation Card
              _buildNeuralRecommendationCard(),
            ],
          ),
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
          children: [
            // Left Card: Balmain
            Expanded(
              child: _buildComparisonCard(
                imagePath: 'assets/images/product_suit.jpg',
                brand: "BALMAIN PARIS",
                title: "Grain de Poudre DB",
                price: "2 190 €",
                sizeBadge: "FR 38",
                matchScore: "98,4% Correspondance",
                matchSubtitle: "Zéro retouche",
                hasTensionPoint: true,
              ),
            ),
            const SizedBox(width: 12),
            // Right Card: Saint Laurent
            Expanded(
              child: _buildComparisonCard(
                imagePath: 'assets/images/pose_profile.jpg',
                brand: "SAINT LAURENT",
                title: "Tuxedo Wool Cut",
                price: "2 450 €",
                sizeBadge: "FR 38",
                matchScore: "92,1% Correspondance",
                matchSubtitle: "Légère tension poitrine",
                hasTensionPoint: true,
                isRight: true,
              ),
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

  Widget _buildComparisonCard({
    required String imagePath,
    required String brand,
    required String title,
    required String price,
    required String sizeBadge,
    required String matchScore,
    required String matchSubtitle,
    bool hasTensionPoint = false,
    bool isRight = false,
  }) {
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
                      imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                // Red Tension Point Dot
                if (hasTensionPoint)
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
                                matchScore,
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF43F5E),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                matchSubtitle,
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
                  brand,
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
                  title,
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
                    Text(
                      price,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sizeBadge,
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

  // ── 3. SUB ATTRIBUTES ROW ────────────────────────────────────────────────

  Widget _buildSubAttributesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
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
        Container(width: 1, height: 12, color: const Color(0xFFCBD5E1)),
        Row(
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

          // Balmain Strain Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Balmain : Tension Taille & Poitrine",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "0,0 cm Tension (Fluide)",
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
              value: 0.15,
              backgroundColor: const Color(0xFFF1F5F9),
              color: const Color(0xFFF43F5E),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 12),

          // Saint Laurent Strain Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Saint Laurent : Blocage Sternum Supérieur",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "+1,8 cm Résistance",
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
              value: 0.78,
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
    return Row(
      children: [
        // Pick Balmain (Option 0)
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedOption = 0),
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
                    "Choisir Balmain FR 38",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _selectedOption == 0 ? Colors.white : const Color(0xFF172554),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "2 190 € • Coupe Parfaite",
                    style: GoogleFonts.inter(
                      fontSize: 10,
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
        // Pick Saint Laurent (Option 1)
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedOption = 1),
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
                    "Saint Laurent FR 38",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _selectedOption == 1 ? Colors.white : const Color(0xFFBE123C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "2 450 € • Retouche Nécessaire",
                    style: GoogleFonts.inter(
                      fontSize: 10,
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
            // Left Card (Balmain)
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
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leftVal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
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
            // Right Card (Saint Laurent)
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
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rightVal,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
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
            // Left Card (Balmain)
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BALMAIN",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "9.4",
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
                          "Jour au Soir",
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
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
            // Right Card (Saint Laurent)
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SAINT LAURENT",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              "8.8",
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
                          "Tenue de Soirée",
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
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
                "RECOMMANDATION NEURONALE DRESKODE",
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
            "Balmain FR 38 est votre idéal anatomique. Sa taille sculptée de 66,5 cm honore votre silhouette sablier de 66 cm sans aucun bâillement de boutons, tandis que Saint Laurent introduit 1,8 cm de tension au niveau de la clavicule de Camille.",
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
                    "Zéro risque de retour prédit pour Balmain",
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

