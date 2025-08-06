import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/stock_management/model/stock.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class StockManagementRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<StockManagement>> getStockManagements() async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.kkStockManagement);

      print('Fetching work order transfers from: $uri'); // Debug log

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print(
        'StockManagements API Response Status: ${response.statusCode}',
      ); // Debug log
      print(
        'StockManagements API Response Body: ${response.body}',
      ); // Debug log

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty response body for work order transfers'); // Debug log
          return [];
        }

        final jsonData = json.decode(responseBody);
        print('Parsed StockManagements JSON: $jsonData'); // Debug log

        List<dynamic> rawList = jsonData['data'] ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(StockManagement.fromJson)
            .toList();
      } else {
        final jsonData = json.decode(response.body);
        print('Error Response JSON: $jsonData'); // Debug log
        throw Exception(
          'Failed to load work order transfers: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      print('No internet connection while fetching work order transfers');
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in getStockManagements: $e');
      rethrow;
    }
  }
}
