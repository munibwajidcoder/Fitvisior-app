import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedFaqIndex = 0; // Default open FAQ 1
  bool _showAssistantFloatingBanner = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> _faqList = [
    {
      'question': 'Comment FitVisor calibre-t-il mon avatar 3D ?',
      'answer':
          'Notre moteur de scan neuronal capture 48 points biométriques à partir de 3 photos rapides, simulant la physique du tissu, la tension des coutures et le module de cisaillement contre vos proportions corporelles exactes avec une précision sous-millimétrique.',
      'badge': '✔ Moteur Tissu Propriétaire RealDrape™',
    },
    {
      'question':
          'Et si le vêtement physique ne taille pas comme la simulation 3D ?',
      'answer':
          'FitVisor offre des retours et échanges gratuits sous 30 jours. De plus, notre algorithme recalibre automatiquement votre avatar 3D en fonction de vos retours d\'essayage post-achat pour une précision toujours plus parfaite.',
      'badge': '✔ Garantie d\'Ajustement 100%',
    },
    {
      'question':
          'Comment réajuster ou affiner les mesures de mon scan corporel ?',
      'answer':
          'Vous pouvez relancer un scan 3D à tout moment depuis l\'onglet Calibrer. Vous pouvez également ajuster manuellement vos tours de taille, poitrine et carrure dans votre Profil Biométrique.',
      'badge': '✔ Recalibrage Manuel Illimité',
    },
    {
      'question':
          'Puis-je essayer plusieurs vêtements ensemble dans une tenue ?',
      'answer':
          'Absolument ! Le Studio d\'Ajustement Spatial de FitVisor gère le drapé multicouche en temps réel (ex: chemise, blazer et manteau) en simulant les frottements et l\'aisance entre tissus.',
      'badge': '✔ Drapé Multi-Couches 3D',
    },
    {
      'question': 'Comment fonctionne l\'essai gratuit Pro de 14 jours ?',
      'answer':
          'Vous profitez de 14 jours d\'accès illimité au rendu 3D haute définition, aux recommandations prioritaires de nos stylistes de Paris et Milan, sans aucun prélèvement automatique.',
      'badge': '✔ Sans Engagement de Durée',
    },
  ];

  void _openLiveChatBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF43F5E), width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/profile_avatar.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A34A),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Camille • Styliste FitVisor",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        Text(
                          "En ligne • Studio Paris & Milan",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Chat Message Area
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Text(
                        "Bonjour Alexa ! Je suis Camille, votre styliste FitVisor dédiée. Avez-vous une question sur le drapé de votre blazer ou le calibrage de votre avatar 3D ?",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF172554),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Input Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Posez votre question à Camille...",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final filteredFaqs = _faqList.where((faq) {
      if (_searchQuery.isEmpty) return true;
      final q = faq['question']!.toLowerCase();
      final a = faq['answer']!.toLowerCase();
      return q.contains(_searchQuery.toLowerCase()) ||
          a.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      appBar: _buildAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildLiveStylistChatFAB(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Dark Concierge Header Banner
              _buildTopConciergeCard(),
              const SizedBox(height: 16),

              // 2. Search Input Bar
              _buildSearchBar(),
              const SizedBox(height: 20),

              // 3. Section: Explore Topics (Explorer les Sujets)
              _buildExploreTopicsSection(),
              const SizedBox(height: 18),

              // 4. Pro Calibration Tip Card
              _buildProCalibrationTipCard(),
              const SizedBox(height: 24),

              // 5. Section: Frequently Answered (Foire Aux Questions)
              _buildFaqSection(filteredFaqs),
              const SizedBox(height: 24),

              // 6. Digital Couture Stylists Contact Box
              _buildStylistsContactCard(),
              const SizedBox(height: 20),

              // 7. Floating Assistant Banner (Camille Fit Expert)
              if (_showAssistantFloatingBanner) _buildAssistantFloatingBanner(),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAF9FB),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF172554)),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Aide & Support",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
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

  // ── 1. TOP CONCIERGE HEADER BANNER ───────────────────────────────────────

  Widget _buildTopConciergeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF172554)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.qr_code_scanner_rounded,
              size: 64,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
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
                    const SizedBox(width: 6),
                    Text(
                      "Concierge Atelier En Direct",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Comment nos stylistes peuvent-ils vous aider aujourd'hui ?",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Obtenez une aide rapide pour les scans biométriques, le drapé 3D ou le suivi de vos commandes.",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. SEARCH INPUT BAR ──────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF172554)),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
          hintText: "Rechercher drapé, scans 3D, tailles...",
          hintStyle: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ── 3. SECTION: EXPLORE TOPICS ───────────────────────────────────────────

  Widget _buildExploreTopicsSection() {
    final topics = [
      {
        'title': 'Avatar 3D & Scan',
        'subtitle': 'Biométrie & photogrammétrie',
        'icon': Icons.accessibility_new_rounded,
        'bg': const Color(0xFFEEF2FF),
        'iconColor': const Color(0xFF4F46E5),
      },
      {
        'title': 'Taille & Drapé',
        'subtitle': 'Physique des tissus & tension',
        'icon': Icons.straighten_rounded,
        'bg': const Color(0xFFFFF1F2),
        'iconColor': const Color(0xFFE11D48),
      },
      {
        'title': 'Commandes & Retours',
        'subtitle': 'Échanges & suivi livraison',
        'icon': Icons.inventory_2_outlined,
        'bg': const Color(0xFFF1F5F9),
        'iconColor': const Color(0xFF475569),
      },
      {
        'title': 'Offre Pro & Factures',
        'subtitle': 'Essai 14j & abonnement',
        'icon': Icons.credit_card_rounded,
        'bg': const Color(0xFFF1F5F9),
        'iconColor': const Color(0xFF475569),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Explorer les Sujets",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
            Text(
              "4 guides spécialisés",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final t = topics[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: t['bg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(t['icon'] as IconData,
                        size: 18, color: t['iconColor'] as Color),
                  ),
                  const Spacer(),
                  Text(
                    t['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF172554),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t['subtitle'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── 4. PRO CALIBRATION TIP CARD ──────────────────────────────────────────

  Widget _buildProCalibrationTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/hero_banner.jpg',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CONSEIL DE CALIBRAGE PRO",
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE11D48),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Perfection du Scan en Lumière Naturelle",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Assurez un éclairage matinal diffus pour un rendu ultra-précis des micro-plis et de la silhouette...",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. SECTION: FREQUENTLY ANSWERED (FAQ ACCORDION) ──────────────────────

  Widget _buildFaqSection(List<Map<String, String>> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Foire Aux Questions",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
            Text(
              "Appuyer pour voir",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqs.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final isExpanded = _expandedFaqIndex == index;
            final faq = faqs[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedFaqIndex = isExpanded ? null : index;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isExpanded
                                  ? const Color(0xFFF43F5E)
                                  : const Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              faq['question']!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF172554),
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF64748B),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expanded Content Answer Box
                  if (isExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              faq['answer']!,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF475569),
                                height: 1.45,
                              ),
                            ),
                            if (faq['badge'] != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      size: 13, color: Color(0xFFE11D48)),
                                  const SizedBox(width: 4),
                                  Text(
                                    faq['badge']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFE11D48),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ── 6. DIGITAL COUTURE STYLISTS CONTACT CARD ─────────────────────────────

  Widget _buildStylistsContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Double Avatar Stack
              SizedBox(
                width: 48,
                height: 34,
                child: Stack(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/profile_avatar.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/avatar_3d.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Stylistes Couture Digitale",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                    Text(
                      "Besoin d'un conseil ? Nos studios de Paris & Milan sont actifs.",
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 13, color: Color(0xFFE11D48)),
              const SizedBox(width: 4),
              Text(
                "Temps d'attente actuel : ~2 minutes",
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE11D48),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons Row (Email Support & Start Instant Chat)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Redirection vers support@fitvisor.com...",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFF172554),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.email_outlined, size: 16),
                  label: Text(
                    "Support E-mail",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF172554),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openLiveChatBottomSheet,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  label: Text(
                    "Chat Instantané",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF172554),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 7. FLOATING ASSISTANT BANNER ─────────────────────────────────────────

  Widget _buildAssistantFloatingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/profile_avatar.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Camille (Fit Expert)",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  "\"Bloqué sur un ourlet ou un drapé ? Appuyez sur le chat !\"",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showAssistantFloatingBanner = false;
              });
            },
            child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ── FLOATING LIVE STYLIST CHAT FAB ───────────────────────────────────────

  Widget _buildLiveStylistChatFAB() {
    return GestureDetector(
      onTap: _openLiveChatBottomSheet,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF43F5E), // Theme Coral Pink
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF43F5E).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              "Chat Styliste En Direct",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
