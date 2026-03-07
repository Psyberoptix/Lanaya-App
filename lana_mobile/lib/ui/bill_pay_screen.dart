import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/wallet_provider.dart';
import '../services/mock_biller_service.dart';
import 'theme.dart';

class BillPayScreen extends StatefulWidget {
  const BillPayScreen({super.key});

  @override
  State<BillPayScreen> createState() => _BillPayScreenState();
}

class _BillPayScreenState extends State<BillPayScreen> {
  final MockBillerService _billerService = MockBillerService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _billers = [];
  Map<String, String>? _selectedBiller;
  String _referenceNumber = '';
  double _amountCop = 0;
  bool _isPaying = false;
  bool _paid = false;

  @override
  void initState() {
    super.initState();
    _billers = _billerService.searchBillers('');
  }

  void _search(String query) {
    setState(() => _billers = _billerService.searchBillers(query));
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'bolt': return Icons.bolt;
      case 'phone': return Icons.phone;
      case 'signal_cellular_alt': return Icons.signal_cellular_alt;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'water_drop': return Icons.water_drop;
      default: return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WalletProvider>();
    final copFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO');

    if (_paid) {
      return Scaffold(
        appBar: AppBar(title: Text('Bill Pay', style: LanaTheme.brandTitle)),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle, color: LanaTheme.emeraldGreen, size: 64),
          const SizedBox(height: 16),
          const Text('Payment Sent!', style: TextStyle(color: LanaTheme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${copFormatter.format(_amountCop)} to ${_selectedBiller?['name']}', style: const TextStyle(color: LanaTheme.textMuted)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ])),
      );
    }

    if (_selectedBiller != null) {
      final usdEquivalent = _amountCop > 0 ? provider.convert(_amountCop, false) : 0.0;
      return Scaffold(
        appBar: AppBar(title: Text(_selectedBiller!['name']!, style: const TextStyle(fontSize: 18))),
        body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: TextInputType.number, style: const TextStyle(color: LanaTheme.textColor),
              decoration: InputDecoration(hintText: 'Reference Number', hintStyle: const TextStyle(color: LanaTheme.textMuted),
                  filled: true, fillColor: LanaTheme.surfaceColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              onChanged: (v) => _referenceNumber = v,
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number, style: const TextStyle(color: LanaTheme.textColor),
              decoration: InputDecoration(hintText: 'Amount (COP)', hintStyle: const TextStyle(color: LanaTheme.textMuted),
                  filled: true, fillColor: LanaTheme.surfaceColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
              onChanged: (v) => setState(() => _amountCop = double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 16),
            if (_amountCop > 0) ...[
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: LanaTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Amount', style: TextStyle(color: LanaTheme.textMuted)),
                    Text(copFormatter.format(_amountCop), style: const TextStyle(color: LanaTheme.textColor, fontWeight: FontWeight.w600)),
                  ]),
                  const Divider(color: Colors.white12, height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('From USD (incl. 1.5%)', style: TextStyle(color: LanaTheme.textMuted)),
                    Text('\$${usdEquivalent.toStringAsFixed(2)} USD', style: const TextStyle(color: LanaTheme.goldAccent, fontWeight: FontWeight.w600)),
                  ]),
                ]),
              ),
            ],
            const Spacer(),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: (_amountCop > 0 && !_isPaying) ? () async {
                setState(() => _isPaying = true);
                await _billerService.payBill(billerId: _selectedBiller!['id']!, amountCop: _amountCop, referenceNumber: _referenceNumber);
                setState(() { _isPaying = false; _paid = true; });
              } : null,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: _isPaying ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Pay Bill', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
          ],
        ))),
      );
    }

    // Biller search list
    return Scaffold(
      appBar: AppBar(title: Text('Pay Bills', style: LanaTheme.brandTitle)),
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: TextField(
          controller: _searchController, style: const TextStyle(color: LanaTheme.textColor),
          decoration: InputDecoration(hintText: 'Search billers...', hintStyle: const TextStyle(color: LanaTheme.textMuted),
              prefixIcon: const Icon(Icons.search, color: LanaTheme.textMuted), filled: true, fillColor: LanaTheme.surfaceColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          onChanged: _search,
        )),
        Expanded(child: ListView.builder(
          itemCount: _billers.length,
          itemBuilder: (ctx, i) {
            final b = _billers[i];
            return ListTile(
              leading: Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: LanaTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getIcon(b['icon']!), color: LanaTheme.emeraldGreen)),
              title: Text(b['name']!, style: const TextStyle(color: LanaTheme.textColor)),
              subtitle: Text(b['category']!, style: const TextStyle(color: LanaTheme.textMuted, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: LanaTheme.textMuted),
              onTap: () => setState(() => _selectedBiller = b),
            );
          },
        )),
      ])),
    );
  }
}
