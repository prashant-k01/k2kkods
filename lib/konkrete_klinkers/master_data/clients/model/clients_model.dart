
class ClientsModel {
  final String id;
  final String name;
  final String address;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int version;

  ClientsModel({
    required this.id,
    required this.name,
    required this.address,
    required this.createdBy,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
    required this.version,
  });

  factory ClientsModel.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      final name = json['name']?.toString() ?? '';
      final address = json['address']?.toString() ?? '';
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

      return ClientsModel(
        id: id,
        name: name,
        address: address,
        createdBy: createdBy,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        version: version,
      );
    } catch (e) {
      print('Error in ClientsModel.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'created_by': createdBy.toJson(),
      'is_deleted': isDeleted,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

class CreatedBy {
  final String id;
  final String email;
  final String username;

  CreatedBy({required this.id, required this.email, required this.username});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final username = json['username']?.toString() ?? '';
      return CreatedBy(id: id, email: email, username: username);
    } catch (e) {
      print('Error in CreatedBy.fromJson: $e');
      return CreatedBy(id: '', email: '', username: 'Unknown');
    }
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'email': email, 'username': username};
  }
}