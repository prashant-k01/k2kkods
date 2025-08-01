import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/qc_check/model/qc_check.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class QcCheckRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool isAddQcCheckLoading = false;
  QcCheckModel? _lastCreatedQcCheck;
  QcCheckModel? get lastCreatedQcCheck => _lastCreatedQcCheck;
  Future<List<String>> getJobOrders() async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getDropdownJobOrder);

      print('Fetching job orders from: $uri');
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Job orders response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty job orders response');
          return [];
        }

        final jsonData = json.decode(responseBody);
        print('Job orders JSON type: ${jsonData.runtimeType}');

        List<dynamic> jobOrdersJson = [];
        if (jsonData is Map<String, dynamic>) {
          jobOrdersJson = jsonData['data'] ?? jsonData['items'] ?? [];
        } else if (jsonData is List) {
          jobOrdersJson = jsonData;
        } else {
          print('Unexpected job orders response type: ${jsonData.runtimeType}');
          return [];
        }

        // Extract job_order_id
        final jobOrders = jobOrdersJson
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  item.containsKey('job_order_id'),
            )
            .map((item) => item['job_order_id'].toString())
            .toList();

        print('Fetched ${jobOrders.length} job orders');
        return jobOrders;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Access denied. You don\'t have permission to view inventory.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Inventory endpoint not found. Please contact support.',
        );
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      } else {
        throw Exception(
          'Failed to load job orders: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on SocketException catch (e) {
      print('Socket exception: $e');
      throw Exception('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      print('HTTP exception: $e');
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      print('Format exception: $e');
      throw Exception('Invalid response format. Please contact support.');
    }
  }

  Future<List<QcCheckModel>> getQcChecks({String? search}) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getKKqcCheckData);

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) return [];

        final jsonData = json.decode(responseBody);

        List<dynamic> rawList = [];
        if (jsonData is List) {
          rawList = jsonData;
        } else if (jsonData is Map<String, dynamic>) {
          rawList =
              jsonData['data'] ??
              jsonData['qcChecks'] ??
              jsonData['items'] ??
              jsonData['records'] ??
              jsonData['results'] ??
              [];
        }

        return rawList
            .whereType<Map<String, dynamic>>()
            .map(QcCheckModel.fromJson)
            .toList();
      } else {
        throw Exception('Failed to load QC checks: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    }
  }
}
