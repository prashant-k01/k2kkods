import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/packing/model/packing.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class PackingRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<PackingModel>> getPackings() async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getpacking);

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) return [];

        final jsonData = json.decode(responseBody);
        List<dynamic> rawList = jsonData['data'] ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(PackingModel.fromJson)
            .toList();
      } else {
        throw Exception('Failed to load packings: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    }
  }

  Future<List<Map<String, String>>> getWorkOrders() async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.fetchWorkOrderDetailsUrl);

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) return [];

        final jsonData = json.decode(responseBody);
        List<dynamic> rawList = jsonData['data'] ?? [];
        return rawList
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => {
                'id': item['_id'] as String? ?? '',
                'number': item['work_order_number'] as String? ?? '',
              },
            )
            .toList();
      } else {
        throw Exception('Failed to load work orders: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    }
  }

  Future<int?> getBundleSize(String productId) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(
        '${AppUrl.baseUrl}/konkreteKlinkers/packing/bundlesize?product_id=$productId',
      );

      print('Fetching bundle size for productId: $productId'); // Debug log
      print('Bundle size request URI: $uri'); // Debug log

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print(
        'Bundle Size API Response Status: ${response.statusCode}',
      ); // Debug log
      print('Bundle Size API Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty response body for bundle size'); // Debug log
          return null;
        }

        final jsonData = json.decode(responseBody);
        print('Parsed Bundle Size JSON: $jsonData'); // Debug log

        // More robust handling of the response
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data') && jsonData['data'] != null) {
            final data = jsonData['data'];
            if (data is Map<String, dynamic> &&
                data.containsKey('qty_in_bundle')) {
              final qtyInBundle = data['qty_in_bundle'];
              print(
                'Found qty_in_bundle: $qtyInBundle (type: ${qtyInBundle.runtimeType})',
              );

              if (qtyInBundle is int) {
                return qtyInBundle;
              } else if (qtyInBundle is String) {
                final parsed = int.tryParse(qtyInBundle);
                print('Parsed string to int: $parsed');
                return parsed;
              } else if (qtyInBundle is double) {
                return qtyInBundle.toInt();
              }
            }
          }
        }

        print('Could not extract qty_in_bundle from response');
        return null;
      } else {
        print('Failed to load bundle size - Status: ${response.statusCode}');
        throw Exception('Failed to load bundle size: ${response.statusCode}');
      }
    } on SocketException {
      print('No internet connection while fetching bundle size');
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in getBundleSize: $e'); // Debug log
      rethrow;
    }
  }
  Future<PackingModel> createPacking(Map<String, dynamic> packingData) async {
  try {
    final token = await fetchAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    final authHeaders = await headers;
    final uri = Uri.parse(AppUrl.createPacking);

    print('Creating packing with data: $packingData'); // Debug log
    print('Create packing request URI: $uri'); // Debug log

    final response = await http
        .post(
          uri,
          headers: authHeaders,
          body: json.encode(packingData),
        )
        .timeout(const Duration(seconds: 30));

    print('Create Packing API Response Status: ${response.statusCode}'); // Debug log
    print('Create Packing API Response Body: ${response.body}'); // Debug log

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        throw Exception('Empty response body');
      }

      final jsonData = json.decode(responseBody);
      print('Parsed Create Packing JSON: $jsonData'); // Debug log

      // Check if the response contains a 'data' field
      final data = jsonData['data'];
      if (data == null) {
        throw Exception('No data found in response');
      }

      // If the API returns a single packing object
      final packing = PackingModel.fromJson(data is List ? data[0] : data);

      // Log required fields
      print('Created Packing ID: ${packing.id}');
      print('Created By: ${packing.createdBy}');
      print('Created At: ${packing.createdAt.toIso8601String()}');

      return packing;
    } else {
      final jsonData = json.decode(response.body);
      print('Error Response JSON: $jsonData'); // Debug log
      throw Exception('Failed to create packing: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}');
    }
  } on SocketException {
    print('No internet connection while creating packing');
    throw Exception('No internet connection.');
  } catch (e) {
    print('Error in createPacking: $e');
    rethrow;
  }
}

  Future<List<Map<String, String>>> getProducts(String workOrderId) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.getproductsbyworkOrder}$workOrderId');

      print('Fetching products for workOrderId: $workOrderId'); // Debug log
      print('Products request URI: $uri'); // Debug log

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print(
        'Products API Response Status: ${response.statusCode}',
      ); // Debug log
      print('Products API Response Body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty products response body');
          return [];
        }

        final jsonData = json.decode(responseBody);
        print('Parsed Products JSON: $jsonData'); // Debug log

        List<dynamic> rawList = jsonData['data'] ?? [];
        print('Raw products list: $rawList'); // Debug log
        print('Raw list length: ${rawList.length}'); // Debug log

        final products = <Map<String, String>>[];

        for (int i = 0; i < rawList.length; i++) {
          final item = rawList[i];
          print('Processing product item $i: $item'); // Debug log
          print('Item type: ${item.runtimeType}'); // Debug log

          if (item is Map<String, dynamic>) {
            // Try different possible field names for ID
            String id = '';
            if (item.containsKey('_id') && item['_id'] != null) {
              id = item['_id'].toString();
            } else if (item.containsKey('id') && item['id'] != null) {
              id = item['id'].toString();
            } else if (item.containsKey('product_id') &&
                item['product_id'] != null) {
              id = item['product_id'].toString();
            } else if (item.containsKey('productId') &&
                item['productId'] != null) {
              id = item['productId'].toString();
            }

            // Try different possible field names for name/code
            String name = '';
            if (item.containsKey('material_code') &&
                item['material_code'] != null) {
              name = item['material_code'].toString();
            } else if (item.containsKey('name') && item['name'] != null) {
              name = item['name'].toString();
            } else if (item.containsKey('product_name') &&
                item['product_name'] != null) {
              name = item['product_name'].toString();
            } else if (item.containsKey('code') && item['code'] != null) {
              name = item['code'].toString();
            }

            print('Extracted - ID: "$id", Name: "$name"'); // Debug log

            if (id.isNotEmpty && name.isNotEmpty) {
              products.add({'id': id, 'name': name});
              print('Added product: {id: $id, name: $name}'); // Debug log
            } else {
              print('Skipped product due to empty ID or name'); // Debug log
            }
          } else {
            print('Item is not a Map<String, dynamic>: ${item.runtimeType}');
          }
        }

        print('Final products list: $products');
        print('Final products list length: ${products.length}');

        return products;
      } else {
        print('Failed to load products - Status: ${response.statusCode}');
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } on SocketException {
      print('No internet connection while fetching products');
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in getProducts: $e');
      rethrow;
    }
  }
}
