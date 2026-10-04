import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'consent_privacy_screen.dart';
import '../../../scan/presentation/screens/capture_guide_screen.dart';

class AvatarIdentityScreen extends StatefulWidget {
  const AvatarIdentityScreen({super.key});

  @override
  State<AvatarIdentityScreen> createState() => _AvatarIdentityScreenState();
}

class _AvatarIdentityScreenState extends State<AvatarIdentityScreen> {
  // 'realistic' or 'anonymous'
  String _selectedAvatar = 'anonymous';
  bool _watermarkEnabled = false;
  bool _faceBlurEnabled = true;

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ConsentPrivacyScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9FB),
        body: SafeArea(
          child: Column(
            children: [
              // ── TOP BAR ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _handleBack(context),
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
                  Image.asset('assets/images/logo.png', width: 30, height: 30),
                ],
              ),
            ),

            // ── SCROLLABLE BODY ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Red label
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            "Confidentialité & Protection Spatiale",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE11D48),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      "Choisissez votre\nidentité d'avatar",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      "Décidez comment vous souhaitez que votre apparence soit affichée lors des séances d'essayage virtuel et du partage de tenues.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── CARD 1 : Apparence Photoréaliste ─────────────
                    _AvatarCard(
                      id: 'realistic',
                      selected: _selectedAvatar == 'realistic',
                      onTap: () =>
                          setState(() => _selectedAvatar = 'realistic'),
                      badgeText: "FIDÈLE À LA RÉALITÉ",
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeTextColor: const Color(0xFF475569),
                      avatarWidget: _realisticAvatar(),
                      title: "Apparence photoréaliste",
                      titleColor: const Color(0xFF0F172A),
                      subLabel: null,
                      description:
                          "Votre avatar reproduit vos traits faciaux réalistes et votre teint pour une expérience d'essayage luxueuse authentique. Visible uniquement par vous.",
                      footerIcon: Icons.lock_outline_rounded,
                      footerText:
                          "Chiffré matériellement dans l'enclave sécurisée locale",
                      footerColor: const Color(0xFF64748B),
                      footerBg: const Color(0xFFF8FAFC),
                      showDefaultBadge: false,
                    ),

                    const SizedBox(height: 12),

                    // ── CARD 2 : Mode Anonyme ─────────────────────────
                    _AvatarCard(
                      id: 'anonymous',
                      selected: _selectedAvatar == 'anonymous',
                      onTap: () =>
                          setState(() => _selectedAvatar = 'anonymous'),
                      badgeText: "100% ANONYMISÉ",
                      badgeBg: const Color(0xFFFFF1F2),
                      badgeTextColor: const Color(0xFFE11D48),
                      avatarWidget: _anonymousAvatar(),
                      title: "Mode Anonyme",
                      titleColor: const Color(0xFF0F172A),
                      subLabel: "Recommandé pour une confidentialité maximale",
                      description:
                          "Conserve votre silhouette corporelle précise et vos mesures, mais remplace votre tête par un mannequin géométrique éditorial.",
                      footerIcon: Icons.shield_outlined,
                      footerText: "Zéro stockage de vecteur facial biométrique",
                      footerColor: const Color(0xFFE11D48),
                      footerBg: const Color(0xFFFFF1F2),
                      showDefaultBadge: true,
                    ),

                    const SizedBox(height: 16),

                    // ── TOGGLE SETTINGS CARD ──────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
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
                      child: Column(
                        children: [
                          _ToggleRow(
                            icon: Icons.grid_view_rounded,
                            iconBg: const Color(0xFFF1F5F9),
                            iconColor: const Color(0xFF475569),
                            title: "Filigrane & Arrière-plan RA flou",
                            subtitle:
                                "Adoucit les pièces domestiques lors des essayages en caméra",
                            value: _watermarkEnabled,
                            onChanged: (v) =>
                                setState(() => _watermarkEnabled = v),
                            activeColor: const Color(0xFF3B82F6),
                          ),
                          Divider(height: 1, color: const Color(0xFFF1F5F9)),
                          _ToggleRow(
                            icon: Icons.face_retouching_natural_rounded,
                            iconBg: const Color(0xFFFFF1F2),
                            iconColor: const Color(0xFFE11D48),
                            title: "Flou du visage lors de l'export",
                            subtitle:
                                "Floute automatiquement le visage de l'avatar pour les clips sur réseaux sociaux",
                            value: _faceBlurEnabled,
                            onChanged: (v) =>
                                setState(() => _faceBlurEnabled = v),
                            activeColor: const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── GDPR NOTICE ───────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
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
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Les données de télémétrie d'ajustement sont conformes au RGPD & CCPA. Les coordonnées du maillage corporel sont strictement éphémères.",
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── MAIN BUTTON ───────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CaptureGuideScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF43F5E),
                          elevation: 0,
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
                                  "Continuer vers le Guide de Capture",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Footer note
                    Center(
                      child: Text(
                        "Vous pouvez modifier cela à tout moment dans Profil > Paramètres de confidentialité.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ── Avatar preview widgets ──────────────────────────────────────────

  Widget _realisticAvatar() {
    return Container(
      width: 82,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/profile_avatar.jpg',
              width: 82,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 6,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF172554),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _anonymousAvatar() {
    return Container(
      width: 82,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/avatar_3d.jpg',
              width: 82,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.visibility_off_rounded,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar Selection Card ────────────────────────────────────────────────

class _AvatarCard extends StatelessWidget {
  final String id;
  final bool selected;
  final VoidCallback onTap;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;
  final Widget avatarWidget;
  final String title;
  final Color titleColor;
  final String? subLabel;
  final String description;
  final IconData footerIcon;
  final String footerText;
  final Color footerColor;
  final Color footerBg;
  final bool showDefaultBadge;

  const _AvatarCard({
    required this.id,
    required this.selected,
    required this.onTap,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.avatarWidget,
    required this.title,
    required this.titleColor,
    required this.subLabel,
    required this.description,
    required this.footerIcon,
    required this.footerText,
    required this.footerColor,
    required this.footerBg,
    required this.showDefaultBadge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFFF43F5E).withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: selected ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Main Content ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: avatarWidget,
                  ),

                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: badgeTextColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 5),

                        // Title
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            letterSpacing: -0.3,
                          ),
                        ),

                        // Sub label (only for anonymous)
                        if (subLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subLabel!,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ],

                        const SizedBox(height: 4),

                        // Description
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Radio / Checkmark
                  selected
                      ? Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF43F5E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 2,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            // ── Footer ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: footerBg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Icon(footerIcon, size: 13, color: footerColor),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      footerText,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: footerColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showDefaultBadge) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Par défaut",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Row ───────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _ToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Toggle
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: activeColor,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }
}

