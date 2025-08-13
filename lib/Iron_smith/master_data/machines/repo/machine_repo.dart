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

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? [];

        print('Number of machines in response: ${dataList.length}');

        List<Machines> machines = [];
        for (int i = 0; i < dataList.length; i++) {
          try {
            final machine = Machines.fromJson(dataList[i]);
            machines.add(machine);
          } catch (e) {
            print('Error parsing machine at index $i: $e');
            print('Problematic data: ${dataList[i]}');
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
      print('Error fetching machines: $e');
      throw Exception('Error fetching machines: $e');
    }
  }

  Future<void> addMachine(Machines machine) async {
    try {
      final headers = await this.headers;
      final response = await http.post(
        Uri.parse(AppUrl.addIsMachines),
        headers: headers,
        body: jsonEncode({
          'name': machine.name,
          'role': machine.role,
        }),
      );

      print('Add machine response status: ${response.statusCode}');
      print('Add machine response body: ${response.body}');

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
      print('Error adding machine: $e');
      throw Exception('Error adding machine: $e');
    }
  }
}