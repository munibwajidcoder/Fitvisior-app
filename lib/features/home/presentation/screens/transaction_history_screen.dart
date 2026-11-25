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
        if (methodStr.contains('google')) {
          cardBrand = 'Google Pay';
        } else if (methodStr.contains('apple')) {
          cardBrand = 'Apple Pay';
        } else if (methodStr.contains('paypal')) {
          cardBrand = 'PayPal';
        } else if (methodStr.contains('Master')) {
          cardBrand = 'Mastercard';
        } else if (methodStr.contains('Amex') || methodStr.contains('American')) {
          cardBrand = 'AMEX';
        } else if (methodStr.contains('CB')) {
          cardBrand = 'Cartes Bancaires (CB)';
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

      final IconData methodIcon = cardBrand.contains('Google')
          ? Icons.g_mobiledata_rounded
          : (cardBrand.contains('Apple')
              ? Icons.apple_rounded
              : (cardBrand.contains('PayPal')
                  ? Icons.account_balance_wallet_rounded
                  : Icons.credit_card_rounded));

      final Color methodColor = cardBrand.contains('Google')
          ? const Color(0xFFEA4335)
          : (cardBrand.contains('Apple')
              ? const Color(0xFF1E293B)
              : (cardBrand.contains('PayPal')
                  ? const Color(0xFF0070BA)
                  : const Color(0xFF10B981)));

      final Color methodBg = cardBrand.contains('Google')
          ? const Color(0xFFFFF7ED)
          : (cardBrand.contains('Apple')
              ? const Color(0xFFF1F5F9)
              : (cardBrand.contains('PayPal')
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFECFDF5)));

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
        'icon': methodIcon,
        'color': methodColor,
        'bgColor': methodBg,
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

  static String _formatTxnRef(String raw) {
    if (raw.isEmpty) return 'TXN-FV';
    if (raw.length <= 15) return raw;
    if (raw.startsWith('TXN-FV-')) {
      final rem = raw.replaceFirst('TXN-FV-', '');
      final p = rem.split('-');
      if (p.length > 1) {
        return 'TXN-${p[0]}-${p[1]}';
      }
      return 'TXN-${rem.substring(0, 8)}';
    }
    if (raw.startsWith('ch_') || raw.startsWith('in_') || raw.startsWith('pi_')) {
      final prefix = raw.substring(0, 3);
      final id = raw.substring(3);
      return '#$prefix${id.substring(0, id.length > 8 ? 8 : id.length)}...';
    }
    return '#${raw.substring(0, 10)}...';
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn ? 'Total Billed (Stripe)' : 'Total Facturé (Stripe)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${totalSpent.toStringAsFixed(2).replaceAll('.', ',')} €',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 1,
            height: 34,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEn ? 'Invoices' : 'Factures',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isEn
                        ? '${_transactions.length} paid'
                        : '${_transactions.length} payée${_transactions.length > 1 ? 's' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: Colors.white, size: 20),
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
      padding: const EdgeInsets.all(14),
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
          // ── TOP ROW: ICON + STATUS/DESC + AMOUNT ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tx['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tx['icon'] as IconData,
                    size: 20, color: tx['color'] as Color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: (tx['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: tx['color'] as Color,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descText as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF172554),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topRight,
                child: Text(
                  tx['amount'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF172554),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          // ── BOTTOM ROW: DATE/TIME + TXN REFERENCE & RECEIPT ──
          Row(
            children: [
              // Left: Date & Time
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 11, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    '${tx['date']} • ${tx['time']}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Right: Reference ID & External Receipt Link
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: tx['ref'] as String));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEn ? 'Transaction ID copied' : 'ID de transaction copié',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                              duration: const Duration(milliseconds: 1200),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Text(
                          _formatTxnRef(tx['ref'] as String),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    if (receiptUrl != null && receiptUrl.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.parse(receiptUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(2),
                          child: Icon(Icons.open_in_new_rounded,
                              size: 13, color: Color(0xFF2563EB)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
