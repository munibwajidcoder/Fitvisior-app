import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/screens/home_screen.dart' show HomeScreen;

class UserStylePreferencesScreen extends StatefulWidget {
  const UserStylePreferencesScreen({super.key});

  @override
  State<UserStylePreferencesScreen> createState() =>
      _UserStylePreferencesScreenState();
}

class _UserStylePreferencesScreenState
    extends State<UserStylePreferencesScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP NAVIGATION BAR ──────────────────────────────────
            _buildTopBar(),

            // ── SCROLLABLE BODY ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),

                    // Step badge
                    _buildStepBadge(),
                    const SizedBox(height: 10),

                    // Page title
                    Text(
                      "Vos Préférences\nde Style",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.8,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choisissez vos préférences pour personnaliser\nvos recommandations de tenues.",
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── AVATAR PROFILE CARD ──────────────────────────
                    _buildAvatarProfileCard(),

                    const SizedBox(height: 20),

                    // ── PROFIL & MESURES SECTION ─────────────────────
                    _buildSectionHeader(
                      title: "Profil & Mensurations",
                      badge: "Complété",
                      isCompleted: true,
                    ),
                    const SizedBox(height: 10),
                    _buildListCard(children: [
                      _buildListItem(
                        icon: Icons.person_outline_rounded,
                        title: "Avatar créé",
                        subtitle:
                            "Votre avatar 3D et vos mensurations sont prêts.",
                        onTap: () {},
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildListItem(
                        icon: Icons.edit_outlined,
                        title: "Corrections",
                        subtitle:
                            "Examinez et ajustez votre avatar si nécessaire.",
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ]),

                    const SizedBox(height: 22),

                    // ── STYLE PREFERENCES SECTION ────────────────────
                    _buildSectionHeader(
                      title: "Vos Préférences de Style",
                      badge: "Étape 4 sur 4",
                      isCompleted: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Choisissez vos préférences pour personnaliser.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildListCard(children: [
                      _buildListItem(
                        icon: Icons.checkroom_outlined,
                        title: "Préférences de Style",
                        subtitle: "Sélectionnez votre style préféré.",
                        onTap: () {},
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildListItem(
                        icon: Icons.people_outline_rounded,
                        title: "Préférences d'Ajustement",
                        subtitle:
                            "Choisissez comment vous aimez que vos vêtements s'ajustent.",
                        onTap: () {},
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildListItem(
                        icon: Icons.palette_outlined,
                        title: "Préférences de Couleurs",
                        subtitle:
                            "Choisissez vos teintes de couleurs préférées.",
                        onTap: () {},
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // ── PRIVACY NOTICE ───────────────────────────────
                    _buildPrivacyNotice(),

                    const SizedBox(height: 22),

                    // ── CTA BUTTON ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Enregistrer & Continuer vers l'Accueil",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 28,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Image.asset('assets/images/logo.png', width: 26, height: 26),
          const SizedBox(width: 6),
          Text(
            "FitVisor",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded,
                color: Color(0xFF64748B), size: 23),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_bag_outlined,
                color: Color(0xFF64748B), size: 23),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.4),
                  width: 1.8),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile_avatar.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP BADGE ────────────────────────────────────────────────────────

  Widget _buildStepBadge() {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFF43F5E),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          "ÉTAPE 4 SUR 4  •  PROFIL & PRÉFÉRENCES",
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFF43F5E),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  // ── AVATAR PROFILE CARD ───────────────────────────────────────────────

  Widget _buildAvatarProfileCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: Avatar + Info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/profile_avatar.jpg',
                        width: 72,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.7),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          "AVATAR",
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "Camille Laurent",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Modifier",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF43F5E),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    size: 14, color: Color(0xFFF43F5E)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Avatar  •  174 cm  •  62 kg",
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF94A3B8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Measurement Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(child: _buildMeasurementCell("TAILLE", "174 cm")),
                const SizedBox(width: 8),
                Expanded(child: _buildMeasurementCell("BUSTE", "86 cm")),
                const SizedBox(width: 8),
                Expanded(child: _buildMeasurementCell("CEINTURE", "66 cm")),
                const SizedBox(width: 8),
                Expanded(child: _buildMeasurementCell("HANCHES", "94 cm")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCell(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 7.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required String title,
    required String badge,
    required bool isCompleted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted) ...[
                const Icon(Icons.check_circle_rounded,
                    size: 13, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
              ],
              Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── WHITE LIST CARD ───────────────────────────────────────────────────

  Widget _buildListCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── LIST ITEM ROW ─────────────────────────────────────────────────────

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF475569)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF94A3B8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  // ── PRIVACY NOTICE ────────────────────────────────────────────────────

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(Icons.lock_outline_rounded,
                size: 18, color: Color(0xFF475569)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Votre profil et vos préférences sont chiffrés et utilisés uniquement pour les recommandations.",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

