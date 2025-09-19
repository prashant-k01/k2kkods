import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/Iron_smith/master_data/shapes/model/shape_model.dart';
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

/// Repository for managing shape-related API operations.
///
/// Provides methods to fetch, add, edit, delete shapes, and fetch dimensions.
class ShapesRepository {
  /// Retrieves authentication headers with bearer token.
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    if (token == null || token.isEmpty) {
      print('Authentication token is missing');
      throw AuthenticationException('Authentication token is missing');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Fetches all shapes from the API.
  ///
  /// Returns a list of [Shape] objects.
  /// Throws [ApiException] on failure.
  Future<List<Shape>> fetchAllShapes() async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.shapes),
        headers: headers,
      );

      print('Fetch shapes response status: ${response.statusCode}');
      print('Fetch shapes response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = _parseJsonResponse(response.body);
        final dataList = decoded['data']?['shapes'] as List<dynamic>? ?? [];

        print('Number of shapes in response: ${dataList.length}');

        return dataList
            .asMap()
            .entries
            .map((entry) {
              try {
                return Shape.fromJson(entry.value);
              } catch (e) {
                print('Error parsing shape at index ${entry.key}: $e');
                print('Problematic data: ${entry.value}');
                return null;
              }
            })
            .whereType<Shape>()
            .toList();
      } else {
        throw ApiException(
          'Failed to load shapes: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error fetching shapes: $e');
      throw ApiException('Error fetching shapes: $e');
    }
  }

  /// Fetches a single shape by ID.
  ///
  /// [id]: The unique identifier of the shape.
  /// Returns a [Shape] object.
  /// Throws [ApiException] on failure.
  Future<Shape> fetchShapeById(String id) async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.shapeById(id)),
        headers: headers,
      );

      print(
        'ShapesRepository: Fetch shape by ID $id, status: ${response.statusCode}, body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = _parseJsonResponse(response.body);
        final shapeData = decoded['data'] as Map<String, dynamic>? ?? {};
        if (shapeData.isEmpty) {
          print('ShapesRepository: Shape data is empty for ID: $id');
          throw ApiException('No shape data returned for ID: $id');
        }
        try {
          final shape = Shape.fromJson(shapeData);
          print('ShapesRepository: Parsed shape: ${shape.toJson()}');
          return shape;
        } catch (e) {
          print('ShapesRepository: Error parsing shape for ID $id: $e');
          print('ShapesRepository: Problematic shape data: $shapeData');
          throw ApiException('Error parsing shape: $e');
        }
      } else {
        throw ApiException(
          'Failed to load shape with ID $id: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('ShapesRepository: Error fetching shape with ID $id: $e');
      throw ApiException('Error fetching shape: $e');
    }
  }

  /// Fetches all dimensions from the API.
  ///
  /// Returns a list of dimension objects with id and dimension_name.
  /// Throws [ApiException] on failure.
  Future<List<Map<String, String>>> fetchDimensions() async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.dimension),
        headers: headers,
      );

      print('Fetch dimensions response status: ${response.statusCode}');
      print('Fetch dimensions response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = _parseJsonResponse(response.body);
        final dataList = decoded['data'] as List<dynamic>? ?? [];

        return dataList.map((item) {
          return {
            'id': item['_id'] as String,
            'dimension_name': item['dimension_name'] as String,
          };
        }).toList();
      } else {
        throw ApiException(
          'Failed to load dimensions: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error fetching dimensions: $e');
      throw ApiException('Error fetching dimensions: $e');
    }
  }

  /// Adds a new shape with a binary file.
  ///
  /// [shape]: The shape to add.
  /// [imageFile]: The binary image file to upload.
  /// Throws [ApiException] on failure.
  Future<void> addShape(Shape shape, {String? imageFile}) async {
    try {
      final headers = await this.headers;
      final request = http.MultipartRequest('POST', Uri.parse(AppUrl.shapes));
      request.headers.addAll({'Authorization': headers['Authorization']!});

      // Add form fields
      request.fields['dimension'] = shape.dimension?.id ?? '';
      request.fields['description'] = shape.description ?? '';
      request.fields['shape_code'] = shape.shapeCode ?? '';

      // Add file if available
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file', imageFile));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Add shape response status: ${response.statusCode}');
      print('Add shape response body: $responseBody');

      if (response.statusCode == 201) {
        final decoded = _parseJsonResponse(responseBody);
        if (decoded['success'] != true) {
          throw ApiException('Failed to add shape: ${decoded['message']}');
        }
      } else {
        throw ApiException(
          'Failed to add shape: ${response.statusCode} - $responseBody',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error adding shape: $e');
      throw ApiException('Error adding shape: $e');
    }
  }

  /// Edits an existing shape by ID with a binary file.
  ///
  /// [id]: The unique identifier of the shape.
  /// [shape]: The updated shape data.
  /// [imageFile]: The binary image file to upload.
  /// Throws [ApiException] on failure.
  Future<void> editShape(String id, Shape shape, {String? imageFile}) async {
    try {
      final headers = await this.headers;
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(AppUrl.shapeById(id)),
      );
      request.headers.addAll({'Authorization': headers['Authorization']!});

      // Add form fields
      request.fields['dimension'] = shape.dimension?.id ?? '';
      request.fields['description'] = shape.description ?? '';
      request.fields['shape_code'] = shape.shapeCode ?? '';

      if (imageFile != null && !imageFile.startsWith('http')) {
        final file = File(imageFile);
        // Add file if available
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath('file', imageFile),
          );
        }
      }
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Edit shape response status: ${response.statusCode}');
      print('Edit shape response body: $responseBody');

      if (response.statusCode == 200) {
        final decoded = _parseJsonResponse(responseBody);
        if (decoded['success'] != true) {
          throw ApiException('Failed to edit shape: ${decoded['message']}');
        }
      } else {
        throw ApiException(
          'Failed to edit shape with ID $id: ${response.statusCode} - $responseBody',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error editing shape with ID $id: $e');
      throw ApiException('Error editing shape: $e');
    }
  }

  /// Deletes a shape by ID.
  ///
  /// [id]: The unique identifier of the shape.
  /// Throws [ApiException] on failure.
  Future<void> deleteShape(String id) async {
    try {
      final headers = await this.headers;
      final response = await http.delete(
        Uri.parse(AppUrl.deleteShapes),
        headers: headers,
        body: jsonEncode({
          "ids": [id],
        }),
      );

      print('Delete shape response status: ${response.statusCode}');
      print('Delete shape response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = _parseJsonResponse(response.body);
        if (decoded['success'] != true) {
          throw ApiException('Failed to delete shape: ${decoded['message']}');
        }
      } else {
        throw ApiException(
          'Failed to delete shape with ID $id: ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('Error deleting shape with ID $id: $e');
      throw ApiException('Error deleting shape: $e');
    }
  }

  /// Parses JSON response and handles invalid JSON.
  Map<String, dynamic> _parseJsonResponse(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid JSON response: $e');
    }
  }
}

/// Custom exception for API-related errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Custom exception for authentication-related errors.
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
