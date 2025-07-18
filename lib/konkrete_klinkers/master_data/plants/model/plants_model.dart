// models/plant_model.dart
import 'dart:convert';

class PlantModel {
  final String id;
  final String plantCode;
  final String plantName;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  PlantModel({
    required this.id,
    required this.plantCode,
    required this.plantName,
    required this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parse ID - handle both _id and id
      final id = json['_id'] ?? json['id'] ?? '';

      // Parse plant code
      final plantCode = json['plant_code'] ?? '';

      // Parse plant name
      final plantName = json['plant_name'] ?? '';

      // Parse created_by - handle both object and string
      CreatedBy createdBy;
      final createdByData = json['created_by'];
      if (createdByData is Map<String, dynamic>) {
        createdBy = CreatedBy.fromJson(createdByData);
      } else if (createdByData is String) {
        createdBy = CreatedBy(id: createdByData, email: '', username: '');
      } else {
        createdBy = CreatedBy(id: '', email: '', username: '');
      }

      // Parse isDeleted
      final isDeleted = json['isDeleted'] ?? false;

      // Parse dates with better error handling
      DateTime createdAt;
      DateTime updatedAt;

      try {
        final createdAtStr = json['createdAt'];
        if (createdAtStr != null) {
          createdAt = DateTime.parse(createdAtStr);
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        createdAt = DateTime.now();
      }

      try {
        final updatedAtStr = json['updatedAt'];
        if (updatedAtStr != null) {
          updatedAt = DateTime.parse(updatedAtStr);
        } else {
          updatedAt = DateTime.now();
        }
      } catch (e) {
        updatedAt = DateTime.now();
      }

      // Parse version - handle both __v and v
      final version = json['__v'] ?? json['v'] ?? 0;

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
      print('❌ Error in PlantModel.fromJson: $e');
      print('❌ JSON that caused error: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'plant_code': plantCode,
      'plant_name': plantName,
      'created_by': createdBy.toJson(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  // Helper method to create a copy with updated fields
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

// Response wrapper for API responses
class PlantResponse {
  final PlantModel data;
  final String message;
  final bool success;

  PlantResponse({
    required this.data,
    required this.message,
    required this.success,
  });

  factory PlantResponse.fromJson(Map<String, dynamic> json) {
    return PlantResponse(
      data: PlantModel.fromJson(json['data']),
      message: json['message'] ?? '',
      success: json['success'] ?? true,
    );
  }
}

// Helper function to parse plant response
PlantResponse plantResponseFromJson(String str) =>
    PlantResponse.fromJson(json.decode(str));