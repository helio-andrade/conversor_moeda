import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const App());
}

// ----------------------------- APP MATERIAL 3 -----------------------------
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const Home(),
    );
  }
}

// ----------------------------- API COTAÇÕES -----------------------------
Future<Map<String, double>> getData() async {
  final usd = await http.get(
      Uri.parse("https://economia.awesomeapi.com.br/json/last/USD-BRL"));
  final eur = await http.get(
      Uri.parse("https://economia.awesomeapi.com.br/json/last/EUR-BRL"));
  final btc = await http.get(
      Uri.parse("https://economia.awesomeapi.com.br/json/last/BTC-BRL"));

  if (usd.statusCode != 200 ||
      eur.statusCode != 200 ||
      btc.statusCode != 200) {
    throw Exception("Erro ao acessar API de cotações");
  }

  return {
    "usd": double.parse(json.decode(usd.body)["USDBRL"]["bid"]),
    "eur": double.parse(json.decode(eur.body)["EURBRL"]["bid"]),
    "btc": double.parse(json.decode(btc.body)["BTCBRL"]["bid"]),
  };
}

// ----------------------------- API HISTÓRICO -----------------------------
Future<List<double>> getHistory(String pair) async {
  final response = await http.get(
      Uri.parse("https://economia.awesomeapi.com.br/json/daily/$pair/30"));

  if (response.statusCode != 200) {
    throw Exception("Erro ao carregar histórico");
  }

  final List data = json.decode(response.body);
  return data.map<double>((item) {
    return double.parse(item["bid"]);
  }).toList().reversed.toList();
}

// ----------------------------- TELA PRINCIPAL -----------------------------
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  double dolar = 0;
  double euro = 0;
  double btc = 0;

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
    btcController.clear();
  }

  // ----------------------------- Conversões -----------------------------
  void _realChanged(String text) {
    if (text.isEmpty) return _clearAll();
    final real = double.parse(text);

    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    btcController.text = (real / btc).toStringAsFixed(7);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) return _clearAll();
    final d = double.parse(text);
    final real = d * dolar;

    realController.text = real.toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    btcController.text = (real / btc).toStringAsFixed(7);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) return _clearAll();
    final e = double.parse(text);
    final real = e * euro;

    realController.text = real.toStringAsFixed(2);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    btcController.text = (real / btc).toStringAsFixed(7);
  }

  void _btcChanged(String text) {
    if (text.isEmpty) return _clearAll();
    final b = double.parse(text);
    final real = b * btc;

    realController.text = real.toStringAsFixed(2);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  // ----------------------------- INTERFACE -----------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _clearAll,
        label: const Text("Limpar"),
        icon: const Icon(Icons.cleaning_services),
      ),

      appBar: AppBar(
        centerTitle: true,
        title: const Text("Conversor de Moedas"),
      ),

      body: FutureBuilder<Map<String, double>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erro ao carregar cotações",
                  style: theme.textTheme.titleLarge),
            );
          }

          dolar = snapshot.data!["usd"]!;
          euro = snapshot.data!["eur"]!;
          btc = snapshot.data!["btc"]!;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    Icon(Icons.currency_exchange,
                        size: 80, color: theme.colorScheme.primary),

                    const SizedBox(height: 12),

                    Text("Cotações em tempo real",
                        style: theme.textTheme.titleMedium),

                    const SizedBox(height: 25),

                    // ------------------- CAMPOS -------------------
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            modernField("Reais (BRL)", "R\$ ",
                                realController, _realChanged),
                            const SizedBox(height: 20),

                            modernField("Dólares (USD)", "US\$ ",
                                dolarController, _dolarChanged),
                            const SizedBox(height: 20),

                            modernField("Euros (EUR)", "€ ",
                                euroController, _euroChanged),
                            const SizedBox(height: 20),

                            modernField("Bitcoin (BTC)", "₿ ",
                                btcController, _btcChanged),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text("Histórico (últimos 30 valores)",
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),

                    chartFuture("USD/BRL", "USD-BRL", Colors.blue),
                    const SizedBox(height: 20),

                    chartFuture("EUR/BRL", "EUR-BRL", Colors.yellow),
                    const SizedBox(height: 20),

                    chartFuture("BTC/BRL", "BTC-BRL", Colors.orange),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ----------------------------- CAMPO MODERNO -----------------------------
Widget modernField(
    String label,
    String prefix,
    TextEditingController controller,
    Function(String) onChanged,
    ) {
  return SizedBox(
    width: 350,
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType:
      const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

// ----------------------------- FUTUREBUILDER DO GRÁFICO -----------------------------
Widget chartFuture(String title, String pair, Color color) {
  return FutureBuilder<List<double>>(
    future: getHistory(pair),
    builder: (context, snap) {
      if (!snap.hasData) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return buildChart(title, snap.data!, color);
    },
  );
}

// ----------------------------- GRÁFICO -----------------------------
Widget buildChart(String title, List<double> values, Color color) {
  final spots = List.generate(
    values.length,
        (i) => FlSpot(i.toDouble(), values[i]),
  );

  return Card(
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),

          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: color,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
