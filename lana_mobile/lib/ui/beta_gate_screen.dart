import 'package:flutter/material.dart';
import '../services/beta_code_service.dart';
import 'theme.dart';

class BetaGateScreen extends StatefulWidget {
  final Widget child; // The app content behind the gate
  final Function(String code) onCodeValidated;

  const BetaGateScreen({super.key, required this.child, required this.onCodeValidated});

  @override
  State<BetaGateScreen> createState() => _BetaGateScreenState();
}

class _BetaGateScreenState extends State<BetaGateScreen> with SingleTickerProviderStateMixin {
  final BetaCodeService _codeService = BetaCodeService();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isValidating = false;
  String? _error;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _validateCode() async {
    if (_code.length != 6) return;
    setState(() { _isValidating = true; _error = null; });

    bool valid = await _codeService.validateCode(_code);
    if (valid) {
      await _codeService.redeemCode(_code, 'test_user_123');
      widget.onCodeValidated(_code);
    } else {
      setState(() { _error = 'Invalid or expired code'; _isValidating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) => Opacity(
                  opacity: 0.6 + (_pulseController.value * 0.4),
                  child: Text('LanaYa', style: LanaTheme.brandTitle.copyWith(fontSize: 42, color: LanaTheme.goldAccent)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Private Beta', style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 4)),
              const Spacer(),

              // Code input
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter Invitation Code', style: TextStyle(color: LanaTheme.goldAccent, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => SizedBox(
                  width: 48, height: 56,
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(color: LanaTheme.goldAccent, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFF111111),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: LanaTheme.goldAccent.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: LanaTheme.goldAccent.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: LanaTheme.goldAccent, width: 2),
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      if (_code.length == 6) _validateCode();
                    },
                  ),
                )),
              ),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],

              const SizedBox(height: 32),

              if (_isValidating)
                const CircularProgressIndicator(color: LanaTheme.goldAccent, strokeWidth: 2)
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _code.length == 6 ? _validateCode : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LanaTheme.goldAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor: const Color(0xFF222222),
                    ),
                    child: const Text('Enter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),

              const Spacer(flex: 2),
              const Text('By invitation only', style: TextStyle(color: Color(0xFF4B5563), fontSize: 12)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
