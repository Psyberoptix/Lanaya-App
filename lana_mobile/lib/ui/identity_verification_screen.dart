import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/wallet_provider.dart';
import 'theme.dart';
import 'review_screen.dart';

class IdentityVerificationScreen extends StatefulWidget {
  final double amount;
  final double equivalentValue;
  final double taxAmount;
  final bool isSendingUsd;
  final bool brebFound;

  const IdentityVerificationScreen({
    super.key,
    required this.amount,
    required this.equivalentValue,
    required this.taxAmount,
    required this.isSendingUsd,
    required this.brebFound,
  });

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isProcessing = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _simulateFaceScan();
  }

  Future<void> _simulateFaceScan() async {
    // Wait for the mock Truora delay
    await Future.delayed(const Duration(seconds: 3));
    
    // In a real app we'd call provider.executeSendCop() which calls Truora,
    // but here we just simulate the UI flow before sending them to the Review Screen.
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      _controller.stop();
      
      // Briefly show the success state then move to Review
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReviewScreen(
              amount: widget.amount,
              equivalentValue: widget.equivalentValue,
              taxAmount: widget.taxAmount,
              isSendingUsd: widget.isSendingUsd,
              brebFound: widget.brebFound,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LanaTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Identity Verification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Position your face in the circle',
              style: TextStyle(color: LanaTheme.textColor, fontSize: 18),
            ),
            const SizedBox(height: 48),
            Stack(
              alignment: Alignment.center,
              children: [
                // The rotating scanner ring
                if (_isProcessing)
                  RotationTransition(
                    turns: _controller,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LanaTheme.emeraldGreen.withOpacity(0.5),
                          width: 4,
                        ),
                        gradient: SweepGradient(
                          colors: [
                            Colors.transparent,
                            LanaTheme.emeraldGreen,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                // The simulated camera feed (matte black container for now)
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    color: LanaTheme.surfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isSuccess ? LanaTheme.goldAccent : Colors.transparent,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _isSuccess ? Icons.check_circle : Icons.face,
                      color: _isSuccess ? LanaTheme.goldAccent : LanaTheme.textMuted,
                      size: 80,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              _isProcessing ? 'Verifying with Truora...' : 'Verification Successful',
              style: TextStyle(
                color: _isSuccess ? LanaTheme.goldAccent : LanaTheme.emeraldGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
