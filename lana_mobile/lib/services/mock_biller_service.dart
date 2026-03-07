class MockBillerService {
  /// Returns a list of available billers matching the search query.
  List<Map<String, String>> searchBillers(String query) {
    final billers = [
      {'id': 'epm', 'name': 'EPM Medellín', 'category': 'Utilities', 'icon': 'bolt'},
      {'id': 'etb', 'name': 'ETB Bogotá', 'category': 'Telecom', 'icon': 'phone'},
      {'id': 'claro', 'name': 'Claro Colombia', 'category': 'Mobile', 'icon': 'signal_cellular_alt'},
      {'id': 'movistar', 'name': 'Movistar', 'category': 'Mobile', 'icon': 'signal_cellular_alt'},
      {'id': 'codensa', 'name': 'Enel-Codensa', 'category': 'Electricity', 'icon': 'bolt'},
      {'id': 'gas_natural', 'name': 'Vanti Gas Natural', 'category': 'Gas', 'icon': 'local_fire_department'},
      {'id': 'acueducto', 'name': 'Acueducto de Bogotá', 'category': 'Water', 'icon': 'water_drop'},
    ];

    if (query.isEmpty) return billers;

    return billers.where((b) =>
      b['name']!.toLowerCase().contains(query.toLowerCase()) ||
      b['category']!.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Simulates a PSE/Factura bill payment.
  Future<Map<String, dynamic>> payBill({
    required String billerId,
    required double amountCop,
    required String referenceNumber,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return {
      'status': 'PAID',
      'billerId': billerId,
      'amountCop': amountCop,
      'reference': referenceNumber,
      'confirmationCode': 'PSE-${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
