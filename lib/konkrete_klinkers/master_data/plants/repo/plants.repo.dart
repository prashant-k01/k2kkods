import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    final page = json['page'] ?? 1;
    final totalPages = json['totalPages'] ?? 1;
    
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: page,
      limit: json['limit'] ?? 10,
      totalPages: totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    );
  }
}

class PaginatedPlantsResponse {
  final List<PlantModel> plants;
  final PaginationInfo pagination;

  PaginatedPlantsResponse({
    required this.plants,
    required this.pagination,
  });
}

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

  // Updated method to support pagination
  Future<PaginatedPlantsResponse> getAllPlants({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;
      
      // Build URL with pagination parameters
      final uri = Uri.parse(AppUrl.allPlantsUrl).replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return PaginatedPlantsResponse(
            plants: [],
            pagination: PaginationInfo(
              total: 0,
              page: 1,
              limit: limit,
              totalPages: 1,
              hasNextPage: false,
              hasPreviousPage: false,
            ),
          );
        }

        final jsonData = json.decode(response.body);
        List<dynamic> plantsJson = [];
        PaginationInfo paginationInfo;

        if (jsonData is Map<String, dynamic>) {
          // Handle pagination info
          if (jsonData.containsKey('pagination')) {
            paginationInfo = PaginationInfo.fromJson(jsonData['pagination']);
          } else {
            // Fallback pagination if not provided
            paginationInfo = PaginationInfo(
              total: 0,
              page: page,
              limit: limit,
              totalPages: 1,
              hasNextPage: false,
              hasPreviousPage: false,
            );
          }

          // Extract plants data
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              plantsJson = data;
            } else if (data is Map && data.containsKey('plants')) {
              plantsJson = data['plants'] is List ? data['plants'] : [];
            } else if (data is Map) {
              plantsJson = [data];
            }
          } else if (jsonData.containsKey('plants')) {
            final plants = jsonData['plants'];
            plantsJson = plants is List ? plants : [plants];
          } else if (jsonData.containsKey('result')) {
            final result = jsonData['result'];
            plantsJson = result is List ? result : [result];
          } else if (jsonData.containsKey('items')) {
            final items = jsonData['items'];
            plantsJson = items is List ? items : [items];
          } else {
            // Check if it's a single plant object
            if (jsonData.containsKey('plant_code') ||
                jsonData.containsKey('plantCode') ||
                jsonData.containsKey('plant_name') ||
                jsonData.containsKey('plantName') ||
                jsonData.containsKey('_id') ||
                jsonData.containsKey('id')) {
              plantsJson = [jsonData];
            }
          }
        } else if (jsonData is List) {
          plantsJson = jsonData;
          paginationInfo = PaginationInfo(
            total: plantsJson.length,
            page: page,
            limit: limit,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          );
        } else {
          throw Exception('Unexpected response structure: ${jsonData.runtimeType}');
        }

        // Parse plants
        final List<PlantModel> plants = [];
        for (final plantJson in plantsJson) {
          try {
            if (plantJson is Map<String, dynamic>) {
              final plant = PlantModel.fromJson(plantJson);
              plants.add(plant);
            }
          } catch (e) {
            print('Error parsing plant: $e');
            // Skip malformed entry
          }
        }

        return PaginatedPlantsResponse(
          plants: plants,
          pagination: paginationInfo,
        );
      } else {
        throw Exception(
          'Failed to Load Plants: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error loading plants: $e');
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
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access: ${response.body}');
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
      final token = await fetchAccessToken();
      final url = AppUrl.addPlantUrl;
      final Map<String, dynamic> body = {
        "plant_code": plantCode,
        "plant_name": plantName,
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
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
          'Failed to Send Plant Data: ${response.statusCode} - ${response.body}',
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
        throw Exception('Failed to Delete Id: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error deleting plant: $e');
    }
  }
}