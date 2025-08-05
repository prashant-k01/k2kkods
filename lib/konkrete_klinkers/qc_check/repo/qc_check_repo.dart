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

  Future<List<Map<String, String>>> getJobOrders() async {
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

        final jobOrders = jobOrdersJson
            .where(
              (item) =>
                  item is Map<String, dynamic> &&
                  item.containsKey('job_order_id') &&
                  item.containsKey('_id'),
            )
            .map(
              (item) => {
                'job_order_id': item['job_order_id'].toString(),
                '_id': item['_id'].toString(),
              },
            )
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

  Future<Map<String, dynamic>> getWorkOrderAndProducts(
    String jobOrderId,
  ) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(
        'https://k2k.kods.work/api/konkreteKlinkers/qc-check/products?id=$jobOrderId',
      );

      print('Fetching work order and products from: $uri');
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Work order and products response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty work order and products response');
          return {'work_order': null, 'products': []};
        }

        final jsonData = json.decode(responseBody);
        print('Work order and products JSON type: ${jsonData.runtimeType}');

        if (jsonData is Map<String, dynamic> && jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;
          final workOrder = data['work_order'] != null
              ? {
                  '_id': data['work_order']['_id'].toString(),
                  'work_order_number': data['work_order']['work_order_number']
                      .toString(),
                }
              : null;
          final products = (data['products'] as List<dynamic>)
              .where(
                (item) =>
                    item is Map<String, dynamic> &&
                    item.containsKey('_id') &&
                    item.containsKey('material_code'),
              )
              .map(
                (item) => {
                  '_id': item['_id'].toString(),
                  'material_code': item['material_code'].toString(),
                },
              )
              .toList();

          print(
            'Fetched work order: $workOrder, products: ${products.length} items',
          );
          return {'work_order': workOrder, 'products': products};
        } else {
          print('Unexpected response structure or success=false');
          return {'work_order': null, 'products': []};
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Access denied. You don\'t have permission to view work orders or products.',
        );
      } else if (response.statusCode == 404) {
        throw Exception(
          'Work order/products endpoint not found. Please contact support.',
        );
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      } else {
        throw Exception(
          'Failed to load work order and products: ${response.statusCode} - ${response.reasonPhrase}',
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

  Future<QcCheckModel> createQcCheck(Map<String, dynamic> qcCheckData) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.createKKQcCheckUrl);

      print('Creating QC check at: $uri with data: $qcCheckData');
      final response = await http
          .post(uri, headers: authHeaders, body: json.encode(qcCheckData))
          .timeout(const Duration(seconds: 30));

      print('Create QC check response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response received from server.');
        }

        final jsonData = json.decode(responseBody);
        print('Create QC check JSON response: $jsonData');

        if (jsonData is Map<String, dynamic> && jsonData['success'] == true) {
          final qcCheck = QcCheckModel.fromJson(jsonData['data']);
          _lastCreatedQcCheck = qcCheck;
          print('QC check created successfully: ${qcCheck.id}');
          return qcCheck;
        } else {
          throw Exception(
            'Failed to create QC check: Invalid response structure.',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Access denied. You don\'t have permission to create QC checks.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('QC check endpoint not found. Please contact support.');
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      } else {
        throw Exception(
          'Failed to create QC check: ${response.statusCode} - ${response.reasonPhrase}',
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

Future<bool> deleteQcCheck(String id) async {
  try {
    final token = await fetchAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }

    final authHeaders = await headers;
    // Don't add the ID to the URL path - use the endpoint as-is
    final uri = Uri.parse(AppUrl.deleteQcCheck);

    // Send the ID in the request body as 'ids' array (API expects plural)
    final requestBody = json.encode({
      'ids': [id], // API expects an array of IDs
    });

    print('Deleting QC check at: $uri');
    print('Request body: $requestBody');
    
    final response = await http
        .delete(
          uri, 
          headers: authHeaders, 
          body: requestBody,
        )
        .timeout(const Duration(seconds: 30));

    print('Delete QC check response status: ${response.statusCode}');
    print('Delete QC check response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('QC check deleted successfully: $id');
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode == 403) {
      throw Exception(
        'Access denied. You don\'t have permission to delete QC checks.',
      );
    } else if (response.statusCode == 404) {
      throw Exception('QC check not found or already deleted.');
    } else if (response.statusCode >= 500) {
      throw Exception(
        'Server error (${response.statusCode}). Please try again later.',
      );
    } else {
      // Parse error message from response if available
      try {
        final responseBody = response.body;
        if (responseBody.isNotEmpty && !responseBody.contains('<!DOCTYPE html>')) {
          final errorData = json.decode(responseBody);
          final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          throw Exception('Failed to delete QC check: $errorMessage');
        }
      } catch (e) {
        // If JSON parsing fails, use default error message
        print('JSON parsing error: $e');
      }
      throw Exception(
        'Failed to delete QC check: ${response.statusCode} - ${response.reasonPhrase}',
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
  Future<QcCheckModel> updateQcCheck(
    String id,
    Map<String, dynamic> qcCheckData,
  ) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please login again.');
      }

      if (qcCheckData['product_id'] is! String ||
          qcCheckData['product_id'].isEmpty) {
        throw Exception('Invalid or missing product_id in payload.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.createKKQcCheckUrl}/$id');

      print('Updating QC check at: $uri with data: $qcCheckData');
      final response = await http
          .put(uri, headers: authHeaders, body: json.encode(qcCheckData))
          .timeout(const Duration(seconds: 30));

      print('Update QC check response status: ${response.statusCode}');
      print('Update QC check response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response received from server.');
        }

        final jsonData = json.decode(responseBody);
        print('Update QC check JSON response: $jsonData');

        if (jsonData is Map<String, dynamic> && jsonData['success'] == true) {
          final qcCheck = QcCheckModel.fromJson(jsonData['data']);
          print('QC check updated successfully: ${qcCheck.id}');
          return qcCheck;
        } else {
          throw Exception(
            'Failed to update QC check: Invalid response structure - ${response.body}',
          );
        }
      } else if (response.statusCode == 400) {
        throw Exception(
          'Failed to update QC check: Bad Request - ${response.body}',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception(
          'Access denied. You don\'t have permission to update QC checks.',
        );
      } else if (response.statusCode == 404) {
        throw Exception('QC check not found. Please contact support.');
      } else if (response.statusCode >= 500) {
        throw Exception(
          'Server error (${response.statusCode}). Please try again later.',
        );
      } else {
        throw Exception(
          'Failed to update QC check: ${response.statusCode} - ${response.reasonPhrase}',
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
}
