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

  Future<ProductResponse> getAllProduct({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.fetchproductDetailsUrl).replace(
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
          return ProductResponse.fromJson(jsonData);
        } else {
          throw Exception(
            'Unexpected response structure: ${jsonData.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'Failed to load Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error loading Product: $e');
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.fetchProjectDetailsUrl}/$productId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Raw Product Response: ${response.body}');

      if (response.statusCode == 200) {
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
      throw Exception('No internet connection: $e');
    } catch (e) {
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

      final response = await http
          .post(Uri.parse(url), headers: authHeaders, body: json.encode(body))
          .timeout(const Duration(seconds: 30));

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
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error creating Product: $e');
    } finally {
      isAddProductLoading = false;
    }
  }

  Future<bool> updateProduct(
    String productId,
    String productCode,
    String productName,
  ) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updateProjectDetailsUrl}/$productId';

      final Map<String, dynamic> body = {
        "product_code": productCode,
        "product_name": productName,
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
          'Failed to update Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Unexpected error updating Product: $e');
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteproductDetailsUrl;

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: jsonEncode({
              "ids": [productId],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete Product: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Unexpected error deleting Product: $e');
    }
  }
}
