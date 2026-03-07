class MockDiceService {
  // Simulates the DICE (Directorio de Información de Cuentas y Entidades)
  // registry for Bre-B keys (Llaves Bre-B)
  final Map<String, Map<String, String>> _registeredKeys = {
    '3001234567': {'name': 'Juan P.', 'bank': 'Bancolombia', 'wallet': 'external'},
    '3109876543': {'name': 'María G.', 'bank': 'Davivienda', 'wallet': 'external'},
  };

  /// Registers a phone number as a Llave Bre-B pointing to LanaYa.
  Future<bool> registerKey({
    required String phoneNumber,
    required String userId,
    required String fullName,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if already registered to another wallet
    if (_registeredKeys.containsKey(phoneNumber) &&
        _registeredKeys[phoneNumber]!['wallet'] != 'lanaya') {
      return false; // Key exists in another bank
    }

    _registeredKeys[phoneNumber] = {
      'name': fullName,
      'bank': 'LanaYa',
      'wallet': 'lanaya',
      'userId': userId,
    };
    return true;
  }

  /// Checks if a phone number has a registered Llave Bre-B.
  Future<Map<String, String>?> lookupKey(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _registeredKeys[phoneNumber];
  }

  /// Checks if the user has already registered a key.
  bool isKeyRegistered(String phoneNumber) {
    final entry = _registeredKeys[phoneNumber];
    return entry != null && entry['wallet'] == 'lanaya';
  }

  /// Returns total registered keys count (simulated 99M+ in Colombia).
  int get totalKeysNationwide => 99000000;
}
