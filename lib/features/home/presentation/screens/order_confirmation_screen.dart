import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'purchase_fit_feedback_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Top Confirmation Header (Red Check Icon + Badge + Title)
              _buildTopHeader(),
              const SizedBox(height: 20),

              // 2. Order Identifier Card (#DK-984210)
              _buildOrderIdentifierCard(),
              const SizedBox(height: 20),

              // 3. Garments Confirmed List
              _buildGarmentsConfirmedSection(),
              const SizedBox(height: 20),

              // 4. Fulfillment Timeline
              _buildFulfillmentTimelineSection(),
              const SizedBox(height: 24),

              // 5. Action Buttons (Continue to Feedback & Return Home)
              _buildActionButtons(),
              const SizedBox(height: 16),

              // 6. Bottom Delivery Ping Banner
              _buildBottomPingBanner(),
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

  // ── 1. TOP HEADER (RED CHECK GLOW + TITLE) ──────────────────────────────

  Widget _buildTopHeader() {
    return Column(
      children: [
        // Glowing Red Check Icon Circle
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFE11D48),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
        const SizedBox(height: 14),

        // Pill Badge: COMMANDE BOUTIQUE PLACÉE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded,
                  size: 13, color: Color(0xFFE11D48)),
              const SizedBox(width: 5),
              Text(
                "COMMANDE BOUTIQUE PLACÉE",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFBE123C),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Main Greeting Title
        Text(
          "Vous êtes tous prêts, Alexa !",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Votre commande sur-mesure est confirmée et en cours de préparation par Atelier FitVisor.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // ── 2. ORDER IDENTIFIER CARD (#DK-984210) ───────────────────────────────

  Widget _buildOrderIdentifierCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Order ID Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "IDENTIFIANT DE COMMANDE",
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "#DK-984210",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172554),
                      ),
                    ),
                  ],
                ),
              ),
              // Copy Button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: "#DK-984210"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Identifiant copié !",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF172554),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.copy_rounded,
                          size: 13, color: Color(0xFF475569)),
                      const SizedBox(width: 4),
                      Text(
                        "Copier",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inner Details Gray Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Livraison Estimée",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Jeu, 31 Oct • Express",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                            overflow: TextOverflow.ellipsis,
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
                            "Mode de Paiement",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Apple Pay • 668,75 €",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF172554),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0xFFE11D48)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "742 Evergreen Terrace, New York, NY 10001",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. GARMENTS CONFIRMED SECTION ────────────────────────────────────────

  Widget _buildGarmentsConfirmedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Vêtements Confirmés (2)",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF172554),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.fit_screen_rounded,
                    size: 13, color: Color(0xFFE11D48)),
                const SizedBox(width: 4),
                Text(
                  "3D Digital Twin Prêt",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE11D48),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Item 1
        _buildGarmentItemCard(
          imagePath: 'assets/images/product_dress.jpg',
          sizeBadge: 'Taille M',
          title: 'Sculpted Drape Silk Midi',
          subtitle: 'Midnight Noir Atelier • 340,00 €',
        ),
        const SizedBox(height: 10),

        // Item 2
        _buildGarmentItemCard(
          imagePath: 'assets/images/product_suit.jpg',
          sizeBadge: 'Taille 38',
          title: 'Tailored Structured Blazer',
          subtitle: 'Midnight Navy Couture • 328,75 €',
        ),
      ],
    );
  }

  Widget _buildGarmentItemCard({
    required String imagePath,
    required String sizeBadge,
    required String title,
    required String subtitle,
  }) {
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: 54,
              height: 66,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 11, color: Color(0xFFE11D48)),
                          const SizedBox(width: 3),
                          Text(
                            "Fit Synced",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sizeBadge,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF172554),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. FULFILLMENT TIMELINE SECTION ─────────────────────────────────────

  Widget _buildFulfillmentTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            "Chronologie d'Exécution",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF172554),
            ),
          ),
          const SizedBox(height: 14),

          // Timeline Step 1 (Completed)
          _buildTimelineStep(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFFE11D48),
            title: "Commande Confirmée",
            subtitle: "Paiement capturé & silhouette biométrique associée",
            isDone: true,
            hasLineBelow: true,
          ),

          // Timeline Step 2 (Active)
          _buildTimelineStep(
            icon: Icons.sync_rounded,
            iconColor: const Color(0xFF172554),
            title: "Confection Atelier & Expédition",
            subtitle: "Précision du patron vérifiée à l'Atelier FitVisor",
            isActive: true,
            hasLineBelow: true,
          ),

          // Timeline Step 3 (Pending)
          _buildTimelineStep(
            icon: Icons.local_shipping_outlined,
            iconColor: const Color(0xFF94A3B8),
            title: "Livraison Prévue",
            subtitle: "Jeudi 31 Octobre • Courrier Direct",
            isDone: false,
            hasLineBelow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isDone = false,
    bool isActive = false,
    bool hasLineBelow = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF172554)
                    : (isDone ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : iconColor,
              ),
            ),
            if (hasLineBelow)
              Container(
                width: 2,
                height: 34,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF172554),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Actif",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  // ── 5. ACTION BUTTONS ───────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Button 1: Continuer vers les Commentaires (Continue to Purchase Feedback)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PurchaseFitFeedbackScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E), // Exact Coral Pink theme color
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
                Text(
                  "Continuer vers les Commentaires",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Button 2: Retour à l'Accueil (Back to Home)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(initialIndex: 0),
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
                const Icon(Icons.storefront_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Retour à l'Accueil",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 6. BOTTOM PING BANNER ────────────────────────────────────────────────

  Widget _buildBottomPingBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.style_rounded, size: 18, color: Color(0xFFE11D48)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Nous vous contacterons après la livraison pour vérifier le drapé réel du tissu !",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFBE123C),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
