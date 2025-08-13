import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/packing/model/packing.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

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
Future<List<Map<String, dynamic>>> getPackingDetails(
  String workOrderId,
  String productId,
) async {
  try {
    final token = await fetchAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found.');
    }

    final authHeaders = await headers;
    final correctUri = Uri.parse(
      'https://k2k.kods.work/api/konkreteKlinkers/packing/get?work_order_id=$workOrderId&product_id=$productId',
    );

    print('Fetching packing details for workOrderId: $workOrderId, productId: $productId');
    print('Trying website endpoint: $correctUri');

    var response = await http
        .get(correctUri, headers: authHeaders)
        .timeout(const Duration(seconds: 30));

    print('Packing Details API Response Status: ${response.statusCode}');
    print('Packing Details API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        print('Empty packing details response body');
        return [];
      }

      final jsonData = json.decode(responseBody);
      print('Parsed Packing Details JSON: $jsonData');

      List<dynamic> rawList = jsonData['data'] ?? [];
      List<Map<String, dynamic>> allPackings = [];

      // Iterate through all items in the data array
      for (var item in rawList) {
        if (item is Map<String, dynamic>) {
          print('Processing item with work_order_id: ${item['work_order_id']}');

          // Check if this item matches the work order
          bool workOrderMatches = item['work_order_id'] == workOrderId;
          print('Work order matches: $workOrderMatches');

          if (workOrderMatches && item['packing_details'] != null) {
            // Extract packing_details array
            List<dynamic> packingsList = item['packing_details'];
            print('Found packing_details array with ${packingsList.length} items');

            // Add all packings from this item with enhanced data
            for (var packing in packingsList) {
              if (packing is Map<String, dynamic>) {
                // Create enhanced packing object with all required fields
                Map<String, dynamic> enhancedPacking = Map<String, dynamic>.from(packing);

                // Add missing fields from parent object
                enhancedPacking['work_order_number'] =
                    packing['work_order_number'] ?? item['work_order_name'] ?? 'N/A';
                enhancedPacking['client_name'] =
                    packing['client_name'] ?? item['client_project']?['client_name'] ?? 'N/A';
                enhancedPacking['project_name'] =
                    packing['project_name'] ?? item['client_project']?['project_name'] ?? 'N/A';
                enhancedPacking['job_order_name'] =
                    packing['job_order_name'] ?? item['job_order_name'] ?? 'N/A';
                enhancedPacking['uom'] = packing['uom'] ?? item['uom'] ?? 'N/A';
                enhancedPacking['status'] = packing['status'] ?? item['status'] ?? 'N/A';
                enhancedPacking['qr_code_id'] = packing['qr_id'] ?? 'N/A';
                enhancedPacking['qr_code'] = packing['qr_code'] ?? 'N/A';

                print('Adding enhanced packing with ID: ${enhancedPacking['packing_id']}');
                print('Enhanced packing data: $enhancedPacking');
                allPackings.add(enhancedPacking);
              }
            }
          }
        }
      }

      print('Total collected packings: ${allPackings.length}');
      print('Collected packings IDs: ${allPackings.map((p) => p['packing_id']).toList()}');
      return allPackings;
    } else {
      print('Failed to load packing details - Status: ${response.statusCode}');
      throw Exception('Failed to load packing details: ${response.statusCode}');
    }
  } on SocketException {
    print('No internet connection while fetching packing details');
    throw Exception('No internet connection.');
  } catch (e) {
    print('Error in getPackingDetails: $e');
    rethrow;
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

      print('Fetching bundle size for productId: $productId');
      print('Bundle size request URI: $uri');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Bundle Size API Response Status: ${response.statusCode}');
      print('Bundle Size API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty response body for bundle size');
          return null;
        }

        final jsonData = json.decode(responseBody);
        print('Parsed Bundle Size JSON: $jsonData');

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
      print('Error in getBundleSize: $e');
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

      print('Creating packing with data: $packingData');
      print('Create packing request URI: $uri');

      final response = await http
          .post(uri, headers: authHeaders, body: json.encode(packingData))
          .timeout(const Duration(seconds: 30));

      print('Create Packing API Response Status: ${response.statusCode}');
      print('Create Packing API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('Empty response body');
        }

        final jsonData = json.decode(responseBody);
        print('Parsed Create Packing JSON: $jsonData');

        final data = jsonData['data'];
        if (data == null) {
          throw Exception('No data found in response');
        }

        final packing = PackingModel.fromJson(data is List ? data[0] : data);

        print('Created Packing ID: ${packing.id}');
        print('Created By: ${packing.createdBy}');
        print('Created At: ${packing.createdAt.toIso8601String()}');

        return packing;
      } else {
        final jsonData = json.decode(response.body);
        print('Error Response JSON: $jsonData');
        throw Exception(
          'Failed to create packing: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      print('No internet connection while creating packing');
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in createPacking: $e');
      rethrow;
    }
  }

  Future<void> submitQrCode(String packingId, String qrCode) async {
    try {
      final token = await fetchAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getpackingqr);

      final body = json.encode({
        'packings': [
          {
            'packing_id': packingId,
            'qrCodeId': qrCode,
          },
        ],
      });

      print('Submitting QR code with data: $body');
      print('QR code request URI: $uri');

      final response = await http
          .post(uri, headers: authHeaders, body: body)
          .timeout(const Duration(seconds: 30));

      print('QR Code API Response Status: ${response.statusCode}');
      print('QR Code API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        print('Parsed QR Code JSON: $jsonData');
      } else {
        final jsonData = json.decode(response.body);
        throw Exception(
          'Failed to submit QR code: ${response.statusCode} - ${jsonData['errors']?.toString() ?? response.reasonPhrase}',
        );
      }
    } on SocketException {
      print('No internet connection while submitting QR code');
      throw Exception('No internet connection.');
    } catch (e) {
      print('Error in submitQrCode: $e');
      rethrow;
    }
  }

  Future<bool> deletePacking(
    String packingId, {
    String? workOrderId,
    String? productId,
  }) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deletePacking;

      final body = jsonEncode({
        "work_order_number": workOrderId ?? "",
        "product_number": productId ?? "",
      });

      print('Sending DELETE to $deleteUrl');
      print('Request Body: $body');

      final response = await http
          .delete(Uri.parse(deleteUrl), headers: authHeaders, body: body)
          .timeout(const Duration(seconds: 30));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('Packing deleted: $packingId');
          return true;
        } else {
          print('Delete operation not successful: ${response.body}');
          throw Exception('Delete operation not successful: ${response.body}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        print('Failed to delete packing: ${response.statusCode} - $errorMessage');
        throw Exception('Failed to delete packing: $errorMessage');
      }
    } on SocketException catch (e) {
      print('No internet connection: $e');
      throw Exception('No internet connection. Please try again.');
    } catch (e) {
      print('Error deleting packing: $e');
      throw Exception('Error deleting packing: $e');
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

      print('Fetching products for workOrderId: $workOrderId');
      print('Products request URI: $uri');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Products API Response Status: ${response.statusCode}');
      print('Products API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          print('Empty products response body');
          return [];
        }

        final jsonData = json.decode(responseBody);
        print('Parsed Products JSON: $jsonData');

        List<dynamic> rawList = jsonData['data'] ?? [];
        print('Raw products list: $rawList');
        print('Raw list length: ${rawList.length}');

        final products = <Map<String, String>>[];

        for (int i = 0; i < rawList.length; i++) {
          final item = rawList[i];
          print('Processing product item $i: $item');
          print('Item type: ${item.runtimeType}');

          if (item is Map<String, dynamic>) {
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

            print('Extracted - ID: "$id", Name: "$name"');

            if (id.isNotEmpty && name.isNotEmpty) {
              products.add({'id': id, 'name': name});
              print('Added product: {id: $id, name: $name}');
            } else {
              print('Skipped product due to empty ID or name');
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