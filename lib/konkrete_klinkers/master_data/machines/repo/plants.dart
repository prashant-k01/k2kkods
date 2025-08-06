import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class PlantRepository {
  // ✅ Internal helper method to get headers
  Future<Map<String, String>> get _headers async {
    final token = await fetchAccessToken(); // Replace with your actual method
    if (token == null || token.isEmpty) {
      print('[PlantRepository] Authentication token is missing');
      throw Exception('Authentication token is missing');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ✅ Fetch all plant list
  Future<List<PlantId>> fetchAllPlants() async {
    try {
      final uri = Uri.parse(AppUrl.allPlantsUrl);
      print('[PlantRepository] Sending GET request to $uri');

      final requestHeaders = await _headers;
      print('[PlantRepository] Request Headers: $requestHeaders');

      final response = await http
          .get(uri, headers: requestHeaders)
          .timeout(const Duration(seconds: 20));

      print('[PlantRepository] Status Code: ${response.statusCode}');
      print('[PlantRepository] Raw Response Body: ${response.body}');

      // ✅ Check if backend returned success
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data['success'] == true && data['data'] is List) {
          final plants = (data['data'] as List)
              .map((e) => PlantId.fromJson(e))
              .toList();

          print('[PlantRepository] ✅ Fetched ${plants.length} plants');
          print(
            '[PlantRepository] Plant Names: ${plants.map((e) => e.plantName).toList()}',
          );

          return plants;
        } else {
          print('[PlantRepository] ❌ Unexpected data structure from backend');
          print('[PlantRepository] Response JSON: $data');
          return [];
        }
      } else {
        print(
          '[PlantRepository] ❌ Backend returned error status code: ${response.statusCode}',
        );
        try {
          final err = jsonDecode(response.body);
          print('[PlantRepository] Backend Error Message: ${err['message']}');
          throw Exception(err['message'] ?? 'Failed to fetch plants');
        } catch (_) {
          print('[PlantRepository] ❌ Error parsing backend error message');
          print('[PlantRepository] ❌ Raw error body: ${response.body}');

          throw Exception('Failed to fetch plants: Unknown backend error');
        }
      }
    } catch (e, stack) {
      print('[PlantRepository] ❌ Frontend Error: $e');
      print('[PlantRepository] Stack Trace:\n$stack');
      throw Exception('Error fetching plants: $e');
    }
  }
}
