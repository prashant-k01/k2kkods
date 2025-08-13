import 'package:intl/intl.dart';

class Machines {
  Id? id;
  String name;
  String role;
  bool isDeleted;
  CreatedBy? createdBy;
  AtedAt? createdAt;
  AtedAt? updatedAt;
  int v;

  Machines({
    this.id,
    required this.name,
    required this.role,
    required this.isDeleted,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    required this.v,
  });

  factory Machines.fromJson(Map<String, dynamic> json) {
    return Machines(
      id: json['_id'] != null ? Id.fromJson(json['_id']) : null,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      createdBy: json['created_by'] != null 
          ? CreatedBy.fromJson(json['created_by']) 
          : (json['createdBy'] != null ? CreatedBy.fromJson(json['createdBy']) : null),
      createdAt: json['createdAt'] != null ? AtedAt.fromJson(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? AtedAt.fromJson(json['updatedAt']) : null,
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id?.toJson(),
      'name': name,
      'role': role,
      'isDeleted': isDeleted,
      'created_by': createdBy?.toJson(),
      'createdAt': createdAt?.toJson(),
      'updatedAt': updatedAt?.toJson(),
      '__v': v,
    };
  }
}

class CreatedBy {
  Id? id;
  String? email;
  String? username;

  CreatedBy({
    this.id,
    this.email,
    this.username,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['_id'] != null ? Id.fromJson(json['_id']) : null,
      email: json['email'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id?.toJson(),
      'email': email,
      'username': username,
    };
  }
}

class AtedAt {
  DateTime date;

  AtedAt({required this.date});

  factory AtedAt.fromJson(dynamic json) {
    if (json == null) {
      throw FormatException("Date cannot be null");
    }
    
    if (json is String) {
      try {
        final customFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
        return AtedAt(date: customFormat.parse(json));
      } catch (e) {
        try {
          return AtedAt(date: DateTime.parse(json));
        } catch (e2) {
          throw FormatException("Invalid date string format: $json");
        }
      }
    } else if (json is Map<String, dynamic> && json.containsKey('\$date')) {
      try {
        return AtedAt(date: DateTime.parse(json['\$date']));
      } catch (e) {
        throw FormatException("Invalid \$date format: ${json['\$date']}");
      }
    } else {
      throw FormatException("Invalid date format: $json");
    }
  }

  Map<String, dynamic> toJson() {
    return {'\$date': date.toIso8601String()};
  }
}

class Id {
  String oid;

  Id({required this.oid});

  factory Id.fromJson(dynamic json) {
    if (json == null) {
      throw FormatException("ObjectId cannot be null");
    }
    
    if (json is String) {
      if (json.isEmpty) {
        throw FormatException("ObjectId string cannot be empty");
      }
      return Id(oid: json);
    } else if (json is Map<String, dynamic> && json.containsKey('\$oid')) {
      final oidValue = json['\$oid'];
      if (oidValue == null || (oidValue is String && oidValue.isEmpty)) {
        throw FormatException("ObjectId \$oid value cannot be null or empty");
      }
      return Id(oid: oidValue.toString());
    } else {
      throw FormatException("Invalid ObjectId format: $json");
    }
  }

  Map<String, dynamic> toJson() {
    return {'\$oid': oid};
  }
}
