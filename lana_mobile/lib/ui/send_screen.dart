import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/wallet_provider.dart';
import 'theme.dart';
import 'review_screen.dart';
import 'identity_verification_screen.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  String _amountStr = '0';
  bool _isSendingUsd = true; 
  String _phoneNumber = '';
  bool _brebFound = false;

  bool _isInit = true;
  bool _maintenanceMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _fetchRate();
      _isInit = false;
    }
  }

  Future<void> _fetchRate() async {
    final provider = context.read<WalletProvider>();
    double? rate = await provider.fetchExchangeRate();
    if (mounted) {
      setState(() {
        _maintenanceMode = rate == null;
      });
    }
  }
  String? _brebName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchExchangeRate();
    });
  }

  void _onKeyPress(String key) {
    setState(() {
      if (key == '<') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (key == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += key;
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = key;
        } else {
          // Limit length so it fits on screen
          if (_amountStr.length < 10) {
            _amountStr += key;
          }
        }
      }
    });
  }

  void _toggleCurrency() {
    setState(() {
      _isSendingUsd = !_isSendingUsd;
    });
  }

  void _checkBrebLookup(String phone) async {
    final provider = context.read<WalletProvider>();
    final result = await provider.lookupBreb(phone);
    if (result != null) {
      setState(() {
        _brebFound = true;
        _brebName = result['name'];
      });
    } else {
      setState(() {
        _brebFound = false;
        _brebName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WalletProvider>();
    final wallet = provider.wallet;
    
    // Formatting
    final double amount = double.tryParse(_amountStr) ?? 0.0;
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final copFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0, locale: 'es_CO');
    
    double equivalentValue = 0.0;
    if (amount > 0) {
      equivalentValue = provider.convert(amount, _isSendingUsd);
    }
    
    // Tax warning condition
    bool showWarning = false;
    double taxAmount = 0.0;

    if (!_isSendingUsd && amount > 0) {
      taxAmount = provider.calculate4x1000Tax(amount);
      if (provider.willExceedMonthlyLimit(amount)) {
        showWarning = true;
      }
    } else if (_isSendingUsd && equivalentValue > 0) {
      // 4x1000 applies to the COP deduction regardless of the input currency.
      taxAmount = provider.calculate4x1000Tax(equivalentValue);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lana'),
        actions: [
          IconButton(
            icon: Icon(
              provider.isComplianceMode ? Icons.verified_user : Icons.gpp_bad,
              color: provider.isComplianceMode ? LanaTheme.emeraldGreen : Colors.grey,
            ),
            tooltip: 'Compliance Mode Toggle',
            onPressed: provider.toggleComplianceMode,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balances
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('USD: ${formatter.format(wallet.balanceUsd)}', style: const TextStyle(color: LanaTheme.textMuted)),
                  const SizedBox(width: 16),
                  Text('COP: ${copFormatter.format(wallet.balanceCop)}', style: const TextStyle(color: LanaTheme.textMuted)),
                ],
              ),
            ),
            const Spacer(),
            
            if (_maintenanceMode)
              Expanded(
                flex: 4,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.redAccent, size: 64),
                      const SizedBox(height: 16),
                      const Text('Maintenance Mode', style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Exchange services offline.', style: TextStyle(color: LanaTheme.textMuted)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _fetchRate,
                        child: const Text('Retry Connection'),
                      )
                    ],
                  ),
                ),
              )
            else
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // Amount Display
                    GestureDetector(
              onTap: _toggleCurrency,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _isSendingUsd ? 'USD ' : 'COP ',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: LanaTheme.emeraldGreen),
                  ),
                  Text(
                    _amountStr,
                    style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w600, color: LanaTheme.textColor),
                  ),
                ],
              ),
            ),
            if (equivalentValue > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '≈ ${_isSendingUsd ? copFormatter.format(equivalentValue) + ' COP' : formatter.format(equivalentValue) + ' USD'}',
                  style: const TextStyle(fontSize: 18, color: LanaTheme.textMuted),
                ),
              ),

            // Tax Warning & Exemption Toggle
            if (showWarning || provider.showTaxWarning)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tax Warning: Volume > ${copFormatter.format(provider.dianThresholdCop)} COP (1,400 UVT)',
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // Simple auto-applied tax preview (Colombians only)
            if (taxAmount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '4x1000 GMF: ${copFormatter.format(taxAmount)}',
                      style: const TextStyle(fontSize: 14, color: Colors.orangeAccent),
                    ),
                  ],
                ),
              ),
                  ],
                ),
              ),

            // Fee-Free Credit Badge Display
            if (provider.user.hasFeeFreeCredit)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.stars, color: LanaTheme.goldAccent, size: 20),
                    SizedBox(width: 8),
                    Text('Fee-Free Credit Applied!', style: TextStyle(color: LanaTheme.goldAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            // Bre-B input
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: LanaTheme.textColor),
                decoration: InputDecoration(
                  hintText: 'Enter phone number (e.g. +573001234567)',
                  hintStyle: const TextStyle(color: LanaTheme.textMuted),
                  filled: true,
                  fillColor: LanaTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: _brebFound 
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flash_on, color: LanaTheme.goldAccent),
                          SizedBox(width: 4),
                          Text('Bre-B', style: TextStyle(color: LanaTheme.goldAccent, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12),
                        ],
                      ) 
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _checkBrebLookup(_phoneNumber),
                      ),
                ),
                onChanged: (val) {
                  _phoneNumber = val;
                  if (val.length > 9) {
                    _checkBrebLookup(val);
                  } else {
                    setState(() {
                      _brebFound = false;
                      _brebName = null;
                    });
                  }
                },
              ),
            ),
            if (_brebName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text('Sending to: $_brebName', style: const TextStyle(color: LanaTheme.emeraldGreen)),
              ),

            const Spacer(),
            
            // Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['4', '5', '6']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['7', '8', '9']),
                  const SizedBox(height: 16),
                  _buildKeypadRow(['.', '0', '<']),
                ],
              ),
            ),

            // Send Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (amount > 0 && !_maintenanceMode) ? () {
                    // Route through Identity Verification first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdentityVerificationScreen(
                          amount: amount,
                          equivalentValue: equivalentValue,
                          taxAmount: taxAmount,
                          isSendingUsd: _isSendingUsd,
                          brebFound: _brebFound,
                        ),
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Send', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) {
        return GestureDetector(
          onTap: () => _onKeyPress(k),
          child: Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: k == '<'
                ? const Icon(Icons.backspace_outlined, size: 28, color: LanaTheme.textColor)
                : Text(
                    k,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: LanaTheme.textColor),
                  ),
          ),
        );
      }).toList(),
    );
  }
}
