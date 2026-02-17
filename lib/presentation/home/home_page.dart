import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/currency_code.dart';
import '../../domain/entities/exchange_rates.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../domain/services/currency_converter.dart';
import 'controllers/home_controller.dart';
import 'widgets/currency_input_field.dart';
import 'widgets/history_chart_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
    required this.converter,
  });

  final CurrencyRepository repository;
  final CurrencyConverter converter;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  static const List<int> _weekIntervals = <int>[1, 2, 4, 8];
  int _selectedWeeks = 4;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      repository: widget.repository,
      converter: widget.converter,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = kIsWeb ? screenWidth < 700 : screenWidth < 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.colorScheme.surface,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _controller.clearAll,
        label: const Text('Limpar'),
        icon: const Icon(Icons.cleaning_services),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Conversor de Moedas'),
      ),
      body: SafeArea(
        child: FutureBuilder<ExchangeRates>(
          future: _controller.ratesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Erro ao carregar cotacoes',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _controller.refreshRates();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final rates = snapshot.data;
            if (rates == null) {
              return const Center(child: Text('Sem dados de cotacao'));
            }

            _controller.setRates(rates);

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Align(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isCompact ? 560 : 960,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 12 : 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: isCompact ? 12 : 20),
                              Icon(
                                Icons.currency_exchange,
                                size: isCompact ? 64 : 80,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Cotacoes em tempo real',
                                style: theme.textTheme.titleMedium,
                              ),
                              SizedBox(height: isCompact ? 16 : 24),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isCompact ? 16 : 24),
                                  child: Column(
                                    children: [
                                      CurrencyInputField(
                                        label: 'Reais (BRL)',
                                        prefix: 'R\$ ',
                                        controller: _controller.brlController,
                                        onChanged: (value) =>
                                            _controller.onInputChanged(
                                          CurrencyCode.brl,
                                          value,
                                        ),
                                      ),
                                      SizedBox(height: isCompact ? 14 : 20),
                                      CurrencyInputField(
                                        label: 'Dolares (USD)',
                                        prefix: 'US\$ ',
                                        controller: _controller.usdController,
                                        onChanged: (value) =>
                                            _controller.onInputChanged(
                                          CurrencyCode.usd,
                                          value,
                                        ),
                                      ),
                                      SizedBox(height: isCompact ? 14 : 20),
                                      CurrencyInputField(
                                        label: 'Euros (EUR)',
                                        prefix: 'EUR ',
                                        controller: _controller.eurController,
                                        onChanged: (value) =>
                                            _controller.onInputChanged(
                                          CurrencyCode.eur,
                                          value,
                                        ),
                                      ),
                                      SizedBox(height: isCompact ? 14 : 20),
                                      CurrencyInputField(
                                        label: 'Bitcoin (BTC)',
                                        prefix: 'BTC ',
                                        controller: _controller.btcController,
                                        onChanged: (value) =>
                                            _controller.onInputChanged(
                                          CurrencyCode.btc,
                                          value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: isCompact ? 22 : 30),
                              Text(
                                'Historico semanal',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _weekIntervals.map((weeks) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: ChoiceChip(
                                        label: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text('$weeks s'),
                                        ),
                                        selected: _selectedWeeks == weeks,
                                        onSelected: (selected) {
                                          if (!selected) {
                                            return;
                                          }
                                          setState(() {
                                            _selectedWeeks = weeks;
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              HistoryChartCard(
                                title: 'USD/BRL',
                                color: Colors.blue,
                                weeks: _selectedWeeks,
                                compact: isCompact,
                                valuesFuture: _controller.historyFuture(
                                  'USD-BRL',
                                  weeks: _selectedWeeks,
                                ),
                              ),
                              const SizedBox(height: 20),
                              HistoryChartCard(
                                title: 'EUR/BRL',
                                color: Colors.yellow,
                                weeks: _selectedWeeks,
                                compact: isCompact,
                                valuesFuture: _controller.historyFuture(
                                  'EUR-BRL',
                                  weeks: _selectedWeeks,
                                ),
                              ),
                              const SizedBox(height: 20),
                              HistoryChartCard(
                                title: 'BTC/BRL',
                                color: Colors.orange,
                                weeks: _selectedWeeks,
                                compact: isCompact,
                                valuesFuture: _controller.historyFuture(
                                  'BTC-BRL',
                                  weeks: _selectedWeeks,
                                ),
                              ),
                              SizedBox(height: isCompact ? 88 : 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
