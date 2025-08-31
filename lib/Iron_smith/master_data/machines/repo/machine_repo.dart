import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k2k/Iron_smith/master_data/machines/model/machines.dart';
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

class MachinesRepository {
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

  Future<List<Machines>> fetchMachines() async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.getIsMachines),
        headers: headers,
      );

      print('fetchMachines - Response status: ${response.statusCode}');
      print('fetchMachines - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? [];

        print(
          'fetchMachines - Number of machines in response: ${dataList.length}',
        );

        List<Machines> machines = [];
        for (int i = 0; i < dataList.length; i++) {
          try {
            final machine = Machines.fromJson(dataList[i]);
            machines.add(machine);
          } catch (e) {
            print('fetchMachines - Error parsing machine at index $i: $e');
            print('fetchMachines - Problematic data: ${dataList[i]}');
            continue;
          }
        }

        return machines;
      } else {
        throw Exception(
          'Failed to load machines: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('fetchMachines - Error: $e');
      throw Exception('Error fetching machines: $e');
    }
  }

  Future<Machines> getMachineById(String id) async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.getIsMachineById(id)),
        headers: headers,
      );

      print('getMachineById - Response status: ${response.statusCode}');
      print('getMachineById - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final machineData = decoded['data'] ?? decoded;
        return Machines.fromJson(machineData);
      } else {
        throw Exception(
          'Failed to load machine by ID: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('getMachineById - Error: $e');
      throw Exception('Error fetching machine by ID: $e');
    }
  }

  Future<void> updateMachine(
    String machineId,
    String machineName,
    String machineRole,
  ) async {
    try {
      final headers = await this.headers;
      final payload = {'name': machineName, 'role': machineRole};
      print('updateMachine - Sending payload: $payload');

      final response = await http.put(
        Uri.parse(AppUrl.getIsMachineById(machineId)),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('updateMachine - Response status: ${response.statusCode}');
      print('updateMachine - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception(
            'Failed to update machine: ${decoded['message']} ${decoded['errors'] ?? ''}',
          );
        }
      } else {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        throw Exception(
          'Failed to update machine: ${response.statusCode} - ${decoded['message']} ${decoded['errors'] ?? ''}',
        );
      }
    } catch (e) {
      print('updateMachine - Error: $e');
      throw Exception('Error updating machine: $e');
    }
  }

  Future<void> deleteMachine(String id) async {
    try {
      final headers = await this.headers;
      final payload = {
        'ids': [id],
      };
      print('deleteMachine - Sending payload: $payload');

      final response = await http.delete(
        Uri.parse(AppUrl.deleteIsMachines),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('deleteMachine - Response status: ${response.statusCode}');
      print('deleteMachine - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to delete machine: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to delete machine: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('deleteMachine - Error: $e');
      throw Exception('Error deleting machine: $e');
    }
  }

  Future<void> addMachine(Machines machine) async {
    try {
      final headers = await this.headers;
      final payload = {'name': machine.name, 'role': machine.role};
      print('addMachine - Sending payload: $payload');

      final response = await http.post(
        Uri.parse(AppUrl.getIsMachines),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('addMachine - Response status: ${response.statusCode}');
      print('addMachine - Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to add machine: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to add machine: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('addMachine - Error: $e');
      throw Exception('Error adding machine: $e');
    }
  }
}
