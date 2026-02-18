import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data/datasources/awesome_api_client.dart';
import 'data/repositories/currency_repository_impl.dart';
import 'domain/repositories/currency_repository.dart';
import 'domain/services/currency_converter.dart';
import 'presentation/home/home_page.dart';

void main() {
  final httpClient = http.Client();
  final apiClient = AwesomeApiClient(client: httpClient);
  final repository = CurrencyRepositoryImpl(apiClient: apiClient);
  final converter = CurrencyConverter();

  runApp(
    App(
      repository: repository,
      converter: converter,
    ),
  );
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.repository,
    required this.converter,
  });

  final CurrencyRepository repository;
  final CurrencyConverter converter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotações',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1.2),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: HomePage(
        repository: repository,
        converter: converter,
      ),
    );
  }
}
