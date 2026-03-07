class AuditLogModel {
  final String userId;
  final String brebRefId;
  final double fxRateAtExecution;
  final double amount;
  final String currency;
  final DateTime timestamp;

  AuditLogModel({
    required this.userId,
    required this.brebRefId,
    required this.fxRateAtExecution,
    required this.amount,
    required this.currency,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'bre_b_ref_id': brebRefId,
      'fx_rate_at_execution': fxRateAtExecution,
      'amount': amount,
      'currency': currency,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class AuditLogService {
  // In production this would write to Firestore `audit_logs` collection.
  // For the MVP we store locally in memory.
  final List<AuditLogModel> _logs = [];

  List<AuditLogModel> get logs => List.unmodifiable(_logs);

  void recordTransaction({
    required String userId,
    required String brebRefId,
    required double fxRate,
    required double amount,
    required String currency,
  }) {
    final entry = AuditLogModel(
      userId: userId,
      brebRefId: brebRefId,
      fxRateAtExecution: fxRate,
      amount: amount,
      currency: currency,
      timestamp: DateTime.now(),
    );
    _logs.add(entry);
    // In production: FirebaseFirestore.instance.collection('audit_logs').add(entry.toMap());
  }
}
