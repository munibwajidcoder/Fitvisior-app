import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/screens/welcome_back_screen.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/data/user_avatar_service.dart';
import '../../data/wardrobe_service.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'subscription_plans_screen.dart';
import 'payment_methods_screen.dart';
import 'transaction_history_screen.dart';
import 'store_partnerships_screen.dart';
import '../../../../core/localization/language_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String _fullName = "FitVisor User";
  String _email = "";
  DateTime? _memberSince;
  String? _currentPlan;
  int _virtualTryOnsCount = 0;
  String _fitPrecision = "98%";
  int _wardrobeItemsCount = 0;

  @override
  void initState() {
    super.initState();
    WardrobeService.instance.wardrobeItemsNotifier.addListener(_onWardrobeChanged);
    UserAvatarService.tryOnsCountNotifier.addListener(_onTryOnsChanged);
    _loadProfileData();
  }

  @override
  void dispose() {
    WardrobeService.instance.wardrobeItemsNotifier.removeListener(_onWardrobeChanged);
    UserAvatarService.tryOnsCountNotifier.removeListener(_onTryOnsChanged);
    super.dispose();
  }

  void _onWardrobeChanged() {
    if (!mounted) return;
    final wardrobe = WardrobeService.instance.wardrobeItemsNotifier.value;
    setState(() {
      _wardrobeItemsCount = wardrobe.length;
      if (wardrobe.isNotEmpty) {
        final avgScore = wardrobe.map((e) => e.matchScoreVal).reduce((a, b) => a + b) / wardrobe.length;
        _fitPrecision = "${avgScore.toStringAsFixed(0)}%";
      }
    });
  }

  void _onTryOnsChanged() {
    if (!mounted) return;
    setState(() {
      _virtualTryOnsCount = UserAvatarService.tryOnsCountNotifier.value;
    });
  }

  Future<void> _loadProfileData() async {
    await UserAvatarService.loadSavedAvatar();
    final user = Supabase.instance.client.auth.currentUser;
    final profile = await AuthService.getProfile();
    final tryOnCount = await UserAvatarService.getTryOnCount();
    await WardrobeService.instance.fetchWardrobeItems();
    final wardrobe = WardrobeService.instance.wardrobeItemsNotifier.value;

    if (!mounted) return;
    setState(() {
      final name = profile?['full_name'] ?? user?.userMetadata?['full_name'];
      if (name != null && name.toString().trim().isNotEmpty) {
        _fullName = name.toString().trim();
      } else {
        _fullName = tr('profile_default_user');
      }
      final email = user?.email ?? profile?['email'];
      if (email != null && email.toString().trim().isNotEmpty) {
        _email = email.toString().trim();
      }

      final createdStr = user?.createdAt ?? profile?['created_at'];
      if (createdStr != null) {
        try {
          _memberSince = DateTime.parse(createdStr);
        } catch (_) {}
      }

      _wardrobeItemsCount = wardrobe.length;
      _virtualTryOnsCount = tryOnCount;
      if (wardrobe.isNotEmpty) {
        final avgScore = wardrobe.map((e) => e.matchScoreVal).reduce((a, b) => a + b) / wardrobe.length;
        _fitPrecision = "${avgScore.toStringAsFixed(0)}%";
      } else if (profile?['fit_precision'] != null) {
        _fitPrecision = "${profile!['fit_precision']}%";
      } else {
        _fitPrecision = "98%";
      }
    });
  }

  String _getMemberLabel() {
    final isEn = LanguageService.instance.isEnglish;
    final plan = _currentPlan ?? (isEn ? "Style Explorer" : "Explorateur de Style");
    if (_memberSince == null) {
      return "$plan • ${isEn ? 'Member' : 'Membre'}";
    }
    final monthsEn = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    final monthsFr = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];
    final monthName = isEn ? monthsEn[_memberSince!.month - 1] : monthsFr[_memberSince!.month - 1];
    return "$plan • ${isEn ? 'Member since' : 'Membre depuis'} $monthName ${_memberSince!.year}";
  }

  void _showEditFieldDialog(String fieldName, String currentValue, ValueChanged<String> onSave) {
    final isEn = LanguageService.instance.isEnglish;
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEn ? "Edit $fieldName" : "Modifier $fieldName",
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
              isEn ? "Cancel" : "Annuler",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final newVal = controller.text.trim();
                onSave(newVal);
                Navigator.pop(ctx);
                if (fieldName.toLowerCase().contains("nom") || fieldName.toLowerCase().contains("name")) {
                  await AuthService.updateProfile({'full_name': newVal});
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEn ? "$fieldName updated successfully!" : "$fieldName mis à jour avec succès !"),
                      backgroundColor: const Color(0xFF172554),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF172554),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isEn ? "Save" : "Enregistrer",
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final isEn = LanguageService.instance.isEnglish;
    final hasExistingAvatar = UserAvatarService.avatarNotifier.value != null;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('photo_picker_title'),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFFE11D48)),
                title: Text(
                  tr('photo_picker_camera'),
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    await UserAvatarService.saveAvatar(File(image.path));
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEn
                                ? 'Profile photo updated successfully!'
                                : 'Photo de profil mise à jour avec succès !',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF172554),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
                title: Text(
                  tr('photo_picker_gallery'),
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1024,
                    maxHeight: 1024,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    await UserAvatarService.saveAvatar(File(image.path));
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEn
                                ? 'Profile photo updated successfully!'
                                : 'Photo de profil mise à jour avec succès !',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF172554),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              if (hasExistingAvatar)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
                  title: Text(
                    tr('photo_picker_remove'),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await UserAvatarService.deleteProfilePhoto();
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEn ? 'Profile photo removed.' : 'Photo de profil supprimée.',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          ),
                          backgroundColor: const Color(0xFF172554),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
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

    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
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
      },
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
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const HomeScreen(initialIndex: 0)),
            (route) => false,
          );
        },
      ),
      title: Text(
        tr('profile_title'),
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
          // Profile Avatar with Camera Picker
          GestureDetector(
            onTap: _pickImage,
            child: ValueListenableBuilder<File?>(
              valueListenable: UserAvatarService.avatarNotifier,
              builder: (context, avatarFile, _) {
                return Stack(
                  children: [
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
                        child: avatarFile != null
                            ? Image.file(
                                avatarFile,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFEFF6FF),
                                child: Center(
                                  child: Text(
                                    _fullName.trim().isNotEmpty
                                        ? _fullName.trim()[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
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
          if (_email.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              _email,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
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
                  _getMemberLabel(),
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
                        _virtualTryOnsCount.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr('stat_tryons'),
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
                        _fitPrecision,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr('stat_fit_match'),
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
                        _wardrobeItemsCount.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr('stat_wardrobe'),
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
              tr('section_personal_info'),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
                letterSpacing: 0.6,
              ),
            ),
            Text(
              tr('tap_to_edit'),
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
          label: tr('label_full_name'),
          value: _fullName,
          onTap: () {
            _showEditFieldDialog(tr('label_full_name'), _fullName, (val) {
              setState(() => _fullName = val);
            });
          },
        ),
        const SizedBox(height: 10),

        // Email Field with Verified Badge
        _buildInfoTile(
          label: tr('label_email'),
          value: _email,
          badgeText: tr('badge_verified'),
          onTap: () {
            _showEditFieldDialog(tr('label_email'), _email, (val) {
              setState(() => _email = val);
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
          tr('section_preferences_security'),
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
              // 🌐 Tile 0: Langue / Language Switcher
              _buildPreferenceTile(
                icon: Icons.language_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF2563EB),
                title: tr('tile_language_title'),
                subtitle: LanguageService.instance.isFrench ? 'Français' : 'English',
                onTap: _showLanguageSelectionSheet,
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Tile 1: Moyens de Paiement
              _buildPreferenceTile(
                icon: Icons.credit_card_rounded,
                iconBg: const Color(0xFFFFF1F2),
                iconColor: const Color(0xFFF43F5E),
                title: tr('tile_payments'),
                subtitle: tr('tile_payments_sub'),
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
                title: tr('tile_transactions'),
                subtitle: tr('tile_transactions_sub'),
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
                title: tr('tile_notifications'),
                subtitle: tr('tile_notifications_sub'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Tile 3.5: Partenariats Boutiques
              _buildPreferenceTile(
                icon: Icons.storefront_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF3B82F6),
                title: tr('tile_partners'),
                subtitle: tr('tile_partners_sub'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StorePartnershipsScreen(
                        productName: 'Produit Démo',
                        productSize: 'M',
                        productImage: 'assets/images/product_dress.jpg',
                      ),
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
                title: tr('tile_subscriptions'),
                subtitle: tr('tile_subscriptions_sub'),
                badgeText: tr('badge_active'),
                onTap: () async {
                  // SubscriptionPlansScreen now returns the plan name as a String
                  final purchasedPlan = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlansScreen(),
                    ),
                  );

                  if (purchasedPlan != null && purchasedPlan.isNotEmpty && mounted) {
                    setState(() {
                      _currentPlan = purchasedPlan;
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
                title: tr('tile_help'),
                subtitle: tr('tile_help_sub'),
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
                title: tr('tile_privacy'),
                subtitle: tr('tile_privacy_sub'),
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

  void _showLanguageSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isFr = LanguageService.instance.isFrench;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('dialog_language_title'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF172554),
                          ),
                        ),
                        Text(
                          isFr
                              ? 'Sélectionnez votre langue d\'affichage'
                              : 'Select your preferred display language',
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
              const SizedBox(height: 20),

              // Option 1: Français
              _buildLanguageOptionItem(
                flagEmoji: '🇫🇷',
                title: tr('lang_french_label'),
                subtitle: tr('lang_french_sub'),
                isSelected: isFr,
                onTap: () {
                  Navigator.of(ctx).pop();
                  LanguageService.instance.setLanguage('fr').then((_) {
                    if (mounted) setState(() {});
                  });
                },
              ),

              const SizedBox(height: 10),

              // Option 2: English
              _buildLanguageOptionItem(
                flagEmoji: '🇬🇧',
                title: tr('lang_english_label'),
                subtitle: tr('lang_english_sub'),
                isSelected: !isFr,
                onTap: () {
                  Navigator.of(ctx).pop();
                  LanguageService.instance.setLanguage('en').then((_) {
                    if (mounted) setState(() {});
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOptionItem({
    required String flagEmoji,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172554),
                    ),
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
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                size: 22,
                color: Color(0xFF16A34A),
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
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
        onPressed: () async {
          await AuthService.signOut();
          if (!mounted) return;
          final isEn = LanguageService.instance.isEnglish;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEn ? "Logged out successfully." : "Déconnexion réussie.",
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
              tr('btn_logout'),
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
    final isEn = LanguageService.instance.isEnglish;
    return Center(
      child: Text(
        isEn
            ? "FitVisor Spatial Studio v2.4.1 (Build 890)"
            : "Studio Spatial FitVisor v2.4.1 (Build 890)",
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
