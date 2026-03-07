import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _scanned = false;
  Map<String, String>? _merchantData;

  /// Parses a Bre-B standard merchant QR code.
  /// Expected format: "BREB:merchantId:businessName:amountCOP"
  Map<String, String>? _parseBrebCode(String rawValue) {
    final parts = rawValue.split(':');
    if (parts.length >= 3 && parts[0] == 'BREB') {
      return {
        'merchantId': parts[1],
        'businessName': parts[2],
        'amountCop': parts.length >= 4 ? parts[3] : '0',
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_scanned && _merchantData != null) {
      return _buildPayMerchantSummary();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Scan QR', style: LanaTheme.brandTitle)),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_scanned) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  final parsed = _parseBrebCode(barcode.rawValue!);
                  if (parsed != null) {
                    setState(() {
                      _scanned = true;
                      _merchantData = parsed;
                    });
                    return;
                  }
                }
              }
            },
          ),
          // Overlay
          Center(
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: LanaTheme.emeraldGreen, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 80,
            left: 0, right: 0,
            child: Text('Align Bre-B merchant QR code', textAlign: TextAlign.center,
                style: TextStyle(color: LanaTheme.textColor, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPayMerchantSummary() {
    final merchant = _merchantData!;
    final amount = double.tryParse(merchant['amountCop'] ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text('Pay Merchant', style: LanaTheme.brandTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: LanaTheme.surfaceColor, shape: BoxShape.circle,
                  border: Border.all(color: LanaTheme.emeraldGreen, width: 2)),
                child: const Icon(Icons.store, color: LanaTheme.emeraldGreen, size: 40),
              ),
              const SizedBox(height: 24),
              Text(merchant['businessName'] ?? 'Unknown', style: const TextStyle(color: LanaTheme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Merchant ID: ${merchant['merchantId']}', style: const TextStyle(color: LanaTheme.textMuted)),
              const SizedBox(height: 32),
              if (amount > 0)
                Text('\$${amount.toStringAsFixed(0)} COP', style: const TextStyle(color: LanaTheme.emeraldGreen, fontSize: 42, fontWeight: FontWeight.bold)),
              const Spacer(),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() { _scanned = false; _merchantData = null; }),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), side: const BorderSide(color: LanaTheme.textMuted),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Scan Again', style: TextStyle(color: LanaTheme.textMuted)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { Navigator.pop(context); },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
