import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  // Mock transaction data
  static final List<Map<String, dynamic>> _transactions = [
    {
      'status': 'Paiement Capturé',
      'description': 'Plan Pro — Abonnement mensuel',
      'amount': '19,00 €',
      'date': '03 Oct 2026',
      'time': '14:32',
      'type': 'subscription',
      'icon': Icons.workspace_premium_rounded,
      'color': const Color(0xFFF43F5E),
      'bgColor': const Color(0xFFFFF1F2),
      'ref': 'TXN-FV-20261003-001',
    },
    {
      'status': 'Paiement Capturé',
      'description': 'Robe Midi Structurée — Commande #4821',
      'amount': '74,95 €',
      'date': '01 Oct 2026',
      'time': '10:15',
      'type': 'order',
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFF4F46E5),
      'bgColor': const Color(0xFFEEF2FF),
      'ref': 'TXN-FV-20261001-002',
    },
    {
      'status': 'Paiement Capturé',
      'description': 'Blazer Oversize Crème — Commande #4789',
      'amount': '129,00 €',
      'date': '28 Sep 2026',
      'time': '18:47',
      'type': 'order',
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFF4F46E5),
      'bgColor': const Color(0xFFEEF2FF),
      'ref': 'TXN-FV-20260928-003',
    },
    {
      'status': 'Paiement Capturé',
      'description': 'Plan Pro — Abonnement mensuel',
      'amount': '19,00 €',
      'date': '03 Sep 2026',
      'time': '09:01',
      'type': 'subscription',
      'icon': Icons.workspace_premium_rounded,
      'color': const Color(0xFFF43F5E),
      'bgColor': const Color(0xFFFFF1F2),
      'ref': 'TXN-FV-20260903-004',
    },
    {
      'status': 'Remboursement Effectué',
      'description': 'Retour — Jean Taille Haute #4712',
      'amount': '- 54,00 €',
      'date': '20 Sep 2026',
      'time': '11:22',
      'type': 'refund',
      'icon': Icons.replay_rounded,
      'color': const Color(0xFF16A34A),
      'bgColor': const Color(0xFFF0FDF4),
      'ref': 'TXN-FV-20260920-005',
    },
    {
      'status': 'Paiement Capturé',
      'description': 'Sac Tote Cuir Vegan — Commande #4701',
      'amount': '89,50 €',
      'date': '15 Sep 2026',
      'time': '16:03',
      'type': 'order',
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFF4F46E5),
      'bgColor': const Color(0xFFEEF2FF),
      'ref': 'TXN-FV-20260915-006',
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Group totals
    final totalSpent = _transactions
        .where((t) => t['type'] != 'refund')
        .fold<double>(0.0, (sum, t) {
      final raw = (t['amount'] as String)
          .replaceAll(' €', '')
          .replaceAll(',', '.');
      return sum + (double.tryParse(raw) ?? 0);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FB),
      appBar: AppBar(
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
          'Historique des Transactions',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF172554),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── SUMMARY BANNER ──────────────────────────────────────────
            _buildSummaryBanner(totalSpent),

            // ── TRANSACTION LIST ────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _transactions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildTransactionCard(
                      context, _transactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBanner(double totalSpent) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172554), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF172554).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total dépensé',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${totalSpent.toStringAsFixed(2).replaceAll('.', ',')} €',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_transactions.length} entrées',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, Map<String, dynamic> tx) {
    final isRefund = tx['type'] == 'refund';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + status + amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tx['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tx['icon'] as IconData,
                    size: 22, color: tx['color'] as Color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (tx['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tx['status'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: tx['color'] as Color,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tx['description'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tx['amount'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isRefund
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF172554),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Bottom row: date/time + ref
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    '${tx['date']} • ${tx['time']}',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Text(
                tx['ref'] as String,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFCBD5E1),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
