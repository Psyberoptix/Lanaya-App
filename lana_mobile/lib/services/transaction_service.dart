import 'dart:math';

class TransactionService {
  static const int _brebTimeoutSeconds = 15;

  /// Simulates a Bre-B transfer with timeout resilience.
  /// Returns a stream of status updates: 'SENDING' → 'PROCESSING' → 'SENT'.
  Stream<Map<String, dynamic>> executeBrebTransfer({
    required double amountCop,
    required String recipientPhone,
  }) async* {
    final random = Random();
    final brebRef = 'BREB-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(9999).toString().padLeft(4, '0')}';

    // Phase 1: Sending
    yield {
      'status': 'SENDING',
      'message': 'Initiating Bre-B transfer...',
      'progress': 0.1,
      'brebRef': brebRef,
    };

    await Future.delayed(const Duration(seconds: 2));

    // Phase 2: DICE lookup
    yield {
      'status': 'SENDING',
      'message': 'Verifying recipient in DICE directory...',
      'progress': 0.3,
      'brebRef': brebRef,
    };

    await Future.delayed(const Duration(seconds: 2));

    // Simulate variable network: 40% chance of slow transfer (>15s total)
    bool isSlow = random.nextDouble() < 0.4;

    if (isSlow) {
      // Phase 3a: Processing (slow path)
      yield {
        'status': 'PROCESSING',
        'message': 'Transfer is taking longer than expected...',
        'progress': 0.5,
        'brebRef': brebRef,
      };

      // Simulate the extended wait
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(seconds: 3));
        yield {
          'status': 'PROCESSING',
          'message': 'Still processing via Bre-B rail...',
          'progress': 0.5 + (i * 0.15),
          'brebRef': brebRef,
        };
      }
    } else {
      // Phase 3b: Fast path
      yield {
        'status': 'SENDING',
        'message': 'Routing through Bre-B rail...',
        'progress': 0.7,
        'brebRef': brebRef,
      };

      await Future.delayed(const Duration(seconds: 2));
    }

    // Phase 4: Confirmed
    yield {
      'status': 'SENT',
      'message': 'Transfer confirmed by DICE directory',
      'progress': 1.0,
      'brebRef': brebRef,
      'timestamp': DateTime.now().toIso8601String(),
      'amountCop': amountCop,
    };
  }
}
