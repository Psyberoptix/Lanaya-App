class LanaExchangeService {
  double _cachedRate = 3950.0;
  DateTime? _lastFetchTime;
  
  // Simulates an API outage or failure
  bool _simulateApiFailure = false;

  void toggleApiFailure() {
    _simulateApiFailure = !_simulateApiFailure;
  }

  Future<double> fetchExchangeRate() async {
    // Cache for 60 seconds
    if (_lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!).inSeconds < 60) {
      if (_simulateApiFailure) throw Exception("Maintenance Mode: API Down");
      return _cachedRate;
    }

    // Simulate API fetch delay
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_simulateApiFailure) {
      throw Exception("Maintenance Mode: API Down");
    }

    _cachedRate = 3985.0; // Mock fetched rate
    _lastFetchTime = DateTime.now();

    return _cachedRate;
  }

  // Applies a 1.5% FX Spread on exchange operations. If [waiveFee] is true, no spread is applied.
  double getExchangeRateWithSpread(double baseRate, bool isUsdToCop, {bool waiveFee = false}) {
    double markup = waiveFee ? 0.0 : 0.015;
    if (isUsdToCop) {
      // User receives less COP
      return baseRate * (1 - markup);
    } else {
      // User pays more COP for USD
      return baseRate * (1 + markup);
    }
  }

  // Calculates the equivalent value given an amount and conversion direction
  double convert(double amount, double baseRate, bool isUsdToCop, {bool waiveFee = false}) {
    double rate = getExchangeRateWithSpread(baseRate, isUsdToCop, waiveFee: waiveFee);
    if (isUsdToCop) {
      return amount * rate;
    } else {
      return amount / rate;
    }
  }
}

