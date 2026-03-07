class CreditUnderwritingService {
  static const double maxAdvanceCop = 200000.0;

  /// Analyzes linked bank data and returns a credit offer.
  /// Returns null if the user doesn't qualify.
  Map<String, dynamic>? evaluateCreditOffer(Map<String, dynamic> accountSummary) {
    if (accountSummary.isEmpty) return null;

    double balance = accountSummary['accountBalance'] ?? 0;
    double income = accountSummary['monthlyIncome'] ?? 0;
    double expenses = accountSummary['monthlyExpenses'] ?? 0;
    int accountAge = accountSummary['accountAge'] ?? 0;

    // Scoring: 0-100
    double score = 0;

    // Balance health (max 30 pts)
    if (balance > 2000000) score += 30;
    else if (balance > 1000000) score += 20;
    else if (balance > 500000) score += 10;

    // Income stability (max 30 pts)
    if (income > 3000000) score += 30;
    else if (income > 1500000) score += 20;
    else if (income > 800000) score += 10;

    // Savings ratio (max 20 pts)
    double savingsRatio = (income - expenses) / income;
    if (savingsRatio > 0.4) score += 20;
    else if (savingsRatio > 0.2) score += 15;
    else if (savingsRatio > 0.1) score += 5;

    // Account age (max 20 pts)
    if (accountAge >= 24) score += 20;
    else if (accountAge >= 12) score += 10;
    else if (accountAge >= 6) score += 5;

    // Minimum score to qualify: 50
    if (score < 50) return null;

    // Calculate offer amount based on score
    double offerPercentage = (score / 100).clamp(0.0, 1.0);
    double offerAmount = (maxAdvanceCop * offerPercentage).roundToDouble();

    return {
      'score': score,
      'offerAmountCop': offerAmount,
      'interestRate': score >= 80 ? 0.0 : 1.5, // 0% for excellent, 1.5% otherwise
      'termDays': 30,
      'reason': score >= 80
          ? 'Excellent financial profile'
          : score >= 60
              ? 'Good standing — stable income detected'
              : 'Eligible — building credit history',
    };
  }
}
