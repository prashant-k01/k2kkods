// To parse this JSON data, do
//
//     final machineResponse = machineResponseFromJson(jsonString);

import 'dart:convert';

import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';

MachineResponse machineResponseFromJson(String str) =>
    MachineResponse.fromJson(json.decode(str));

String machineResponseToJson(MachineResponse data) =>
    json.encode(data.toJson());

class MachineResponse {
  int? statusCode;
  List<Machine>? data;
  String? message;
  bool? success;

  MachineResponse({this.statusCode, this.data, this.message, this.success});

  factory MachineResponse.fromJson(Map<String, dynamic> json) =>
      MachineResponse(
        statusCode: json["statusCode"],
        data: json["data"] == null
            ? []
            : List<Machine>.from(json["data"].map((x) => Machine.fromJson(x))),
        message: json["message"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
    "success": success,
  };
}

class Machine {
  String? id;
  PlantModel? plantId;
  String? name;
  MachineCreatedBy? createdBy;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Machine({
    this.id,
    this.plantId,
    this.name,
    this.createdBy,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json["_id"],
      plantId: json['plant_id'] != null
          ? PlantModel.fromJson(json['plant_id'])
          : null,
      name: json["name"],
      createdBy: json["created_by"] != null
          ? MachineCreatedBy.fromJson(json["created_by"])
          : null,
      isDeleted: json["isDeleted"],
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "plant_id": plantId?.toJson(),
    "name": name,
    "created_by": createdBy?.toJson(),
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class MachineCreatedBy {
  String? id;
  String? email;
  String? username;

  MachineCreatedBy({this.id, this.email, this.username});

  factory MachineCreatedBy.fromJson(Map<String, dynamic> json) =>
      MachineCreatedBy(
        id: json["_id"],
        email: json["email"],
        username: json["username"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "username": username,
  };
}
