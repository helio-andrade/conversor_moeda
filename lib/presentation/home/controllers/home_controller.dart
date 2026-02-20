import 'package:flutter/material.dart';

import '../../../domain/entities/currency_code.dart';
import '../../../domain/entities/exchange_rates.dart';
import '../../../domain/entities/history_point.dart';
import '../../../domain/repositories/currency_repository.dart';
import '../../../domain/services/currency_converter.dart';

class HomeController {
  HomeController({
    required this.repository,
    required this.converter,
  });

  final CurrencyRepository repository;
  final CurrencyConverter converter;

  final TextEditingController brlController = TextEditingController();
  final TextEditingController usdController = TextEditingController();
  final TextEditingController eurController = TextEditingController();
  final TextEditingController btcController = TextEditingController();

  ExchangeRates? _rates;
  Future<ExchangeRates>? _ratesFuture;
  final Map<String, Future<List<HistoryPoint>>> _historyFutures =
      <String, Future<List<HistoryPoint>>>{};

  Future<ExchangeRates> get ratesFuture {
    return _ratesFuture ??= repository.getExchangeRates();
  }

  Future<ExchangeRates> refreshRates() {
    _ratesFuture = repository.getExchangeRates();
    _rates = null;
    return _ratesFuture!;
  }

  void setRates(ExchangeRates rates) {
    _rates = rates;
  }

  Future<List<HistoryPoint>> historyFuture(
    String pair, {
    required int weeks,
  }) {
    final int days = weeks * 7;
    final String cacheKey = '$pair-$days';

    return _historyFutures.putIfAbsent(
      cacheKey,
      () => repository.getHistory(pair: pair, days: days),
    );
  }

  void clearAll() {
    brlController.clear();
    usdController.clear();
    eurController.clear();
    btcController.clear();
  }

  void onInputChanged(CurrencyCode source, String rawText) {
    if (rawText.trim().isEmpty) {
      clearAll();
      return;
    }

    final rates = _rates;
    if (rates == null) {
      return;
    }

    final parsed = _tryParseDecimal(rawText);
    if (parsed == null) {
      return;
    }

    final amountInBrl = converter.toBrl(
      amount: parsed,
      from: source,
      rates: rates,
    );

    _setConvertedValue(CurrencyCode.brl, amountInBrl, source, rates);
    _setConvertedValue(CurrencyCode.usd, amountInBrl, source, rates);
    _setConvertedValue(CurrencyCode.eur, amountInBrl, source, rates);
    _setConvertedValue(CurrencyCode.btc, amountInBrl, source, rates);
  }

  TextEditingController controllerFor(CurrencyCode code) {
    switch (code) {
      case CurrencyCode.brl:
        return brlController;
      case CurrencyCode.usd:
        return usdController;
      case CurrencyCode.eur:
        return eurController;
      case CurrencyCode.btc:
        return btcController;
    }
  }

  void dispose() {
    brlController.dispose();
    usdController.dispose();
    eurController.dispose();
    btcController.dispose();
  }

  void _setConvertedValue(
    CurrencyCode target,
    double amountInBrl,
    CurrencyCode source,
    ExchangeRates rates,
  ) {
    if (target == source) {
      return;
    }

    final value = converter.fromBrl(
      amountInBrl: amountInBrl,
      to: target,
      rates: rates,
    );

    controllerFor(target).text = _formatValue(target, value);
  }

  String _formatValue(CurrencyCode code, double value) {
    final precision = code == CurrencyCode.btc ? 7 : 2;
    return value.toStringAsFixed(precision);
  }

  double? _tryParseDecimal(String rawText) {
    final normalized = rawText.trim().replaceAll(' ', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
