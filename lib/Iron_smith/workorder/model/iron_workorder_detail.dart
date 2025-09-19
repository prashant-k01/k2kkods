// To parse this JSON data, do
//
//     final ioWorkOrderDetail = ioWorkOrderDetailFromJson(jsonString);

import 'dart:convert';

IoWorkOrderDetail ioWorkOrderDetailFromJson(String str) =>
    IoWorkOrderDetail.fromJson(json.decode(str));

String ioWorkOrderDetailToJson(IoWorkOrderDetail? data) =>
    json.encode(data?.toJson());

class IoWorkOrderDetail {
  final int? statusCode;
  final Data? data;
  final String? message;
  final bool? success;

  IoWorkOrderDetail({this.statusCode, this.data, this.message, this.success});

  factory IoWorkOrderDetail.fromJson(Map<String, dynamic> json) =>
      IoWorkOrderDetail(
        statusCode: json["statusCode"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
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

class Data {
  final TId? clientId;
  final TId? projectId;
  final WorkOrderDetails? workOrderDetails;
  final List<Product>? products;
  final List<FileElement>? files;

  Data({
    this.clientId,
    this.projectId,
    this.workOrderDetails,
    this.products,
    this.files,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    clientId: json["client_id"] != null
        ? TId.fromJson(json["client_id"])
        : null,
    projectId: json["project_id"] != null
        ? TId.fromJson(json["project_id"])
        : null,
    workOrderDetails: json["work_order_details"] != null
        ? WorkOrderDetails.fromJson(json["work_order_details"])
        : null,
    products: json["products"] != null
        ? List<Product>.from(json["products"].map((x) => Product.fromJson(x)))
        : [],
    files: json["files"] != null
        ? List<FileElement>.from(
            json["files"].map((x) => FileElement.fromJson(x)),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId?.toJson(),
    "project_id": projectId?.toJson(),
    "work_order_details": workOrderDetails?.toJson(),
    "products": products != null
        ? List<dynamic>.from(products!.map((x) => x.toJson()))
        : [],
    "files": files != null
        ? List<dynamic>.from(files!.map((x) => x.toJson()))
        : [],
  };
}

class TId {
  final String? id;
  final String? name;
  final String? address;

  TId({this.id, this.name, this.address});

  factory TId.fromJson(Map<String, dynamic> json) =>
      TId(id: json["_id"], name: json["name"], address: json["address"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
  };
}

class FileElement {
  final String? fileName;
  final String? fileUrl;
  final DateTime? uploadedAt;
  final String? id;

  FileElement({this.fileName, this.fileUrl, this.uploadedAt, this.id});

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
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

class Product {
  final ShapeId? shapeId;
  final String? barMark;
  final String? uom;
  final int? quantity;
  final String? memberDetails;
  final String? deliveryDate;
  final int? memberQuantity;
  final int? diameter;
  final String? weight;
  final List<Dimension>? dimensions;
  final String? id;

  Product({
    this.shapeId,
    this.barMark,
    this.uom,
    this.quantity,
    this.memberDetails,
    this.deliveryDate,
    this.memberQuantity,
    this.diameter,
    this.weight,
    this.dimensions,
    this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    shapeId: json["shapeId"] != null ? ShapeId.fromJson(json["shapeId"]) : null,
    barMark: json["barMark"],
    uom: json["uom"],
    quantity: json["quantity"],
    memberDetails: json["memberDetails"],
    deliveryDate: json["deliveryDate"],
    memberQuantity: json["memberQuantity"],
    diameter: json["diameter"],
    weight: json["weight"],
    dimensions: json["dimensions"] != null
        ? List<Dimension>.from(
            json["dimensions"].map((x) => Dimension.fromJson(x)),
          )
        : [],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "shapeId": shapeId?.toJson(),
    "barMark": barMark,
    "uom": uom,
    "quantity": quantity,
    "memberDetails": memberDetails,
    "deliveryDate": deliveryDate,
    "memberQuantity": memberQuantity,
    "diameter": diameter,
    "weight": weight,
    "dimensions": dimensions != null
        ? List<dynamic>.from(dimensions!.map((x) => x.toJson()))
        : [],
    "_id": id,
  };
}

class Dimension {
  final String? name;
  final String? value;
  final String? id;

  Dimension({this.name, this.value, this.id});

  factory Dimension.fromJson(Map<String, dynamic> json) =>
      Dimension(name: json["name"], value: json["value"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"name": name, "value": value, "_id": id};
}

class ShapeId {
  final String? id;
  final String? shapeCode;
  final String? description;

  ShapeId({this.id, this.shapeCode, this.description});

  factory ShapeId.fromJson(Map<String, dynamic> json) => ShapeId(
    id: json["_id"],
    shapeCode: json["shape_code"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "shape_code": shapeCode,
    "description": description,
  };
}

class WorkOrderDetails {
  final String? id;
  final String? workOrderNumber;
  final String? createdAt;
  final String? createdBy;
  final String? date;
  final String? status;

  WorkOrderDetails({
    this.id,
    this.workOrderNumber,
    this.createdAt,
    this.createdBy,
    this.date,
    this.status,
  });

  factory WorkOrderDetails.fromJson(Map<String, dynamic> json) =>
      WorkOrderDetails(
        id: json["_id"],
        workOrderNumber: json["work_order_number"],
        createdAt: json["created_at"],
        createdBy: json["created_by"],
        date: json["date"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order_number": workOrderNumber,
    "created_at": createdAt,
    "created_by": createdBy,
    "date": date,
    "status": status,
  };
}
