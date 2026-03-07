class TransactionModel {
  final String id;
  final String type; // P2P, EXCHANGE, BRE_B_OUT
  final double amount;
  final String currency; // USD, COP
  final double? exchangeRate;
  final double? tax4x1000;
  final String status; // PENDING, COMPLETED, FAILED
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    this.exchangeRate,
    this.tax4x1000,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      id: data['id'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? '',
      exchangeRate: data['exchangeRate']?.toDouble(),
      tax4x1000: data['tax4x1000']?.toDouble(),
      status: data['status'] ?? 'PENDING',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'tax4x1000': tax4x1000,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
