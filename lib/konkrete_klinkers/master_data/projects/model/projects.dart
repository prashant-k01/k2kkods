import 'dart:convert';

class ProjectModelResponse {
  final List<ProjectModel> projectModels;
  final String message;
  final bool success;

  ProjectModelResponse({
    required this.projectModels,
    required this.message,
    required this.success,
  });

  factory ProjectModelResponse.fromJson(Map<String, dynamic> json) {
    try {
      final dataJson = json['data'];
      if (dataJson == null) {
        print('Error: data field is null in JSON response: $json');
        return ProjectModelResponse(
          projectModels: [],
          message: json['message']?.toString() ?? 'No data field in response',
          success: json['success'] as bool? ?? false,
        );
      }

      final projectModels = (dataJson as List<dynamic>)
          .map((projectModelJson) {
            try {
              if (projectModelJson is Map<String, dynamic>) {
                return ProjectModel.fromJson(projectModelJson);
              } else {
                print('Error: Project item is not a Map: $projectModelJson');
                return null;
              }
            } catch (e) {
              print('Error parsing project: $e for item: $projectModelJson');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<ProjectModel>()
          .toList();

      return ProjectModelResponse(
        projectModels: projectModels,
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool? ?? true,
      );
    } catch (e) {
      print('Error parsing ProjectModelResponse: $e for JSON: $json');
      return ProjectModelResponse(
        projectModels: [],
        message: 'Failed to parse response: $e',
        success: false,
      );
    }
  }
}

class ProjectModel {
  final String id;
  final String name;
  final String address;
  final Client client;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  ProjectModel({
    required this.id,
    required this.name,
    required this.address,
    required this.client,
    required this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      if (id.isEmpty) {
        print('Warning: Project ID is empty in JSON: $json');
      }

      final name = json['name']?.toString() ?? '';
      final address = json['address']?.toString() ?? '';

      // Handle client field: string (ID) or map (Client object)
      Client client;
      final clientData = json['client'];
      if (clientData is String) {
        client = Client(id: clientData, name: '', address: '');
      } else if (clientData is Map<String, dynamic>) {
        client = Client.fromJson(clientData);
      } else {
        client = Client(id: '', name: '', address: '');
      }

      // Handle created_by field: string (ID) or map (CreatedBy object)
      CreatedBy createdBy;
      final createdByData = json['created_by'];
      if (createdByData is String) {
        createdBy = CreatedBy(id: createdByData, email: '', username: '');
      } else if (createdByData is Map<String, dynamic>) {
        createdBy = CreatedBy.fromJson(createdByData);
      } else {
        createdBy = CreatedBy(id: '', email: '', username: 'Unknown');
      }

      final isDeleted = json['isDeleted'] as bool? ?? false;

      DateTime createdAt;
      try {
        final createdAtStr = json['createdAt']?.toString();
        createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();
      } catch (e) {
        print('Error parsing createdAt: $e for JSON: $json');
        createdAt = DateTime.now();
      }

      DateTime updatedAt;
      try {
        final updatedAtStr = json['updatedAt']?.toString();
        updatedAt = updatedAtStr != null ? DateTime.parse(updatedAtStr) : DateTime.now();
      } catch (e) {
        print('Error parsing updatedAt: $e for JSON: $json');
        updatedAt = DateTime.now();
      }

      final version = json['__v'] is num
          ? (json['__v'] as num).toInt()
          : (json['v'] is num ? (json['v'] as num).toInt() : 0);

      return ProjectModel(
        id: id,
        name: name,
        address: address,
        client: client,
        createdBy: createdBy,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        version: version,
      );
    } catch (e) {
      print('Error parsing ProjectModel: $e for JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'client': client.toJson(),
      'created_by': createdBy.toJson(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? name,
    String? address,
    Client? client,
    CreatedBy? createdBy,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      client: client ?? this.client,
      createdBy: createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

class Client {
  final String id;
  final String name;
  final String address;

  Client({
    required this.id,
    required this.name,
    required this.address,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      final name = json['name']?.toString() ?? '';
      final address = json['address']?.toString() ?? '';
      return Client(id: id, name: name, address: address);
    } catch (e) {
      print('Error parsing Client: $e for JSON: $json');
      return Client(id: '', name: '', address: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
    };
  }
}

class CreatedBy {
  final String id;
  final String email;
  final String username;

  CreatedBy({
    required this.id,
    required this.email,
    required this.username,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final username = json['username']?.toString() ?? 'Unknown';
      return CreatedBy(id: id, email: email, username: username);
    } catch (e) {
      print('Error parsing CreatedBy: $e for JSON: $json');
      return CreatedBy(id: '', email: '', username: 'Unknown');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
    };
  }
}

ProjectModelResponse projectModelResponseFromJson(String str) =>
    ProjectModelResponse.fromJson(json.decode(str));