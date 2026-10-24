import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/language_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  int _activeTab = 0; // 0 = 3D Privacy, 1 = Collection, 2 = Vault, 3 = Terms & Rights

  void _showDataExportDialog(bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.download_rounded, color: Color(0xFF172554), size: 22),
            const SizedBox(width: 8),
            Text(
              isEn ? "Export Your Data" : "Exporter vos Données",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
          ],
        ),
        content: Text(
          isEn
              ? "An encrypted package containing your biometric measurements, 3D fitting history, and sizing preferences will be generated in JSON and PDF format."
              : "Un paquet chiffré contenant vos mesures biométriques, historiques d'essayage 3D et préférences de taille sera généré au format JSON et PDF.",
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: const Color(0xFF475569),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isEn ? "Cancel" : "Annuler",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEn
                        ? "Export successful! Archive saved to your Data Vault."
                        : "Exportation réussie ! Fichier enregistré dans votre Coffre de Données.",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF172554),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF172554),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isEn ? "Download Archive" : "Télécharger l'Archive",
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDataWipeConfirmationDialog(bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 22),
            const SizedBox(width: 8),
            Text(
              isEn ? "Purge 3D Vault?" : "Purger le Coffre 3D ?",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE11D48),
              ),
            ),
          ],
        ),
        content: Text(
          isEn
              ? "This action will permanently delete your 3D avatar, 48 biometric points, and scan photos from FitVisor servers. This operation cannot be undone."
              : "Cette action supprimera définitivement votre avatar 3D, vos 48 points biométriques et vos photos de scan des serveurs FitVisor. Cette opération est irréversible.",
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: const Color(0xFF475569),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isEn ? "Cancel" : "Annuler",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEn
                        ? "All biometric data has been successfully purged."
                        : "Toutes les données biométriques ont été purgées avec succès.",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: const Color(0xFFBE123C),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isEn ? "Confirm Purge" : "Confirmer la Purge",
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return AnimatedBuilder(
      animation: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          appBar: _buildAppBar(isEn),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Security Vault Banner Card
                  _buildSecurityVaultCard(isEn),
                  const SizedBox(height: 16),

                  // 2. Navigation Pills Selector
                  _buildCategoryPillsBar(isEn),
                  const SizedBox(height: 20),

                  // 3. Main Policy Document Content Container
                  _buildPolicyDocumentContainer(isEn),
                  const SizedBox(height: 20),

                  // 4. Data Control & Management Card (Export / Wipe)
                  _buildDataManagementCard(isEn),
                  const SizedBox(height: 20),

                  // 5. Version & Revision Footer
                  _buildRevisionFooter(isEn),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isEn) {
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
        isEn ? "Privacy & Vault" : "Confidentialité & Coffre",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
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

  // ── 1. TOP SECURITY VAULT BANNER CARD ────────────────────────────────────

  Widget _buildSecurityVaultCard(bool isEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172554), Color(0xFF0F172A)],
        ),
        borderRadius: BorderRadius.circular(22),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 12, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 4),
                    Text(
                      isEn
                          ? "FitVisor Secure Biometric Vault"
                          : "Coffre Biométrique Sécurisé FitVisor",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isEn
                ? "3D Data Protection & Confidentiality"
                : "Protection de vos Données 3D & Confidentialité",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isEn
                ? "Your body scans, biometric measurements, and fitting photos are end-to-end encrypted with the AES-256 protocol and are never shared with third parties."
                : "Vos scans corporels, mesures biométriques et photos d'essayage sont chiffrés de bout en bout avec le protocole AES-256 et ne sont jamais partagés avec des tiers.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildVaultBadge(isEn
                  ? "🟢 AES-256 Encryption Active"
                  : "🟢 Chiffrement AES-256 Actif"),
              _buildVaultBadge(isEn
                  ? "🔒 Private Biometric Data"
                  : "🔒 Données Biométriques Privées"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaultBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── 2. CATEGORY PILLS BAR ────────────────────────────────────────────────

  Widget _buildCategoryPillsBar(bool isEn) {
    final tabs = isEn
        ? [
            "1. 3D Privacy",
            "2. Collection & Usage",
            "3. Vault & Security",
            "4. Terms & Rights",
          ]
        : [
            "1. Confidentialité 3D",
            "2. Collecte & Usage",
            "3. Coffre & Sécurité",
            "4. CGU & Droits",
          ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _activeTab == index;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF172554) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                tabs[index],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 3. MAIN POLICY DOCUMENT CONTAINER ────────────────────────────────────

  Widget _buildPolicyDocumentContainer(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isEn
                      ? "Privacy Policy & Terms of Service"
                      : "Politique de Confidentialité & CGU",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEn ? "Updated: Oct. 2026" : "Mis à jour : Oct. 2026",
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // Section 1: Engagement de Confidentialité & Scan 3D
          _buildPolicySection(
            number: "01",
            title: isEn
                ? "Privacy Commitment & 3D Scanning"
                : "Engagement de Confidentialité & Scan 3D",
            content: isEn
                ? "At FitVisor, the privacy of your silhouette and biometric data is our absolute priority.\n\n"
                    "• Photos captured during scan guidance are never transmitted to third-party servers nor stored as identifiable raw images.\n"
                    "• Our AI engine immediately extracts vector features and converts your scan into an anonymized 3D mesh prior to any synchronization."
                : "Chez FitVisor, la confidentialité de votre silhouette et de vos données biométriques est notre priorité absolue.\n\n"
                    "• Les photos capturées lors du guidage de scan ne sont jamais transmises à des serveurs tiers ni stockées sous forme d'images brutes identifiables.\n"
                    "• Notre moteur d'IA extrait immédiatement les caractéristiques vectorielles et convertit votre scan en un maillage 3D anonymisé avant toute synchronisation.",
            isHighlighted: _activeTab == 0,
          ),
          const SizedBox(height: 18),

          // Section 2: Informations Collectées & Utilisation
          _buildPolicySection(
            number: "02",
            title: isEn
                ? "Information Collected & Data Usage"
                : "Informations Collectées & Utilisation des Données",
            content: isEn
                ? "To compute physical draping, seam tension, and fitting precision, FitVisor processes only essential parameters:\n\n"
                    "1. Biometric Data: Shoulder width, chest circumference, waist circumference, hip circumference, and total height.\n"
                    "2. Fit Preferences: Desired comfort fit (slim fit, regular fit, relaxed fit).\n"
                    "3. Virtual Fitting History: Anonymized interaction records to improve stylist recommendations."
                : "Pour calculer le drapé physique, la tension des coutures et la précision d'ajustement, FitVisor traite uniquement les paramètres indispensables :\n\n"
                    "1. Données Biométriques : Carrure, tour de poitrine, tour de taille W, tour de hanches et hauteur totale.\n"
                    "2. Préférences d'Ajustement : Niveau de confort souhaité (ajusté, standard, décontracté).\n"
                    "3. Historique d'Essayage Virtuel : Données anonymes d'interaction pour perfectionner les recommandations des stylistes.",
            isHighlighted: _activeTab == 1,
          ),
          const SizedBox(height: 18),

          // Section 3: Coffre de Données & Chiffrement
          _buildPolicySection(
            number: "03",
            title: isEn
                ? "Data Vault & AES-256 Secure Storage"
                : "Coffre de Données & Stockage Sécurisé AES-256",
            content: isEn
                ? "All your 3D avatar data is securely preserved inside the FitVisor Biometric Vault.\n\n"
                    "• Your data is protected by AES-256 encryption both at rest and during SSL/TLS transmission.\n"
                    "• No commercial partner or designer brand receives access to your raw measurements; only size recommendations (e.g., Size M • 99.2% Match) are shared at checkout."
                : "Toutes les données de votre avatar 3D sont conservées dans le Coffre Biométrique Sécurisé de FitVisor.\n\n"
                    "• Vos données sont protégées par un chiffrement AES-256 à la fois au repos et lors des transferts SSL/TLS.\n"
                    "• Aucun partenaire commercial ou boutique créateur n'a accès à vos mensurations brutes ; seules les recommandations de tailles (ex: Taille M • 99.2% Match) sont partagées lors du paiement.",
            isHighlighted: _activeTab == 2,
          ),
          const SizedBox(height: 18),

          // Section 4: Conditions Générales d'Utilisation (CGU)
          _buildPolicySection(
            number: "04",
            title: isEn
                ? "Terms of Service & Usage (ToS)"
                : "Conditions Générales d'Utilisation (CGU)",
            content: isEn
                ? "By using the FitVisor app and the RealDrape™ 3D simulation service:\n\n"
                    "• You guarantee you are the legitimate owner of the captured imagery or have acquired express authorization.\n"
                    "• Intellectual property rights over garment 3D models and the rendering engine remain exclusively reserved to FitVisor and partner couture fashion houses."
                : "En utilisant l'application FitVisor et le service de simulation 3D RealDrape™ :\n\n"
                    "• Vous garantissez être le propriétaire légitime des images capturées ou avoir obtenu l'autorisation expresse.\n"
                    "• Les droits de propriété intellectuelle sur les modèles 3D de vêtements et le moteur de rendu sont réservés à FitVisor et ses maisons de couture partenaires.",
            isHighlighted: _activeTab == 3,
          ),
          const SizedBox(height: 18),

          // Section 5: Droits de l'Utilisateur & Suppression
          _buildPolicySection(
            number: "05",
            title: isEn
                ? "Your Rights & Full Data Control"
                : "Vos Droits & Contrôle Total sur vos Données",
            content: isEn
                ? "In compliance with GDPR and international data protection standards:\n\n"
                    "• Right to Access & Export: You may export a complete copy of your biometric data at any time.\n"
                    "• Right to Erasure: You have an instant purge button to permanently erase all your data from our 3D Vault."
                : "Conformément au RGPD et aux normes internationales de protection des données :\n\n"
                    "• Droit d'Accès & d'Exportation : Vous pouvez exporter à tout moment une copie intégrale de vos données biométriques.\n"
                    "• Droit à l'Oubli : Vous bénéficiez d'un bouton de purge instantanée pour supprimer définitivement toutes vos données de notre Coffre 3D.",
            isHighlighted: _activeTab == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection({
    required String number,
    required String title,
    required String content,
    bool isHighlighted = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(isHighlighted ? 10 : 0),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF8FAFC) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: const Color(0xFFE2E8F0))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isHighlighted ? const Color(0xFF172554) : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  number,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isHighlighted ? Colors.white : const Color(0xFFE11D48),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF475569),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. DATA MANAGEMENT CARD ──────────────────────────────────────────────

  Widget _buildDataManagementCard(bool isEn) {
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
          Text(
            isEn ? "Data Vault Management" : "Gestion du Coffre de Données",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEn
                ? "Exercise direct control over your biometric data and download or erase your records at any time."
                : "Exercez un contrôle direct sur vos données biométriques et téléchargez ou supprimez vos archives à tout moment.",
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showDataExportDialog(isEn),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: Text(
                    isEn ? "Export My Data" : "Exporter Mes Données",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF172554),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
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
                  onPressed: () => _showDataWipeConfirmationDialog(isEn),
                  icon: const Icon(Icons.delete_forever_rounded, size: 16),
                  label: Text(
                    isEn ? "Purge Vault" : "Purger le Coffre",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF1F2),
                    foregroundColor: const Color(0xFFBE123C),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFECDD3)),
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

  // ── 5. REVISION FOOTER ───────────────────────────────────────────────────

  Widget _buildRevisionFooter(bool isEn) {
    return Center(
      child: Column(
        children: [
          Text(
            isEn
                ? "FitVisor Privacy Vault & ToS v2.4"
                : "FitVisor Privacy Vault & CGU v2.4",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isEn
                ? "AES-256 Encryption • GDPR & ISO/IEC 27001 Compliant"
                : "Chiffrement AES-256 • Conforme RGPD & ISO/IEC 27001",
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
