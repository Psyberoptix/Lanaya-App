import 'dart:math';

class BetaCodeService {
  // In production: Firestore `beta_codes` collection
  final Map<String, Map<String, dynamic>> _codes = {
    '777777': {'status': 'ACTIVE', 'usedBy': null, 'createdAt': '2026-03-01'},
    '888888': {'status': 'ACTIVE', 'usedBy': null, 'createdAt': '2026-03-01'},
    '999999': {'status': 'ACTIVE', 'usedBy': null, 'createdAt': '2026-03-01'},
  };

  /// Validates an invite code. Returns true if valid and active.
  Future<bool> validateCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final entry = _codes[code];
    return entry != null && entry['status'] == 'ACTIVE';
  }

  /// Redeems a code for a user. Returns true on success.
  Future<bool> redeemCode(String code, String userId) async {
    if (!_codes.containsKey(code) || _codes[code]!['status'] != 'ACTIVE') {
      return false;
    }
    _codes[code] = {
      'status': 'USED',
      'usedBy': userId,
      'createdAt': _codes[code]!['createdAt'],
      'redeemedAt': DateTime.now().toIso8601String(),
    };
    return true;
  }

  /// Generates a batch of new invite codes.
  List<String> generateCodes(int count) {
    final random = Random();
    final newCodes = <String>[];
    for (int i = 0; i < count; i++) {
      String code = (100000 + random.nextInt(899999)).toString();
      while (_codes.containsKey(code)) {
        code = (100000 + random.nextInt(899999)).toString();
      }
      _codes[code] = {
        'status': 'ACTIVE',
        'usedBy': null,
        'createdAt': DateTime.now().toIso8601String(),
      };
      newCodes.add(code);
    }
    return newCodes;
  }

  /// Deactivates a code.
  void deactivateCode(String code) {
    if (_codes.containsKey(code)) {
      _codes[code]!['status'] = 'DEACTIVATED';
    }
  }

  /// Reactivates a code.
  void activateCode(String code) {
    if (_codes.containsKey(code) && _codes[code]!['status'] == 'DEACTIVATED') {
      _codes[code]!['status'] = 'ACTIVE';
    }
  }

  /// Returns all codes for the admin portal.
  List<Map<String, dynamic>> getAllCodes() {
    return _codes.entries.map((e) => {
      'code': e.key,
      ...e.value,
    }).toList();
  }

  /// Returns the pre-formatted invite message.
  String getInviteMessage(String code) {
    return '🌟 You\'ve been invited to LanaYa — the smartest way to send money in Colombia!\n\n'
        'Enter this exclusive code to unlock the app:\n\n'
        '🔑 $code\n\n'
        'Download: https://lanaya.co/beta\n'
        'Powered by Bre-B instant rails ⚡';
  }
}
