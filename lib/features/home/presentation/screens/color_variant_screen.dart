import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'size_selection_screen.dart';

class ColorVariantScreen extends StatefulWidget {
  const ColorVariantScreen({super.key});

  @override
  State<ColorVariantScreen> createState() => _ColorVariantScreenState();
}

class _ColorVariantScreenState extends State<ColorVariantScreen> {
  int _selectedColorIndex = 0;
  int _selectedHeroViewIndex = 0; // 0: 3D Avatar Drape, 1: Macro 4K Swatch
  int _selectedLiningIndex = 0; // 0: Signature Cupro, 1: Monogram Jacquard
  int _selectedHardwareIndex = 0; // 0: Gold Embossed, 1: Matte Black

  final List<_ColorwayOption> _colorways = [
    _ColorwayOption(
      name: "Bleu Nuit Minuit",
      subtitle: "Boutons Dorés Gravés • En Stock",
      price: "2.190 €",
      badge1: "CLASSIQUE ATELIER",
      badge1Color: const Color(0xFFE11D48),
      fitMatch: "Compatibilité 99,4%",
      swatchColor: const Color(0xFF172554),
      accentColor: const Color(0xFFD97706),
      isClassic: true,
    ),
    _ColorwayOption(
      name: "Noir Profond",
      subtitle: "Boutons en Corne Matte • Pur",
      price: "2.190 €",
      badge1: "2 Restants",
      badge1Color: const Color(0xFFE11D48),
      fitMatch: "Compatibilité 99,4%",
      swatchColor: const Color(0xFF1E293B),
      accentColor: const Color(0xFF64748B),
    ),
    _ColorwayOption(
      name: "Ivoire Albâtre",
      subtitle: "Boutons Argent Polie • SS25",
      price: "2.290 €",
      badge1: "Précommande",
      badge1Color: const Color(0xFF64748B),
      fitMatch: "FR 36, FR 38, FR 40",
      swatchColor: const Color(0xFFF5F2EB),
      accentColor: const Color(0xFF94A3B8),
    ),
    _ColorwayOption(
      name: "Camel Mêlé",
      subtitle: "Laine Vierge & Cachemire • Chaud",
      price: "2.350 €",
      badge1: "Mélange Cachemire",
      badge1Color: const Color(0xFFD97706),
      fitMatch: "Compatibilité 98,1%",
      swatchColor: const Color(0xFFB38E65),
      accentColor: const Color(0xFF78350F),
    ),
    _ColorwayOption(
      name: "Bordeaux Volcanique",
      subtitle: "Velours de Soie • Sur Commande",
      price: "2.490 €",
      badge1: "Défilé Limité",
      badge1Color: const Color(0xFF172554),
      fitMatch: "Haute Couture",
      swatchColor: const Color(0xFF581C25),
      accentColor: const Color(0xFFD97706),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final selectedColorway = _colorways[_selectedColorIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero 3D Rendu Interactive Stack
                    _buildHeroVisualStack(),
                    const SizedBox(height: 20),

                    // 2. En-tête Titre & Maison
                    _buildProductTitleHeader(),
                    const SizedBox(height: 20),

                    // 3. Nuancier d'Atelier (Atelier Colorways)
                    _buildColorwaysSection(),
                    const SizedBox(height: 24),

                    // 4. Inspecteur Physique des Textiles
                    _buildTextileInspectorSection(),
                    const SizedBox(height: 24),

                    // 5. Doublure & Boutonnerie Sur-Mesure
                    _buildBespokeHardwareSection(),
                    const SizedBox(height: 20),

                    // 6. Livraison d'Échantillon Tactile
                    _buildSampleDeliveryCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // 7. Barre d'Action Fixe Inférieure
            _buildBottomActionBar(selectedColorway),
          ],
        ),
      ),
    );
  }

  // ── BARRE D'APPLICATION ───────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF172554)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        "Sélection des Couleurs & Variantes",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
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

  // ── 1. HERO VISUAL STACK ──────────────────────────────────────────────────

  Widget _buildHeroVisualStack() {
    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/hero_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // En-tête Badge Top Left & Right Buttons
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE11D48),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "RENDU 4K HDR • ÉCLAIRAGE STUDIO",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wb_sunny_outlined,
                          size: 16, color: Color(0xFF172554)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.zoom_in_rounded,
                          size: 18, color: Color(0xFF172554)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Tag Overlay "Selected: Midnight Navy"
          Positioned(
            bottom: 58,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF172554),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Sélectionné : ${_colorways[_selectedColorIndex].name}",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Interactive Dual View Toggle Capsule Pill
          Positioned(
            bottom: 12,
            left: 24,
            right: 24,
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFF172554).withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedHeroViewIndex = 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: _selectedHeroViewIndex == 0
                              ? const Color(0xFF172554)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.accessibility_new_rounded,
                                size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              "Drapé Avatar 3D",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedHeroViewIndex = 1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: _selectedHeroViewIndex == 1
                              ? const Color(0xFF172554)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grid_view_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.7)),
                            const SizedBox(width: 6),
                            Text(
                              "Échantillon Macro 4K",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // ── 2. PRODUCT TITLE HEADER ───────────────────────────────────────────────

  Widget _buildProductTitleHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "BALMAIN PARIS ATELIER",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE11D48),
                letterSpacing: 0.5,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.verified_outlined,
                    size: 13, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  "Jumeau Numérique Sur-Mesure",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Blazer Croisé en Laine Grain de Poudre",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Silhouette croisée emblématique à revers en pointe, boutons dorés gravés de la Maison et drapé infroissable 4 saisons.",
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: const Color(0xFF64748B),
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ── 3. NUANCIER D'ATELIER ────────────────────────────────────────────────

  Widget _buildColorwaysSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Nuancier d'Atelier",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
            Text(
              "5 Nuances d'Atelier",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: _colorways.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isSelected = _selectedColorIndex == idx;

            return GestureDetector(
              onTap: () => setState(() => _selectedColorIndex = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF172554)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF172554)
                                .withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Color Circle Swatch with accent gold dot
                    Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.swatchColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: item.swatchColor ==
                                          const Color(0xFFF5F2EB)
                                      ? const Color(0xFF172554)
                                      : Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: item.accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF172554),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.badge1Color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.badge1,
                                  style: GoogleFonts.inter(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: item.badge1Color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price & Match
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.fitMatch,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.price,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF172554),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 4. INSPECTEUR PHYSIQUE DES TEXTILES ───────────────────────────────────

  Widget _buildTextileInspectorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.biotech_rounded,
                    size: 16, color: Color(0xFFE11D48)),
                const SizedBox(width: 6),
                Text(
                  "Inspecteur Physique des Textiles",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ],
            ),
            Text(
              "Vérifié en Labo",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2x2 Grid Cards
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: [
            _buildPhysicsCard(
              icon: Icons.layers_rounded,
              badge: "Résistant au Fluage",
              badgeColor: const Color(0xFFE11D48),
              label: "CONSTRUCTION DU TISSAGE",
              value: "Grain de Poudre",
              desc: "Laine vierge peignée haute torsion au toucher sec et net.",
            ),
            _buildPhysicsCard(
              icon: Icons.scale_rounded,
              badge: "Toutes Saisons",
              badgeColor: const Color(0xFF10B981),
              label: "DENSITÉ SURFACIQUE",
              value: "280 g/m²",
              desc: "Grammage moyen au drapé naturel impeccable sous gravité.",
            ),
            _buildPhysicsCard(
              icon: Icons.auto_awesome_outlined,
              badge: "Index 0,22",
              badgeColor: const Color(0xFF64748B),
              label: "RÉFLECTANCE LUMINEUSE",
              value: "Brillance Architecturale",
              desc: "Satinage discret soulignant la carrure des épaules.",
            ),
            _buildPhysicsCard(
              icon: Icons.loop_rounded,
              badge: "99,2%",
              badgeColor: const Color(0xFFE11D48),
              label: "MÉMOIRE ÉLASTIQUE",
              value: "Récupération 99,2%",
              desc:
                  "Résilience instantanée après simulation de mouvements assis.",
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhysicsCard({
    required IconData icon,
    required String badge,
    required Color badgeColor,
    required String label,
    required String value,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: const Color(0xFF172554)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.3,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 9.5,
                color: const Color(0xFF64748B),
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. DOUBLURE & BOUTONNERIE SUR-MESURE ─────────────────────────────────

  Widget _buildBespokeHardwareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Doublure & Boutonnerie Sur-Mesure",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
            Text(
              "Inclus",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Sub 1: Interior Lining Fabric
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Tissu de Doublure Intérieure",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            Text(
              "Soie Cupro Signature",
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedLiningIndex = 0),
                child: _buildBespokeOptionCard(
                  title: "Cupro Signature",
                  desc: "Thermorégulation & glissement antistatique.",
                  isSelected: _selectedLiningIndex == 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedLiningIndex = 1),
                child: _buildBespokeOptionCard(
                  title: "Jacquard Monogramme",
                  desc: "Tissage jacquard ton sur ton aux initiales PB.",
                  isSelected: _selectedLiningIndex == 1,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Sub 2: Architectural Button Hardware
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Boutonnerie Architecturale",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            Text(
              "Écusson Doré Balmain",
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedHardwareIndex = 0),
                child: _buildHardwareOptionCard(
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFFD97706),
                  title: "Doré Gravé",
                  desc: "Patrimoine Atelier",
                  isSelected: _selectedHardwareIndex == 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedHardwareIndex = 1),
                child: _buildHardwareOptionCard(
                  icon: Icons.circle,
                  iconColor: const Color(0xFF1E293B),
                  title: "Noir Mat",
                  desc: "Émail Discret",
                  isSelected: _selectedHardwareIndex == 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBespokeOptionCard({
    required String title,
    required String desc,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF172554)
              : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: Color(0xFF172554)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              color: const Color(0xFF64748B),
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF172554)
              : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
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

  // ── 6. LIVRAISON D'ÉCHANTILLON TACTILE ──────────────────────────────────

  Widget _buildSampleDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('assets/images/product_dress.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Livraison d'Échantillon Tactile",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Demandez un échantillon physique envoyé gratuitement à votre salon privé.",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Échantillon tactile commandé avec succès !",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF172554),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Text(
                "Commander",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF172554),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. BARRE D'ACTION FIXE INFÉRIEURE ─────────────────────────────────────

  Widget _buildBottomActionBar(_ColorwayOption selectedColorway) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
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
      child: Row(
        children: [
          // Price info on left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedColorway.price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              Text(
                "Taxes incl. • ${selectedColorway.name}",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Pink CTA button on right
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SizeSelectionScreen(),
                  ),
                );
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                    const Icon(Icons.auto_awesome_rounded,
                        size: 15, color: Colors.white),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "Appliquer & Voir sur l'Avatar",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}

// ── COLORWAY OPTION MODEL ───────────────────────────────────────────────────

class _ColorwayOption {
  final String name;
  final String subtitle;
  final String price;
  final String badge1;
  final Color badge1Color;
  final String fitMatch;
  final Color swatchColor;
  final Color accentColor;
  final bool isClassic;

  _ColorwayOption({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.badge1,
    required this.badge1Color,
    required this.fitMatch,
    required this.swatchColor,
    required this.accentColor,
    this.isClassic = false,
  });
}
