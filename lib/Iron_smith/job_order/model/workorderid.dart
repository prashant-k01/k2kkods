import 'dart:convert';

JoWorkOrder joWorkOrderFromJson(String str) =>
    JoWorkOrder.fromJson(json.decode(str));

String joWorkOrderToJson(JoWorkOrder data) => json.encode(data.toJson());

class JoWorkOrder {
  int? statusCode;
  JoData? data;
  String? message;
  bool? success;

  JoWorkOrder({this.statusCode, this.data, this.message, this.success});

  factory JoWorkOrder.fromJson(Map<String, dynamic> json) => JoWorkOrder(
    statusCode: json["statusCode"],
    data: json["data"] != null ? JoData.fromJson(json["data"]) : null,
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

class JoData {
  String? workOrderId;
  String? workOrderNumber;
  DateTime? workOrderDate;
  JoClient? client;
  JoClient? project;
  List<JoProduct>? products;
  String? status;
  List<JoFile>? files;

  JoData({
    this.workOrderId,
    this.workOrderNumber,
    this.workOrderDate,
    this.client,
    this.project,
    this.products,
    this.status,
    this.files,
  });

  factory JoData.fromJson(Map<String, dynamic> json) => JoData(
    workOrderId: json["workOrderId"],
    workOrderNumber: json["workOrderNumber"],
    workOrderDate: json["workOrderDate"] != null
        ? DateTime.tryParse(json["workOrderDate"])
        : null,
    client: json["client"] != null ? JoClient.fromJson(json["client"]) : null,
    project: json["project"] != null
        ? JoClient.fromJson(json["project"])
        : null,
    products: json["products"] != null
        ? List<JoProduct>.from(
            json["products"].map((x) => JoProduct.fromJson(x)),
          )
        : [],
    status: json["status"],
    files: json["files"] != null
        ? List<JoFile>.from(json["files"].map((x) => JoFile.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "workOrderId": workOrderId,
    "workOrderNumber": workOrderNumber,
    "workOrderDate": workOrderDate?.toIso8601String(),
    "client": client?.toJson(),
    "project": project?.toJson(),
    "products": products != null
        ? List<dynamic>.from(products!.map((x) => x.toJson()))
        : [],
    "status": status,
    "files": files != null
        ? List<dynamic>.from(files!.map((x) => x.toJson()))
        : [],
  };
}

class JoClient {
  String? id;
  String? name;
  String? address;
  String? client;

  JoClient({this.id, this.name, this.address, this.client});

  factory JoClient.fromJson(Map<String, dynamic> json) => JoClient(
    id: json["_id"],
    name: json["name"],
    address: json["address"],
    client: json["client"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
    "client": client,
  };
}

class JoFile {
  String? fileName;
  String? fileUrl;
  DateTime? uploadedAt;
  String? id;

  JoFile({this.fileName, this.fileUrl, this.uploadedAt, this.id});

  factory JoFile.fromJson(Map<String, dynamic> json) => JoFile(
    fileName: json["file_name"],
    fileUrl: json["file_url"],
    uploadedAt: json["uploaded_at"] != null
        ? DateTime.tryParse(json["uploaded_at"])
        : null,
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "file_name": fileName,
    "file_url": fileUrl,
    "uploaded_at": uploadedAt?.toIso8601String(),
    "_id": id,
  };
}

class JoProduct {
  String? objId;
  String? shapeId;
  String? shapeName;
  String? uom;
  int? poQuantity;
  int? achievedQuantity;
  int? rejectedQuantity;
  DateTime? deliveryDate;
  String? barMark;
  String? memberDetails;
  int? memberQuantity;
  int? diameter;
  String? weight;
  List<JoDimension>? dimensions;

  JoProduct({
    this.objId,
    this.shapeId,
    this.shapeName,
    this.uom,
    this.poQuantity,
    this.achievedQuantity,
    this.rejectedQuantity,
    this.deliveryDate,
    this.barMark,
    this.memberDetails,
    this.memberQuantity,
    this.diameter,
    this.weight,
    this.dimensions,
  });

  factory JoProduct.fromJson(Map<String, dynamic> json) => JoProduct(
    objId: json["objId"],
    shapeId: json["shapeId"],
    shapeName: json["shapeName"],
    uom: json["uom"],
    poQuantity: json["poQuantity"],
    achievedQuantity: json["achievedQuantity"],
    rejectedQuantity: json["rejectedQuantity"],
    deliveryDate: json["deliveryDate"] != null
        ? DateTime.tryParse(json["deliveryDate"])
        : null,
    barMark: json["barMark"],
    memberDetails: json["memberDetails"],
    memberQuantity: json["memberQuantity"],
    diameter: json["diameter"],
    weight: json["weight"],
    dimensions: json["dimensions"] != null
        ? List<JoDimension>.from(
            json["dimensions"].map((x) => JoDimension.fromJson(x)),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "objId": objId,
    "shapeId": shapeId,
    "shapeName": shapeName,
    "uom": uom,
    "poQuantity": poQuantity,
    "achievedQuantity": achievedQuantity,
    "rejectedQuantity": rejectedQuantity,
    "deliveryDate": deliveryDate?.toIso8601String(),
    "barMark": barMark,
    "memberDetails": memberDetails,
    "memberQuantity": memberQuantity,
    "diameter": diameter,
    "weight": weight,
    "dimensions": dimensions != null
        ? List<dynamic>.from(dimensions!.map((x) => x.toJson()))
        : [],
  };
}

class JoDimension {
  String? name;
  String? value;
  String? id;

  JoDimension({this.name, this.value, this.id});

  factory JoDimension.fromJson(Map<String, dynamic> json) =>
      JoDimension(name: json["name"], value: json["value"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"name": name, "value": value, "_id": id};
}
