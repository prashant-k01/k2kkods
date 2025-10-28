import 'dart:convert';

DispatchDetailResponse dispatchDetailResponseFromJson(String str) =>
    DispatchDetailResponse.fromJson(json.decode(str));

String dispatchDetailResponseToJson(DispatchDetailResponse data) =>
    json.encode(data.toJson());

class DispatchDetailResponse {
  final int? statusCode;
  final DispatchData? data;
  final String? message;
  final bool? success;

  DispatchDetailResponse({
    this.statusCode,
    this.data,
    this.message,
    this.success,
  });

  factory DispatchDetailResponse.fromJson(Map<String, dynamic> json) =>
      DispatchDetailResponse(
        statusCode: json["statusCode"] as int?,
        data: json["data"] != null ? DispatchData.fromJson(json["data"]) : null,
        message: json["message"] as String?,
        success: json["success"] as bool?,
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "data": data?.toJson(),
    "message": message,
    "success": success,
  };
}

class DispatchData {
  final ClientProject? clientProject;
  final String? workOrderName;
  final String? workOrderId;
  final String? jobOrderName;
  final String? jobOrderId;
  final CreatedInfo? createdInfo;
  final List<DispatchProduct>? products;
  final DateTime? dispatchDate;
  final String? invoiceOrSto;
  final String? vehicleNumber;
  final List<String>? invoiceFiles;

  DispatchData({
    this.clientProject,
    this.workOrderName,
    this.workOrderId,
    this.jobOrderName,
    this.jobOrderId,
    this.createdInfo,
    this.products,
    this.dispatchDate,
    this.invoiceOrSto,
    this.vehicleNumber,
    this.invoiceFiles,
  });

  factory DispatchData.fromJson(Map<String, dynamic> json) => DispatchData(
    clientProject: json["client_project"] != null
        ? ClientProject.fromJson(json["client_project"])
        : null,
    workOrderName: json["work_order_name"] as String?,
    workOrderId: json["work_order_id"] as String?,
    jobOrderName: json["job_order_name"] as String?,
    jobOrderId: json["job_order_id"] as String?,
    createdInfo: json["created"] != null
        ? CreatedInfo.fromJson(json["created"])
        : null,
    products: (json["products"] as List<dynamic>?)
        ?.map((e) => DispatchProduct.fromJson(e))
        .toList(),
    dispatchDate: json["dispatch_date"] != null
        ? DateTime.tryParse(json["dispatch_date"])
        : null,
    invoiceOrSto: json["invoice_or_sto"] as String?,
    vehicleNumber: json["vehicle_number"] as String?,
    invoiceFiles: (json["invoice_file"] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "client_project": clientProject?.toJson(),
    "work_order_name": workOrderName,
    "work_order_id": workOrderId,
    "job_order_name": jobOrderName,
    "job_order_id": jobOrderId,
    "created": createdInfo?.toJson(),
    "products": products?.map((e) => e.toJson()).toList(),
    "dispatch_date": dispatchDate?.toIso8601String(),
    "invoice_or_sto": invoiceOrSto,
    "vehicle_number": vehicleNumber,
    "invoice_file": invoiceFiles,
  };
}

class ClientProject {
  final String? clientName;
  final String? projectName;

  ClientProject({this.clientName, this.projectName});

  factory ClientProject.fromJson(Map<String, dynamic> json) => ClientProject(
    clientName: json["client_name"] as String?,
    projectName: json["project_name"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "client_name": clientName,
    "project_name": projectName,
  };
}

class CreatedInfo {
  final String? createdBy;
  final DateTime? createdAt;

  CreatedInfo({this.createdBy, this.createdAt});

  factory CreatedInfo.fromJson(Map<String, dynamic> json) => CreatedInfo(
    createdBy: json["created_by"] as String?,
    createdAt: json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
  };
}

class DispatchProduct {
  final String? productName;
  final List<String>? uoms;
  final String? batchId;
  final int? dispatchQuantity;

  DispatchProduct({
    this.productName,
    this.uoms,
    this.batchId,
    this.dispatchQuantity,
  });

  factory DispatchProduct.fromJson(Map<String, dynamic> json) =>
      DispatchProduct(
        productName: json["product_name"] as String?,
        uoms: (json["uom"] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        batchId: json["batch_id"] as String?,
        dispatchQuantity: json["dispatch_quantity"] is int
            ? json["dispatch_quantity"] as int
            : int.tryParse(json["dispatch_quantity"].toString()),
      );

  Map<String, dynamic> toJson() => {
    "product_name": productName,
    "uom": uoms,
    "batch_id": batchId,
    "dispatch_quantity": dispatchQuantity,
  };
}
