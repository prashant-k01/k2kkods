import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class PlantRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool isAddPlantsLoading = false;
  PlantModel? _lastCreatedPlant;
  PlantModel? get lastCreatedPlant => _lastCreatedPlant;

  Future<List<PlantModel>> getPlants({
    required int skip,
    required int limit,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;
      print('Headers: $authHeaders'); // Debug
      final uri = Uri.parse(AppUrl.allPlantsUrl).replace(
        queryParameters: {
          'skip': skip.toString(),
          'limit': limit.toString(),
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      print('Request URL: $uri'); // Debug

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));
      print('Response status: ${response.statusCode}, body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Decoded JSON: $jsonData'); // Debug
        List<dynamic> plantsJson;

        // Handle various response structures
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              plantsJson = data;
            } else if (data is Map<String, dynamic>) {
              plantsJson = data['plants'] ?? data['items'] ?? [];
            } else {
              throw Exception('Unexpected data structure: ${data.runtimeType}');
            }
          } else if (jsonData.containsKey('plants')) {
            plantsJson = jsonData['plants'] ?? [];
          } else {
            throw Exception('Response missing expected keys: $jsonData');
          }
        } else if (jsonData is List) {
          plantsJson = jsonData;
        } else {
          throw Exception('Unexpected response type: ${jsonData.runtimeType}');
        }

        final plants = plantsJson
            .where((item) => item is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .map((plantJson) {
              print('Parsing plant: $plantJson'); // Debug
              try {
                return PlantModel.fromJson(plantJson);
              } catch (e) {
                print('Error parsing plant: $e, JSON: $plantJson');
                rethrow;
              }
            })
            .toList();

        print('Parsed plants: ${plants.length}'); // Debug
        return plants;
      } else {
        throw Exception('Failed to load plants: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: $e');
    } catch (e) {
      print('Error in getPlants: $e'); // Debug
      rethrow;
    }
  }

  Future<PlantModel?> getPlant(String plantId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.allPlantsUrl}/$plantId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final plantData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        return PlantModel.fromJson(plantData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load plant: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error loading plant: $e');
    }
  }

  Future<PlantModel> createPlant(String plantCode, String plantName) async {
    isAddPlantsLoading = true;
    try {
      final authHeaders = await headers;
      final url = AppUrl.addPlantUrl;
      final Map<String, dynamic> body = {
        "plant_code": plantCode,
        "plant_name": plantName,
      };

      final response = await http
          .post(Uri.parse(url), headers: authHeaders, body: json.encode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final plantData = (responseData is Map<String, dynamic>)
            ? responseData['data'] ?? responseData
            : responseData;

        final createdPlant = PlantModel.fromJson(plantData);
        _lastCreatedPlant = createdPlant;
        return createdPlant;
      } else {
        throw Exception(
          'Failed to create plant: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error creating plant: $e');
    } finally {
      isAddPlantsLoading = false;
    }
  }

  Future<bool> updatePlant(
    String plantId,
    String plantCode,
    String plantName,
  ) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updatePlanturl}/$plantId';

      final Map<String, dynamic> body = {
        "plant_code": plantCode,
        "plant_name": plantName,
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
          'Failed to update plant: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error updating plant: $e');
    }
  }

  Future<bool> deletePlant(String plantId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deletePlantUrl;

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: jsonEncode({
              "ids": [plantId],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete plant: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error deleting plant: $e');
    }
  }
}