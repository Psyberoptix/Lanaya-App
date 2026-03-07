class WalletModel {
  final String userId;
  final double balanceUsd; // in standard USD format (e.g. 10.50)
  final double balanceCop;
  final double monthlyCopVolume;

  WalletModel({
    required this.userId,
    required this.balanceUsd,
    required this.balanceCop,
    this.monthlyCopVolume = 0.0,
  });

  factory WalletModel.fromMap(Map<String, dynamic> data) {
    return WalletModel(
      userId: data['userId'] ?? '',
      balanceUsd: (data['balanceUsd'] ?? 0).toDouble(),
      balanceCop: (data['balanceCop'] ?? 0).toDouble(),
      monthlyCopVolume: (data['monthlyCopVolume'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balanceUsd': balanceUsd,
      'balanceCop': balanceCop,
      'monthlyCopVolume': monthlyCopVolume,
    };
  }

  WalletModel copyWith({
    double? balanceUsd,
    double? balanceCop,
    double? monthlyCopVolume,
  }) {
    return WalletModel(
      userId: userId,
      balanceUsd: balanceUsd ?? this.balanceUsd,
      balanceCop: balanceCop ?? this.balanceCop,
      monthlyCopVolume: monthlyCopVolume ?? this.monthlyCopVolume,
    );
  }
}
