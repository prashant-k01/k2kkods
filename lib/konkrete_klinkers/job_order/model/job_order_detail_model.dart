import 'dart:convert';

JobOrderDetailResponse jobOrderDetailResponseFromJson(String str) =>
    JobOrderDetailResponse.fromJson(json.decode(str));

String jobOrderDetailResponseToJson(JobOrderDetailResponse data) =>
    json.encode(data.toJson());

class JobOrderDetailResponse {
  final bool? success;
  final String? message;
  final Data? data;

  JobOrderDetailResponse({this.success, this.message, this.data});

  factory JobOrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      JobOrderDetailResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final String? id;
  final String? salesOrderNumber;
  final List<Product>? products;
  final DateTime? batchDate;
  final Date? date;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Client? client;
  final Client? project;
  final WorkOrderDetails? workOrderDetails;
  final String? jobOrderStatus;
  final String? createdBy;

  Data({
    this.id,
    this.salesOrderNumber,
    this.products,
    this.batchDate,
    this.date,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.client,
    this.project,
    this.workOrderDetails,
    this.jobOrderStatus,
    this.createdBy,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    salesOrderNumber: json["sales_order_number"],
    products: json["products"] != null
        ? List<Product>.from(json["products"].map((x) => Product.fromJson(x)))
        : [],
    batchDate: json["batch_date"] != null
        ? DateTime.tryParse(json["batch_date"])
        : null,
    date: json["date"] != null ? Date.fromJson(json["date"]) : null,
    status: json["status"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
    client: json["client"] != null ? Client.fromJson(json["client"]) : null,
    project: json["project"] != null ? Client.fromJson(json["project"]) : null,
    workOrderDetails: json["work_order_details"] != null
        ? WorkOrderDetails.fromJson(json["work_order_details"])
        : null,
    jobOrderStatus: json["job_order_status"],
    createdBy: json["created_by"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sales_order_number": salesOrderNumber,
    "products": products?.map((x) => x.toJson()).toList(),
    "batch_date": batchDate?.toIso8601String(),
    "date": date?.toJson(),
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "client": client?.toJson(),
    "project": project?.toJson(),
    "work_order_details": workOrderDetails?.toJson(),
    "job_order_status": jobOrderStatus,
    "created_by": createdBy,
  };
}

class Client {
  final String? name;
  final String? address;

  Client({this.name, this.address});

  factory Client.fromJson(Map<String, dynamic> json) =>
      Client(name: json["name"], address: json["address"]);

  Map<String, dynamic> toJson() => {"name": name, "address": address};
}

class Date {
  final DateTime? from;
  final DateTime? to;

  Date({this.from, this.to});

  factory Date.fromJson(Map<String, dynamic> json) => Date(
    from: json["from"] != null ? DateTime.tryParse(json["from"]) : null,
    to: json["to"] != null ? DateTime.tryParse(json["to"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "from": from?.toIso8601String(),
    "to": to?.toIso8601String(),
  };
}

class Product {
  final String? id;
  final String? product;
  final int? plannedQuantity;
  final DateTime? scheduledDate;
  final String? description;
  final String? materialCode;
  final String? machineId;
  final String? machineName;
  final String? plantId;
  final String? plantName;
  final int? achievedQuantity;
  final int? rejectedQuantity;

  Product({
    this.id,
    this.product,
    this.plannedQuantity,
    this.scheduledDate,
    this.description,
    this.materialCode,
    this.machineId,
    this.machineName,
    this.plantId,
    this.plantName,
    this.achievedQuantity,
    this.rejectedQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    product: json["product"],
    plannedQuantity: json["planned_quantity"],
    scheduledDate: json["scheduled_date"] != null
        ? DateTime.tryParse(json["scheduled_date"])
        : null,
    description: json["description"],
    materialCode: json["material_code"],
    machineId: json["machine_id"],
    machineName: json["machine_name"],
    plantId: json["plant_id"],
    plantName: json["plant_name"],
    achievedQuantity: json["achieved_quantity"],
    rejectedQuantity: json["rejected_quantity"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "product": product,
    "planned_quantity": plannedQuantity,
    "scheduled_date": scheduledDate?.toIso8601String(),
    "description": description,
    "material_code": materialCode,
    "machine_id": machineId,
    "machine_name": machineName,
    "plant_id": plantId,
    "plant_name": plantName,
    "achieved_quantity": achievedQuantity,
    "rejected_quantity": rejectedQuantity,
  };
}

class WorkOrderDetails {
  final String? id;
  final String? workOrderNumber;
  final String? status;
  final DateTime? createdAt;
  final String? createdBy;

  WorkOrderDetails({
    this.id,
    this.workOrderNumber,
    this.status,
    this.createdAt,
    this.createdBy,
  });

  factory WorkOrderDetails.fromJson(Map<String, dynamic> json) =>
      WorkOrderDetails(
        id: json["_id"],
        workOrderNumber: json["work_order_number"],
        status: json["status"],
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        createdBy: json["created_by"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order_number": workOrderNumber,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "created_by": createdBy,
  };
}
