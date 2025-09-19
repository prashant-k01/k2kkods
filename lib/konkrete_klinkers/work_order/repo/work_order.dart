import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/client_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_detail_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';

class WorkOrderRepository {
  bool isAddWorkOrderLoading = false;
  Datum? _lastCreatedWorkOrder;
  Datum? get lastCreatedWorkOrder => _lastCreatedWorkOrder;

  Future<Map<String, String>> get headers async {
    try {
      final String? token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing or invalid');
      }
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    } catch (e) {
      print('Error fetching token: $e');
      return {'Content-Type': 'application/json'};
    }
  }

  Future<List<ProductModel>> getAllProducts({
    String? search,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final Map<String, String> queryParams = {
        if (search != null && search.isNotEmpty) 'search': search,
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final Uri uri = Uri.parse(
        AppUrl.fetchproductDetailsUrl,
      ).replace(queryParameters: queryParams);
      print('🔍 Fetching products: $uri');

      final http.Response response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('📦 Products response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData.containsKey('data')) {
          final List<dynamic> productsData = jsonData['data'] as List<dynamic>;
          return productsData
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
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

  Future<List<Datum>> getAllWorkOrders({
    int skip = 0,
    int limit = 10,
    String? search,
  }) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final Uri uri = Uri.parse(AppUrl.fetchWorkOrderDetailsUrl).replace(
        queryParameters: {
          'skip': skip.toString(),
          'limit': limit.toString(),
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final http.Response response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print(
        '📦 Work orders response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          return (jsonData['data'] as List<dynamic>)
              .map((x) => Datum.fromJson(x as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            'Unexpected response structure: ${jsonData['message'] ?? 'No data'}',
          );
        }
      } else {
        throw Exception(
          'Failed to load work orders: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again.');
    } catch (e) {
      throw Exception('Failed to load work orders: $e');
    }
  }

  Future<List<ClientModel>> getAllClients({
    String? search,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final Map<String, String> queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final Uri uri = Uri.parse(
        AppUrl.fetchClientDetailsUrl,
      ).replace(queryParameters: queryParams);
      print('🔍 Fetching clients: $uri');

      final http.Response response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('📦 Clients response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData.containsKey('data')) {
          final List<dynamic> clientsJson = jsonData['data'] as List<dynamic>;
          return clientsJson
              .whereType<Map<String, dynamic>>()
              .map((clientJson) => ClientModel.fromJson(clientJson))
              .toList();
        } else {
          throw Exception(
            'Unexpected response: ${jsonData['message'] ?? 'No data found'}',
          );
        }
      } else {
        throw Exception(
          'Failed to load clients: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again.');
    } catch (e) {
      throw Exception('Failed to load clients: $e');
    }
  }

  Future<Datum?> getWorkOrder(String id) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final Uri uri = Uri.parse('${AppUrl.fetchWorkOrderDetailsUrl}/$id');

      final http.Response response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print(
          '📦 Work order response: ${response.statusCode} - ${response.body}',
        );
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (kDebugMode) {
          print(
            '📝 [WorkOrderRepository] Parsed JSON data type: ${jsonData['data']?.runtimeType}',
          );
        }

        // Parse response using WorkOrderModel
        final workOrderModel = WorkOrderModel.fromJson(jsonData);

        if (kDebugMode) {
          print(
            '📝 [WorkOrderRepository] WorkOrderModel data length: ${workOrderModel.data.length}',
          );
        }

        // Return the first Datum from the data list (or null if empty)
        return workOrderModel.data.isNotEmpty
            ? workOrderModel.data.first
            : null;
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          print('📝 [WorkOrderRepository] Work order $id not found (404)');
        }
        return null;
      } else {
        throw Exception(
          'Failed to load work order: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException catch (e, stackTrace) {
      if (kDebugMode) {
        print('📝 [WorkOrderRepository] FormatException: $e\n$stackTrace');
      }
      throw Exception('Invalid data format: ${e.message}');
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(
          '📝 [WorkOrderRepository] Error fetching work order $id: $e\n$stackTrace',
        );
      }
      throw Exception('Failed to load work order: $e');
    }
  }

  Future<WODData?> getWorkOrderById(String id) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final Uri uri = Uri.parse('${AppUrl.fetchWorkOrderDetailsUrl}/$id');

      final http.Response response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));
      print('API Response Status: ${response.statusCode}'); // Debug log
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        final workOrderDetails = WODWorkOrderDetails.fromJson(jsonData);

        // Return the first item from data list or null
        return workOrderDetails.data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load work order: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException catch (e) {
      throw Exception('Invalid data format: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load work order: $e');
    }
  }

  Future<Datum> createWorkOrder({
    required String workOrderNumber,
    String? clientId,
    String? projectId,
    DateTime? date,
    required bool bufferStock,
    int? bufferStockQuantity,
    required List<Product> products,
    required List<FileElement> files,
    required Status status,
  }) async {
    isAddWorkOrderLoading = true;
    try {
      final Map<String, String> authHeaders = await headers;
      final String url = AppUrl.createWorkOrderUrl;
      final Map<String, dynamic> body = {
        'work_order_number': workOrderNumber,
        if (clientId != null) 'client_id': clientId,
        if (projectId != null) 'project_id': projectId,
        if (date != null) 'date': date.toIso8601String(),
        'buffer_stock': bufferStock,
        if (bufferStock && bufferStockQuantity != null)
          'buffer_stock_quantity': bufferStockQuantity,
        'products': products.map((product) => product.toJson()).toList(),
        'files': files.map((file) => file.toJson()).toList(),
        'status': statusValues.reverse[status]!,
      };

      print('📤 Creating work order: $url');
      print('📤 Payload: ${json.encode(body)}');

      final http.Response response = await http
          .post(Uri.parse(url), headers: authHeaders, body: json.encode(body))
          .timeout(const Duration(seconds: 30));

      print(
        '📦 Create work order response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          final createdWorkOrder = Datum.fromJson(responseData['data']);
          _lastCreatedWorkOrder = createdWorkOrder;
          return createdWorkOrder;
        } else {
          throw Exception(
            'Unexpected response structure: ${responseData['message'] ?? response.body}',
          );
        }
      } else {
        throw Exception(
          'Failed to create work order: ${response.statusCode}  ?? response.body}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException {
      throw Exception('Invalid server response format. Please try again.');
    } catch (e) {
      throw Exception('Failed to create work order: $e');
    } finally {
      isAddWorkOrderLoading = false;
    }
  }

  Future<bool> updateWorkOrder({
    required String id,
    required String workOrderNumber,
    String? clientId,
    String? projectId,
    DateTime? date,
    required bool bufferStock,
    int? bufferStockQuantity,
    required List<Product> products,
    required List<FileElement> files,
    required Status status,
  }) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final String updateUrl = '${AppUrl.updateWorkOrderDetailsUrl}/$id';

      final Map<String, dynamic> body = {
        'work_order_number': workOrderNumber,
        if (clientId != null) 'client_id': clientId,
        if (projectId != null) 'project_id': projectId,
        if (date != null) 'date': date.toIso8601String(),
        'buffer_stock': bufferStock,
        if (bufferStock && bufferStockQuantity != null)
          'buffer_stock_quantity': bufferStockQuantity,
        'products': products.map((product) => product.toJson()).toList(),
        'files': files.map((file) => file.toJson()).toList(),
        'status': statusValues.reverse[status]!,
      };

      final http.Response response = await http
          .put(
            Uri.parse(updateUrl),
            headers: authHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData['success'] == true;
      } else {
        throw Exception(
          'Server error: ${response.statusCode} - ${responseData['message'] ?? 'Unknown error'}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } on FormatException {
      throw Exception('Invalid server response');
    } catch (e) {
      throw Exception('Failed to update work order: ${e.toString()}');
    }
  }

  Future<bool> deleteWorkOrder(String id) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final String deleteUrl = AppUrl.deleteWorkOrderDetailsUrl;

      final http.Response response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: jsonEncode({
              'ids': [id],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete work order: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } catch (e) {
      throw Exception('Failed to delete work order: $e');
    }
  }

  Future<List<TId>> getProjectsByClient(String clientId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.getWOProjectbyClient}$clientId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Raw Projects by Client Response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final projectData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        if (projectData is List) {
          return List<TId>.from(
            projectData.map((x) => TId.fromJson(x as Map<String, dynamic>)),
          );
        } else {
          throw Exception(
            'Unexpected project data structure: ${projectData.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to load Projects: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error loading Projects: $e');
    }
  }
}
