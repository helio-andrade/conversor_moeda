import 'dart:convert';

import 'package:http/http.dart' as http;

class AwesomeApiClient {
  AwesomeApiClient({required this.client});

  final http.Client client;
  static const String _baseUrl = 'https://economia.awesomeapi.com.br/json';

  Future<Map<String, dynamic>> getLastTicker(String pair) async {
    final response = await client
        .get(Uri.parse('$_baseUrl/last/$pair'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load ticker for $pair');
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getDailyHistory({
    required String pair,
    required int days,
  }) async {
    final response = await client
        .get(Uri.parse('$_baseUrl/daily/$pair/$days'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to load history for $pair');
    }

    return json.decode(response.body) as List<dynamic>;
  }
}
