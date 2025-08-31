import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k2k/Iron_smith/master_data/clients/model/is_client_model.dart';
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

class ClientsRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    if (token == null || token.isEmpty) {
      print('Authentication token is missing');
      throw Exception('Authentication token is missing');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<List<IsClient>> fetchClients() async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.getAllClients),
        headers: headers,
      );

      print('fetchClients - Response status: ${response.statusCode}');
      print('fetchClients - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data']?['clients'] ?? [];

        print(
          'fetchClients - Number of clients in response: ${dataList.length}',
        );

        List<IsClient> clients = [];
        for (int i = 0; i < dataList.length; i++) {
          try {
            final client = IsClient.fromJson(dataList[i]);
            clients.add(client);
          } catch (e) {
            print('fetchClients - Error parsing client at index $i: $e');
            print('fetchClients - Problematic data: ${dataList[i]}');
            continue;
          }
        }

        return clients;
      } else {
        throw Exception(
          'Failed to load clients: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('fetchClients - Error: $e');
      throw Exception('Error fetching clients: $e');
    }
  }

  Future<IsClient> getClientById(String id) async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.getClientById(id)),
        headers: headers,
      );

      print('getClientById - Response status: ${response.statusCode}');
      print('getClientById - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final clientData = decoded['data'] ?? decoded;
        return IsClient.fromJson(clientData);
      } else {
        throw Exception(
          'Failed to load client by ID: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('getClientById - Error: $e');
      throw Exception('Error fetching client by ID: $e');
    }
  }

  Future<void> updateClient(
    String clientId,
    String clientName,
    String clientAddress,
  ) async {
    try {
      final headers = await this.headers;
      final payload = {'name': clientName, 'address': clientAddress};
      print('updateClient - Sending payload: $payload');

      final response = await http.put(
        Uri.parse(AppUrl.getClientById(clientId)),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('updateClient - Response status: ${response.statusCode}');
      print('updateClient - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to update client: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to update client: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('updateClient - Error: $e');
      throw Exception('Error updating client: $e');
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      final headers = await this.headers;
      final payload = {
        'ids': [id],
      };
      print('deleteClient - Sending payload: $payload');

      final response = await http.delete(
        Uri.parse(AppUrl.deleteIsClient),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('deleteClient - Response status: ${response.statusCode}');
      print('deleteClient - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to delete client: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to delete client: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('deleteClient - Error: $e');
      throw Exception('Error deleting client: $e');
    }
  }

  Future<void> addClient(IsClient client) async {
    try {
      final headers = await this.headers;
      final payload = {'name': client.name, 'address': client.address};
      print('addClient - Sending payload: $payload');

      final response = await http.post(
        Uri.parse(AppUrl.getAllClients),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('addClient - Response status: ${response.statusCode}');
      print('addClient - Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to add client: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to add client: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('addClient - Error: $e');
      throw Exception('Error adding client: $e');
    }
  }
}
