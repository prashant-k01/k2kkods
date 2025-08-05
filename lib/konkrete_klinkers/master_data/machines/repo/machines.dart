import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class MachineRepository {
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

  bool isAddmachinesLoading = false;
  MachineElement? _lastCreatedMachine;
  MachineElement? get lastCreatedMachine => _lastCreatedMachine;

  Future<MachinesResponse> getAllmachines({
    int limit = 10,
    String? search,
    int skip = 0,
  }) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.fetchMachineDetailsUrl).replace(
        queryParameters: {
          'limit': limit.toString(),
          'skip': skip.toString(),
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      print('Fetching machines: $uri');
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final machine = machineFromJson(response.body);
        if (machine.success) {
          if (machine.data.length > limit) {
            print(
              'Warning: Received ${machine.data.length} machines, expected up to $limit',
            );
          }
          final activeMachines = machine.data
              .where((m) => !m.isDeleted)
              .toList();
          return MachinesResponse(machines: activeMachines);
        } else {
          print('No machines found in response or success is false');
          return MachinesResponse(machines: []);
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        print(
          'Failed to load machines: ${response.statusCode} - $errorMessage',
        );
        throw Exception('Failed to load machines: $errorMessage');
      }
    } on SocketException catch (e) {
      print('No internet connection: $e');
      throw Exception('No internet connection. Please try again.');
    } on HttpException catch (e) {
      print('Network error occurred: $e');
      throw Exception('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Invalid response format: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('Error loading machines: $e');
      throw Exception('Error loading machines: $e');
    }
  }

  Future<MachineElement?> getmachines(String machinesId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.fetchMachineDetailsUrl}/$machinesId');

      print('Fetching machine: $uri');
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final machine = MachineElement.fromJson(responseData['data']);
          if (machine.isDeleted) {
            print('Machine is deleted: $machinesId');
            return null;
          }
          print('Parsed Machine: ${machine.name} (${machine.id})');
          return machine;
        } else {
          print('No machine data found in response or success is false');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('Machine not found (404)');
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        print('Failed to load machine: ${response.statusCode} - $errorMessage');
        throw Exception('Failed to load machine: $errorMessage');
      }
    } on SocketException catch (e) {
      print('No internet connection: $e');
      throw Exception('No internet connection. Please try again.');
    } catch (e) {
      print('Error loading machine: $e');
      throw Exception('Error loading machine: $e');
    }
  }

  Future<MachineElement> createMachine(
    String machineName,
    String plantId,
  ) async {
    isAddmachinesLoading = true;

    try {
      final authHeaders = await headers;
      final url = AppUrl.createMachineUrl;
      final Map<String, dynamic> body = {
        "name": machineName,
        "plant_id": plantId,
      };

      print('Sending POST to $url');
      print('Request Headers: $authHeaders');
      print('Request Body: $body');

      final response = await http
          .post(Uri.parse(url), headers: authHeaders, body: json.encode(body))
          .timeout(const Duration(seconds: 30));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final machine = MachineElement.fromJson(responseData['data']);
          print('Created Machine: ${machine.id} - ${machine.name}');
          _lastCreatedMachine = machine;
          return machine;
        } else {
          print('Invalid response format: ${response.body}');
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        print(
          'Failed to create machine: ${response.statusCode} - $errorMessage',
        );
        throw Exception('Failed to create machine: $errorMessage');
      }
    } on SocketException catch (e) {
      print('No internet connection: $e');
      throw Exception('No internet connection. Please try again.');
    } on HttpException catch (e) {
      print('Network error occurred: $e');
      throw Exception('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Invalid response format: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    } finally {
      isAddmachinesLoading = false;
      print('isAddmachinesLoading set to false');
    }
  }

  Future<MachineElement> updateMachine(
    String machinesId,
    String machineName,
    String plantId,
  ) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updateMachineDetailsUrl}/$machinesId';
      final Map<String, dynamic> body = {
        "name": machineName,
        "plant_id": plantId,
      };

      print('Sending PUT to $updateUrl');
      print('Request Body: $body');

      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: authHeaders,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final machine = MachineElement.fromJson(responseData['data']);
          print('Updated Machine: ${machine.id} - ${machine.name}');
          return machine;
        } else {
          print('Invalid response format: ${response.body}');
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        print(
          'Failed to update machine: ${response.statusCode} - $errorMessage',
        );
        throw Exception('Failed to update machine: $errorMessage');
      }
    } on SocketException catch (e) {
      print('No internet connection: $e');
      throw Exception('No internet connection. Please try again.');
    } on HttpException catch (e) {
      print('Network error occurred: $e');
      throw Exception('Network error occurred. Please try again.');
    } on FormatException catch (e) {
      print('Invalid response format: $e');
      throw Exception('Invalid response format: $e');
    } catch (e) {
      print('Error updating machine: $e');
      throw Exception('Error updating machine: $e');
    }
  }

  Future<bool> deleteMachine(String machinesId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteMachineDetailsUrl;
      final body = jsonEncode({
        "ids": [machinesId],
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
          print('Machine deleted: $machinesId');
          return true;
        } else {
          print('Delete operation not successful: ${response.body}');
          throw Exception('Delete operation not successful: ${response.body}');
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        print(
          'Failed to delete machine: ${response.statusCode} - $errorMessage',
        );
        throw Exception('Failed to delete machine: $errorMessage');
      }
    } on SocketException catch (e) {
      print('No internet connection: $e');
      throw Exception('No internet connection. Please try again.');
    } catch (e) {
      print('Error deleting machine: $e');
      throw Exception('Error deleting machine: $e');
    }
  }
}

class MachinesResponse {
  final List<MachineElement> machines;

  MachinesResponse({required this.machines});
}
