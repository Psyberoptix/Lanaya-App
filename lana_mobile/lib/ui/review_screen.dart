import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/wallet_provider.dart';
import 'theme.dart';
import 'success_screen.dart';

class ReviewScreen extends StatelessWidget {
  final double amount;
  final double equivalentValue;
  final double taxAmount;
  final bool isSendingUsd;
  final bool brebFound;

  const ReviewScreen({
    super.key,
    required this.amount,
    required this.equivalentValue,
    required this.taxAmount,
    required this.isSendingUsd,
    required this.brebFound,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WalletProvider>();
    final copFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO');
    
    // Get the rate used for the transaction
    double currentRate = provider.getExchangeRateWithSpread(isSendingUsd);
    
    // Total COP to be received (if sending USD -> COP) or total COP to be paid (if sending COP)
    double targetCop = isSendingUsd ? equivalentValue : amount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Transfer'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Total COP ${isSendingUsd ? 'Received' : 'Sent'}',
                  style: const TextStyle(color: LanaTheme.textMuted, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${copFormatter.format(targetCop)} COP',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: LanaTheme.emeraldGreen),
                ),
              ),
              const SizedBox(height: 48),

              // Breakdown Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: LanaTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (isSendingUsd) ...[
                      _buildRow('Sending', '\$${amount.toStringAsFixed(2)} USD'),
                      const Divider(color: Colors.white12, height: 32),
                      _buildRow('Markup Rate (vs Mid-market)', '1 USD = ${copFormatter.format(currentRate)} COP'),
                      const Divider(color: Colors.white12, height: 32),
                    ],
                    
                    if (taxAmount > 0) ...[
                      _buildRow(
                        isSendingUsd ? 'COP Equivalent' : 'Sending Original',
                        '${copFormatter.format(isSendingUsd ? equivalentValue : amount)} COP',
                      ),
                      const Divider(color: Colors.white12, height: 32),
                      _buildRow('4x1000 GMF Tax', '+ ${copFormatter.format(taxAmount)}', valueColor: Colors.orangeAccent),
                      const Divider(color: Colors.white12, height: 32),
                      _buildRow(
                        'Total COP Deduction',
                        '${copFormatter.format((isSendingUsd ? equivalentValue : amount) + taxAmount)} COP',
                      ),
                      const Divider(color: Colors.white12, height: 32),
                    ],

                    _buildRow(
                      'Arrival Time', 
                      brebFound ? 'Instant via Bre-B' : 'Standard P2P',
                      valueColor: brebFound ? LanaTheme.goldAccent : LanaTheme.emeraldGreen,
                    ),
                  ],
                ),
              ),

              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // In a real app, this would await provider.executeSendCop(...)
                    provider.executeSendCop(isSendingUsd ? targetCop : amount);
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SuccessScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('LanaYa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color valueColor = LanaTheme.textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: LanaTheme.textMuted, fontSize: 16)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
