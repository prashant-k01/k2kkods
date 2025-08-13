import 'dart:convert';

class StockManagement {
  final String id;
  final String fromWorkOrderId;
  final String toWorkOrderId;
  final int quantityTransferred;
  final String transferredBy;
  final DateTime transferDate;
  final bool isBufferTransfer;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productName;

  StockManagement({
    required this.id,
    required this.fromWorkOrderId,
    required this.toWorkOrderId,
    required this.quantityTransferred,
    required this.transferredBy,
    required this.transferDate,
    required this.isBufferTransfer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.productName,
  });

  factory StockManagement.fromJson(Map<String, dynamic> json) {
    return StockManagement(
      id: json['_id'] ?? '',
      fromWorkOrderId: json['from_work_order_id'] ?? '',
      toWorkOrderId: json['to_work_order_id'] ?? '',
      quantityTransferred: json['quantity_transferred'] ?? 0,
      transferredBy: json['transferred_by'] ?? '',
      transferDate: DateTime.parse(json['transfer_date']),
      isBufferTransfer: json['isBufferTransfer'] ?? false,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productName: json['product_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from_work_order_id': fromWorkOrderId,
      'to_work_order_id': toWorkOrderId,
      'quantity_transferred': quantityTransferred,
      'transferred_by': transferredBy,
      'transfer_date': transferDate.toIso8601String(),
      'isBufferTransfer': isBufferTransfer,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'product_name': productName,
    };
  }
}
// To parse this JSON dataQ, do
//
//     final product = productFromJson(jsonString);

Product productFromJson(String str) => Product.fromJson(json.decode(str));
String productToJson(Product data) => json.encode(data.toJson());

class Product {
  int? statusCode;
  List<Datum>? data;
  String? message;
  bool? success;

  Product({this.statusCode, this.data, this.message, this.success});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    statusCode: json["statusCode"],
    data: json["data"] == null
        ? []
        : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
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

class Datum {
  String? id;
  Plant? plant;
  String? materialCode;
  String? description;
  List<Uom>? uom;
  double? area;
  int? noOfPiecesPerPunch;
  int? qtyInBundle;
  CreatedBy? createdBy;
  Status? status;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  Areas? areas;

  Datum({
    this.id,
    this.plant,
    this.materialCode,
    this.description,
    this.uom,
    this.area,
    this.noOfPiecesPerPunch,
    this.qtyInBundle,
    this.createdBy,
    this.status,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.areas,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    plant: json["plant"] != null ? Plant.fromJson(json["plant"]) : null,
    materialCode: json["material_code"],
    description: json["description"],
    uom: json["uom"] == null
        ? []
        : List<Uom>.from(json["uom"].map((x) => uomValues.map[x]!)),
    area: json["area"]?.toDouble(),
    noOfPiecesPerPunch: json["no_of_pieces_per_punch"],
    qtyInBundle: json["qty_in_bundle"],
    createdBy: json["created_by"] != null
        ? CreatedBy.fromJson(json["created_by"])
        : null,
    status: json["status"] != null ? statusValues.map[json["status"]] : null,
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
    v: json["__v"],
    areas: json["areas"] != null ? Areas.fromJson(json["areas"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "plant": plant?.toJson(),
    "material_code": materialCode,
    "description": description,
    "uom": uom == null
        ? []
        : List<dynamic>.from(uom!.map((x) => uomValues.reverse[x])),
    "area": area,
    "no_of_pieces_per_punch": noOfPiecesPerPunch,
    "qty_in_bundle": qtyInBundle,
    "created_by": createdBy?.toJson(),
    "status": statusValues.reverse[status],
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "areas": areas?.toJson(),
  };
}

class Areas {
  double? squareMeterNo;
  double? squareMetreNo;
  double? metreNo;
  double? meterNo;

  Areas({this.squareMeterNo, this.squareMetreNo, this.metreNo, this.meterNo});

  factory Areas.fromJson(Map<String, dynamic> json) => Areas(
    squareMeterNo: json["Square Meter/No"]?.toDouble(),
    squareMetreNo: json["Square Metre/No"]?.toDouble(),
    metreNo: json["Metre/No"]?.toDouble(),
    meterNo: json["Meter/No"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "Square Meter/No": squareMeterNo,
    "Square Metre/No": squareMetreNo,
    "Metre/No": metreNo,
    "Meter/No": meterNo,
  };
}

class CreatedBy {
  Id? id;
  Email? email;
  Username? username;

  CreatedBy({this.id, this.email, this.username});

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
    id: json["_id"] != null ? idValues.map[json["_id"]] : null,
    email: json["email"] != null ? emailValues.map[json["email"]] : null,
    username: json["username"] != null
        ? usernameValues.map[json["username"]]
        : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": idValues.reverse[id],
    "email": emailValues.reverse[email],
    "username": usernameValues.reverse[username],
  };
}

class Plant {
  String? id;
  String? plantCode;
  String? plantName;

  Plant({this.id, this.plantCode, this.plantName});

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json["_id"],
    plantCode: json["plant_code"],
    plantName: json["plant_name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "plant_code": plantCode,
    "plant_name": plantName,
  };
}

/// ENUMS
enum Email { ADMIN_GMAIL_COM }

final emailValues = EnumValues({"admin@gmail.com": Email.ADMIN_GMAIL_COM});

enum Id { THE_68467_BBCC6407_E1_FDF09_D18_E }

final idValues = EnumValues({
  "68467bbcc6407e1fdf09d18e": Id.THE_68467_BBCC6407_E1_FDF09_D18_E,
});

enum Username { ADMIN }

final usernameValues = EnumValues({"admin": Username.ADMIN});

enum Status { ACTIVE }

final statusValues = EnumValues({"Active": Status.ACTIVE});

enum Uom { METER_NO, METRE_NO, SQUARE_METER_NO, SQUARE_METRE_NO }

final uomValues = EnumValues({
  "Meter/No": Uom.METER_NO,
  "Metre/No": Uom.METRE_NO,
  "Square Meter/No": Uom.SQUARE_METER_NO,
  "Square Metre/No": Uom.SQUARE_METRE_NO,
});

/// Helper class for enum mapping
class EnumValues<T> {
  final Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }

  Map<T, String> get reverse => reverseMap;
}
// To parse this JSON data, do
//
//     final workOrderResponse = workOrderResponseFromJson(jsonString);

WorkOrderResponse workOrderResponseFromJson(String str) =>
    WorkOrderResponse.fromJson(json.decode(str));

String workOrderResponseToJson(WorkOrderResponse data) =>
    json.encode(data.toJson());

class WorkOrderResponse {
  bool success;
  String message;
  List<Data> data;

  WorkOrderResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WorkOrderResponse.fromJson(Map<String, dynamic> json) =>
      WorkOrderResponse(
        success: json["success"],
        message: json["message"],
        data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Data {
  String workOrderId;
  String workOrderNumber;

  Data({required this.workOrderId, required this.workOrderNumber});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    workOrderId: json["work_order_id"],
    workOrderNumber: json["work_order_number"],
  );

  Map<String, dynamic> toJson() => {
    "work_order_id": workOrderId,
    "work_order_number": workOrderNumber,
  };
}

// To parse this JSON data, do
//
//     final availableQuantity = availableQuantityFromJson(jsonString);

AvailableQuantity availableQuantityFromJson(String str) =>
    AvailableQuantity.fromJson(json.decode(str));

String availableQuantityToJson(AvailableQuantity data) =>
    json.encode(data.toJson());

class AvailableQuantity {
  bool success;
  String message;
  DataQ data;

  AvailableQuantity({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AvailableQuantity.fromJson(Map<String, dynamic> json) =>
      AvailableQuantity(
        success: json["success"],
        message: json["message"],
        data: DataQ.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class DataQ {
  String workOrderId;
  String productId;
  int totalAchievedQuantity;

  DataQ({
    required this.workOrderId,
    required this.productId,
    required this.totalAchievedQuantity,
  });

  factory DataQ.fromJson(Map<String, dynamic> json) => DataQ(
    workOrderId: json["workOrderId"],
    productId: json["productId"],
    totalAchievedQuantity: json["totalAchievedQuantity"],
  );

  Map<String, dynamic> toJson() => {
    "workOrderId": workOrderId,
    "productId": productId,
    "totalAchievedQuantity": totalAchievedQuantity,
  };
}

// To parse this JSON data, do
//
//     final stockById = stockByIdFromJson(jsonString);

StockById stockByIdFromJson(String str) => StockById.fromJson(json.decode(str));
String stockByIdToJson(StockById data) => json.encode(data.toJson());

class StockById {
  bool? success;
  String? message;
  Stock? data;

  StockById({this.success, this.message, this.data});
  @override
  String toString() {
    return 'StockById(success: $success, message: $message, data: $data)';
  }

  factory StockById.fromJson(Map<String, dynamic> json) => StockById(
    success: json["success"],
    message: json["message"],
    data: json["data"] != null ? Stock.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Stock {
  From? from;
  From? to;

  Stock({this.from, this.to});

  factory Stock.fromJson(Map<String, dynamic> json) {
    print('Parsing Stock: $json'); // Debug
    return Stock(
      from: json["from"] != null ? From.fromJson(json["from"]) : null,
      to: json["to"] != null ? From.fromJson(json["to"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {"from": from?.toJson(), "to": to?.toJson()};
}

class From {
  String? workOrderId;
  String? productName;
  int? quantityTransferred;
  DateTime? createdAt;
  String? transferredBy;
  String? client;
  String? project;

  From({
    this.workOrderId,
    this.productName,
    this.quantityTransferred,
    this.createdAt,
    this.transferredBy,
    this.client,
    this.project,
  });

  factory From.fromJson(Map<String, dynamic> json) => From(
    workOrderId: json["work_order_id"],
    productName: json["product_name"],
    quantityTransferred: json["quantity_transferred"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    transferredBy: json["transferred_by"],
    client: json["client"],
    project: json["project"],
  );

  Map<String, dynamic> toJson() => {
    "work_order_id": workOrderId,
    "product_name": productName,
    "quantity_transferred": quantityTransferred,
    "createdAt": createdAt?.toIso8601String(),
    "transferred_by": transferredBy,
    "client": client,
    "project": project,
  };
}
