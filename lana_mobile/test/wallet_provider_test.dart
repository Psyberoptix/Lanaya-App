import 'package:flutter_test/flutter_test.dart';
// Note: Normally imported with package name, using relative here for simplicity outside full flutter env.
import '../lib/logic/wallet_provider.dart';
import '../lib/services/tax_service.dart';

void main() {
  group('WalletProvider & TaxService Business Logic', () {
    late WalletProvider provider;

    setUp(() {
      provider = WalletProvider();
    });

    test('4x1000 Tax applies normally when not exempt', () {
      // 1,000,000 COP * 0.004 = 4000
      double tax = provider.calculate4x1000Tax(1000000.0);
      expect(tax, closeTo(4000.0, 0.01));
    });

    test('willExceedMonthlyLimit triggers at \$18.3M COP', () {
      // Setup default volume is 15.5M
      expect(provider.wallet.monthlyCopVolume, 15500000.0);
      
      // Adding 2.8M => 18.3M => Should not warn yet
      bool noWarning = provider.willExceedMonthlyLimit(2800000.0);
      expect(noWarning, isFalse);

      // Adding 3.0M => 18.5M => Should warn based on TaxService.exemptMonthlyLimitCop
      bool warning = provider.willExceedMonthlyLimit(3000000.0);
      expect(warning, isTrue);
    });

    test('Tax is 0 when exempt AND under 350 UVT limit', () {
      provider.toggleTaxExempt();
      expect(provider.isTaxExempt, isTrue);
      
      // Sending 1M when volume is 15.5M (total 16.5M < 18.3M)
      double tax = provider.calculate4x1000Tax(1000000.0);
      expect(tax, 0.0);
    });

    test('Tax applies proportionally when exempt but crossing 350 UVT limit', () {
      provider.toggleTaxExempt();
      
      // Volume = 15.5M. Limit = ~18.33M.
      // If we send 3.0M, total is 18.5M.
      // Taxable amount is essentially 18.5M - 18.33M = ~169.1k
      // 169.1k * 0.004 = ~676.4
      double tax = provider.calculate4x1000Tax(3000000.0);
      
      double newVolume = 15500000.0 + 3000000.0;
      double taxableAmount = newVolume - TaxService.exemptMonthlyLimitCop;
      double expectedTax = taxableAmount * 0.004;

      expect(tax, closeTo(expectedTax, 0.01));
    });

    test('fetchExchangeRate caches the API result for 60s within LanaExchangeService', () async {
      double rate1 = await provider.fetchExchangeRate();
      expect(rate1, 3985.0); // Wait, cached mock rate is 3985.0

      // Call immediately again to check caching behavior
      double rate2 = await provider.fetchExchangeRate();
      expect(rate2, rate1);
    });

    test('getExchangeRateWithSpread applies 1.5% markup correctly', () async {
      await provider.fetchExchangeRate(); // sets _currentBaseRate to 3985.0

      // USD -> COP: user gets less COP, so rate is 3985 * 0.985 = 3925.225
      double rateUsdToCop = provider.getExchangeRateWithSpread(true);
      expect(rateUsdToCop, closeTo(3925.225, 0.01));

      // COP -> USD: user pays more COP, so rate is 3985 * 1.015 = 4044.775
      double rateCopToUsd = provider.getExchangeRateWithSpread(false);
      expect(rateCopToUsd, closeTo(4044.775, 0.01));
    });
    test('Fee-Free credit waives BOTH the 1.5% markup and 4x1000 tax', () async {
      await provider.fetchExchangeRate(); // cache rate
      
      // Give the user a fee free credit
      bool initialCreditState = provider.user.hasFeeFreeCredit; // Assuming default true right now via mock
      if (!initialCreditState) {
          provider.toggleFeeFreeCredit();
      }

      // Check spread logic
      double rateUsdToCop = provider.getExchangeRateWithSpread(true);
      expect(rateUsdToCop, 3985.0); // Exact base rate, no spread

      // Check tax logic
      double tax = provider.calculate4x1000Tax(1000000.0);
      expect(tax, 0.0); // Tax is waived by credit regardless of UVT limits

      // Execute send should consume the credit
      provider.toggleComplianceMode(); // Bypass Truora mock for test
      bool success = await provider.executeSendCop(100000.0);
      expect(success, isTrue);
      
      // Credit should be consumed
      expect(provider.user.hasFeeFreeCredit, isFalse);
    });
  });
}

