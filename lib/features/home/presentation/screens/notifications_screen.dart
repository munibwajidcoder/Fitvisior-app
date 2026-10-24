import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../../auth/data/user_avatar_service.dart';
import '../../data/product_service.dart';
import '../../data/notification_service.dart';
import 'product_detail_screen.dart';
import 'checkout_screen.dart';
import '../../../../core/localization/language_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0; // 0 = All, 1 = Try-ons & Drapes, 2 = Orders & Deliveries
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final items = await NotificationService.fetchNotifications();
    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilterIndex == 1) {
      return _notifications.where((n) => n.category == 'tryon').toList();
    } else if (_selectedFilterIndex == 2) {
      return _notifications.where((n) => n.category == 'order').toList();
    }
    return _notifications;
  }

  Future<void> _handleMarkAllAsRead(bool isEn) async {
    await NotificationService.markAllAsRead();
    if (mounted) {
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? "All notifications marked as read."
                : "Toutes les notifications ont été marquées comme lues.",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF172554),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _handleDeleteNotification(String id, bool isEn) async {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
    await NotificationService.deleteNotification(id);
  }

  Future<void> _handleClearAll(bool isEn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEn ? "Clear all notifications?" : "Effacer toutes les notifications ?",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text(
          isEn
              ? "This will remove all notifications from your list."
              : "Cela supprimera toutes les notifications de votre liste.",
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isEn ? "Cancel" : "Annuler", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isEn ? "Clear" : "Effacer",
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NotificationService.clearAllNotifications();
      if (mounted) {
        setState(() {
          _notifications = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEn ? "All notifications cleared." : "Toutes les notifications ont été effacées.",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF172554),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _handleTapNotification(NotificationItem item) async {
    if (!item.isRead) {
      await NotificationService.markAsRead(item.id);
      if (mounted) {
        setState(() {
          final idx = _notifications.indexWhere((n) => n.id == item.id);
          if (idx != -1) {
            _notifications[idx] = _notifications[idx].copyWith(isRead: true);
          }
        });
      }
    }

    if (!mounted) return;

    if (item.actionRoute == '/product_detail') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(
            product: ProductService.instance.fallbackProducts.first,
          ),
        ),
      );
    } else if (item.actionRoute == '/checkout_order') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CheckoutScreen()),
      );
    }
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
        final isEn = LanguageService.instance.isEnglish;
        final filtered = _filteredNotifications;

        // Group into today vs earlier
        final now = DateTime.now();
        final todayItems = filtered.where((n) => now.difference(n.createdAt).inDays < 1).toList();
        final earlierItems = filtered.where((n) => now.difference(n.createdAt).inDays >= 1).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FB),
          appBar: _buildAppBar(),
          body: SafeArea(
            top: false,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF172554)),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: const Color(0xFF172554),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Unread count bar + Mark all as read action
                          _buildAlertHeaderBar(_unreadCount, isEn),
                          const SizedBox(height: 12),

                          // 2. Filter Pills Bar
                          _buildFilterPillsBar(isEn),
                          const SizedBox(height: 20),

                          // 3. Section: TODAY
                          if (todayItems.isNotEmpty) ...[
                            _buildSectionHeader(
                              isEn ? "TODAY" : "AUJOURD'HUI",
                              rightText: isEn ? "Live" : "En direct",
                            ),
                            const SizedBox(height: 10),
                            ...todayItems.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDynamicNotificationCard(item, isEn),
                                )),
                            const SizedBox(height: 10),
                          ],

                          // 4. Section: EARLIER THIS WEEK
                          if (earlierItems.isNotEmpty) ...[
                            _buildSectionHeader(
                              isEn ? "EARLIER" : "PLUS TÔT",
                            ),
                            const SizedBox(height: 10),
                            ...earlierItems.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDynamicNotificationCard(item, isEn),
                                )),
                            const SizedBox(height: 14),
                          ],

                          // Empty State if no items in filter
                          if (filtered.isEmpty) ...[
                            const SizedBox(height: 40),
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.notifications_none_rounded,
                                    size: 48,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isEn ? "No notifications yet" : "Aucune notification pour le moment",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],

                          // 5. Bottom Notification Preferences Button & Description
                          _buildNotificationPreferencesSection(isEn),
                        ],
                      ),
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
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Notifications",
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
          child: ValueListenableBuilder<File?>(
            valueListenable: UserAvatarService.avatarNotifier,
            builder: (context, avatarFile, _) {
              return Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: ClipOval(
                  child: avatarFile != null
                      ? Image.file(avatarFile, fit: BoxFit.cover)
                      : const Icon(Icons.person_rounded, size: 20, color: Color(0xFF2563EB)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 1. ALERT HEADER BAR ──────────────────────────────────────────────────

  Widget _buildAlertHeaderBar(int unreadCount, bool isEn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: unreadCount > 0 ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isEn ? "$unreadCount New Alerts" : "$unreadCount Nouvelles Alertes",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mark all as read button
            GestureDetector(
              onTap: unreadCount > 0 ? () => _handleMarkAllAsRead(isEn) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: unreadCount > 0
                      ? const Color(0xFFFFF1F2)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: unreadCount > 0
                        ? const Color(0xFFFECDD3)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 13,
                      color: unreadCount > 0
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? "Mark read" : "Marquer lu",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: unreadCount > 0
                            ? const Color(0xFFE11D48)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Clear all button
            GestureDetector(
              onTap: _notifications.isNotEmpty ? () => _handleClearAll(isEn) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? "Clear" : "Effacer",
                      style: GoogleFonts.inter(
                        fontSize: 11,
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

  // ── 2. FILTER PILLS BAR ──────────────────────────────────────────────────

  Widget _buildFilterPillsBar(bool isEn) {
    final tryonCount = _notifications.where((n) => n.category == 'tryon').length;
    final orderCount = _notifications.where((n) => n.category == 'order').length;

    final filters = [
      {'label': isEn ? 'All' : 'Tous', 'count': _notifications.length},
      {'label': isEn ? 'Try-ons & Drapes' : 'Essayages & Drapés', 'count': tryonCount},
      {'label': isEn ? 'Orders & Deliveries' : 'Commandes & Livraisons', 'count': orderCount},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF172554) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF172554) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF172554).withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  if (filter['count'] != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${filter['count']}",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── SECTION HEADER ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {String? rightText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF64748B),
            letterSpacing: 0.6,
          ),
        ),
        if (rightText != null)
          Text(
            rightText,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
      ],
    );
  }

  // ── DYNAMIC NOTIFICATION CARD BUILDER ────────────────────────────────────

  Widget _buildDynamicNotificationCard(NotificationItem item, bool isEn) {
    // Styling by category
    Color badgeColor;
    Color iconBg;
    IconData iconData;
    String tagText;

    switch (item.category) {
      case 'tryon':
        badgeColor = const Color(0xFFE11D48);
        iconBg = const Color(0xFFFFF1F2);
        iconData = Icons.view_in_ar_rounded;
        tagText = isEn ? "3D RENDER" : "RENDU 3D";
        break;
      case 'order':
        badgeColor = const Color(0xFF16A34A);
        iconBg = const Color(0xFFF0FDF4);
        iconData = Icons.local_shipping_rounded;
        tagText = isEn ? "ORDER UPDATE" : "COMMANDE";
        break;
      case 'style':
        badgeColor = const Color(0xFF2563EB);
        iconBg = const Color(0xFFEFF6FF);
        iconData = Icons.auto_awesome_rounded;
        tagText = isEn ? "STYLE MATCH" : "RECOMMANDATION";
        break;
      case 'system':
      default:
        badgeColor = const Color(0xFF9333EA);
        iconBg = const Color(0xFFFAF5FF);
        iconData = Icons.waving_hand_rounded;
        tagText = isEn ? "WELCOME" : "BIENVENUE";
        break;
    }

    final timeAgo = _formatTimeAgo(item.createdAt, isEn);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _handleDeleteNotification(item.id, isEn),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE11D48),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: () => _handleTapNotification(item),
        child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: item.isRead ? null : Border.all(color: badgeColor.withValues(alpha: 0.25), width: 1.2),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: badgeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$tagText • $timeAgo",
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (!item.isRead)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: badgeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.getTitle(isEn),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF172554),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.getBody(isEn),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.actionRoute != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEn ? "View Details" : "Voir les détails",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: badgeColor),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  String _formatTimeAgo(DateTime dt, bool isEn) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) {
      return isEn ? 'Just now' : "À l'instant";
    }
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return isEn ? '${mins}m ago' : 'il y a $mins min';
    }
    if (diff.inHours < 24) {
      final hrs = diff.inHours;
      return isEn ? '${hrs}h ago' : 'il y a $hrs h';
    }
    final days = diff.inDays;
    return isEn ? '${days}d ago' : 'il y a $days j';
  }

  // ── 5. NOTIFICATION PREFERENCES BOTTOM SECTION ───────────────────────────

  Widget _buildNotificationPreferencesSection(bool isEn) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEn
                        ? "Notification preferences panel opened."
                        : "Panneau de préférences de notification ouvert.",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: const Color(0xFF172554),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF172554),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF172554)),
                const SizedBox(width: 8),
                Text(
                  isEn ? "Notification Preferences" : "Préférences de Notification",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isEn
              ? "Manage push alerts, try-on updates, and stylist recommendations"
              : "Gérer les alertes push, les essayages et les recommandations des stylistes",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
