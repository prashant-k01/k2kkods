import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:k2k/api_services/api_services.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/model/projects.dart';
import 'package:k2k/shared_preference/shared_preference.dart';

class ProjectRepository {
  Future<Map<String, String>> get headers async {
    final token = await fetchAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  bool isAddProjectsLoading = false;
  ProjectModel? _lastCreatedProject;
  ProjectModel? get lastCreatedProject => _lastCreatedProject;

Future<ProjectModel> createProject(String name, String address, String clientId) async {
  isAddProjectsLoading = true;
  try {
    final authHeaders = await headers;
    final url = AppUrl.createProjectUrl;
    final Map<String, dynamic> body = {
      'name': name,
      'address': address,
      'client': clientId,
    };

    final response = await http
        .post(
          Uri.parse(url),
          headers: authHeaders,
          body: json.encode(body),
        )
        .timeout(const Duration(seconds: 30));

    print('Create Project Response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData is! Map<String, dynamic>) {
        throw Exception('Invalid response format: Expected JSON object, got ${responseData.runtimeType}');
      }

      final projectData = responseData['data'];
      if (projectData is! Map<String, dynamic>) {
        throw Exception('Invalid project data format: Expected JSON object, got ${projectData.runtimeType}');
      }

      final createdProject = ProjectModel.fromJson(projectData);
      _lastCreatedProject = createdProject;
      return createdProject;
    } else {
      print('Create Project API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to create Project: ${response.statusCode} - ${response.body}');
    }
  } on SocketException catch (e) {
    throw Exception('No internet connection: $e');
  } on HttpException catch (e) {
    throw Exception('Network error occurred: $e');
  } on FormatException catch (e) {
    throw Exception('Invalid response format: $e');
  } catch (e) {
    print('Error creating Project: $e');
    rethrow; // Preserve stack trace
  } finally {
    isAddProjectsLoading = false;
  }
}
  Future<PaginatedProjectsResponse> getAllProjects({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse(AppUrl.fetchProjectDetailsUrl).replace(
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
        List<dynamic> projectsJson = [];
        PaginationInfo paginationInfo;

        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final data = jsonData['data'];
          paginationInfo = PaginationInfo.fromJson(data['pagination'] ?? {});
          projectsJson = (data['projects'] as List?) ?? [];
        } else {
          throw Exception('Unexpected response structure: ${jsonData.runtimeType}');
        }

        final projects = projectsJson
            .whereType<Map<String, dynamic>>()
            .map((projectJson) => ProjectModel.fromJson(projectJson))
            .toList();

        return PaginatedProjectsResponse(
          projects: projects,
          pagination: paginationInfo,
        );
      } else {
        throw Exception(
          'Failed to load Projects: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } on HttpException catch (e) {
      throw Exception('Network error occurred: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Error loading Projects: $e');
    }
  }

  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final authHeaders = await headers;
      final uri = Uri.parse('${AppUrl.fetchProjectDetailsUrl}/$projectId');

      final response = await http
          .get(uri, headers: authHeaders)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final projectData = (jsonData is Map<String, dynamic>)
            ? jsonData['data'] ?? jsonData
            : jsonData;

        return ProjectModel.fromJson(projectData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load Project: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error loading Project: $e');
    }
  }
 Future<bool> updateProject(
    String projectId,
    String name,
    String address,
    String clientId,
  ) async {
    try {
      final authHeaders = await headers;
      final updateUrl = '${AppUrl.updateProjectDetailsUrl}/$projectId';

      final Map<String, dynamic> body = {
        'name': name,
        'address': address,
        'client': clientId,
      };

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
          'Failed to update Project: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error updating Project: $e');
    }
  }

  Future<bool> deleteProject(String projectId) async {
    try {
      final authHeaders = await headers;
      final deleteUrl = AppUrl.deleteProjectDetailsUrl;

      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: authHeaders,
            body: json.encode({
              'ids': [projectId],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to delete Project: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection: $e');
    } catch (e) {
      throw Exception('Error deleting Project: $e');
    }
  }
}

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

class PaginatedProjectsResponse {
  final List<ProjectModel> projects;
  final PaginationInfo pagination;

  PaginatedProjectsResponse({required this.projects, required this.pagination});
}