import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/language_service.dart';
import '../../data/subscription_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final rawList = await SubscriptionService.instance.getTransactions();

    final List<Map<String, dynamic>> formatted = [];

    for (final item in rawList) {
      final amountNum = (item['amount'] as num?)?.toDouble() ?? 2.99;
      final planName = item['plan_name']?.toString() ?? 'FitVisor Pro';
      final billingCycle = item['billing_cycle']?.toString() ?? 'monthly';
      final isAnnual = billingCycle.toLowerCase() == 'annual';
      final txnNum = item['transaction_number']?.toString() ??
          item['id']?.toString() ??
          'TXN-FV-2026';
      final cardLast4 = item['card_last_four']?.toString() ?? '4242';
      final methodStr = item['payment_method']?.toString() ?? '';
      String cardBrand = item['card_brand']?.toString() ?? '';
      if (cardBrand.isEmpty) {
        if (methodStr.contains('Master')) {
          cardBrand = 'Mastercard';
        } else if (methodStr.contains('Amex') || methodStr.contains('American')) {
          cardBrand = 'AMEX';
        } else if (methodStr.contains('CB')) {
          cardBrand = 'CB';
        } else {
          cardBrand = 'Visa';
        }
      }
      final receiptUrl = item['receipt_url']?.toString();

      DateTime dt = DateTime.now();
      if (item['created_at'] != null) {
        dt = DateTime.tryParse(item['created_at'].toString())?.toLocal() ?? DateTime.now();
      }

      final dateStr = '${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}';
      final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

      formatted.add({
        'status_fr': 'Paiement Stripe Capturé',
        'status_en': 'Stripe Payment Captured',
        'desc_fr': '$planName — Abonnement ${isAnnual ? 'annuel' : 'mensuel'} ($cardBrand •••• $cardLast4)',
        'desc_en': '$planName — ${isAnnual ? 'Annual' : 'Monthly'} Subscription ($cardBrand •••• $cardLast4)',
        'amount': '${amountNum.toStringAsFixed(2).replaceAll('.', ',')} €',
        'raw_amount': amountNum,
        'date': dateStr,
        'time': timeStr,
        'type': 'subscription',
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFF10B981),
        'bgColor': const Color(0xFFECFDF5),
        'ref': txnNum,
        'receipt_url': receiptUrl,
      });
    }

    if (mounted) {
      setState(() {
        _transactions = formatted;
        _isLoading = false;
      });
    }
  }

  static String _monthName(int month) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return m[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final totalSpent = _transactions.fold<double>(
      0.0,
      (sum, t) => sum + ((t['raw_amount'] as double?) ?? 0.0),
    );

    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        final isEn = LanguageService.instance.isEnglish;
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
              isEn ? 'Billing & Transactions' : 'Facturation & Transactions',
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
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF172554), size: 20),
                onPressed: _loadTransactions,
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFFF43F5E),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadTransactions,
                    color: const Color(0xFFF43F5E),
                    child: Column(
                      children: [
                        // Summary Banner
                        _buildSummaryBanner(totalSpent, isEn),

                        const SizedBox(height: 12),

                        // List of Transactions or Empty State
                        Expanded(
                          child: _transactions.isEmpty
                              ? _buildEmptyState(isEn)
                              : ListView.separated(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                  itemCount: _transactions.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    return _buildTransactionCard(
                                        context, _transactions[index], isEn);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryBanner(double totalSpent, bool isEn) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            color: const Color(0xFF172554).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
                  isEn ? 'Total Billed (Stripe)' : 'Total Facturé (Stripe)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
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
            height: 38,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Invoices' : 'Factures',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEn
                      ? '${_transactions.length} paid'
                      : '${_transactions.length} payée${_transactions.length > 1 ? 's' : ''}',
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

  Widget _buildEmptyState(bool isEn) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_rounded,
                    size: 36, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 18),
              Text(
                isEn ? 'No Transactions Yet' : 'Aucune Transaction Pour le Moment',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isEn
                    ? 'When you subscribe to FitVisor Pro or Family via Stripe, your monthly invoices will appear here.'
                    : 'Lorsque vous souscrivez à FitVisor Pro ou Family via Stripe, vos factures apparaîtront ici.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(
      BuildContext context, Map<String, dynamic> tx, bool isEn) {
    final statusText = isEn ? tx['status_en'] : tx['status_fr'];
    final descText = isEn ? tx['desc_en'] : tx['desc_fr'];
    final receiptUrl = tx['receipt_url'] as String?;

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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (tx['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText as String,
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
                      descText as String,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF172554),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
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
              Row(
                children: [
                  Text(
                    tx['ref'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (receiptUrl != null && receiptUrl.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse(receiptUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Icon(Icons.open_in_new_rounded,
                          size: 13, color: Color(0xFF2563EB)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
