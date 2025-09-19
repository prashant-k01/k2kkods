import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/Iron_smith/job_order/model/job_order_detail.dart';
import 'package:k2k/Iron_smith/job_order/model/job_order_summary.dart';
import 'package:k2k/Iron_smith/job_order/model/workorderid.dart';
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

class JobOrderISRepository {
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

  Future<Data> getJobOrderById(String id) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getJobOrderById(id));

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return Data.fromJson(jsonData['data']);
        } else {
          throw Exception(
            jsonData['message'] ?? "Failed to fetch Job Order details",
          );
        }
      } else {
        throw Exception(
          'Failed to fetch Job Order: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Unexpected error while fetching Job Order: $e');
    }
  }

  Future<JoData> getWorkorderById(String id) async {
    try {
      final authHeaders = await headers;
      print('DEBUG: getWorkorderById - ID: $id');
      print('DEBUG: getWorkorderById - Headers: $authHeaders');
      final uri = Uri.parse(AppUrl.getWorkOrderByWorkOrderId(id));
      print('DEBUG: getWorkorderById - URI: $uri');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('DEBUG: getWorkorderById - Status Code: ${response.statusCode}');
      print('DEBUG: getWorkorderById - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('DEBUG: getWorkorderById - Parsed JSON: $jsonData');

        if (jsonData['success'] == true && jsonData['data'] != null) {
          try {
            final joData = JoData.fromJson(jsonData['data']);
            print('DEBUG: getWorkorderById - Parsed JoData: $joData');
            return joData;
          } catch (e) {
            print('DEBUG: getWorkorderById - Error parsing JoData: $e');
            throw Exception('Failed to parse Job Order data: $e');
          }
        } else {
          final message =
              jsonData['message'] ?? 'Failed to fetch Job Order details';
          print('DEBUG: getWorkorderById - API error: $message');
          throw Exception(message);
        }
      } else {
        final error =
            'Failed to fetch Job Order: ${response.statusCode} - ${response.body}';
        print('DEBUG: getWorkorderById - HTTP error: $error');
        throw Exception(error);
      }
    } catch (e) {
      print('DEBUG: getWorkorderById - Unexpected error: $e');
      throw Exception('Unexpected error while fetching Job Order: $e');
    }
  }

  /// ✅ CREATE Job Order
  Future<JobOrderModel> createJobOrder(Map<String, dynamic> body) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.createISJobOrder);

      final response = await http
          .post(uri, headers: authHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          _lastCreatedJobOrder = JobOrderModel.fromJson(jsonData['data']);
          return _lastCreatedJobOrder!;
        } else {
          throw Exception(jsonData['message'] ?? "Failed to create Job Order");
        }
      } else {
        throw Exception(
          'Failed to create Job Order: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Unexpected error while creating Job Order: $e');
    }
  }

  /// ✅ READ Job Orders
  Future<List<JobOrderData>> getAllJobOrder() async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getAllJobOrder);

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          final success = jsonData['success'] as bool? ?? false;
          if (!success) {
            throw Exception(
              jsonData['message'] ?? 'Failed to fetch job orders',
            );
          }

          final data = jsonData['data'];
          if (data is List) {
            return data.map((e) => JobOrderData.fromJson(e)).toList();
          } else {
            throw Exception(
              'Unexpected "data" type: expected List but got ${data.runtimeType}',
            );
          }
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
    } on TimeoutException {
      throw Exception('Request timeout, please try again later');
    } catch (e) {
      throw Exception('Unexpected error loading JobOrder: $e');
    }
  }

  /// ✅ UPDATE Job Order
  Future<JobOrderModel> updateJobOrder(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse("$AppUrl.getJobOrderById(id)");

      final response = await http
          .put(uri, headers: authHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return JobOrderModel.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? "Failed to update Job Order");
        }
      } else {
        throw Exception(
          'Failed to update Job Order: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Unexpected error while updating Job Order: $e');
    }
  }

  /// ✅ DELETE Job Order
  Future<bool> deleteJobOrder(String id) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteISJobOrder;

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: {...authHeaders, 'Content-Type': 'application/json'},
            body: jsonEncode({
              "ids": [id],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true &&
            (responseData['data']?['deletedCount'] ?? 0) > 0) {
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception('Failed: ${response.statusCode} - ${response.body}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Request timeout, please try again later');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
