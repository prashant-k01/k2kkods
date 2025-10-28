import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/common/constant/app_url.dart';
import 'package:k2k/core/shared_preference/shared_preference.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order_detail_model.dart';

class JobOrderRepository {
  Future<Map<String, String>> get headers async {
    final token = await SessionManager.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool isAddJobOrderLoading = false;
  JobOrderModel? _lastCreatedJobOrder;
  JobOrderModel? get lastCreatedJobOrder => _lastCreatedJobOrder;
  Future<JobOrderDetailResponse?> getJobOrderById(String mongoId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.getjoborderbyId}/$mongoId');

      print('Fetching JobOrder by ID from: ${uri.toString()}');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Raw JobOrderById Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Safely parse with null-aware checks
        return JobOrderDetailResponse.fromJson(jsonData);
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
      print('📦 Received response with status: ${response.statusCode}');

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

  Future<JobOrderDetailResponse?> getJobOrder(String mongoId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.getjoborder}/$mongoId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Raw JobOrder Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        return JobOrderDetailResponse.fromJson(jsonData);
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
        final url = "${AppUrl.getJOMachinesbyProduct}$productId";
        final uri = Uri.parse(url);

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
          if (response.statusCode >= 500 && retryCount < maxRetries - 1) {
            retryCount++;
            final delay = baseDelay * (1 << retryCount);
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
        if (retryCount < maxRetries - 1) {
          retryCount++;
          final delay = baseDelay * (1 << retryCount);
          await Future.delayed(delay);
          continue;
        }
        throw Exception('No internet connection: $e');
      } on FormatException catch (e) {
        throw Exception('Invalid response format: $e');
      } catch (e) {
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

      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: authHeaders,
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMessage =
            'Failed to update JobOrder: ${response.statusCode} - ${response.body}';
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error updating JobOrder: $e');
    }
  }

  Future<bool> deleteJobOrder(String mongoId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteJobOrder;

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: jsonEncode({
              "ids": [mongoId],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
          'Failed to delete JobOrder: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error deleting JobOrder: $e');
    }
  }

  Future<MachineResponse> getMachinesByProductId(String materialCode) async {
    if (materialCode.isEmpty) {
      throw Exception("❌ materialCode cannot be empty");
    }

    try {
      final authHeaders = await headers;
      final uri = Uri.parse("${AppUrl.getJOMachinesbyProduct}$materialCode");

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print("📡 Status Code: ${response.statusCode}");
      print("📄 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final machineResponse = MachineResponse.fromJson(jsonData);
        return machineResponse;
      } else if (response.statusCode == 404) {
        return MachineResponse(
          success: false,
          message: "No machines found for material_code: $materialCode",
          data: [],
        );
      } else {
        throw Exception(
          "❌ Failed to fetch machines: ${response.statusCode} - ${response.body}",
        );
      }
    } on SocketException catch (e) {
      throw Exception("🚫 No internet connection: $e");
    } on FormatException catch (e) {
      throw Exception("⚠️ Invalid response format: $e");
    } catch (e) {
      throw Exception("💥 Error fetching machines by productId: $e");
    }
  }
}
