import 'dart:convert';

class ProjectResponse {
  final List<Project> projects;
  final Pagination pagination;
  final String message;
  final bool success;

  ProjectResponse({
    required this.projects,
    required this.pagination,
    required this.message,
    required this.success,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    var projectsList = json['data']['projects'] as List<dynamic>? ?? [];
    return ProjectResponse(
      projects: projectsList
          .map((projectJson) => Project.fromJson(projectJson))
          .toList(),
      pagination: Pagination.fromJson(json['data']['pagination'] ?? {}),
      message: json['message'] ?? '',
      success: json['success'] ?? true,
    );
  }
}

class Project {
  final String id;
  final String name;
  final String address;
  final Client client;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Project({
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

  factory Project.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id'] ?? json['id'] ?? '';
      final name = json['name'] ?? '';
      final address = json['address'] ?? '';
      final client = Client.fromJson(json['client'] ?? {});
      final createdBy = CreatedBy.fromJson(json['created_by'] ?? {});
      final isDeleted = json['isDeleted'] ?? false;

      DateTime createdAt;
      try {
        final createdAtStr = json['createdAt'];
        createdAt = createdAtStr != null
            ? DateTime.parse(createdAtStr)
            : DateTime.now();
      } catch (e) {
        createdAt = DateTime.now();
      }

      DateTime updatedAt;
      try {
        final updatedAtStr = json['updatedAt'];
        updatedAt = updatedAtStr != null
            ? DateTime.parse(updatedAtStr)
            : DateTime.now();
      } catch (e) {
        updatedAt = DateTime.now();
      }

      final version = json['__v'] ?? json['v'] ?? 0;

      return Project(
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

  Project copyWith({
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
    return Project(
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
      final id = json['_id'] ?? json['id'] ?? '';
      final name = json['name'] ?? '';
      final address = json['address'] ?? '';
      return Client(id: id, name: name, address: address);
    } catch (e) {
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
      final id = json['_id'] ?? json['id'] ?? '';
      final email = json['email'] ?? '';
      final username = json['username'] ?? '';
      return CreatedBy(id: id, email: email, username: username);
    } catch (e) {
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

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

ProjectResponse projectResponseFromJson(String str) =>
    ProjectResponse.fromJson(json.decode(str));