import 'package:flutter/foundation.dart';
import '../models/wallet_model.dart';
import '../services/mock_breb_service.dart';
import '../services/lana_exchange_service.dart';
import '../services/tax_service.dart';
import '../services/mock_truora_service.dart';
import '../services/audit_log_service.dart';
import '../models/user_model.dart';

class WalletProvider with ChangeNotifier {
  WalletModel _wallet = WalletModel(
    userId: 'test_user_123',
    balanceUsd: 1250.00,
    balanceCop: 15500000.0,
    monthlyCopVolume: 15500000.0, 
  );

  bool _isComplianceMode = false;
  double _currentBaseRate = 3950.0; // Current base market rate
  
  final MockBrebService _brebService = MockBrebService();
  final LanaExchangeService _exchangeService = LanaExchangeService();
  final TaxService _taxService = TaxService();
  final MockTruoraService _truoraService = MockTruoraService();
  final AuditLogService _auditLogService = AuditLogService();
  
  UserModel user = UserModel(
    id: 'test_user_123',
    cedula: '1234567890',
    kycStatus: 'APPROVED',
    lanayaPoints: 1500,
    hasFeeFreeCredit: true,
  );

  bool get isComplianceMode => _isComplianceMode;
  bool get isColombian => user.cedula.isNotEmpty;
  WalletModel get wallet => _wallet;

  void toggleComplianceMode() {
    _isComplianceMode = !_isComplianceMode;
    notifyListeners();
  }

  void toggleApiFailure() {
    _exchangeService.toggleApiFailure();
    notifyListeners();
  }

  void toggleFeeFreeCredit() {
    user = UserModel(
      id: user.id,
      cedula: user.cedula,
      kycStatus: user.kycStatus,
      complianceModeBypass: user.complianceModeBypass,
      lanayaPoints: user.lanayaPoints,
      hasFeeFreeCredit: !user.hasFeeFreeCredit,
    );
    notifyListeners();
  }

  Future<double?> fetchExchangeRate() async {
    try {
      _currentBaseRate = await _exchangeService.fetchExchangeRate();
      notifyListeners();
      return _currentBaseRate;
    } catch (e) {
      if (e.toString().contains('Maintenance Mode')) {
        return null; // Return null to signal UI of failure
      }
      rethrow;
    }
  }

  double getExchangeRateWithSpread(bool isUsdToCop) {
    return _exchangeService.getExchangeRateWithSpread(_currentBaseRate, isUsdToCop, waiveFee: user.hasFeeFreeCredit);
  }

  double convert(double amount, bool isUsdToCop) {
    return _exchangeService.convert(amount, _currentBaseRate, isUsdToCop, waiveFee: user.hasFeeFreeCredit);
  }

  double calculate4x1000Tax(double amountCop) {
    if (user.hasFeeFreeCredit) return 0.0;
    return _taxService.calculate4x1000(amountCop,
      isColombian: isColombian,
      currentMonthlyVolume: _wallet.monthlyCopVolume,
    );
  }

  // Tax Tracker helpers
  double get taxExemptionUsage => _taxService.getExemptionUsagePercent(_wallet.monthlyCopVolume);
  double get taxExemptionRemaining => _taxService.getRemainingExemption(_wallet.monthlyCopVolume);

  /// For foreigners: checks if their volume hits DIAN's 1,400 UVT reporting threshold.
  bool foreignerNeedsDianReporting() {
    if (isColombian) return false;
    return _taxService.foreignerExceedsDianThreshold(_wallet.monthlyCopVolume);
  }

  /// Returns true if adding [additionalCop] would push monthly volume past the
  /// DIAN 1,400 UVT reporting threshold.
  bool willExceedMonthlyLimit(double additionalCop) {
    return _taxService.foreignerExceedsDianThreshold(
      _wallet.monthlyCopVolume + additionalCop,
    );
  }

  /// True when the current monthly volume already exceeds the DIAN threshold.
  bool get showTaxWarning =>
      _taxService.foreignerExceedsDianThreshold(_wallet.monthlyCopVolume);

  /// The DIAN 1,400 UVT reporting threshold in COP (used for UI display).
  double get dianThresholdCop => TaxService.dianForeignerReportingThresholdCop;

  // Execute the send logic (simulated)
  Future<bool> executeSendCop(double amountCop) async {
    // 1. Identity Check
    if (!_isComplianceMode) {
      bool verified = await _truoraService.verifyIdentityFaceScan();
      if (!verified) return false;
    }

    // 2. Calculation
    double tax = calculate4x1000Tax(amountCop);
    double totalDeduction = amountCop + tax;
    
    // 3. Execution & Credit Consumption
    if (_wallet.balanceCop >= totalDeduction) {
      _wallet = _wallet.copyWith(
        balanceCop: _wallet.balanceCop - totalDeduction,
        monthlyCopVolume: _wallet.monthlyCopVolume + amountCop,
      );

      // Consume credit if one was used
      if (user.hasFeeFreeCredit) {
        user = UserModel(
          id: user.id,
          cedula: user.cedula,
          kycStatus: user.kycStatus,
          lanayaPoints: user.lanayaPoints,
          hasFeeFreeCredit: false,
        );
      }

      // 4. Audit Log
      _auditLogService.recordTransaction(
        userId: user.id,
        brebRefId: 'BREB-${DateTime.now().millisecondsSinceEpoch}',
        fxRate: _currentBaseRate,
        amount: amountCop,
        currency: 'COP',
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, String>?> lookupBreb(String phone) async {
    return await _brebService.lookupPhoneNumber(phone);
  }
}

