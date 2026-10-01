import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'avatar_identity_screen.dart';

class ConsentPrivacyScreen extends StatefulWidget {
  const ConsentPrivacyScreen({super.key});

  @override
  State<ConsentPrivacyScreen> createState() => _ConsentPrivacyScreenState();
}

class _ConsentPrivacyScreenState extends State<ConsentPrivacyScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      body: SafeArea(
        child: Column(
          children: [
            // ---- TOP APP BAR ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', width: 32, height: 32),
                  const SizedBox(width: 10),
                  Text(
                    "Consentement & Confidentialité",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),

            // ---- SCROLLABLE CONTENT ----
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ---- PRIVACY SHIELD AVATAR HERO ----
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF43F5E),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              'assets/images/profile_avatar.jpg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A5F),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ---- TITLE ----
                    Text(
                      "Vos photos, votre vie privée",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Nous croyons que la mode virtuelle doit être sécurisée, transparente et entièrement sous votre contrôle.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ---- CARD 1: Avatar Virtuel Uniquement ----
                    _buildPrivacyCard(
                      icon: Icons.accessibility_new_rounded,
                      iconColor: const Color(0xFF1E3A5F),
                      iconBg: const Color(0xFFEEF2FF),
                      title: "Avatar Virtuel Uniquement",
                      badge: "Isolé",
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeColor: const Color(0xFF64748B),
                      description:
                          "Vos photos et mesures sont utilisées exclusivement pour générer votre mannequin 3D d'essayage personnalisé. Elles ne sont jamais publiées ni partagées.",
                    ),

                    const SizedBox(height: 12),

                    // ---- CARD 2: Chiffré & Privé ----
                    _buildPrivacyCard(
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFF1E3A5F),
                      iconBg: const Color(0xFFEEF2FF),
                      title: "Chiffré & Privé",
                      badge: "Coffre Protégé",
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeColor: const Color(0xFF64748B),
                      description:
                          "Toutes les données visuelles biométriques sont traitées avec un chiffrement de bout en bout et stockées en toute sécurité dans votre coffre privé.",
                    ),

                    const SizedBox(height: 12),

                    // ---- CARD 3: Supprimer à Tout Moment ----
                    _buildPrivacyCard(
                      icon: Icons.delete_outline_rounded,
                      iconColor: const Color(0xFF1E3A5F),
                      iconBg: const Color(0xFFEEF2FF),
                      title: "Supprimer à Tout Moment",
                      badge: "1 Appui",
                      badgeBg: const Color(0xFFFFF1F2),
                      badgeColor: const Color(0xFFF43F5E),
                      description:
                          "Vous êtes entièrement propriétaire. Effacez vos mesures, scans photo et historique d'essayage à tout moment en un seul appui dans les paramètres du compte.",
                    ),

                    const SizedBox(height: 22),

                    // ---- CHECKBOX ----
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: _agreed,
                            activeColor: const Color(0xFFF43F5E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            side: const BorderSide(
                              color: Color(0xFFCBD5E1),
                              width: 1.8,
                            ),
                            onChanged: (val) =>
                                setState(() => _agreed = val ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text:
                                  "Je confirme avoir au moins 13 ans et j'accepte les ",
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: "Conditions d'utilisation",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF43F5E),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFFF43F5E),
                                  ),
                                ),
                                const TextSpan(text: " & "),
                                TextSpan(
                                  text: "Politique de confidentialité",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF43F5E),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFFF43F5E),
                                  ),
                                ),
                                const TextSpan(text: "."),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ---- AGREE BUTTON ----
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _agreed
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AvatarIdentityScreen(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          disabledBackgroundColor:
                              const Color(0xFFF43F5E).withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Accepter et continuer",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ---- FOOTER LINKS ----
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Personnaliser les autorisations",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            "Lire la politique complète",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),

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

  Widget _buildPrivacyCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Badge Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.45,
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
