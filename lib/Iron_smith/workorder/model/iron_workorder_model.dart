import 'dart:convert';
import 'dart:io' as io;

IronWorkOrder? ironWorkOrderFromJson(String str) =>
    str.isNotEmpty ? IronWorkOrder.fromJson(json.decode(str)) : null;

String ironWorkOrderToJson(IronWorkOrder? data) => json.encode(data?.toJson());

class IronWorkOrder {
  int? statusCode;
  List<IronWorkOrderData>? data;
  String? message;
  bool? success;

  IronWorkOrder({this.statusCode, this.data, this.message, this.success});

  factory IronWorkOrder.fromJson(Map<String, dynamic> json) => IronWorkOrder(
    statusCode: json["statusCode"],
    data: json["data"] == null
        ? []
        : List<IronWorkOrderData>.from(
            json["data"].map((x) => IronWorkOrderData.fromJson(x)),
          ),
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

class IronWorkOrderData {
  String? id;
  TId? clientId;
  TId? projectId;
  String? workOrderNumber;
  String? workOrderDate;
  List<Product>? products;
  List<FileElement>? files;
  String? status;
  AtedBy? createdBy;
  AtedBy? updatedBy;
  String? createdAt;
  String? updatedAt;
  int? v;

  IronWorkOrderData({
    this.id,
    this.clientId,
    this.projectId,
    this.workOrderNumber,
    this.workOrderDate,
    this.products,
    this.files,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory IronWorkOrderData.fromJson(
    Map<String, dynamic> json,
  ) => IronWorkOrderData(
    id: json["_id"],
    clientId: json["clientId"] != null ? TId.fromJson(json["clientId"]) : null,
    projectId: json["projectId"] != null
        ? TId.fromJson(json["projectId"])
        : null,
    workOrderNumber: json["workOrderNumber"],
    workOrderDate: json["workOrderDate"],
    products: json["products"] == null
        ? []
        : List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    files: json["files"] == null
        ? []
        : List<FileElement>.from(
            json["files"].map((x) => FileElement.fromJson(x)),
          ),
    status: json["status"],
    createdBy: json["created_by"] != null
        ? AtedBy.fromJson(json["created_by"])
        : null,
    updatedBy: json["updated_by"] != null
        ? AtedBy.fromJson(json["updated_by"])
        : null,
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "clientId": clientId?.toJson(),
    "projectId": projectId?.toJson(),
    "workOrderNumber": workOrderNumber,
    "workOrderDate": workOrderDate,
    "products": products == null
        ? []
        : List<dynamic>.from(products!.map((x) => x.toJson())),
    "files": files == null
        ? []
        : List<dynamic>.from(files!.map((x) => x.toJson())),
    "status": status,
    "created_by": createdBy?.toJson(),
    "updated_by": updatedBy?.toJson(),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class TId {
  String? id;
  String? name;
  String? address;

  TId({this.id, this.name, this.address});

  factory TId.fromJson(Map<String, dynamic> json) =>
      TId(id: json["_id"], name: json["name"], address: json["address"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
  };
}

class AtedBy {
  String? id;
  String? email;
  String? username;

  AtedBy({this.id, this.email, this.username});

  factory AtedBy.fromJson(Map<String, dynamic> json) =>
      AtedBy(id: json["_id"], email: json["email"], username: json["username"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "username": username,
  };
}

class FileElement {
  String? fileName;
  String? fileUrl;
  io.File? file;
  String? uploadedAt;
  String? id;

  FileElement({
    this.fileName,
    this.fileUrl,
    this.file,
    this.uploadedAt,
    this.id,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
    fileName: json["file_name"],
    file: null,
    fileUrl: json["file_url"],

    uploadedAt: json["uploaded_at"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "file_name": fileName,
    "file_url": fileUrl,
    "uploaded_at": uploadedAt,
    "_id": id,
  };
}

class Product {
  ShapeId? shapeId;
  String? uom;
  int? quantity;
  String? deliveryDate;
  String? barMark;
  String? memberDetails;
  int? memberQuantity;
  int? diameter;
  String? weight;
  List<Dimension>? dimensions;
  String? id;

  Product({
    this.shapeId,
    this.uom,
    this.quantity,
    this.deliveryDate,
    this.barMark,
    this.memberDetails,
    this.memberQuantity,
    this.diameter,
    this.weight,
    this.dimensions,
    this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    shapeId: json["shapeId"] != null ? ShapeId.fromJson(json["shapeId"]) : null,
    uom: json["uom"],
    quantity: json["quantity"],
    deliveryDate: json["deliveryDate"],
    barMark: json["barMark"],
    memberDetails: json["memberDetails"],
    memberQuantity: json["memberQuantity"],
    diameter: json["diameter"],
    weight: json["weight"],
    dimensions: json["dimensions"] == null
        ? []
        : List<Dimension>.from(
            json["dimensions"].map((x) => Dimension.fromJson(x)),
          ),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "shapeId": shapeId?.toJson(),
    "uom": uom,
    "quantity": quantity,
    "deliveryDate": deliveryDate,
    "barMark": barMark,
    "memberDetails": memberDetails,
    "memberQuantity": memberQuantity,
    "diameter": diameter,
    "weight": weight,
    "dimensions": dimensions == null
        ? []
        : List<dynamic>.from(dimensions!.map((x) => x.toJson())),
    "_id": id,
  };
}

class Dimension {
  String? name;
  String? value;
  String? id;

  Dimension({this.name, this.value, this.id});

  factory Dimension.fromJson(Map<String, dynamic> json) =>
      Dimension(name: json["name"], value: json["value"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"name": name, "value": value, "_id": id};
}

class ShapeId {
  String? id;

  ShapeId({this.id, String? shapeCode});

  factory ShapeId.fromJson(Map<String, dynamic> json) =>
      ShapeId(id: json["_id"]);

  Map<String, dynamic> toJson() => {"_id": id};
}

ClientResponse? clientResponseFromJson(String str) =>
    str.isNotEmpty ? ClientResponse.fromJson(json.decode(str)) : null;

String clientResponseToJson(ClientResponse? data) =>
    json.encode(data?.toJson());

class ClientResponse {
  int? statusCode;
  ClientData? data;
  String? message;
  bool? success;

  ClientResponse({this.statusCode, this.data, this.message, this.success});

  factory ClientResponse.fromJson(Map<String, dynamic> json) => ClientResponse(
    statusCode: json["statusCode"],
    data: json["data"] == null ? null : ClientData.fromJson(json["data"]),
    message: json["message"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "data": data?.toJson(),
    "message": message,
    "success": success,
  };
}

class ClientData {
  List<Client>? clients;

  ClientData({this.clients});

  factory ClientData.fromJson(Map<String, dynamic> json) => ClientData(
    clients: json["clients"] == null
        ? []
        : List<Client>.from(json["clients"].map((x) => Client.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "clients": clients == null
        ? []
        : List<dynamic>.from(clients!.map((x) => x.toJson())),
  };
}

class Client {
  String? id;
  String? name;
  String? address;
  bool? isDeleted;
  AtedBy? createdBy;
  String? createdAt;
  String? updatedAt;
  int? v;

  Client({
    this.id,
    this.name,
    this.address,
    this.isDeleted,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json["_id"],
    name: json["name"],
    address: json["address"],
    isDeleted: json["isDeleted"],
    createdBy: json["created_by"] != null
        ? AtedBy.fromJson(json["created_by"])
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

ProjectResponse? projectResponseFromJson(String str) =>
    str.isNotEmpty ? ProjectResponse.fromJson(json.decode(str)) : null;

String projectResponseToJson(ProjectResponse? data) =>
    json.encode(data?.toJson());

class ProjectResponse {
  bool? success;
  String? message;
  List<Project>? data;

  ProjectResponse({this.success, this.message, this.data});

  factory ProjectResponse.fromJson(Map<String, dynamic> json) =>
      ProjectResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<Project>.from(json["data"].map((x) => Project.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Project {
  String? id;
  String? name;

  Project({this.id, this.name});

  factory Project.fromJson(Map<String, dynamic> json) =>
      Project(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

ShapeResponse? shapeResponseFromJson(String str) =>
    str.isNotEmpty ? ShapeResponse.fromJson(json.decode(str)) : null;

// Function to convert ShapeResponse to JSON string
String shapeResponseToJson(ShapeResponse? data) => json.encode(data?.toJson());

class ShapeResponse {
  int? statusCode;
  bool? success;
  String? message;
  ShapeData? data;

  ShapeResponse({this.statusCode, this.success, this.message, this.data});

  factory ShapeResponse.fromJson(Map<String, dynamic> json) => ShapeResponse(
    statusCode: json["statusCode"],
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : ShapeData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class ShapeData {
  List<Shape>? shapes;

  ShapeData({this.shapes});

  factory ShapeData.fromJson(Map<String, dynamic> json) => ShapeData(
    shapes: json["shapes"] == null
        ? []
        : List<Shape>.from(json["shapes"].map((x) => Shape.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "shapes": shapes == null
        ? []
        : List<dynamic>.from(shapes!.map((x) => x.toJson())),
  };
}

class Shape {
  String? id;
  Dimension? dimension;
  String? description;
  String? shapeCode;
  FileElement? file;
  AtedBy? createdBy;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? v;

  Shape({
    this.id,
    this.dimension,
    this.description,
    this.shapeCode,
    this.file,
    this.createdBy,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Shape.fromJson(Map<String, dynamic> json) => Shape(
    id: json["_id"],
    dimension: json["dimension"] == null
        ? null
        : Dimension.fromJson(json["dimension"]),
    description: json["description"],
    shapeCode: json["shape_code"],
    file: json["file"] == null ? null : FileElement.fromJson(json["file"]),
    createdBy: json["created_by"] == null
        ? null
        : AtedBy.fromJson(json["created_by"]),
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "dimension": dimension?.toJson(),
    "description": description,
    "shape_code": shapeCode,
    "file": file?.toJson(),
    "created_by": createdBy?.toJson(),
    "isDeleted": isDeleted,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

// 🔹 Decode JSON string into RawMaterialResponse
DiameterResponse? diameterResponseFromJson(String str) =>
    str.isNotEmpty ? DiameterResponse.fromJson(json.decode(str)) : null;

// 🔹 Encode RawMaterialResponse into JSON string
String diameterResponseToJson(DiameterResponse? data) =>
    json.encode(data?.toJson());

class DiameterResponse {
  bool? success;
  List<DiameterData>? rawMaterialData;
  String? message;

  DiameterResponse({this.success, this.rawMaterialData, this.message});

  factory DiameterResponse.fromJson(Map<String, dynamic> json) =>
      DiameterResponse(
        success: json["success"],
        rawMaterialData: json["rawMaterialData"] == null
            ? []
            : List<DiameterData>.from(
                json["rawMaterialData"].map((x) => DiameterData.fromJson(x)),
              ),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "rawMaterialData": rawMaterialData == null
        ? []
        : List<dynamic>.from(rawMaterialData!.map((x) => x.toJson())),
    "message": message,
  };
}

class DiameterData {
  int? diameter;
  int? qty;

  DiameterData({this.diameter, this.qty});

  factory DiameterData.fromJson(Map<String, dynamic> json) =>
      DiameterData(diameter: json["diameter"], qty: json["qty"]);

  Map<String, dynamic> toJson() => {"diameter": diameter, "qty": qty};
}

DimensionResponse dimensionResponseFromJson(String str) =>
    DimensionResponse.fromJson(json.decode(str));

String dimensionResponseToJson(DimensionResponse data) =>
    json.encode(data.toJson());

class DimensionResponse {
  final bool success;
  final DimensionData? data;

  DimensionResponse({required this.success, this.data});

  factory DimensionResponse.fromJson(Map<String, dynamic> json) =>
      DimensionResponse(
        success: json["success"] ?? false,
        data: json["data"] != null
            ? DimensionData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class DimensionData {
  final String id;
  final String dimensionName;
  final int dimensionCount;
  final int v;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DimensionData({
    required this.id,
    required this.dimensionName,
    required this.dimensionCount,
    required this.v,
    this.createdAt,
    this.updatedAt,
  });

  factory DimensionData.fromJson(Map<String, dynamic> json) => DimensionData(
    id: json["_id"] ?? "",
    dimensionName: json["dimension_name"] ?? "",
    dimensionCount: json["dimension_count"] ?? 0,
    v: json["__v"] ?? 0,
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "dimension_name": dimensionName,
    "dimension_count": dimensionCount,
    "__v": v,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
