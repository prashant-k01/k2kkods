import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/production/model/common_model.dart';
import 'package:k2k/konkrete_klinkers/production/model/production_logs_model.dart';
import 'package:k2k/konkrete_klinkers/production/model/production_model.dart';
import 'package:k2k/shared_preference/shared_preference.dart';
import 'package:intl/intl.dart';

class ProductionRepository {
  Future<Map<String, String>> get headers async {
    try {
      final token = await fetchAccessToken();
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    } catch (e) {
      print('Error fetching token: $e');
      return {'Content-Type': 'application/json'};
    }
  }

  Future<Production> fetchProductionJobOrderByDate({DateTime? date}) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getProductionJoborderBydate).replace(
        queryParameters: date != null
            ? {'date': DateFormat('yyyy-MM-dd').format(date)}
            : null,
      );
      print('Fetching production data with URI: $uri');
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final production = productionFromJson(response.body);
        print(
          'Parsed Production: success=${production.success}, '
          'message=${production.message}, '
          'data lists: pastDPR=${production.data.pastDpr.length}, '
          'todayDPR=${production.data.todayDpr.length}, '
          'futureDPR=${production.data.futureDpr.length}',
        );
        return production;
      } else {
        throw Exception(
          'Failed to load production data: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('No internet connection: $e');
    } catch (e) {
      print('Error fetching production data: $e');
      throw Exception('Error loading production data: $e');
    }
  }

  Future<bool> addDownTime(
    String productId,
    String jobOrder,
    Map<String, dynamic> downtimeData,
  ) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.addDownTime);
      final response = await http
          .post(uri, headers: authHeaders, body: json.encode(downtimeData))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to add downtime: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error adding downtime: $e');
    }
  }

  Future<List<Downtime>> fetchDownTimeLogs(
    String productId,
    String jobOrder,
  ) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(
        '${AppUrl.fetchDownTimeLogs}$productId&job_order=$jobOrder',
      );
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final downtimeData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;
        if (downtimeData is List) {
          return List<Downtime>.from(
            downtimeData.map((x) => Downtime.fromJson(x)),
          );
        } else {
          throw Exception(
            'Unexpected downtime data structure: ${downtimeData.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch downtime logs: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error fetching downtime logs: $e');
    }
  }

  Future<List<ProductionLog>> fetchProductionLogs(
    String productId,
    String jobOrder,
  ) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(
        '${AppUrl.fetchProductionLogs}$productId&job_order=$jobOrder',
      );
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;
        if (data is Map<String, dynamic> && data['production_logs'] is List) {
          return (data['production_logs'] as List)
              .map((e) => ProductionLog.fromJson(e))
              .toList();
        } else {
          throw Exception(
            'Unexpected production log data structure: ${data.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to fetch production logs: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error fetching production logs: $e');
    }
  }

  Future<PastDpr?> performAction({
    required String jobOrder,
    required String productId,
    required String action,
  }) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.startTheProduction);
      final body = {
        "action": action,
        "job_order": jobOrder,
        "product_id": productId,
      };

      print('Sending action request: $action, URI: $uri, Body: $body');
      final response = await http
          .post(uri, headers: authHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      print('Action Response Status: ${response.statusCode}');
      print('Action Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Parsed Action Response: $jsonData');

        if (jsonData['success'] == true) {
          // Check if data exists and is a Map
          if (jsonData['data'] != null &&
              jsonData['data'] is Map<String, dynamic>) {
            print('Parsing PastDpr from data: ${jsonData['data']}');
            try {
              return PastDpr.fromJson(jsonData['data']);
            } catch (e) {
              print('Error parsing PastDpr: $e');
              // If parsing fails, still consider it successful but return null
              return null;
            }
          } else {
            print(
              'Data is not a Map or is null, received: ${jsonData['data']} (type: ${jsonData['data']?.runtimeType})',
            );
            // Action was successful but no data to parse - this is common for pause/resume actions
            return null;
          }
        } else {
          throw Exception(jsonData['message'] ?? 'Unknown error occurred.');
        }
      } else {
        throw Exception(
          'Failed to perform action: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception('No internet connection: $e');
    } catch (e) {
      print('Error performing action: $e');
      throw Exception('Error performing action: $e');
    }
  }

  Future<bool> updateProduction(String productId, String jobOrder) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.updatedProduction).replace(
        queryParameters: {'product_id': productId, 'job_order': jobOrder},
      );

      print('PUT URL: $uri');
      print('PUT Headers: $authHeaders');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));
      print('GET response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update production: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      print('Error updating production: $e');
      throw Exception('Error updating production: $e');
    }
  }
}
