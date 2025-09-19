import 'dart:convert';

class PlantModel {
  final String id;
  final String plantCode;
  final String plantName;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;

  PlantModel({
    required this.id,
    required this.plantCode,
    required this.plantName,
    required this.createdBy,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    required this.version,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      final plantCode = json['plant_code']?.toString() ?? json['plantCode']?.toString() ?? '';
      final plantName = json['plant_name']?.toString() ?? json['plantName']?.toString() ?? '';

      CreatedBy createdBy;
      final createdByData = json['created_by'] ?? json['createdBy'];
      if (createdByData is Map<String, dynamic>) {
        createdBy = CreatedBy.fromJson(createdByData);
      } else if (createdByData is String) {
        createdBy = CreatedBy(id: createdByData, email: '', username: '');
      } else {
        createdBy = CreatedBy(id: '', email: '', username: 'Unknown');
      }

      final isDeleted = json['is_deleted']?.toString() == 'true' ||
          json['isDeleted'] == true ||
          false;

      DateTime? createdAt;
      try {
        final createdAtStr = json['created_at'] ?? json['createdAt'];
        createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr.toString()) : null;
      } catch (e) {
        print('Error parsing createdAt: $e');
        createdAt = null;
      }

      DateTime? updatedAt;
      try {
        final updatedAtStr = json['updatedAt'] ?? json['updated_at'];
        updatedAt = updatedAtStr != null ? DateTime.tryParse(updatedAtStr.toString()) : null;
      } catch (e) {
        print('Error parsing updatedAt: $e');
        updatedAt = null;
      }

      final version = (json['__v'] ?? json['version'] ?? 0) as int;

      return PlantModel(
        id: id,
        plantCode: plantCode,
        plantName: plantName,
        createdBy: createdBy,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        version: version,
      );
    } catch (e) {
      print('Error in PlantModel.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'plant_code': plantCode,
      'plant_name': plantName,
      'created_by': createdBy.toJson(),
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  PlantModel copyWith({
    String? id,
    String? plantCode,
    String? plantName,
    CreatedBy? createdBy,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return PlantModel(
      id: id ?? this.id,
      plantCode: plantCode ?? this.plantCode,
      plantName: plantName ?? this.plantName,
      createdBy: createdBy ?? this.createdBy,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
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
      final username = json['username']?.toString() ?? '';

      return CreatedBy(
        id: id,
        email: email,
        username: username,
      );
    } catch (e) {
      print('Error in CreatedBy.fromJson: $e');
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

class PlantResponse {
  final PlantModel data;
  final String? message;
  final bool success;

  PlantResponse({
    required this.data,
    this.message,
    required this.success,
  });

  factory PlantResponse.fromJson(Map<String, dynamic> json) {
    try {
      return PlantResponse(
        data: PlantModel.fromJson(json['data'] ?? json),
        message: json['message']?.toString(),
        success: json['success'] == true,
      );
    } catch (e) {
      print('Error in PlantResponse.fromJson: $e');
      rethrow;
    }
  }
}

PlantResponse plantResponseFromJson(String str) {
  try {
    return PlantResponse.fromJson(json.decode(str));
  } catch (e) {
    print('Error in plantResponseFromJson: $e');
    rethrow;
  }
}