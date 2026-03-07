import 'dart:math';

class MockTruoraService {
  /// Simulates a biometric face-scan and document verification response.
  /// Returns a boolean indicating whether the verification was successful.
  Future<bool> verifyIdentityFaceScan() async {
    // Simulate real-world delay for network upload and ML processing
    await Future.delayed(const Duration(seconds: 3));
    
    // Simulate a 95% success rate for the demo
    final random = Random();
    return random.nextDouble() <= 0.95;
  }
}
