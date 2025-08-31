// To parse this JSON data:
//
//     final isProjectResponse = isProjectResponseFromJson(jsonString);

import 'dart:convert';

IsProjectResponse isProjectResponseFromJson(String str) =>
    IsProjectResponse.fromJson(json.decode(str));

String isProjectResponseToJson(IsProjectResponse data) =>
    json.encode(data.toJson());

class IsProjectResponse {
  final int? statusCode;
  final bool? success;
  final String? message;
  final List<IsProject>? data;

  IsProjectResponse({this.statusCode, this.success, this.message, this.data});

  factory IsProjectResponse.fromJson(Map<String, dynamic> json) =>
      IsProjectResponse(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<IsProject>.from(
                json["data"].map((x) => IsProject.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class IsProject {
  final String? id;
  final String? name;
  final IsPClient? client;
  final String? address;
  final bool? isDeleted;
  final IsPCreatedBy? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  IsProject({
    this.id,
    this.name,
    this.client,
    this.address,
    this.isDeleted,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory IsProject.fromJson(Map<String, dynamic> json) => IsProject(
    id: json["_id"],
    name: json["name"],
    client: json["client"] == null ? null : IsPClient.fromJson(json["client"]),
    address: json["address"],
    isDeleted: json["isDeleted"],
    createdBy: json["created_by"] == null
        ? null
        : IsPCreatedBy.fromJson(json["created_by"]),
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "client": client?.toJson(),
    "address": address,
    "isDeleted": isDeleted,
    "created_by": createdBy?.toJson(),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class IsPClient {
  final String? id;
  final String? name;
  final String? address;

  IsPClient({this.id, this.name, this.address});

  factory IsPClient.fromJson(Map<String, dynamic> json) =>
      IsPClient(id: json["_id"], name: json["name"], address: json["address"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
  };
}

class IsPCreatedBy {
  final String? id;
  final String? email;
  final String? username;

  IsPCreatedBy({this.id, this.email, this.username});

  factory IsPCreatedBy.fromJson(Map<String, dynamic> json) => IsPCreatedBy(
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
