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

  Future<JobOrderResponse> getAllJobOrder({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getjoborder).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

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

  Future<JobOrderModel?> getJobOrder(String jobOrderId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.getjoborder}/$jobOrderId');

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

  Future<JobOrderModel> createJobOrder({
    required String plantId,
    required String materialCode,
    required String description,
    required List<String> uom,
    required Map<String, double> areas,
    required int noOfPiecesPerPunch,
    required int qtyInBundle,
  }) async {
    isAddJobOrderLoading = true;
    try {
      final authHeaders = await headers;
      final url = AppUrl.createJoborder;
      final Map<String, dynamic> body = {
        "plant": plantId,
        "material_code": materialCode,
        "description": description,
        "uom": uom,
        "areas": areas,
        "no_of_pieces_per_punch": noOfPiecesPerPunch,
        "qty_in_bundle": qtyInBundle,
      };

      final response = await http
          .post(Uri.parse(url), headers: authHeaders, body: json.encode(body))
          .timeout(const Duration(seconds: 30));

      print('Create JobOrder Response: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final JobOrderData = (responseData is Map<String, dynamic>)
            ? responseData['data'] ?? responseData
            : responseData;

        final createdJobOrder = JobOrderModel.fromJson(JobOrderData);
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
    required String jobOrderId,
    required String plantId,
    required String materialCode,
    required String description,
    required List<String> uom,
    required Map<String, double> areas,
    required int noOfPiecesPerPunch,
    required int qtyInBundle,
  }) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updatejoborder}/$jobOrderId';

      final Map<String, dynamic> body = {
        "plant": plantId,
        "material_code": materialCode,
        "description": description,
        "uom": uom,
        "areas": areas,
        "no_of_pieces_per_punch": noOfPiecesPerPunch,
        "qty_in_bundle": qtyInBundle,
      };

      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: authHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update JobOrder: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Unexpected error updating JobOrder: $e');
    }
  }

  Future<bool> deleteJobOrder(String jobOrderId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteJobOrder;

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: jsonEncode({
              "ids": [jobOrderId],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete JobOrder: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Unexpected error deleting JobOrder: $e');
    }
  }
}