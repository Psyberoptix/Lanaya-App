import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/mock_bank_service.dart';
import '../services/credit_underwriting_service.dart';
import 'theme.dart';

class LinkBankScreen extends StatefulWidget {
  const LinkBankScreen({super.key});

  @override
  State<LinkBankScreen> createState() => _LinkBankScreenState();
}

class _LinkBankScreenState extends State<LinkBankScreen> {
  final MockBankService _bankService = MockBankService();
  final CreditUnderwritingService _creditService = CreditUnderwritingService();
  bool _isLinking = false;
  bool _isLinked = false;
  List<Map<String, dynamic>> _transactions = [];
  Map<String, dynamic>? _creditOffer;

  Future<void> _linkBank() async {
    setState(() => _isLinking = true);
    bool success = await _bankService.linkBancolombia();
    if (success) {
      _transactions = await _bankService.fetchRecentTransactions();
      final summary = await _bankService.getAccountSummary();
      _creditOffer = _creditService.evaluateCreditOffer(summary);
    }
    setState(() {
      _isLinking = false;
      _isLinked = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final copFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO');

    return Scaffold(
      appBar: AppBar(title: Text('Link Bank', style: LanaTheme.brandTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: !_isLinked
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: LanaTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Icon(Icons.account_balance, color: LanaTheme.goldAccent, size: 48),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Connect Your Bank', style: TextStyle(color: LanaTheme.textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Link your Bancolombia account to unlock\ncredit offers and transaction insights.',
                          textAlign: TextAlign.center, style: TextStyle(color: LanaTheme.textMuted, height: 1.5)),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLinking ? null : _linkBank,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                          child: _isLinking
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Link Bancolombia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Success banner
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: LanaTheme.emeraldGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: const Row(children: [
                          Icon(Icons.check_circle, color: LanaTheme.emeraldGreen),
                          SizedBox(width: 12),
                          Text('Bancolombia linked successfully', style: TextStyle(color: LanaTheme.emeraldGreen, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // Credit offer card
                      if (_creditOffer != null) ...[
                        Container(
                          width: double.infinity, padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: LanaTheme.surfaceColor, borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: LanaTheme.goldAccent.withOpacity(0.4)),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Row(children: [
                              Icon(Icons.stars, color: LanaTheme.goldAccent, size: 22),
                              SizedBox(width: 8),
                              Text('LanaYa Advance', style: TextStyle(color: LanaTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 12),
                            Text('You qualify for up to', style: const TextStyle(color: LanaTheme.textMuted)),
                            const SizedBox(height: 4),
                            Text('${copFormatter.format(_creditOffer!['offerAmountCop'])} COP',
                                style: const TextStyle(color: LanaTheme.textColor, fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(_creditOffer!['reason'], style: const TextStyle(color: LanaTheme.textMuted, fontSize: 13)),
                            Text('${_creditOffer!['interestRate']}% interest · ${_creditOffer!['termDays']} day term',
                                style: const TextStyle(color: LanaTheme.emeraldGreen, fontSize: 13, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Recent transactions
                      const Text('Recent Transactions', style: TextStyle(color: LanaTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ..._transactions.map((tx) => Container(
                        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: LanaTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Icon(tx['type'] == 'CREDIT' ? Icons.arrow_downward : Icons.arrow_upward,
                              color: tx['type'] == 'CREDIT' ? LanaTheme.emeraldGreen : Colors.redAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(tx['description'], style: const TextStyle(color: LanaTheme.textColor, fontSize: 14)),
                            Text(tx['date'], style: const TextStyle(color: LanaTheme.textMuted, fontSize: 12)),
                          ])),
                          Text(copFormatter.format(tx['amount'].abs()),
                              style: TextStyle(color: tx['type'] == 'CREDIT' ? LanaTheme.emeraldGreen : Colors.redAccent, fontWeight: FontWeight.w600)),
                        ]),
                      )),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
