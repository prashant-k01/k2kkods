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

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return [];
        }

        final jsonData = json.decode(responseBody);

        List<dynamic> rawList = jsonData['data'] ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(StockManagement.fromJson)
            .toList();
      } else {
        final jsonData = json.decode(response.body);
        throw Exception(
          'Failed to load work order transfers: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Datum>> getAllProducts({String? search}) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final Map<String, String> queryParams = {};

      final Uri uri = Uri.parse(
        AppUrl.fetchproductDetailsUrl,
      ).replace(queryParameters: queryParams);

      final http.Response response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData.containsKey('data')) {
          final List<dynamic> productsData = jsonData['data'] as List<dynamic>;
          return productsData
              .map((item) => Datum.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Unexpected response: ${jsonData['message'] ?? 'No data found'}',
          );
        }
      } else {
        throw Exception(
          'Failed to load products: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again.');
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  Future<void> createBuffer({
    required String fromWorkOrderId,
    required String toWorkOrderId,
    required String productId,
    required int quantityTransferred,
    required bool isBufferTransfer,
  }) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.createStockManagement);
      final payload = {
        'from_work_order_id': fromWorkOrderId,
        'to_work_order_id': toWorkOrderId,
        'product_id': productId,
        'quantity_transferred': quantityTransferred,
        'isBufferTransfer': isBufferTransfer,
      };

      print('Sending buffer creation to: $uri'); // Debug log
      print('Payload: $payload'); // Debug log

      final response = await http
          .post(uri, headers: authHeaders, body: json.encode(payload))
          .timeout(const Duration(seconds: 30));

      // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] != true) {
          throw Exception(
            'Failed to create buffer: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        final jsonData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};
        throw Exception(
          'Failed to create buffer: ${response.statusCode} - ${jsonData['errors']?.toString() ?? jsonData['message'] ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } on FormatException {
      throw Exception('Invalid server response format.');
    } catch (e) {
      rethrow;
    }
  }

  Future<Stock> getStockById(String id) async {
    try {
      final token = await fetchAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;

      final uri = Uri.parse('${AppUrl.kkStockManagement}/$id');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response body');
        }

        final jsonData = json.decode(responseBody);

        if (jsonData['success'] == true && jsonData.containsKey('data')) {
          return Stock.fromJson(jsonData['data']);
        } else {
          throw Exception(
            'Failed to load stock management: ${jsonData['message'] ?? 'No data found'}',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        throw Exception(
          'Failed to load stock management: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      print('❌ [getStockById] No internet connection.');
      throw Exception('No internet connection.');
    } catch (e, stack) {
      print('❌ [getStockById] Exception: $e');
      print('📜 [Stack Trace]: $stack');
      rethrow;
    }
  }

  Future<List<Data>> getWorkOrdersByProductId(
    String productId,
    bool isBuffer,
  ) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getwobyproduct).replace(
        queryParameters: {'prId': productId, 'isBuffer': isBuffer.toString()},
      );

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          return [];
        }

        final jsonData = json.decode(responseBody);

        final workOrderResponse = WorkOrderResponse.fromJson(jsonData);
        if (workOrderResponse.success) {
          return workOrderResponse.data;
        } else {
          throw Exception(
            'Failed to load work orders: ${workOrderResponse.message}',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        throw Exception(
          'Failed to load work orders: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      rethrow;
    }
  }

  Future<DataQ> getAchievedQuantity({
    required String workOrderId,
    required String productId,

    required bool isBuffer,
  }) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getAchievedQuantity).replace(
        queryParameters: {
          'prId': productId,
          'wrId': workOrderId,
          'isBuffer': isBuffer.toString(),
        },
      );

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response body');
        }

        final jsonData = json.decode(responseBody);

        final achievedQuantityResponse = AvailableQuantity.fromJson(jsonData);
        if (achievedQuantityResponse.success) {
          return achievedQuantityResponse.data;
        } else {
          throw Exception(
            'Failed to load achieved quantity: ${achievedQuantityResponse.message}',
          );
        }
      } else {
        final jsonData = json.decode(response.body);
        throw Exception(
          'Failed to load achieved quantity: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      rethrow;
    }
  }
}
