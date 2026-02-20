import '../../domain/entities/exchange_rates.dart';
import '../../domain/entities/history_point.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/awesome_api_client.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  CurrencyRepositoryImpl({required this.apiClient});

  final AwesomeApiClient apiClient;

  @override
  Future<ExchangeRates> getExchangeRates() async {
    final responses = await Future.wait<Map<String, dynamic>>([
      apiClient.getLastTicker('USD-BRL'),
      apiClient.getLastTicker('EUR-BRL'),
      apiClient.getLastTicker('BTC-BRL'),
    ]);

    return ExchangeRates(
      usdToBrl: _extractBid(responses[0], 'USDBRL'),
      eurToBrl: _extractBid(responses[1], 'EURBRL'),
      btcToBrl: _extractBid(responses[2], 'BTCBRL'),
    );
  }

  @override
  Future<List<HistoryPoint>> getHistory({
    required String pair,
    int days = 30,
  }) async {
    final rawData = await apiClient.getDailyHistory(pair: pair, days: days);

    return rawData
        .map<HistoryPoint>((dynamic item) {
          final map = item as Map<String, dynamic>;
          return HistoryPoint(
            value: double.parse(map['bid'] as String),
            date: _extractDate(map),
          );
        })
        .toList()
        .reversed
        .toList();
  }

  double _extractBid(Map<String, dynamic> payload, String key) {
    final item = payload[key] as Map<String, dynamic>?;
    final bid = item?['bid'];

    if (bid is String) {
      return double.parse(bid);
    }

    throw Exception('Invalid bid response for $key');
  }

  DateTime _extractDate(Map<String, dynamic> item) {
    final timestamp = item['timestamp'];
    if (timestamp is String) {
      final seconds = int.tryParse(timestamp);
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000,
          isUtc: true,
        ).toLocal();
      }
    }

    final createDate = item['create_date'];
    if (createDate is String) {
      final parsed = DateTime.tryParse(createDate);
      if (parsed != null) {
        return parsed;
      }
    }

    return DateTime.now();
  }
}
