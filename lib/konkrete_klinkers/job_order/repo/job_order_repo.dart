import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class JobOrderRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool isAddJobOrderLoading = false;
  JobOrderModel? _lastCreatedJobOrder;
  JobOrderModel? get lastCreatedJobOrder => _lastCreatedJobOrder;
  Future<JobOrderModel?> getJobOrderById(String mongoId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.getjoborderbyId}/$mongoId');

      print('Raw JobOrderById Response: ${uri.toString()}');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Raw JobOrderById Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final jobOrderData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        return JobOrderModel.fromJson(jobOrderData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load JobOrder by ID: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Unexpected error loading JobOrder by ID: $e');
    }
  }

  Future<JobOrderResponse> getAllJobOrder() async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getjoborder);

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Raw API Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is Map<String, dynamic>) {
          return JobOrderResponse.fromJson(jsonData);
        } else {
          throw Exception(
            'Unexpected response structure: ${jsonData.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to load JobOrder: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error loading JobOrder: $e');
    }
  }

  Future<JobOrderModel?> getJobOrder(String mongoId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.getjoborder}/$mongoId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Raw JobOrder Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final jobOrderData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        return JobOrderModel.fromJson(jobOrderData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load JobOrder: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Unexpected error loading JobOrder: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductDetailsByIds(
    List<String> productIds,
  ) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.baseUrl}/products/details');

      print('🔗 Fetching product details from: $uri');
      print('🆔 Product IDs: $productIds');

      final response = await http
          .post(
            uri,
            headers: authHeaders,
            body: json.encode({'product_ids': productIds}),
          )
          .timeout(const Duration(seconds: 30));

      print('📱 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> dataList =
            jsonData['data'] ?? jsonData['products'] ?? [];

        print('✅ Retrieved ${dataList.length} product details');
        return dataList.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Failed to fetch product details: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error in fetchProductDetailsByIds: $e');
      throw Exception('Error fetching product details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByWorkOrder(
    String workOrderId,
  ) async {
    try {
      final authHeaders = await headers;
      final fullUrl = '${AppUrl.getproductsbyworkOrder}$workOrderId';
      final uri = Uri.parse(fullUrl);

      print('🔗 Full API URL: $fullUrl');
      print('🆔 Work Order ID being sent: $workOrderId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('📱 HTTP Response Status Code: ${response.statusCode}');
      print('📄 Raw Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('🔍 Parsed JSON data: $jsonData');

        final List<dynamic> dataList = jsonData['data'] ?? [];
        print('📋 Data List Length: ${dataList.length}');

        for (int i = 0; i < dataList.length; i++) {
          final product = dataList[i];
          print('🎯 Product $i: $product');
        }

        if (dataList.isEmpty) {
          print(
            '⚠️ Warning: Empty product list returned for work order: $workOrderId',
          );
        }

        return dataList.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        print('🔍 404 Error - No products found for work order: $workOrderId');
        return [];
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('💥 Error in fetchProductsByWorkOrder: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMachineNamesByProductId(
    String productId,
  ) async {
    if (productId.isEmpty) {
      print('❌ Invalid product_id: empty or null');
      throw Exception('Product ID cannot be empty');
    }

    const maxRetries = 3;
    int retryCount = 0;
    const baseDelay = Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        final authHeaders = await headers;
        final uri = Uri.parse(
          'http://3.6.6.231/api/konkreteKlinkers/joborder-getMachine?material_code=$productId',
        );

        print(
          '🔗 Fetching machine names from: $uri (Attempt ${retryCount + 1}/$maxRetries)',
        );

        final response = await http
            .get(uri, headers: authHeaders)
            .timeout(const Duration(seconds: 30));

        print('📱 Response Status: ${response.statusCode}');
        print('📄 Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final List<dynamic> dataList = jsonData['data'] ?? [];

          final machineData = dataList
              .where((item) => item != null && item['name'] != null)
              .cast<Map<String, dynamic>>()
              .toList();

          print('✅ Retrieved ${machineData.length} machines');
          print('🔧 Machine data: $machineData');
          return machineData;
        } else {
          final errorMessage =
              'Failed to fetch machine names: ${response.statusCode} - ${response.body}';
          print('❌ $errorMessage');
          if (response.statusCode >= 500 && retryCount < maxRetries - 1) {
            retryCount++;
            final delay = baseDelay * (1 << retryCount);
            print('⏳ Retrying after ${delay.inMilliseconds}ms...');
            await Future.delayed(delay);
            continue;
          } else if (response.statusCode == 401) {
            throw Exception('Unauthorized: Invalid or expired token');
          } else if (response.statusCode == 404) {
            throw Exception('No machines found for product ID: $productId');
          }
          throw Exception(errorMessage);
        }
      } on SocketException catch (e) {
        print('❌ Network error: $e');
        if (retryCount < maxRetries - 1) {
          retryCount++;
          final delay = baseDelay * (1 << retryCount);
          print('⏳ Retrying after ${delay.inMilliseconds}ms...');
          await Future.delayed(delay);
          continue;
        }
        throw Exception('No internet connection: $e');
      } on FormatException catch (e) {
        print('❌ Invalid response format: $e');
        throw Exception('Invalid response format: $e');
      } catch (e) {
        print('❌ Error in fetchMachineNamesByProductId: $e');
        throw Exception('Error fetching machine names: $e');
      }
    }

    throw Exception('Failed to fetch machine names after $maxRetries attempts');
  }

  Future<List<Map<String, dynamic>>> fetchWorkOrderDetailsRaw() async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.fetchWorkOrderDetailsUrl);
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));
      print('Work Order fetch response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> dataList = jsonData['data'] ?? [];
        return dataList.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Failed to fetch work order details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching work order details: $e');
    }
  }

  Future<JobOrderModel> createJobOrder(Map<String, dynamic> payload) async {
    isAddJobOrderLoading = true;
    try {
      final authHeaders = await headers;
      final url = AppUrl.createJoborder;

      final response = await http
          .post(
            Uri.parse(url),
            headers: authHeaders,
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      print('Create JobOrder Response: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final jobOrderData =
            responseData['data']?['jobOrder'] ??
            responseData['data'] ??
            responseData;

        final createdJobOrder = JobOrderModel.fromJson(jobOrderData);
        _lastCreatedJobOrder = createdJobOrder;
        return createdJobOrder;
      } else {
        throw Exception(
          'Failed to create JobOrder: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error creating JobOrder: $e');
    } finally {
      isAddJobOrderLoading = false;
    }
  }

  Future<bool> updateJobOrder({
    required String mongoId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updateJobOrder}/$mongoId';
      print('🔗 Updating JobOrder at URL: $updateUrl');
      print('📤 Payload: ${jsonEncode(payload)}');

      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: authHeaders,
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      print('📱 Update Response Status: ${response.statusCode}');
      print('📄 Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ JobOrder updated successfully');
        return true;
      } else {
        final errorMessage =
            'Failed to update JobOrder: ${response.statusCode} - ${response.body}';
        print('❌ $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('No internet connection: $e');
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('❌ Unexpected error updating JobOrder: $e');
      throw Exception('Unexpected error updating JobOrder: $e');
    }
  }

  Future<bool> deleteJobOrder(String mongoId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteJobOrder;
      print('🔗 Deleting JobOrder at URL: $deleteUrl');
      print('📤 Payload: {"ids": ["$mongoId"]}');

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: jsonEncode({
              "ids": [mongoId],
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📱 Delete Response Status: ${response.statusCode}');
      print('📄 Delete Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          'Failed to delete JobOrder: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      print('❌ HttpException: $e');
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('❌ Unexpected error deleting JobOrder: $e');
      throw Exception('Unexpected error deleting JobOrder: $e');
    }
  }
}
