import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:k2k/Iron_smith/master_data/projects/model/is_project_model.dart';
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
}
