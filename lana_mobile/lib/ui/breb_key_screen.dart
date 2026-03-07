import 'package:flutter/material.dart';
import '../services/mock_dice_service.dart';
import 'theme.dart';

class BrebKeyScreen extends StatefulWidget {
  const BrebKeyScreen({super.key});

  @override
  State<BrebKeyScreen> createState() => _BrebKeyScreenState();
}

class _BrebKeyScreenState extends State<BrebKeyScreen> {
  final MockDiceService _diceService = MockDiceService();
  final TextEditingController _phoneController = TextEditingController();
  bool _isRegistering = false;
  bool? _registrationResult;
  String _statusMessage = '';

  Future<void> _registerKey() async {
    if (_phoneController.text.length < 10) return;

    setState(() { _isRegistering = true; _registrationResult = null; });

    bool success = await _diceService.registerKey(
      phoneNumber: _phoneController.text.replaceAll('+57', ''),
      userId: 'test_user_123',
      fullName: 'Test User',
    );

    setState(() {
      _isRegistering = false;
      _registrationResult = success;
      _statusMessage = success
          ? 'Your Llave Bre-B is now linked to LanaYa!'
          : 'This number is already registered to another bank. Transfer it first.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Llave Bre-B', style: LanaTheme.brandTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Key icon
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: LanaTheme.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: LanaTheme.goldAccent.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.key, color: LanaTheme.goldAccent, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Register Your Llave', style: TextStyle(color: LanaTheme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Link your phone number to receive\ninstant Bre-B payments in LanaYa.',
                  textAlign: TextAlign.center, style: TextStyle(color: LanaTheme.textMuted, height: 1.5)),
              const SizedBox(height: 12),
              Text('99M+ keys registered nationwide',
                  style: TextStyle(color: LanaTheme.emeraldGreen.withOpacity(0.7), fontSize: 13)),
              const SizedBox(height: 32),

              // Phone input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: LanaTheme.textColor, fontSize: 20),
                decoration: InputDecoration(
                  prefixText: '+57 ',
                  prefixStyle: const TextStyle(color: LanaTheme.textMuted, fontSize: 20),
                  hintText: '300 123 4567',
                  hintStyle: TextStyle(color: LanaTheme.textMuted.withOpacity(0.5), fontSize: 20),
                  filled: true, fillColor: LanaTheme.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Result
              if (_registrationResult != null)
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (_registrationResult! ? LanaTheme.emeraldGreen : Colors.redAccent).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(_registrationResult! ? Icons.check_circle : Icons.error,
                        color: _registrationResult! ? LanaTheme.emeraldGreen : Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_statusMessage,
                        style: TextStyle(color: _registrationResult! ? LanaTheme.emeraldGreen : Colors.redAccent, fontSize: 14))),
                  ]),
                ),

              const Spacer(),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _registerKey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isRegistering
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Register Key', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
