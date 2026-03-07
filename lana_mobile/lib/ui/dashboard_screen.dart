import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/wallet_provider.dart';
import '../services/lana_insights_engine.dart';
import '../services/biometric_service.dart';
import 'theme.dart';
import 'send_screen.dart';
import 'qr_scanner_screen.dart';
import 'bill_pay_screen.dart';
import 'link_bank_screen.dart';
import 'breb_key_screen.dart';
import 'package:share_plus/share_plus.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final LanaInsightsEngine _insightsEngine = LanaInsightsEngine();
  final BiometricService _biometricService = BiometricService();
  String _smartTip = '';
  bool _tipDismissed = false;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticateOnOpen();
  }

  Future<void> _authenticateOnOpen() async {
    bool result = await _biometricService.authenticate(reason: 'Unlock LanaYa');
    setState(() => _authenticated = result);

    if (_authenticated) {
      _generateSmartTip();
    }
  }

  void _generateSmartTip() {
    final provider = context.read<WalletProvider>();
    final rate = provider.getExchangeRateWithSpread(true);
    setState(() {
      _smartTip = _insightsEngine.generateSmartTip(
        balanceUsd: provider.wallet.balanceUsd,
        balanceCop: provider.wallet.balanceCop,
        currentFxRate: rate,
        now: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return Scaffold(
        backgroundColor: LanaTheme.darkBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: LanaTheme.goldAccent, size: 64),
              const SizedBox(height: 24),
              Text('LanaYa', style: LanaTheme.brandTitle.copyWith(fontSize: 36)),
              const SizedBox(height: 16),
              const Text('Authenticate to continue', style: TextStyle(color: LanaTheme.textMuted)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _authenticateOnOpen,
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<WalletProvider>(
      builder: (context, provider, _) {
        final wallet = provider.wallet;
        final copFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO');
        final now = DateTime.now();
        final isFridayAfternoon = now.weekday == 5 && now.hour >= 12;

        return Scaffold(
          backgroundColor: LanaTheme.darkBackground,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('LanaYa', style: LanaTheme.brandTitle),
                if (provider.user.isFoundingMember) ...[                  
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: LanaTheme.goldAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: LanaTheme.goldAccent.withOpacity(0.4)),
                    ),
                    child: const Text('👑 Founder', style: TextStyle(color: LanaTheme.goldAccent, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.key, color: LanaTheme.goldAccent, size: 20),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BrebKeyScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: LanaTheme.textMuted),
                onPressed: () {},
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.small(
            backgroundColor: LanaTheme.surfaceColor,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: LanaTheme.surfaceColor,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Report a Bug', style: TextStyle(color: LanaTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Your screenshot and device logs will be sent to our team.', style: TextStyle(color: LanaTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 20),
                    SizedBox(width: double.infinity, child: ElevatedButton(
                      onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bug report sent! Gracias 🙏'), backgroundColor: LanaTheme.emeraldGreen)); },
                      child: const Text('Send Report'),
                    )),
                    const SizedBox(height: 12),
                  ]),
                ),
              );
            },
            child: const Icon(Icons.bug_report, color: LanaTheme.textMuted, size: 20),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Cards
                  Row(
                    children: [
                      Expanded(child: _buildBalanceCard('USD', '\$${wallet.balanceUsd.toStringAsFixed(2)}', LanaTheme.emeraldGreen)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildBalanceCard('COP', copFormatter.format(wallet.balanceCop), LanaTheme.goldAccent)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tax Tracker Widget (Colombians only)
                  if (provider.isColombian)
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: LanaTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('4x1000 Tax Tracker', style: TextStyle(color: LanaTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('${(provider.taxExemptionUsage * 100).toStringAsFixed(1)}% used',
                              style: TextStyle(color: provider.taxExemptionUsage > 0.8 ? Colors.orangeAccent : LanaTheme.emeraldGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                        const SizedBox(height: 10),
                        ClipRRect(borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: provider.taxExemptionUsage,
                            backgroundColor: LanaTheme.darkBackground,
                            valueColor: AlwaysStoppedAnimation<Color>(provider.taxExemptionUsage > 0.8 ? Colors.orangeAccent : LanaTheme.emeraldGreen),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${copFormatter.format(provider.taxExemptionRemaining)} COP exempt remaining',
                            style: const TextStyle(color: LanaTheme.textMuted, fontSize: 12)),
                      ]),
                    ),
                  const SizedBox(height: 16),

                  // Smart Tip Card
                  if (!_tipDismissed && _smartTip.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [LanaTheme.surfaceColor, LanaTheme.surfaceColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: LanaTheme.goldAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_smartTip, style: const TextStyle(color: LanaTheme.textColor, fontSize: 14, height: 1.5)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: LanaTheme.textMuted, size: 18),
                            onPressed: () => setState(() => _tipDismissed = true),
                          ),
                        ],
                      ),
                    ),
                  if (!_tipDismissed && _smartTip.isNotEmpty) const SizedBox(height: 24),

                  // Quick Actions
                  const Text('Quick Actions', style: TextStyle(color: LanaTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  // Dynamic Send Button — bigger on Friday afternoons
                  SizedBox(
                    width: double.infinity,
                    height: isFridayAfternoon ? 80 : 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SendScreen()));
                      },
                      icon: Icon(Icons.send_rounded, size: isFridayAfternoon ? 28 : 20),
                      label: Text(
                        isFridayAfternoon ? 'Send Money — Best Rates Before Monday!' : 'Send Money',
                        style: TextStyle(fontSize: isFridayAfternoon ? 18 : 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFridayAfternoon ? LanaTheme.goldAccent : LanaTheme.emeraldGreen,
                        foregroundColor: isFridayAfternoon ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen())),
                          child: _buildActionCard(Icons.qr_code_scanner, 'Scan QR', LanaTheme.emeraldGreen),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPayScreen())),
                          child: _buildActionCard(Icons.receipt_long, 'Pay Bills', LanaTheme.goldAccent),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkBankScreen())),
                          child: _buildActionCard(Icons.account_balance, 'Link Bank', LanaTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bill Reminder (simulated)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: LanaTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.receipt_long, color: Colors.orangeAccent, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ETB Electricity', style: TextStyle(color: LanaTheme.textColor, fontWeight: FontWeight.w600)),
                              Text('Due March 15 · \$142,300 COP', style: TextStyle(color: LanaTheme.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: LanaTheme.textMuted),
                      ],
                    ),
                  ),

                  // LanaYa Points
                  if (provider.user.lanayaPoints > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LanaTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: LanaTheme.goldAccent, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('LanaYa Points', style: TextStyle(color: LanaTheme.textColor, fontWeight: FontWeight.w600)),
                                Text('${provider.user.lanayaPoints} pts · ${provider.user.hasFeeFreeCredit ? "1 Fee-Free credit available" : "Refer a friend to earn more"}',
                                  style: const TextStyle(color: LanaTheme.textMuted, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Share LanaYa Referral Section
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [LanaTheme.goldAccent.withOpacity(0.15), LanaTheme.surfaceColor],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LanaTheme.goldAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.card_giftcard, color: LanaTheme.goldAccent, size: 22),
                          SizedBox(width: 8),
                          Text('Share LanaYa', style: TextStyle(color: LanaTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 8),
                        const Text('Invite friends and earn Fee-Free credits!', style: TextStyle(color: LanaTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Share.share('Join LanaYa — the smartest way to send money in Colombia! Use my code: LANA-${provider.user.id.substring(0, 6).toUpperCase()} for a free transfer. https://lanaya.co/invite');
                            },
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share Referral Link'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: LanaTheme.goldAccent,
                              side: const BorderSide(color: LanaTheme.goldAccent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildBalanceCard(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LanaTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: LanaTheme.textColor, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: LanaTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
