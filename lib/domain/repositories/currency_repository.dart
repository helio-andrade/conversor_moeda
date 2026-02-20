import '../entities/exchange_rates.dart';
import '../entities/history_point.dart';

abstract class CurrencyRepository {
  Future<ExchangeRates> getExchangeRates();

  Future<List<HistoryPoint>> getHistory({
    required String pair,
    int days = 30,
  });
}
