import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'community_screen.dart';
import 'friend_feedback_screen.dart';

class ShareOutfitScreen extends StatefulWidget {
  final String? productName;
  final String? productBrand;
  final String? productSize;
  final String? productImage;
  final String? fitPercent;

  const ShareOutfitScreen({
    super.key,
    this.productName,
    this.productBrand,
    this.productSize,
    this.productImage,
    this.fitPercent,
  });

  @override
  State<ShareOutfitScreen> createState() => _ShareOutfitScreenState();
}

class _ShareOutfitScreenState extends State<ShareOutfitScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  int _selectedRatio = 0; // 0=4:5, 1=1:1, 2=9:16
  final List<String> _ratios = ['4:5', '1:1', '9:16'];

  final TextEditingController _captionCtrl = TextEditingController(
    text:
        'La structure en soie fluide avec des pinces ajustées le long de la taille haute. La simulation AR a parfaitement capturé le tombé du tissu lors des mouvements. ✨',
  );

  final List<String> _trendingTags = [
    '#OOTD',
    '#VirtualFit',
    '#GalaStyle',
    '#FitVisor',
    '#SoieAtelier',
  ];
  final List<String> _selectedTags = ['#OOTD', '#VirtualFit', '#GalaStyle', '#FitVisor'];

  bool _showBiometricBadge = true;

  String get _name => widget.productName ?? 'Drapé Sculpté';
  String get _brand => widget.productBrand ?? 'Série Atelier • Taille M';
  String get _image => widget.productImage ?? 'assets/images/product_dress.jpg';
  String get _fit => widget.fitPercent ?? '99,4%';

  // Share settings state
  int _selectedVisibility = 1; // 0=Only me, 1=Friends with link, 2=Community
  int _selectedDuration = 1;   // 0=24h, 1=7 days, 2=30 days
  final List<String> _visibilityOptions = ['Only me', 'Friends with the link', 'Community'];
  final List<String> _durationOptions = ['24 hours', '7 days', '30 days'];
  String get _visibilityLabel => _visibilityOptions[_selectedVisibility];
  String get _expiryLabel => 'Link expires in ${_durationOptions[_selectedDuration]}';

  int get _captionLength => _captionCtrl.text.length;

  @override
  void initState() {
    super.initState();
    _captionCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  // ── Share helpers ─────────────────────────────────────────────────────────

  String get _shareText =>
      '$_name — Ajustement Biométrique FitVisor $_fit ✨\n'
      '${_captionCtrl.text}\n'
      '${_selectedTags.join(' ')}\n'
      'Découvrez FitVisor : https://fitvisor.app';

  Future<void> _shareToInstagram() async {
    final uri = Uri.parse('instagram://app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(Uri.parse('https://www.instagram.com'),
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareToTikTok() async {
    final uri = Uri.parse('tiktok://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(Uri.parse('https://www.tiktok.com'),
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareToWhatsApp() async {
    final encoded = Uri.encodeComponent(_shareText);
    final uri = Uri.parse('whatsapp://send?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(
          Uri.parse('https://web.whatsapp.com/send?text=$encoded'),
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareToFacebook() async {
    final uri = Uri.parse('fb://');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await launchUrl(Uri.parse('https://www.facebook.com'),
          mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareGeneral() async {
    await Share.share(_shareText);
  }

  void _copyLink() {
    Clipboard.setData(const ClipboardData(text: 'https://fitvisor.app/feedback/outfit-123'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lien copié ! Partagez-le avec vos amis.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF43F5E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Aperçu',
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FriendFeedbackScreen(
                  productName: _name,
                  productSize: 'Taille M',
                  productImage: _image,
                  visibilityLabel: _visibilityLabel,
                  linkExpiry: _expiryLabel,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showShareSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.settings_rounded, size: 18, color: Color(0xFF172554)),
                          const SizedBox(width: 8),
                          Text('Share Settings',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            )),
                        ]),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF172554)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Who can see
                    Text('Who can see this?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      )),
                    const SizedBox(height: 10),
                    ...List.generate(_visibilityOptions.length, (i) {
                      final selected = _selectedVisibility == i;
                      return GestureDetector(
                        onTap: () {
                          setSheet(() => _selectedVisibility = i);
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                i == 0 ? Icons.lock_outline_rounded
                                    : i == 1 ? Icons.link_rounded
                                    : Icons.public_rounded,
                                size: 18,
                                color: selected ? const Color(0xFFF43F5E) : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 10),
                              Text(_visibilityOptions[i],
                                style: GoogleFonts.inter(
                                  fontSize: 13.5, fontWeight: FontWeight.w600,
                                  color: selected ? const Color(0xFFF43F5E) : const Color(0xFF334155),
                                )),
                              const Spacer(),
                              if (selected)
                                const Icon(Icons.check_circle_rounded,
                                    size: 18, color: Color(0xFFF43F5E)),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    // Link duration
                    Text('Link active for',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      )),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(_durationOptions.length, (i) {
                        final selected = _selectedDuration == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setSheet(() => _selectedDuration = i);
                              setState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFFF43F5E) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? const Color(0xFFF43F5E) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(_durationOptions[i],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5, fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : const Color(0xFF64748B),
                                )),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF172554),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text('Save Settings',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700,
                          )),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _postToCommunity() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tenue partagée avec la communauté ! 🎉',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF172554),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CommunityScreen()),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Brouillon sauvegardé dans votre dressing privé.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF475569),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. FORMAT RATIO TOGGLE ─────────────────────────────────
              _buildFormatRatioToggle(),
              const SizedBox(height: 12),

              // ── 2. PRODUCT PREVIEW CARD ────────────────────────────────
              _buildProductPreviewCard(),
              const SizedBox(height: 16),

              // ── 3. STYLING NOTES & CAPTION ─────────────────────────────
              _buildStylingNotesSection(),
              const SizedBox(height: 16),

              // ── 4. TRENDING LOOK TAGS ──────────────────────────────────
              _buildTrendingTagsSection(),
              const SizedBox(height: 16),

              // ── 5. 3D FIT & BIOMETRICS BADGE ──────────────────────────
              _buildBiometricsBadgeRow(),
              const SizedBox(height: 20),

              // ── 6. INSTANT EXPORT & CHANNELS ──────────────────────────
              _buildInstantExportSection(),
              const SizedBox(height: 20),

              // ── 7. POST BUTTON ─────────────────────────────────────────
              _buildPostButton(),
              const SizedBox(height: 12),

              // ── 8. SAVE DRAFT BUTTON ───────────────────────────────────
              _buildSaveDraftButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────

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
        'Partager la Tenue',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF172554),
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded,
              size: 20, color: Color(0xFF172554)),
          tooltip: 'Share Settings',
          onPressed: _showShareSettings,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14),
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

  // ── 1. FORMAT RATIO TOGGLE ────────────────────────────────────────────────

  Widget _buildFormatRatioToggle() {
    return Row(
      children: [
        const Icon(Icons.aspect_ratio_rounded,
            size: 16, color: Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(
          'Format Ratio',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF172554),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_ratios.length, (i) {
              final selected = _selectedRatio == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedRatio = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _ratios[i],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF172554)
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── 2. PRODUCT PREVIEW CARD ───────────────────────────────────────────────

  Widget _buildProductPreviewCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Main image — aspect ratio changes with toggle
          AspectRatio(
            aspectRatio: _selectedRatio == 0
                ? 4 / 5
                : _selectedRatio == 1
                    ? 1 / 1
                    : 9 / 16,
            child: Image.asset(
              _image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          // Top-left badge: FitVisor 3D Fit • 99.4% Match
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF43F5E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'FitVisor 3D Fit • $_fit Correspondance',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top-right AR settings icon
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_suggest_rounded,
                  size: 18, color: Colors.white),
            ),
          ),

          // Bottom overlay: product name + biometric fit
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.accessibility_new_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _brand,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded,
                            size: 11, color: Color(0xFFF43F5E)),
                        const SizedBox(width: 4),
                        Text(
                          'Ajustement Bio',
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
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. STYLING NOTES & CAPTION ────────────────────────────────────────────

  Widget _buildStylingNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit_note_rounded, size: 18, color: Color(0xFF172554)),
            const SizedBox(width: 6),
            Text(
              'Notes de Style & Légende',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
            const Spacer(),
            Text(
              '$_captionLength/280',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _captionLength > 260
                    ? const Color(0xFFE11D48)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Caption text field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _captionCtrl,
            maxLines: 4,
            maxLength: 280,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF172554),
              height: 1.5,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
              hintText: 'Décrivez votre style...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // AI Caption Assist + Emoji row
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _captionCtrl.text =
                      'Tenue structurée à flux de soie avec des finitions couture signature FitVisor. La simulation AR 3D garantit une précision d\'ajustement de $_fit. 🌟';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 13, color: Color(0xFFF43F5E)),
                    const SizedBox(width: 5),
                    Text(
                      'Assistant Légende IA',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF43F5E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() {
                _captionCtrl.text += ' ✨';
              }),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text('😊', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 4. TRENDING LOOK TAGS ─────────────────────────────────────────────────

  Widget _buildTrendingTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags Tendance',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._trendingTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF172554)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              );
            }),

            // + Custom tag
            GestureDetector(
              onTap: () => _showAddTagDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded,
                        size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 3),
                    Text(
                      'Personnalisé',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
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

  void _showAddTagDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ajouter un Tag',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554))),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '#MonStyle',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                final tag = ctrl.text.trim().startsWith('#')
                    ? ctrl.text.trim()
                    : '#${ctrl.text.trim()}';
                setState(() {
                  _trendingTags.add(tag);
                  _selectedTags.add(tag);
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Ajouter',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── 5. 3D FIT & BIOMETRICS BADGE ─────────────────────────────────────────

  Widget _buildBiometricsBadgeRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined,
                size: 20, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Badge 3D Fit & Biométrique',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                Text(
                  'Afficher le score de précision avatar vérifié sur les publications',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: _showBiometricBadge,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF172554),
            onChanged: (val) => setState(() => _showBiometricBadge = val),
          ),
        ],
      ),
    );
  }

  // ── 6. INSTANT EXPORT & CHANNELS ─────────────────────────────────────────

  Widget _buildInstantExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Instantané & Canaux',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildChannelIcon(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                color: const Color(0xFFE1306C),
                bgColor: const Color(0xFFFFF0F5),
                onTap: _shareToInstagram,
              ),
              const SizedBox(width: 16),
              _buildChannelIcon(
                icon: Icons.music_note_rounded,
                label: 'TikTok',
                color: const Color(0xFF010101),
                bgColor: const Color(0xFFF1F5F9),
                onTap: _shareToTikTok,
              ),
              const SizedBox(width: 16),
              _buildChannelIcon(
                icon: Icons.chat_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                bgColor: const Color(0xFFF0FDF4),
                onTap: _shareToWhatsApp,
              ),
              const SizedBox(width: 16),
              _buildChannelIcon(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                bgColor: const Color(0xFFEFF6FF),
                onTap: _shareToFacebook,
              ),
              const SizedBox(width: 16),
              _buildChannelIcon(
                icon: Icons.link_rounded,
                label: 'Copier Lien',
                color: const Color(0xFF475569),
                bgColor: const Color(0xFFF1F5F9),
                onTap: _copyLink,
              ),
              const SizedBox(width: 16),
              _buildChannelIcon(
                icon: Icons.share_rounded,
                label: 'Partager',
                color: const Color(0xFF172554),
                bgColor: const Color(0xFFEEF2FF),
                onTap: _shareGeneral,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChannelIcon({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── 7. POST BUTTON ────────────────────────────────────────────────────────

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _postToCommunity,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF43F5E),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                'Post to Community',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  // ── 8. SAVE DRAFT BUTTON ──────────────────────────────────────────────────

  Widget _buildSaveDraftButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _saveDraft,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF475569),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border_rounded,
                size: 16, color: Color(0xFF475569)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sauvegarder en Brouillon — Dressing Privé',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF475569),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 24), // Balance the icon space
          ],
        ),
      ),
    );
  }
}
