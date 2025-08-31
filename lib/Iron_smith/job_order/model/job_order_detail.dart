import 'dart:convert';

IoWorkOrderDetail? ioWorkOrderDetailFromJson(String str) =>
    str.isNotEmpty ? IoWorkOrderDetail.fromJson(json.decode(str)) : null;

String ioWorkOrderDetailToJson(IoWorkOrderDetail? data) =>
    json.encode(data?.toJson());

class IoWorkOrderDetail {
  int? statusCode;
  Data? data;
  String? message;
  bool? success;

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
  String? id;
  String? jobOrderNumber;
  String? salesOrderNumber;
  DateRange? dateRange;
  List<Product>? products;
  AtedBy? createdBy;
  AtedBy? updatedBy;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? workOrderId;
  String? workOrderNumber;
  Client? client;
  Client? project;

  Data({
    this.id,
    this.jobOrderNumber,
    this.salesOrderNumber,
    this.dateRange,
    this.products,
    this.createdBy,
    this.updatedBy,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.workOrderId,
    this.workOrderNumber,
    this.client,
    this.project,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    jobOrderNumber: json["job_order_number"],
    salesOrderNumber: json["sales_order_number"],
    dateRange: json["date_range"] != null
        ? DateRange.fromJson(json["date_range"])
        : null,
    products:
        (json["products"] as List<dynamic>?)
            ?.map((x) => Product.fromJson(x))
            .toList() ??
        [],
    createdBy: json["created_by"] != null
        ? AtedBy.fromJson(json["created_by"])
        : null,
    updatedBy: json["updated_by"] != null
        ? AtedBy.fromJson(json["updated_by"])
        : null,
    status: json["status"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    workOrderId: json["workOrderId"],
    workOrderNumber: json["workOrderNumber"],
    client: json["client"] != null ? Client.fromJson(json["client"]) : null,
    project: json["project"] != null ? Client.fromJson(json["project"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "job_order_number": jobOrderNumber,
    "sales_order_number": salesOrderNumber,
    "date_range": dateRange?.toJson(),
    "products": products?.map((x) => x.toJson()).toList(),
    "created_by": createdBy?.toJson(),
    "updated_by": updatedBy?.toJson(),
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "workOrderId": workOrderId,
    "workOrderNumber": workOrderNumber,
    "client": client?.toJson(),
    "project": project?.toJson(),
  };
}

class Client {
  String? id;
  String? name;
  String? address;

  Client({this.id, this.name, this.address});

  factory Client.fromJson(Map<String, dynamic> json) =>
      Client(id: json["_id"], name: json["name"], address: json["address"]);

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

class DateRange {
  String? from;
  String? to;

  DateRange({this.from, this.to});

  factory DateRange.fromJson(Map<String, dynamic> json) =>
      DateRange(from: json["from"], to: json["to"]);

  Map<String, dynamic> toJson() => {"from": from, "to": to};
}

class Product {
  String? id;
  String? shapeId;
  String? shapeCode;
  String? uom;
  String? member;
  String? barMark;
  String? weight;
  String? description;
  int? plannedQuantity;
  String? scheduleDate;
  int? dia;
  int? achievedQuantity;
  int? rejectedQuantity;
  List<SelectedMachine>? selectedMachines;
  String? qrCodeId;
  String? qrCodeUrl;
  int? poQuantity;
  List<Dimension>? dimensions;

  Product({
    this.id,
    this.shapeId,
    this.shapeCode,
    this.uom,
    this.member,
    this.barMark,
    this.weight,
    this.description,
    this.plannedQuantity,
    this.scheduleDate,
    this.dia,
    this.achievedQuantity,
    this.rejectedQuantity,
    this.selectedMachines,
    this.qrCodeId,
    this.qrCodeUrl,
    this.poQuantity,
    this.dimensions,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    shapeId: json["shape_id"],
    shapeCode: json["shape_code"],
    uom: json["uom"],
    member: json["member"],
    barMark: json["barMark"],
    weight: json["weight"],
    description: json["description"],
    plannedQuantity: json["planned_quantity"],
    scheduleDate: json["schedule_date"],
    dia: json["dia"],
    achievedQuantity: json["achieved_quantity"],
    rejectedQuantity: json["rejected_quantity"],
    selectedMachines:
        (json["selected_machines"] as List<dynamic>?)
            ?.map((x) => SelectedMachine.fromJson(x))
            .toList() ??
        [],
    qrCodeId: json["qr_code_id"],
    qrCodeUrl: json["qr_code_url"],
    poQuantity: json["po_quantity"],
    dimensions:
        (json["dimensions"] as List<dynamic>?)
            ?.map((x) => Dimension.fromJson(x))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "shape_id": shapeId,
    "shape_code": shapeCode,
    "uom": uom,
    "member": member,
    "barMark": barMark,
    "weight": weight,
    "description": description,
    "planned_quantity": plannedQuantity,
    "schedule_date": scheduleDate,
    "dia": dia,
    "achieved_quantity": achievedQuantity,
    "rejected_quantity": rejectedQuantity,
    "selected_machines": selectedMachines?.map((x) => x.toJson()).toList(),
    "qr_code_id": qrCodeId,
    "qr_code_url": qrCodeUrl,
    "po_quantity": poQuantity,
    "dimensions": dimensions?.map((x) => x.toJson()).toList(),
  };
}

class Dimension {
  String? name;
  String? value;

  Dimension({this.name, this.value});

  factory Dimension.fromJson(Map<String, dynamic> json) =>
      Dimension(name: json["name"], value: json["value"]);

  Map<String, dynamic> toJson() => {"name": name, "value": value};
}

class SelectedMachine {
  String? id;
  String? name;

  SelectedMachine({this.id, this.name});

  factory SelectedMachine.fromJson(Map<String, dynamic> json) =>
      SelectedMachine(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}
