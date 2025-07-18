import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  int statusCode;
  Data? data;
  String message;
  bool success;

  LoginModel({
    required this.statusCode,
    required this.data,
    required this.message,
    required this.success,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    statusCode: json["statusCode"] ?? 0,
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    message: json["message"] ?? '',
    success: json["success"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "data": data?.toJson(),
    "message": message,
    "success": success,
  };
}

class Data {
  User? user;
  String accessToken;
  String refreshToken;

  Data({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] != null ? User.fromJson(json["user"]) : null,
    accessToken: json["accessToken"] ?? '',
    refreshToken: json["refreshToken"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "accessToken": accessToken,
    "refreshToken": refreshToken,
  };
}

class User {
  String id;
  String phoneNumber;
  String email;
  String userType;
  String fullName;
  DateTime? createdAt;
  DateTime? updatedAt;
  int v;
  String username;

  User({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.userType,
    required this.fullName,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"] ?? '',
    phoneNumber: json["phoneNumber"] ?? '',
    email: json["email"] ?? '',
    userType: json["userType"] ?? '',
    fullName: json["fullName"] ?? '',
    createdAt:
        json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) : null,
    updatedAt:
        json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
    v: json["__v"] ?? 0,
    username: json["username"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "phoneNumber": phoneNumber,
    "email": email,
    "userType": userType,
    "fullName": fullName,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "username": username,
  };
}
