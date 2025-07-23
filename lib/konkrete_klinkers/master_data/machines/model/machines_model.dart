import 'dart:convert';

Machine machineFromJson(String str) {
  final jsonData = json.decode(str);
  return Machine.fromJson(jsonData);
}

String machineToJson(Machine data) => json.encode(data.toJson());

class Machine {
  int statusCode;
  dynamic data; // Changed to dynamic to handle both Data and MachineElement
  String message;
  bool success;

  Machine({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.success,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    dynamic data;
    if (json['data'] is Map<String, dynamic> &&
        json['data'].containsKey('machines')) {
      data = Data.fromJson(json['data']);
    } else {
      data = MachineElement.fromJson(json['data']);
    }

    return Machine(
      statusCode: json["statusCode"] ?? 0,
      data: data,
      message: json["message"] ?? '',
      success: json["success"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "data": data is Data ? data.toJson() : data.toJson(),
    "message": message,
    "success": success,
  };
}

class Data {
  List<MachineElement> machines;
  Pagination pagination;

  Data({required this.machines, required this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    machines: json["machines"] != null
        ? List<MachineElement>.from(
            json["machines"].map((x) => MachineElement.fromJson(x)),
          )
        : [],
    pagination: Pagination.fromJson(json["pagination"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "machines": List<dynamic>.from(machines.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class MachineElement {
  String id;
  PlantId plantId;
  String name;
  CreatedBy createdBy;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  MachineElement({
    required this.id,
    required this.plantId,
    required this.name,
    required this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory MachineElement.fromJson(Map<String, dynamic> json) => MachineElement(
    id: json["_id"] ?? '',
    plantId: PlantId.fromJson(json["plant_id"]),
    name: json["name"] ?? '',
    createdBy: CreatedBy.fromJson(json["created_by"]),
    isDeleted: json["isDeleted"] ?? false,
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : DateTime.now(),
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : DateTime.now(),
    v: json["__v"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "plant_id": plantId.id,
    "name": name,
    "created_by": createdBy.id, // Send only ID for POST
    "isDeleted": isDeleted,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class CreatedBy {
  String id;
  String email;
  String username;

  CreatedBy({required this.id, required this.email, required this.username});

  factory CreatedBy.fromJson(dynamic json) {
    if (json is String) {
      return CreatedBy(id: json, email: '', username: '');
    } else {
      return CreatedBy(
        id: json["_id"] ?? '',
        email: json["email"] ?? '',
        username: json["username"] ?? '',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "username": username,
  };
}

class PlantId {
  String id;
  String plantCode;
  String plantName;

  PlantId({required this.id, required this.plantCode, required this.plantName});

  factory PlantId.fromJson(dynamic json) {
    if (json is String) {
      return PlantId(id: json, plantCode: '', plantName: '');
    } else {
      return PlantId(
        id: json["_id"] ?? '',
        plantCode: json["plant_code"] ?? '',
        plantName: json["plant_name"] ?? '',
      );
    }
  }

  Map<String, dynamic> toFullJson() => {
    "_id": id,
    "plant_code": plantCode,
    "plant_name": plantName,
  };
}

class Pagination {
  int total;
  int page;
  int limit;
  int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"] ?? 0,
    page: json["page"] ?? 1,
    limit: json["limit"] ?? 10,
    totalPages: json["totalPages"] ?? 1,
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "page": page,
    "limit": limit,
    "totalPages": totalPages,
  };
}
