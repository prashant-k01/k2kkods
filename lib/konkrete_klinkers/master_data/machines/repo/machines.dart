import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k2k/common/constant/app_url.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/core/shared_preference/shared_preference.dart';

class MachineRepository {
  Future<Map<String, String>> get headers async {
    final token = await SessionManager.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// ✅ Get All Machines
  Future<MachineResponse> getAllMachines({
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
        return MachineResponse.fromJson(jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw Exception('Failed to load machines: $errorMessage');
      }
    } catch (e) {
      print('Error loading machines: $e');
      throw Exception('Error loading machines: $e');
    }
  }

  /// ✅ Get Single Machine by ID
  Future<Machine?> getMachine(String machineId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.fetchMachineDetailsUrl}/$machineId');

      print('Fetching machine: $uri');
      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Machine.fromJson(responseData['data']);
        }
        return null;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        throw Exception('Failed to load machine: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error loading machine: $e');
    }
  }

  /// ✅ Create Machine
  Future<Machine> createMachine(String machineName, String plantId) async {
    try {
      final authHeaders = await headers;
      final url = AppUrl.createMachineUrl;
      final body = jsonEncode({"name": machineName, "plant_id": plantId});

      final response = await http
          .post(Uri.parse(url), headers: authHeaders, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        print('✅ Create Machine API success: ${response.body}');
        final responseData = jsonDecode(response.body);
        return Machine.fromJson(responseData['data']);
      } else {
        print(
          '❌ Create Machine API failed: Status=${response.statusCode}, Body=${response.body}',
        );
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create machine');
      }
    } catch (e) {
      throw Exception('Error creating machine: $e');
    }
  }

  /// ✅ Update Machine
  Future<Machine> updateMachine(
    String machineId,
    String machineName,
    String plantId,
  ) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updateMachineDetailsUrl}/$machineId';
      final body = jsonEncode({"name": machineName, "plant_id": plantId});

      final response = await http
          .put(Uri.parse(updateUrl), headers: authHeaders, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Machine.fromJson(responseData['data']);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update machine');
      }
    } catch (e) {
      throw Exception('Error updating machine: $e');
    }
  }

  /// ✅ Delete Machine
  Future<bool> deleteMachine(String machineId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteMachineDetailsUrl;
      final body = jsonEncode({
        "ids": [machineId],
      });

      final response = await http
          .delete(Uri.parse(deleteUrl), headers: authHeaders, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete machine');
      }
    } catch (e) {
      throw Exception('Error deleting machine: $e');
    }
  }
}
