import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/model/product.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class ProductRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool isAddProductLoading = false;
  ProductModel? _lastCreatedProduct;
  ProductModel? get lastCreatedProduct => _lastCreatedProduct;

  Future<ProductResponse> getAllProduct({String? search}) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.fetchproductDetailsUrl).replace(
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      print('Making request to: $uri');
      
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 120)); // Increased timeout

      print('API Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Length: ${response.body.length}');
      
      // Only print first 500 characters to avoid truncation in logs
      if (response.body.length > 500) {
        print('Response Preview (first 500 chars): ${response.body.substring(0, 500)}...');
      } else {
        print('Full Response: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          // Check if response is complete JSON
          final trimmedBody = response.body.trim();
          if (!trimmedBody.endsWith('}') && !trimmedBody.endsWith(']')) {
            print('Warning: Response may be truncated - last 50 chars: ${trimmedBody.substring(trimmedBody.length - 50)}');
            // Continue parsing anyway as it might just be a logging issue
          }

          final jsonData = json.decode(response.body);
          
          if (jsonData is Map<String, dynamic>) {
            print('Successfully parsed JSON with ${jsonData.keys.length} keys');
            
            // Check if data field exists and is a list
            if (jsonData.containsKey('data') && jsonData['data'] is List) {
              final dataList = jsonData['data'] as List;
              print('Found ${dataList.length} products in response');
            }
            
            return ProductResponse.fromJson(jsonData);
          } else {
            throw Exception(
              'Unexpected response structure: ${jsonData.runtimeType}',
            );
          }
        } on FormatException catch (e) {
          print('JSON Parsing Error: $e');
          print('Response body length: ${response.body.length}');
          print('Last 100 characters: ${response.body.substring(response.body.length - 100)}');
          throw Exception('Invalid JSON format - response may be truncated: $e');
        }
      } else {
        print('HTTP Error - Status: ${response.statusCode}');
        print('Error Response: ${response.body}');
        throw Exception(
          'Failed to load Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('Network Error: $e');
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw Exception('Response parsing error: $e');
    } catch (e) {
      print('Unexpected Error: $e');
      throw Exception('Unexpected error loading Product: $e');
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.fetchproductDetailsUrl}/$productId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 60)); // Increased timeout

      print('Single Product Response Status: ${response.statusCode}');
      print('Single Product Response Length: ${response.body.length}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check for truncated response
        if (!response.body.trim().endsWith('}') && !response.body.trim().endsWith(']')) {
          throw FormatException('Single product response appears to be truncated');
        }

        final jsonData = json.decode(response.body);
        final productData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        return ProductModel.fromJson(productData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('Network Error in getProduct: $e');
      throw Exception('No internet connection: $e');
    } on FormatException catch (e) {
      print('JSON Error in getProduct: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('Error in getProduct: $e');
      throw Exception('Unexpected error loading Product: $e');
    }
  }

  Future<ProductModel> createProduct({
    required String plantId,
    required String materialCode,
    required String description,
    required List<String> uom,
    required Map<String, double> areas,
    required int noOfPiecesPerPunch,
    required int qtyInBundle,
  }) async {
    isAddProductLoading = true;
    try {
      final authHeaders = await headers;
      final url = AppUrl.createproductUrl;
      final Map<String, dynamic> body = {
        "plant": plantId,
        "material_code": materialCode,
        "description": description,
        "uom": uom,
        "areas": areas,
        "no_of_pieces_per_punch": noOfPiecesPerPunch,
        "qty_in_bundle": qtyInBundle,
      };

      print('Creating product with body: ${json.encode(body)}');

      final response = await http
          .post(Uri.parse(url), headers: authHeaders, body: json.encode(body))
          .timeout(const Duration(seconds: 60)); // Increased timeout

      print('Create Product Response Status: ${response.statusCode}');
      print('Create Product Response: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final productData = (responseData is Map<String, dynamic>)
            ? responseData['data'] ?? responseData
            : responseData;

        final createdProduct = ProductModel.fromJson(productData);
        _lastCreatedProduct = createdProduct;
        return createdProduct;
      } else {
        throw Exception(
          'Failed to create Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('Network Error in createProduct: $e');
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      print('HTTP Error in createProduct: $e');
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      print('JSON Error in createProduct: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('Error in createProduct: $e');
      throw Exception('Unexpected error creating Product: $e');
    } finally {
      isAddProductLoading = false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
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
      final updateUrl = '${AppUrl.updateproductDetailsUrl}/$productId';

      final Map<String, dynamic> body = {
        "plant": plantId,
        "material_code": materialCode,
        "description": description,
        "uom": uom,
        "areas": areas,
        "no_of_pieces_per_punch": noOfPiecesPerPunch,
        "qty_in_bundle": qtyInBundle,
      };

      print('Updating product $productId with body: ${json.encode(body)}');

      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: authHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 60)); // Increased timeout

      print('Update Product Response Status: ${response.statusCode}');
      print('Update Product Response: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('Network Error in updateProduct: $e');
      throw Exception('No internet connection: $e');
    } catch (e) {
      print('Error in updateProduct: $e');
      throw Exception('Unexpected error updating Product: $e');
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteproductDetailsUrl;

      final body = jsonEncode({
        "ids": [productId],
      });

      print('Deleting product with body: $body');

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: body,
          )
          .timeout(const Duration(seconds: 60)); // Increased timeout

      print('Delete Product Response Status: ${response.statusCode}');
      print('Delete Product Response: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      print('Network Error in deleteProduct: $e');
      throw Exception('No internet connection: $e');
    } catch (e) {
      print('Error in deleteProduct: $e');
      throw Exception('Unexpected error deleting Product: $e');
    }
  }
}