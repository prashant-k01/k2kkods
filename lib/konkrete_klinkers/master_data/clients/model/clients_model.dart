
class ClientsModel {
  final String id;
  final String name;
  final String address;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  ClientsModel({
    required this.id,
    required this.name,
    required this.address,
    required this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ClientsModel.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id'] ?? json['id'] ?? '';
      final name = json['name'] ?? '';
      final address = json['address'] ?? '';
      CreatedBy createdBy;
      final createdByData = json['created_by'];
      if (createdByData is Map<String, dynamic>) {
        createdBy = CreatedBy.fromJson(createdByData);
      } else if (createdByData is String) {
        createdBy = CreatedBy(id: createdByData, email: '', username: '');
      } else {
        createdBy = CreatedBy(id: '', email: '', username: '');
      }
      final isDeleted = json['isDeleted'] ?? false;
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
      final version = json['__v'] ?? json['v'] ?? 0;

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
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'created_by': createdBy.toJson(),
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
      final id = json['_id'] ?? json['id'] ?? '';
      final email = json['email'] ?? '';
      final username = json['username'] ?? '';
      return CreatedBy(id: id, email: email, username: username);
    } catch (e) {
      return CreatedBy(id: '', email: '', username: 'Unknown');
    }
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'email': email, 'username': username};
  }
}