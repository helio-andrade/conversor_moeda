import '../entities/currency_code.dart';
import '../entities/exchange_rates.dart';

class CurrencyConverter {
  double toBrl({
    required double amount,
    required CurrencyCode from,
    required ExchangeRates rates,
  }) {
    return amount * rates.factorToBrl(from);
  }

  double fromBrl({
    required double amountInBrl,
    required CurrencyCode to,
    required ExchangeRates rates,
  }) {
    return amountInBrl / rates.factorToBrl(to);
  }
}
