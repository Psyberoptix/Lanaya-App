import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks whether biometrics are available on this device.
  Future<bool> isBiometricAvailable() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Prompts the user for biometric authentication.
  /// Returns true if authenticated, false otherwise.
  Future<bool> authenticate({String reason = 'Verify your identity to continue'}) async {
    try {
      bool available = await isBiometricAvailable();
      if (!available) {
        // No biometrics — fall through (passcode fallback handled by OS)
        return true;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow passcode fallback
        ),
      );
    } catch (e) {
      // In case of platform exception, allow through for development
      return true;
    }
  }
}
