// To parse this JSON data, do
//
//     final isIsClientsResponse = isClientsResponseFromJson(jsonString);

import 'dart:convert';

IsClientsResponse isClientsFromJson(String str) =>
    IsClientsResponse.fromJson(json.decode(str));

String isClientsToJson(IsClientsResponse data) => json.encode(data.toJson());

class IsClientsResponse {
  final int? statusCode;
  final bool? success;
  final String? message;
  final Data? data;

  IsClientsResponse({this.statusCode, this.success, this.message, this.data});

  factory IsClientsResponse.fromJson(Map<String, dynamic> json) =>
      IsClientsResponse(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final List<IsClient>? clients;

  Data({this.clients});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    clients: json["clients"] == null
        ? []
        : List<IsClient>.from(json["clients"].map((x) => IsClient.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "clients": clients == null
        ? []
        : List<dynamic>.from(clients!.map((x) => x.toJson())),
  };
}

class IsClient {
  final String? id;
  final String? name;
  final String? address;
  final bool? isDeleted;
  final CreatedBy? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  IsClient({
    this.id,
    this.name,
    this.address,
    this.isDeleted,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory IsClient.fromJson(Map<String, dynamic> json) => IsClient(
    id: json["_id"],
    name: json["name"],
    address: json["address"],
    isDeleted: json["isDeleted"],
    createdBy: json["created_by"] != null
        ? CreatedBy.fromJson(json["created_by"])
        : null,
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
    "isDeleted": isDeleted,
    "created_by": createdBy?.toJson(),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class CreatedBy {
  final String? id;
  final String? email;
  final String? username;

  CreatedBy({this.id, this.email, this.username});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
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
