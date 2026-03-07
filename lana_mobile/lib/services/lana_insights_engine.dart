class LanaInsightsEngine {
  /// Generates a contextual "Smart Tip" based on balance, time, and trends.
  String generateSmartTip({
    required double balanceUsd,
    required double balanceCop,
    required double currentFxRate,
    required DateTime now,
  }) {
    final hour = now.hour;
    final weekday = now.weekday; // 1=Mon, 5=Fri, 7=Sun

    // Friday afternoon — remittance window
    if (weekday == 5 && hour >= 12) {
      return '💡 Friday tip: COP tends to weaken on Mondays. '
          'Consider converting your USD now at ${currentFxRate.toStringAsFixed(0)} COP to lock in the rate.';
    }

    // Low USD balance alert
    if (balanceUsd < 50.0) {
      return '💡 Your USD balance is running low (\$${balanceUsd.toStringAsFixed(2)}). '
          'Top up before the next rate shift to avoid converting at a worse spread.';
    }

    // Large COP balance — suggest converting
    if (balanceCop > 10000000.0) {
      double usdEquivalent = balanceCop / currentFxRate;
      return '💡 You're holding ${(balanceCop / 1000000).toStringAsFixed(1)}M COP. '
          'That's ~\$${usdEquivalent.toStringAsFixed(0)} USD at today's rate. '
          'Consider diversifying into USD.';
    }

    // Morning insight
    if (hour < 12) {
      return '☀️ Good morning! The USD/COP rate is at ${currentFxRate.toStringAsFixed(0)}. '
          'Markets are most liquid between 9 AM and 2 PM COT.';
    }

    // Evening wind-down
    if (hour >= 18) {
      return '🌙 Evening check: Your balances are secure. '
          'Bre-B transfers before 8 PM arrive instantly.';
    }

    // Default mid-day
    return '📈 Current rate: 1 USD = ${currentFxRate.toStringAsFixed(0)} COP (incl. 1.5% spread). '
        'Rates refresh every 60 seconds.';
  }
}
