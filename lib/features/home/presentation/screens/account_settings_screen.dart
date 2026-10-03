import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/screens/welcome_back_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'subscription_plans_screen.dart';
import 'payment_methods_screen.dart';
import 'transaction_history_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String _fullName = "Alexa Morgan";
  String _email = "alexa.designer@example.com";
  String _phoneNumber = "+1 (555) 382-9104";
  final String _avatarAsset = 'assets/images/profile_avatar.jpg';
  String _memberLabel = "Explorateur de Style • Membre depuis 2024";

  void _showEditFieldDialog(String fieldName, String currentValue, ValueChanged<String> onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Modifier $fieldName",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF172554)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF172554), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Annuler",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$fieldName mis à jour avec succès !"),
                    backgroundColor: const Color(0xFF172554),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF172554),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              "Enregistrer",
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Avatar picker removed as per user request

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
              // 1. Top Profile Overview Card (DP + Name + Stats)
              _buildTopProfileCard(),
              const SizedBox(height: 20),

              // 2. Section: INFORMATIONS PERSONNELLES
              _buildPersonalInformationSection(),
              const SizedBox(height: 22),

              // 3. Section: PRÉFÉRENCES ET SÉCURITÉ
              _buildPreferencesAndSecuritySection(),
              const SizedBox(height: 24),

              // 4. Log Out Button (Déconnexion -> WelcomeBackScreen)
              _buildLogOutButton(),
              const SizedBox(height: 18),

              // 5. Build Version Footer
              _buildVersionFooter(),
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
        "Paramètres du Compte",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF172554),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
    );
  }

  // ── 1. TOP PROFILE OVERVIEW CARD ─────────────────────────────────────────

  Widget _buildTopProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          // Profile Avatar (display only)
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF1F5F9), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42),
              child: Image.asset(
                _avatarAsset,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // User Name
          Text(
            _fullName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 5),

          // Member Tag (dynamic based on subscription)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Flexible(
                child: Text(
                  _memberLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stat Cards Box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "42",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Essayages Virtuels",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "98%",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Précision Ajustement",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "16",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Tenues Enregistrées",
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 2. SECTION: INFORMATIONS PERSONNELLES ────────────────────────────────

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "INFORMATIONS PERSONNELLES",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
                letterSpacing: 0.6,
              ),
            ),
            Text(
              "Appuyez pour modifier",
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Full Name Field
        _buildInfoTile(
          label: "Nom Complet",
          value: _fullName,
          onTap: () {
            _showEditFieldDialog("le Nom Complet", _fullName, (val) {
              setState(() => _fullName = val);
            });
          },
        ),
        const SizedBox(height: 10),

        // Email Field with Verified Badge
        _buildInfoTile(
          label: "E-mail",
          value: _email,
          badgeText: "Vérifié",
          onTap: () {
            _showEditFieldDialog("l'E-mail", _email, (val) {
              setState(() => _email = val);
            });
          },
        ),
        const SizedBox(height: 10),

        // Phone Number Field
        _buildInfoTile(
          label: "Numéro de Téléphone",
          value: _phoneNumber,
          onTap: () {
            _showEditFieldDialog("le Numéro de Téléphone", _phoneNumber, (val) {
              setState(() => _phoneNumber = val);
            });
          },
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 10, color: Color(0xFFE11D48)),
                            const SizedBox(width: 3),
                            Text(
                              badgeText,
                              style: GoogleFonts.inter(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE11D48),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 15,
                color: Color(0xFF172554),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. SECTION: PRÉFÉRENCES ET SÉCURITÉ ─────────────────────────────────

  Widget _buildPreferencesAndSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "PRÉFÉRENCES ET SÉCURITÉ",
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),

        Container(
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
            children: [
              // Tile 1: Moyens de Paiement
              _buildPreferenceTile(
                icon: Icons.credit_card_rounded,
                iconBg: const Color(0xFFFFF1F2),
                iconColor: const Color(0xFFF43F5E),
                title: 'Moyens de Paiement',
                subtitle: 'Cartes, Apple Pay, Google Pay',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Tile 2: Historique des Transactions
              _buildPreferenceTile(
                icon: Icons.receipt_long_rounded,
                iconBg: const Color(0xFFF0FDF4),
                iconColor: const Color(0xFF16A34A),
                title: 'Historique des Transactions',
                subtitle: 'Vos paiements et remboursements',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TransactionHistoryScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Tile 3: Notifications
              _buildPreferenceTile(
                icon: Icons.notifications_none_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF475569),
                title: 'Notifications',
                subtitle: 'Alertes de nouveautés, recommandations',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Tile 4: Abonnements FitVisor
              _buildPreferenceTile(
                icon: Icons.workspace_premium_rounded,
                iconBg: const Color(0xFFFFF1F2),
                iconColor: const Color(0xFFE11D48),
                title: 'Abonnements FitVisor',
                subtitle: 'Rendu d\'essayage 3D illimité',
                badgeText: 'ACTIF',
                onTap: () async {
                  // SubscriptionPlansScreen now returns the plan name as a String
                  final purchasedPlan = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansScreen(),
                    ),
                  );

                  if (purchasedPlan != null && purchasedPlan.isNotEmpty && mounted) {
                    setState(() {
                      // Dynamic member label: "[Plan Name] • Membre depuis 2024"
                      _memberLabel = '$purchasedPlan • Membre depuis 2024';
                    });
                  }
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Tile 5: Aide & Support
              _buildPreferenceTile(
                icon: Icons.help_outline_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF475569),
                title: 'Aide & Support',
                subtitle: 'FAQ, guide des tailles, chat en direct',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Tile 6: Confidentialité & Conditions
              _buildPreferenceTile(
                icon: Icons.lock_outline_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: const Color(0xFF475569),
                title: 'Confidentialité & Conditions',
                subtitle: 'Politique de confidentialité, CGU',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF172554),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badgeText != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFBE123C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.inter(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          color: const Color(0xFF64748B),
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Color(0xFFCBD5E1),
      ),
      onTap: onTap ?? () {},
    );
  }

  // ── 4. LOG OUT BUTTON (DÉCONNEXION -> WELCOME BACK / AUTH PAGE) ───────────

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Déconnexion réussie.",
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              backgroundColor: const Color(0xFF172554),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );

          // Navigates directly to WelcomeBackScreen (Sign in / Auth page)
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const WelcomeBackScreen(),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFBE123C),
          elevation: 0,
          side: const BorderSide(color: Color(0xFFFECDD3), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFBE123C)),
            const SizedBox(width: 8),
            Text(
              "Déconnexion",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFBE123C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 5. BUILD VERSION FOOTER ──────────────────────────────────────────────

  Widget _buildVersionFooter() {
    return Center(
      child: Text(
        "Studio Spatial FitVisor v2.4.1 (Build 890)",
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
