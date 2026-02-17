import 'currency_code.dart';

class ExchangeRates {
  const ExchangeRates({
    required this.usdToBrl,
    required this.eurToBrl,
    required this.btcToBrl,
  });

  final double usdToBrl;
  final double eurToBrl;
  final double btcToBrl;

  double factorToBrl(CurrencyCode code) {
    switch (code) {
      case CurrencyCode.brl:
        return 1;
      case CurrencyCode.usd:
        return usdToBrl;
      case CurrencyCode.eur:
        return eurToBrl;
      case CurrencyCode.btc:
        return btcToBrl;
    }
  }
}
