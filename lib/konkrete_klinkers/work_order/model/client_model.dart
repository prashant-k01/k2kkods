class ClientModel {
  final String id;
  final String name;
  final String address;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ClientModel({
    required this.id,
    required this.name,
    required this.address,
    required this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
    id: json["_id"] as String,
    name: json["name"] as String,
    address: json["address"] as String,
    createdBy: CreatedBy.fromJson(json["created_by"] as Map<String, dynamic>),
    isDeleted: json["isDeleted"] as bool,
    createdAt: DateTime.parse(json["createdAt"] as String),
    updatedAt: DateTime.parse(json["updatedAt"] as String),
    v: json["__v"] as int,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
    "created_by": createdBy.toJson(),
    "isDeleted": isDeleted,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class CreatedBy {
  final Id id;
  final Email email;
  final Username username;

  CreatedBy({required this.id, required this.email, required this.username});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: idValues.map[json["_id"] as String]!,
    email: emailValues.map[json["email"] as String]!,
    username: usernameValues.map[json["username"] as String]!,
  );

  Map<String, dynamic> toJson() => {
    "_id": idValues.reverse[id],
    "email": emailValues.reverse[email],
    "username": usernameValues.reverse[username],
  };
}

enum Email { adminGmailCom }

final emailValues = EnumValues({"admin@gmail.com": Email.adminGmailCom});

enum Id { the68467bbcc6407e1fdf09d18e }

final idValues = EnumValues({
  "68467bbcc6407e1fdf09d18e": Id.the68467bbcc6407e1fdf09d18e,
});

enum Username { admin }

final usernameValues = EnumValues({"admin": Username.admin});

class EnumValues<T> {
  final Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
