import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k2k/Iron_smith/master_data/projects/model/is_project_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/model/is_raw_material_model.dart';
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/api_services/shared_preference/shared_preference.dart';

class ProjectsRepository {
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

  Future<List<IsProject>> fetchProjects() async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.getAllProjects),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> dataList = decoded['data'] ?? [];

        List<IsProject> projects = [];
        for (int i = 0; i < dataList.length; i++) {
          try {
            final project = IsProject.fromJson(dataList[i]);
            projects.add(project);
          } catch (e) {
            continue;
          }
        }

        return projects;
      } else {
        throw Exception(
          'Failed to load projects: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  Future<IsProject> getProjectById(String id) async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.getProjectById(id)),
        headers: headers,
      );

      print('getProjectById - Response status: ${response.statusCode}');
      print('getProjectById - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final projectData = decoded['data'] ?? decoded;
        return IsProject.fromJson(projectData);
      } else {
        throw Exception(
          'Failed to load project by ID: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('getProjectById - Error: $e');
      throw Exception('Error fetching project by ID: $e');
    }
  }

  Future<void> updateProject(
    String projectId,
    String projectAddress,
    String clientId,
    String projectName,
  ) async {
    try {
      final headers = await this.headers;
      final payload = {
        'address': projectAddress,
        'client': clientId,
        'name': projectName,
      };
      print('updateProject - Sending payload: $payload');

      final response = await http.put(
        Uri.parse(AppUrl.getProjectById(projectId)),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('updateProject - Response status: ${response.statusCode}');
      print('updateProject - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to update project: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to update project: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('updateProject - Error: $e');
      throw Exception('Error updating project: $e');
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      final headers = await this.headers;
      final payload = {
        'ids': [id],
      };
      print('deleteProject - Sending payload: $payload');

      final response = await http.delete(
        Uri.parse(AppUrl.deleteIsProject),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('deleteProject - Response status: ${response.statusCode}');
      print('deleteProject - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to delete project: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to delete project: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('deleteProject - Error: $e');
      throw Exception('Error deleting project: $e');
    }
  }

  Future<void> addProject(IsProject project) async {
    try {
      final headers = await this.headers;
      final payload = {
        'address': project.address,
        'client': project.client?.id,
        'name': project.name,
      };
      print('addProject - Sending payload: $payload');

      final response = await http.post(
        Uri.parse(AppUrl.getAllProjects),
        headers: headers,
        body: jsonEncode(payload),
      );

      print('addProject - Response status: ${response.statusCode}');
      print('addProject - Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        if (decoded['success'] != true) {
          throw Exception('Failed to add project: ${decoded['message']}');
        }
      } else {
        throw Exception(
          'Failed to add project: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('addProject - Error: $e');
      throw Exception('Error adding project: $e');
    }
  }

  //Methods for Raw Materials

  /// 1. GET - Fetch raw materials by projectId
  Future<List<RawMaterial>> fetchRawMaterials(String projectId) async {
    try {
      final headers = await this.headers;
      final response = await http.get(
        Uri.parse(AppUrl.getRawMaterials(projectId)),
        headers: headers,
      );

      print("fetchRawMaterials - Status: ${response.statusCode}");
      print("fetchRawMaterials - Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];
        return data.map((json) => RawMaterial.fromJson(json)).toList();
      } else {
        throw Exception(
          "Failed to fetch raw materials: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching raw materials: $e");
    }
  }

  /// 2. POST - Create raw material
  Future<void> createRawMaterial(Map<String, dynamic> payload) async {
    try {
      final headers = await this.headers;

      print("createRawMaterial - Payload: $payload");

      final response = await http.post(
        Uri.parse(AppUrl.createRawMaterial),
        headers: headers,
        body: jsonEncode(payload),
      );

      print("createRawMaterial - Status: ${response.statusCode}");
      print("createRawMaterial - Body: ${response.body}");

      if (response.statusCode != 201) {
        throw Exception(
          "Failed to create raw material: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error creating raw material: $e");
    }
  }

  /// 3. PUT - Update raw material
  Future<void> updateRawMaterial(
    String rawMaterialId, // <- change here
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await this.headers;

      print("updateRawMaterial - Payload: $payload");
      print("updateRawMaterial - rawMaterialId: $rawMaterialId");

      final response = await http.put(
        Uri.parse(
          AppUrl.updateRawMaterials(rawMaterialId),
        ), // <- use rawMaterialId
        headers: headers,
        body: jsonEncode(payload),
      );

      print("updateRawMaterial - Status: ${response.statusCode}");
      print("updateRawMaterial - Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to update raw material: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error updating raw material: $e");
    }
  }

  /// 4. GET - View consumption (with query params)
  Future<RawMaterial> fetchConsumption({
    required String dia,
    required String projectId,
    required String id,
  }) async {
    try {
      final headers = await this.headers;

      final url = AppUrl.getRawMaterialConsumption(
        dia: dia,
        projectId: projectId,
        id: id,
      );

      final response = await http.get(Uri.parse(url), headers: headers);

      print("fetchConsumption - URL: $url");
      print("fetchConsumption - Status: ${response.statusCode}");
      print("fetchConsumption - Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // API gives data as a single object, not a list
        return RawMaterial.fromJson(body["data"]);
      } else {
        throw Exception(
          "Failed to fetch consumption: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching consumption: $e");
    }
  }
}
