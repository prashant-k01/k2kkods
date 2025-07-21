import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/model/clients_model.dart';
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

class PaginatedClientsResponse {
  final List<ClientsModel> clients;
  final PaginationInfo pagination;

  PaginatedClientsResponse({required this.clients, required this.pagination});
}

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

  // Updated method to support pagination
  Future<PaginatedClientsResponse> getAllClients({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;

      // Build URL with pagination parameters
      final uri = Uri.parse(AppUrl.fetchClientDetailsUrl).replace(
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
          return PaginatedClientsResponse(
            clients: [],
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
        List<dynamic> clientsJson = [];
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

          // Extract clients data
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              clientsJson = data;
            } else if (data is Map && data.containsKey('clients')) {
              clientsJson = data['clients'] is List ? data['clients'] : [];
            } else if (data is Map) {
              clientsJson = [data];
            }
          } else if (jsonData.containsKey('clients')) {
            final clients = jsonData['clients'];
            clientsJson = clients is List ? clients : [clients];
          } else if (jsonData.containsKey('result')) {
            final result = jsonData['result'];
            clientsJson = result is List ? result : [result];
          } else if (jsonData.containsKey('items')) {
            final items = jsonData['items'];
            clientsJson = items is List ? items : [items];
          } else {
            // Check if it's a single client object
            if (jsonData.containsKey('address') ||
                jsonData.containsKey('name') ||
                jsonData.containsKey('_id') ||
                jsonData.containsKey('id')) {
              clientsJson = [jsonData];
            }
          }
        } else if (jsonData is List) {
          clientsJson = jsonData;
          paginationInfo = PaginationInfo(
            total: clientsJson.length,
            page: page,
            limit: limit,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          );
        } else {
          throw Exception(
            'Unexpected response structure: ${jsonData.runtimeType}',
          );
        }

        // Parse clients
        final List<ClientsModel> clients = [];
        for (final clientJson in clientsJson) {
          try {
            if (clientJson is Map<String, dynamic>) {
              final client = ClientsModel.fromJson(clientJson);
              clients.add(client);
            }
          } catch (e) {
            print('Error parsing client: $e');
            // Skip malformed entry
          }
        }

        return PaginatedClientsResponse(
          clients: clients,
          pagination: paginationInfo,
        );
      } else {
        throw Exception(
          'Failed to Load clients: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error loading clients: $e');
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
        final clientsData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        return ClientsModel.fromJson(clientsData);
      } else if (response.statusCode == 404) {
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access: ${response.body}');
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
      final token = await fetchAccessToken();
      final url = AppUrl.createClientUrl;
      final Map<String, dynamic> body = {"name": name, "address": address};

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
        final clientsData = (responseData is Map<String, dynamic>)
            ? responseData['data'] ?? responseData
            : responseData;

        final createdClient = ClientsModel.fromJson(clientsData);
        _lastCreatedClient = createdClient;
        return createdClient;
      } else {
        throw Exception(
          'Failed to send client data: ${response.statusCode} - ${response.body}',
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
    String address,
    String name,
  ) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updateClientDetailsUrl}/$clientsId';

      final Map<String, dynamic> body = {"address": address, "name": name};

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
        throw Exception('Failed to delete Id: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error deleting client: $e');
    }
  }
}
