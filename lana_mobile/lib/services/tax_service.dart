class TaxService {
  // 2026 UVT value
  static const double uvtValue2026Cop = 52374.0;

  // Monthly exemption: 350 UVT = $18,330,900 COP
  static const double exemptMonthlyLimitUvt = 350.0;
  static const double exemptMonthlyLimitCop = uvtValue2026Cop * exemptMonthlyLimitUvt;

  // DIAN reporting threshold for non-residents: 1,400 UVT
  static const double dianForeignerReportingThresholdUvt = 1400.0;
  static const double dianForeignerReportingThresholdCop = uvtValue2026Cop * dianForeignerReportingThresholdUvt;

  /// Calculates the 4x1000 (0.4%) GMF tax.
  /// - Foreigners: always $0 (GMF is a Colombian banking tax).
  /// - Colombians: auto-exempt up to 350 UVT/month, then 0.4% on the overage.
  double calculate4x1000(double amountCop, {
    required bool isColombian,
    double currentMonthlyVolume = 0,
  }) {
    if (!isColombian) return 0.0;

    // Check if already past the monthly limit
    if (currentMonthlyVolume >= exemptMonthlyLimitCop) {
      return amountCop * 0.004;
    }

    // Check if this transaction pushes over the limit
    double newVolume = currentMonthlyVolume + amountCop;
    if (newVolume > exemptMonthlyLimitCop) {
      double taxableAmount = newVolume - exemptMonthlyLimitCop;
      return taxableAmount * 0.004;
    }

    // Within exempt limit
    return 0.0;
  }

  /// Returns how much of the monthly exemption has been used (0.0 to 1.0).
  double getExemptionUsagePercent(double currentMonthlyVolume) {
    return (currentMonthlyVolume / exemptMonthlyLimitCop).clamp(0.0, 1.0);
  }

  /// Returns the remaining exempt amount in COP.
  double getRemainingExemption(double currentMonthlyVolume) {
    return (exemptMonthlyLimitCop - currentMonthlyVolume).clamp(0.0, exemptMonthlyLimitCop);
  }

  /// Checks if a foreigner's cumulative COP volume triggers DIAN reporting.
  bool foreignerExceedsDianThreshold(double totalVolumeCop) {
    return totalVolumeCop >= dianForeignerReportingThresholdCop;
  }
}
