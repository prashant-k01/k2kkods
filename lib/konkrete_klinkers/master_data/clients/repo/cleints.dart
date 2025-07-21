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

  Future<PaginatedClientsResponse> getAllClients({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;
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
        final jsonData = json.decode(response.body);
        List<dynamic> clientsJson = [];
        PaginationInfo paginationInfo;

        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final data = jsonData['data'];
          paginationInfo = PaginationInfo.fromJson(data['pagination'] ?? {});
          clientsJson = (data['clients'] as List?) ?? [];
        } else {
          throw Exception('Unexpected response structure: ${jsonData.runtimeType}');
        }

        final clients = clientsJson
            .whereType<Map<String, dynamic>>()
            .map((clientJson) => ClientsModel.fromJson(clientJson))
            .toList();

        return PaginatedClientsResponse(
          clients: clients,
          pagination: paginationInfo,
        );
      } else {
        throw Exception(
          'Failed to load clients: ${response.statusCode} - ${response.body}',
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