class MockBrebService {
  /// Simulates a phone number lookup on the Bre-B national rail.
  /// If phone number equals '3001234567', returns Juan Pérez.
  /// Otherwise returns an error map or null.
  Future<Map<String, String>?> lookupPhoneNumber(String phoneNumber) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Clean phone number (strip spaces/country code to match exactly)
    String cleaned = phoneNumber.replaceAll(' ', '');
    // Remove +57 if typed to allow '3001234567' to match
    if (cleaned.startsWith('+57')) {
      cleaned = cleaned.substring(3);
    }

    if (cleaned == '3001234567') {
      return {
        'name': 'Juan P.',
        'bank': 'Bancolombia',
      };
    }
    
    // Requirements state: return 'User not found in Bre-B directory'
    return {
      'error': 'User not found in Bre-B directory'
    };
  }
}

