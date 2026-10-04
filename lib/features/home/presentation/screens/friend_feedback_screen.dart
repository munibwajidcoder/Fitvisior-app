import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendFeedbackScreen extends StatefulWidget {
  final String productName;
  final String productSize;
  final String productImage;
  final String visibilityLabel; // "Friends only", "Community", "Only me"
  final String linkExpiry; // "Link expires in 7 days"

  const FriendFeedbackScreen({
    super.key,
    this.productName = 'Silk Midi Dress',
    this.productSize = 'Size M',
    this.productImage = 'assets/images/product_dress.jpg',
    this.visibilityLabel = 'Friends only',
    this.linkExpiry = 'Link expires in 7 days',
  });

  @override
  State<FriendFeedbackScreen> createState() => _FriendFeedbackScreenState();
}

class _FriendFeedbackScreenState extends State<FriendFeedbackScreen> {
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<_FeedbackMessage> _messages = [
    _FeedbackMessage(
      author: 'Maya',
      avatarColor: const Color(0xFFFFEBEB),
      initials: 'M',
      text: 'This looks great on you!',
      time: '4:18 PM',
      isAI: false,
    ),
    _FeedbackMessage(
      author: 'AI Stylist',
      avatarColor: const Color(0xFFFFF1F2),
      initials: '✦',
      text: 'This jean fits you, but this shirt is too tight.',
      time: '4:20 PM',
      isAI: true,
    ),
  ];

  final List<_QuickReaction> _reactions = [
    _QuickReaction(icon: Icons.thumb_up_outlined, label: 'Like'),
    _QuickReaction(icon: Icons.thumb_down_outlined, label: 'Dislike'),
    _QuickReaction(icon: Icons.straighten_rounded, label: 'Too tight'),
    _QuickReaction(icon: Icons.palette_outlined, label: 'Color'),
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_FeedbackMessage(
        author: 'You',
        avatarColor: const Color(0xFFEFF6FF),
        initials: 'Y',
        text: text,
        time: _nowTime(),
        isAI: false,
      ));
      _commentCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendReaction(String label) {
    setState(() {
      _messages.add(_FeedbackMessage(
        author: 'You',
        avatarColor: const Color(0xFFEFF6FF),
        initials: 'Y',
        text: '👍 $label',
        time: _nowTime(),
        isAI: false,
      ));
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              physics: const BouncingScrollPhysics(),
              children: [
                // Product card
                _buildProductCard(),
                const SizedBox(height: 12),

                // Visibility chips
                _buildVisibilityChips(),
                const SizedBox(height: 24),

                // Feedback section header
                Text(
                  'Feedback',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 16),

                // Chat messages
                ..._messages.map((msg) => _buildMessageBubble(msg)),
                const SizedBox(height: 12),

                // Quick reaction chips
                _buildReactionChips(),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Comment input (sticky at bottom)
          _buildCommentInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Color(0xFF172554)),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
      title: Text(
        'Friend Feedback',
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
              color: const Color(0xFFF1F5F9),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: const Icon(Icons.person_outline_rounded,
                size: 18, color: Color(0xFF172554)),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.productImage,
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 120,
                    color: const Color(0xFFF1F5F9),
                    child: const Icon(Icons.checkroom_rounded,
                        color: Color(0xFF94A3B8), size: 32),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Simulated render',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.productSize,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                // Confidence chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF6EE7B7), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded,
                          size: 13, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      Text(
                        'Confidence: High',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF059669),
                        ),
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

  Widget _buildVisibilityChips() {
    return Row(
      children: [
        _buildInfoChip(Icons.remove_red_eye_outlined, widget.visibilityLabel),
        const SizedBox(width: 10),
        _buildInfoChip(Icons.access_time_rounded, widget.linkExpiry),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDA4AF), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFF43F5E)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF172554),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_FeedbackMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: msg.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: msg.isAI
                  ? const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: Color(0xFFF43F5E))
                  : Text(
                      msg.initials,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF43F5E),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // Bubble
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (msg.isAI) ...[
                      const Icon(Icons.auto_awesome_rounded,
                          size: 12, color: Color(0xFFF43F5E)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      msg.author,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: msg.isAI
                            ? const Color(0xFFF43F5E)
                            : const Color(0xFF172554),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      msg.time,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: msg.isAI
                        ? const Color(0xFFEDE9FE)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    msg.text,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _reactions
          .map((r) => GestureDetector(
                onTap: () => _sendReaction(r.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(r.icon, size: 15, color: const Color(0xFF475569)),
                      const SizedBox(width: 6),
                      Text(
                        r.label,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              onSubmitted: (_) => _sendComment(),
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Write a comment...',
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
                    horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackMessage {
  final String author;
  final Color avatarColor;
  final String initials;
  final String text;
  final String time;
  final bool isAI;

  const _FeedbackMessage({
    required this.author,
    required this.avatarColor,
    required this.initials,
    required this.text,
    required this.time,
    required this.isAI,
  });
}

class _QuickReaction {
  final IconData icon;
  final String label;
  const _QuickReaction({required this.icon, required this.label});
}
