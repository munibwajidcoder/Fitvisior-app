import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../scan/presentation/screens/avatar_preview_screen.dart';
import '../../../scan/presentation/screens/manual_measurements_screen.dart';

class SizeSelectionScreen extends StatefulWidget {
  const SizeSelectionScreen({super.key});

  @override
  State<SizeSelectionScreen> createState() => _SizeSelectionScreenState();
}

class _SizeSelectionScreenState extends State<SizeSelectionScreen> {
  String _selectedStandard = 'FR (France)';
  String _selectedSizeCode = 'FR 36';

  static const Color _midnightNavy = Color(0xFF172554);

  final List<String> _standards = [
    'FR (France)',
    'IT (Italie)',
    'US (États-Unis)',
    'UK (Royaume-Uni)',
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Sub-Banner: AI 3D Fitting & Security
                    _buildSubBanner(),
                    const SizedBox(height: 14),

                    // 1. En-tête Produit
                    _buildProductHeader(),
                    const SizedBox(height: 16),

                    // 2. Carte Telemetrie Profile & Mensurations (Navy Container #172554)
                    _buildUserProfileCard(),
                    const SizedBox(height: 20),

                    // 3. Sélecteur de Normes de Taille (FR, IT, US, UK)
                    _buildSizeStandardsSelector(),
                    const SizedBox(height: 20),

                    // 4. Prédictions d'Ajustement Algorithmique (Fit Predictions)
                    _buildFitPredictionsSection(),
                    const SizedBox(height: 20),

                    // 5. Carte Thermique de Tension du Tissu 3D
                    _buildHeatmapSection(),
                    const SizedBox(height: 16),

                    // 6. Boîte d'Informations Indicatives d'Ajustement
                    _buildIndicativeInfoCard(),
                    const SizedBox(height: 16),

                    // 7. Carte Tissu & Coupe (Fabric & Fit)
                    _buildFabricAndFitCard(),
                    const SizedBox(height: 12),

                    // 8. Info Notice Banner
                    _buildNoticeBanner(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 9. Barre d'Action Fixe Inférieure (Boutons Principal & Secondaire)
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left_rounded,
          size: 28,
          color: _midnightNavy,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        "Guide des Tailles & Ajustement",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: _midnightNavy,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            size: 20,
            color: _midnightNavy,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Guide des tailles partagé !",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 4),
          child: Container(
            width: 34,
            height: 34,
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

  // ── TOP SUB BANNER ─────────────────────────────────────────────────────────
  Widget _buildSubBanner() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "Ajustement 3D IA",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE11D48),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  "• Basé sur vos photos & mensurations",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 13,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 3),
            Text(
              "Sécurisé & Privé",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 1. EN-TÊTE PRODUIT ────────────────────────────────────────────────────
  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                "Grain de Poudre Blazer",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _midnightNavy,
                  letterSpacing: -0.4,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "2 490 €",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Blazer structuré à revers crantés  •  100% laine vierge",
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ── 2. CARTE TELEMETRIE PROFILE & MENSURATIONS (NAVY CONTAINER #172554) ───
  Widget _buildUserProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _midnightNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _midnightNavy.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row with User Avatar & Brand Pill
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Camille Laurent",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: Color(0xFF38BDF8),
                        ),
                      ],
                    ),
                    Text(
                      "Mode Féminine de Luxe & Premium",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "LOUIS",
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          "CAMILLE",
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4 Grid Telemetry Cards
          Row(
            children: [
              _buildTelemetryTile(value: "176", unit: "cm", label: "Taille"),
              const SizedBox(width: 8),
              _buildTelemetryTile(value: "88", unit: "cm", label: "Poitrine"),
              const SizedBox(width: 8),
              _buildTelemetryTile(value: "66", unit: "cm", label: "Taille"),
              const SizedBox(width: 8),
              _buildTelemetryTile(value: "94", unit: "cm", label: "Hanches"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTile({
    required String value,
    required String unit,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. SÉLECTEUR DE NORMES DE TAILLE (FR, IT, US, UK) ─────────────────────
  Widget _buildSizeStandardsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Normes de Taille",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _midnightNavy,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFF4F46E5),
                ),
                const SizedBox(width: 4),
                Text(
                  "Guide des Tailles Authentique",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(_standards.length, (index) {
            final selected = _selectedStandard == _standards[index];
            return Expanded(
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedStandard = _standards[index]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                    right: index == _standards.length - 1 ? 0 : 8,
                  ),
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? _midnightNavy : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? _midnightNavy
                          : const Color(0xFFE2E8F0),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${_standards[index].split(' ')[0]} (${_standards[index].split('(')[1].replaceAll(')', '')})",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── 4. PRÉDICTIONS D'AJUSTEMENT (FIT PREDICTIONS) ─────────────────────────
  Widget _buildFitPredictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: Color(0xFFE11D48),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Vos Prédictions d'Ajustement",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: _midnightNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "SIMULATION EN DIRECT",
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE11D48),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Prediction Item 1: Top Fit Recommended
        _buildPredictionCard(
          sizeCode: "FR 36",
          title: "Top Fit – Recommandé",
          subtitle: "Bon ajustement pour vos mensurations et morphologie.",
          isSelected: _selectedSizeCode == 'FR 36',
          onTap: () => setState(() => _selectedSizeCode = 'FR 36'),
        ),
        const SizedBox(height: 10),

        // Prediction Item 2: Fitted Silhouette REGULAR
        _buildPredictionCard(
          sizeCode: "FR 36",
          title: "Silhouette Ajustée",
          tagText: "REGULAR",
          subtitle: "Légèrement structuré • Donne un look défini.",
          isSelected: false,
          onTap: () => setState(() => _selectedSizeCode = 'FR 36'),
        ),
        const SizedBox(height: 10),

        // Recommendation Featured Highlight Box (FR 36)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.track_changes_rounded,
                          size: 16,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "Recommandation estimée",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _midnightNavy,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Confiance : Modérée",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _midnightNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "FR",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          "36",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Taille recommandée : 36",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _midnightNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Basé sur vos mensurations et le tableau des tailles de la marque.",
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Prediction Item 4: Relaxed Fit (FR 40)
        _buildPredictionCard(
          sizeCode: "FR 40",
          title: "Coupe Décontractée",
          subtitle: "Plus d'espace pour le confort.",
          isSelected: _selectedSizeCode == 'FR 40',
          onTap: () => setState(() => _selectedSizeCode = 'FR 40'),
        ),
        const SizedBox(height: 10),

        // Prediction Item 5: Oversized (FR 42)
        _buildPredictionCard(
          sizeCode: "FR 42",
          title: "Oversized",
          subtitle: "Un style plus ample et décontracté.",
          isSelected: _selectedSizeCode == 'FR 42',
          onTap: () => setState(() => _selectedSizeCode = 'FR 42'),
        ),
      ],
    );
  }

  Widget _buildPredictionCard({
    required String sizeCode,
    required String title,
    String? tagText,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final codeParts = sizeCode.split(' ');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _midnightNavy : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    codeParts[0],
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    codeParts.length > 1 ? codeParts[1] : '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _midnightNavy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _midnightNavy,
                        ),
                      ),
                      if (tagText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tagText,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. CARTE THERMIQUE DE TENSION DU TISSUS 3D ────────────────────────────
  Widget _buildHeatmapSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Carte Thermique de Tension du Tissu 3D",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Color(0xFFE11D48),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "Simulation indicative — pas une mesure physique",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          // Custom 3D Blazer Tension Diagram
          Center(
            child: SizedBox(
              width: 180,
              height: 110,
              child: CustomPaint(
                painter: _AvatarHeatmapPainter(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Legend — Overflow proof Wrap layout
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 6,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Faible tension (plus flexible)",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF43F5E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Forte tension (moins flexible)",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
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

  // ── 6. BOÎTE D'INFORMATIONS INDICATIVES D'AJUSTEMENT ──────────────────────
  Widget _buildIndicativeInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              size: 16,
              color: Color(0xFFE11D48),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Informations d'Ajustement Indicatives",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "La carte thermique montre les zones de plus ou moins grande tension du tissu selon vos mensurations. L'ajustement réel peut varier selon le tissu et la coupe.",
                  style: GoogleFonts.inter(
                    fontSize: 11,
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

  // ── 7. CARTE TISSU & COUPE (FABRIC & FIT) ───────────────────────────────────
  Widget _buildFabricAndFitCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/product_suit.jpg',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, s) => Container(
                width: 48,
                height: 48,
                color: const Color(0xFFF1F5F9),
                child: const Icon(
                  Icons.texture_rounded,
                  size: 24,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tissu & Coupe",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _midnightNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Composition : 100% laine vierge",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  "Coupe : Blazer structuré à revers crantés",
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
    );
  }

  // ── 8. INFO NOTICE BANNER ──────────────────────────────────────────────────
  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFF3B82F6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "L'ajustement peut varier selon la taille, le tissu et la morphologie.",
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 9. BARRE D'ACTION FIXE INFÉRIEURE ─────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Button: Midnight Navy #172554
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AvatarPreviewScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E), // Coral Pink
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "✨ Confirmer $_selectedSizeCode & Accéder à la Cabine d'Essayage Virtuelle",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Secondary Button: Edit Measurements (Modifier les Mensurations)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ManualMeasurementsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _midnightNavy,
                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: _midnightNavy,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Modifier les Mensurations",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _midnightNavy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PAINTER CUSTOM AVATAR HEATMAP ──────────────────────────────────────────
class _AvatarHeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final headPaint = Paint()
      ..color = const Color(0xFF172554)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(center.dx, 14), 7, headPaint);

    final blazerPath = Path();
    blazerPath.moveTo(center.dx - 12, 24);
    blazerPath.lineTo(center.dx - 36, 34);
    blazerPath.lineTo(center.dx - 30, 95);
    blazerPath.lineTo(center.dx - 20, 95);
    blazerPath.lineTo(center.dx - 22, 60);
    blazerPath.lineTo(center.dx, 70);
    blazerPath.lineTo(center.dx + 22, 60);
    blazerPath.lineTo(center.dx + 20, 95);
    blazerPath.lineTo(center.dx + 30, 95);
    blazerPath.lineTo(center.dx + 36, 34);
    blazerPath.lineTo(center.dx + 12, 24);
    blazerPath.close();

    canvas.drawPath(blazerPath, headPaint);

    final redHaloPaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 32, 36), 9, redHaloPaint);
    canvas.drawCircle(Offset(center.dx + 32, 36), 9, redHaloPaint);

    final greenHaloPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx, 76), width: 26, height: 14),
      greenHaloPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

