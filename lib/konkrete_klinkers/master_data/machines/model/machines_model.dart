// To parse this JSON data, do
//
//     final machine = machineFromJson(jsonString);

import 'dart:convert';

Machine machineFromJson(String str) => Machine.fromJson(json.decode(str));

String machineToJson(Machine data) => json.encode(data.toJson());

class Machine {
  Machine({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.success,
  });

  int statusCode;
  List<MachineElement> data;
  String message;
  bool success;

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
    statusCode: json["statusCode"] ?? 0,
    data: List<MachineElement>.from(
      (json["data"] ?? []).map((x) => MachineElement.fromJson(x)),
    ),
    message: json["message"] ?? '',
    success: json["success"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
    "success": success,
  };
}

class MachineElement {
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

  String id;
  PlantId plantId;
  String name;
  CreatedBy createdBy;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  factory MachineElement.fromJson(Map<String, dynamic> json) {
    // Handle plant_id
    final plantIdRaw = json["plant_id"];
    final plantId = plantIdRaw is String
        ? PlantId(id: plantIdRaw, plantName: '', plantCode: '')
        : plantIdRaw is Map<String, dynamic>
        ? PlantId.fromJson(plantIdRaw)
        : PlantId(id: '', plantName: '', plantCode: '');

    // Handle created_by
    final createdByRaw = json["created_by"];
    final createdBy = createdByRaw is String
        ? CreatedBy(id: createdByRaw, username: '', email: '')
        : createdByRaw is Map<String, dynamic>
        ? CreatedBy.fromJson(createdByRaw)
        : CreatedBy(id: '', username: '', email: '');

    return MachineElement(
      id: json["_id"] ?? '',
      plantId: plantId,
      name: json["name"] ?? '',
      createdBy: createdBy,
      isDeleted: json["isDeleted"] ?? false,
      createdAt: DateTime.tryParse(json["createdAt"] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? '') ?? DateTime.now(),
      v: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "plant_id": plantId.toJson(),
    "name": name,
    "created_by": createdBy.toJson(),
    "isDeleted": isDeleted,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class CreatedBy {
  CreatedBy({required this.id, required this.email, this.username = ''});

  String id;
  String email;
  String username;

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["_id"] ?? '',
    email: json["email"] ?? '',
    username: json["username"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "username": username,
  };
}

class PlantId {
  PlantId({required this.id, required this.plantName, required this.plantCode});

  String id;
  String plantName;
  String plantCode;

  factory PlantId.fromJson(Map<String, dynamic> json) => PlantId(
    id: json["_id"] ?? '',
    plantName: json["plant_name"] ?? '',
    plantCode: json["plant_code"] ?? '',
  );

  Map<String, dynamic> toJson() => {"_id": id, "plant_name": plantName};
}
