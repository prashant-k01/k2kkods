import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:k2k/common/constant/app_url.dart';
import 'package:k2k/core/shared_preference/shared_preference.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/client_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_detail_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';

class WorkOrderRepository {
  Future<Map<String, String>> get headers async {
    try {
      final String? token = await SessionManager.getAccessToken();

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

  Future<WorkOrderModel> getAllWorkOrders({
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

        // Return the full response object
        return WorkOrderModel.fromJson(jsonData);
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

  Future<WorkOrder?> getWorkOrder(String id) async {
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

  Future<WorkOrder> createWorkOrder(Map<String, dynamic> payload) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final String url = AppUrl.createWorkOrderUrl;
      print('📤 [Repo] Sending multipart request to $url');

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(authHeaders);

      // Handle normal fields
      for (final entry in payload.entries) {
        final key = entry.key;
        final value = entry.value;

        if (key == 'files' || key == 'products') continue; // handled separately
        request.fields[key] = value.toString();
        print('   ➡️ field: $key = ${request.fields[key]}');
      }

      // Handle products array
      if (payload['products'] != null) {
        final products = payload['products'] as List<Map<String, dynamic>>;
        for (int i = 0; i < products.length; i++) {
          final p = products[i];
          request.fields['products[$i][product_id]'] = p['product_id'];
          request.fields['products[$i][uom]'] = p['uom'];
          request.fields['products[$i][po_quantity]'] = p['po_quantity']
              .toString();
          request.fields['products[$i][delivery_date]'] = p['delivery_date'];
          request.fields['products[$i][plant_code]'] = p['plant_code'];
        }
      }

      // Handle files
      if (payload['files'] != null) {
        for (var f in payload['files'] as List<File>) {
          print('   📎 Attaching file: ${f.path}');
          request.files.add(await http.MultipartFile.fromPath('files', f.path));
        }
      }

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📦 [Repo] Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonRes = json.decode(response.body);
        return WorkOrder.fromJson(jsonRes['data']);
      } else {
        throw Exception('❌ Failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('❌ [Repo] Error: $e');
      rethrow;
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
    required List<Map<String, dynamic>> products,
    required List<File> files,
    required Status status,
  }) async {
    try {
      final Map<String, String> authHeaders = await headers;
      final String updateUrl = '${AppUrl.updateWorkOrderDetailsUrl}/$id';

      final request = http.MultipartRequest('PUT', Uri.parse(updateUrl));
      request.headers.addAll(authHeaders);

      // Add normal fields
      request.fields['work_order_number'] = workOrderNumber;
      if (clientId != null) request.fields['client_id'] = clientId;
      if (projectId != null) request.fields['project_id'] = projectId;

      if (date != null) {
        // ✅ Format to yyyy-MM-dd instead of ISO (most APIs expect this)
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        request.fields['date'] = formattedDate;
      }

      request.fields['buffer_stock'] = bufferStock ? 'true' : 'false';
      if (bufferStock && bufferStockQuantity != null) {
        request.fields['buffer_stock_quantity'] = bufferStockQuantity
            .toString();
      }

      request.fields['status'] = statusValues.reverse[status]!;

      // Add products
      if (products.isNotEmpty) {
        for (int i = 0; i < products.length; i++) {
          final p = products[i];
          request.fields['products[$i][product_id]'] = p['product_id']
              .toString();
          request.fields['products[$i][uom]'] = p['uom'].toString();
          request.fields['products[$i][po_quantity]'] = p['po_quantity']
              .toString();
          request.fields['products[$i][delivery_date]'] = p['delivery_date']
              .toString();
          request.fields['products[$i][plant_code]'] = p['plant_code']
              .toString();
        }
      }

      // Add files
      for (var f in files) {
        print('📎 Preparing file: ${f.path}');
        if (await f.exists()) {
          request.files.add(await http.MultipartFile.fromPath('files', f.path));
        } else {
          print('⚠️ File does not exist locally: ${f.path}');
        }
      }
      // 🔎 Debug: print headers + fields before sending
      print('🔐 Headers: $authHeaders');
      print('🌐 URL: $updateUrl');
      print('📝 Fields being sent:');
      request.fields.forEach((k, v) => print('   • $k = $v'));

      // Send request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📦 [Update WorkOrder] Status: ${response.statusCode}');
      print('📦 [Update WorkOrder] Body: ${response.body}');

      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('success')) {
            print('✅ success field = ${decoded['success']}');
          }
          if (decoded.containsKey('message')) {
            print('ℹ️ message field = ${decoded['message']}');
          }
          if (decoded.containsKey('errors')) {
            print('❌ errors field = ${decoded['errors']}');
          }
        }
      } catch (e) {
        print('⚠️ Could not parse response JSON: $e');
      }

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
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
