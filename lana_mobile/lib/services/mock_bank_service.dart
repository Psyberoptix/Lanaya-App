class MockBankService {
  // Simulates connecting to a Bancolombia Open Finance API
  bool _isLinked = false;

  bool get isLinked => _isLinked;

  /// Simulates the OAuth bank linking flow.
  Future<bool> linkBancolombia() async {
    await Future.delayed(const Duration(seconds: 2));
    _isLinked = true;
    return true;
  }

  /// Returns the last 5 transactions from the linked account.
  Future<List<Map<String, dynamic>>> fetchRecentTransactions() async {
    if (!_isLinked) return [];

    await Future.delayed(const Duration(milliseconds: 600));

    return [
      {'description': 'Nómina - Empresa SAS', 'amount': 4200000.0, 'type': 'CREDIT', 'date': '2026-03-01'},
      {'description': 'Pago Arriendo', 'amount': -1800000.0, 'type': 'DEBIT', 'date': '2026-03-02'},
      {'description': 'Transferencia Recibida', 'amount': 350000.0, 'type': 'CREDIT', 'date': '2026-03-03'},
      {'description': 'Supermercado Éxito', 'amount': -187500.0, 'type': 'DEBIT', 'date': '2026-03-04'},
      {'description': 'Pago Claro Móvil', 'amount': -62000.0, 'type': 'DEBIT', 'date': '2026-03-05'},
    ];
  }

  /// Returns simulated account summary for credit scoring.
  Future<Map<String, dynamic>> getAccountSummary() async {
    if (!_isLinked) return {};
    return {
      'accountBalance': 2500500.0,
      'monthlyIncome': 4200000.0,
      'monthlyExpenses': 2049500.0,
      'accountAge': 36, // months
    };
  }
}
