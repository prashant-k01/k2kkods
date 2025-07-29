import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/model/clients_model.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class ClientRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool isAddClientsLoading = false;
  ClientsModel? _lastCreatedClient;
  ClientsModel? get lastCreatedClient => _lastCreatedClient;

  Future<List<ClientsModel>> getAllClients({
    required int skip,
    required int limit,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;
      print('Headers: $authHeaders'); // Debug
      final uri = Uri.parse(AppUrl.fetchClientDetailsUrl).replace(
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
        List<dynamic> clientsJson;

        // Handle various response structures
        if (jsonData is Map<String, dynamic>) {
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              clientsJson = data;
            } else if (data is Map<String, dynamic>) {
              clientsJson = data['clients'] ?? data['items'] ?? [];
            } else {
              throw Exception('Unexpected data structure: ${data.runtimeType}');
            }
          } else if (jsonData.containsKey('clients')) {
            clientsJson = jsonData['clients'] ?? [];
          } else {
            throw Exception('Response missing expected keys: $jsonData');
          }
        } else if (jsonData is List) {
          clientsJson = jsonData;
        } else {
          throw Exception('Unexpected response type: ${jsonData.runtimeType}');
        }

        final clients = clientsJson
            .where((item) => item is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .map((clientJson) {
              print('Parsing client: $clientJson'); // Debug
              try {
                return ClientsModel.fromJson(clientJson);
              } catch (e) {
                print('Error parsing client: $e, JSON: $clientJson');
                rethrow;
              }
            })
            .toList();

        print('Parsed clients: ${clients.length}'); // Debug
        return clients;
      } else {
        throw Exception('Failed to load clients: ${response.statusCode} - ${response.body}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: $e');
    } catch (e) {
      print('Error in getAllClients: $e'); // Debug
      rethrow;
    }
  }

  Future<ClientsModel?> getClients(String clientsId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.fetchClientDetailsUrl}/$clientsId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final clientData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        return ClientsModel.fromJson(clientData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load client: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error loading client: $e');
    }
  }

  Future<ClientsModel> createClient(String name, String address) async {
    isAddClientsLoading = true;
    try {
      final authHeaders = await headers;
      final url = AppUrl.createClientUrl;
      final Map<String, dynamic> body = {"name": name, "address": address};

      final response = await http
          .post(
            Uri.parse(url),
            headers: authHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final clientData = (responseData is Map<String, dynamic>)
            ? responseData['data'] ?? responseData
            : responseData;

        final createdClient = ClientsModel.fromJson(clientData);
        _lastCreatedClient = createdClient;
        return createdClient;
      } else {
        throw Exception(
          'Failed to create client: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error creating client: $e');
    } finally {
      isAddClientsLoading = false;
    }
  }

  Future<bool> updateClient(
    String clientsId,
    String name,
    String address,
  ) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updateClientDetailsUrl}/$clientsId';

      final Map<String, dynamic> body = {"name": name, "address": address};

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
          'Failed to update client: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error updating client: $e');
    }
  }

  Future<bool> deleteClient(String clientsId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteClientDetailsUrl;

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: jsonEncode({
              "ids": [clientsId],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete client: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error deleting client: $e');
    }
  }
}