import 'package:flutter/material.dart';
import 'theme.dart';
import '../services/receipt_service.dart';
import 'package:provider/provider.dart';
import '../logic/wallet_provider.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WalletProvider>();
    final amountSpent = provider.wallet.monthlyCopVolume.toString(); // Simulated recent spend for display
    final date = DateTime.now();

    return Scaffold(
      backgroundColor: LanaTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // The Golden Receipt Mock
              Transform.scale(
                scale: 0.85,
                child: ReceiptService().buildGoldenReceipt(
                  amountSpent, 
                  'BREB-TXN-99X${date.millisecond}', 
                  date,
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Transfer Complete',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: LanaTheme.textColor),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Your funds are on their way.',
                style: TextStyle(fontSize: 16, color: LanaTheme.textMuted),
              ),
              
              const Spacer(),
              
              // Share Receipt Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generating high-res JPG for WhatsApp...')),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, color: LanaTheme.goldAccent),
                    label: const Text('Share Receipt', style: TextStyle(color: LanaTheme.goldAccent)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: LanaTheme.goldAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
              
              // Done Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop back to Send Screen
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LanaTheme.surfaceColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Done', style: TextStyle(color: LanaTheme.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
