import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/common/constant/app_url.dart'; // Ensure this has the inventory URL constants
import 'package:k2k/core/shared_preference/shared_preference.dart';
import 'package:k2k/konkrete_klinkers/inventory/model/inventory.dart';
import 'package:k2k/konkrete_klinkers/inventory/model/inventory_detail.dart';

class InventoryRepository {
  Future<Map<String, String>> get headers async {
    final token = await SessionManager.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<InventoryItem>> getInventory({String? search}) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.getinventory).replace();

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> inventoryJson;

        // Handle various response structures similarly to PlantRepository
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              inventoryJson = data;
            } else if (data is Map<String, dynamic>) {
              inventoryJson = data['inventory'] ?? data['items'] ?? [];
            } else {
              throw Exception('Unexpected data structure: ${data.runtimeType}');
            }
          } else if (jsonData.containsKey('inventory')) {
            inventoryJson = jsonData['inventory'] ?? [];
          } else {
            throw Exception('Response missing expected keys: $jsonData');
          }
        } else if (jsonData is List) {
          inventoryJson = jsonData;
        } else {
          throw Exception('Unexpected response type: ${jsonData.runtimeType}');
        }

        final inventoryItems = inventoryJson
            .whereType<Map<String, dynamic>>()
            .map((invJson) => InventoryItem.fromJson(invJson))
            .toList();

        return inventoryItems;
      } else {
        throw Exception(
          'Failed to load inventory: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: $e');
    } catch (e) {
      rethrow;
    }
  }

  Future<InventoryDetailResponse> getProductDetails(String productId) async {
    final authHeaders = await headers;
    final uri = Uri.parse("${AppUrl.getinventoriesbyid}$productId");

    try {
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['product_details'] != null) {
          return InventoryDetailResponse.fromJson(data);
        } else {
          throw Exception('Invalid data received');
        }
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: $e');
    } catch (e) {
      rethrow;
    }
  }
}
