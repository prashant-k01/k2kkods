import 'dart:convert';

QcCheckDetailResponse qcCheckDetailResponseFromJson(String str) =>
    QcCheckDetailResponse.fromJson(json.decode(str));

String qcCheckDetailResponseToJson(QcCheckDetailResponse data) =>
    json.encode(data.toJson());

class QcCheckDetailResponse {
  bool? success;
  String? message;
  QcCheckDetail? data;

  QcCheckDetailResponse({this.success, this.message, this.data});

  factory QcCheckDetailResponse.fromJson(Map<String, dynamic> json) =>
      QcCheckDetailResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] != null
            ? QcCheckDetail.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };

  QcCheckDetailResponse copyWith({
    bool? success,
    String? message,
    QcCheckDetail? data,
  }) => QcCheckDetailResponse(
    success: success ?? this.success,
    message: message ?? this.message,
    data: data ?? this.data,
  );
}

class QcCheckDetail {
  String? id;
  WorkOrder? workOrder;
  JobOrder? jobOrder;
  ProductId? productId;
  int? rejectedQuantity;
  int? recycledQuantity;
  String? remarks;
  CreatedBy? createdBy;
  DateTime? createdAt;

  QcCheckDetail({
    this.id,
    this.workOrder,
    this.jobOrder,
    this.productId,
    this.rejectedQuantity,
    this.recycledQuantity,
    this.remarks,
    this.createdBy,
    this.createdAt,
  });

  factory QcCheckDetail.fromJson(Map<String, dynamic> json) => QcCheckDetail(
    id: json["_id"],
    workOrder: json["work_order"] != null
        ? WorkOrder.fromJson(json["work_order"])
        : null,
    jobOrder: json["job_order"] != null
        ? JobOrder.fromJson(json["job_order"])
        : null,
    productId: json["product_id"] != null
        ? ProductId.fromJson(json["product_id"])
        : null,
    rejectedQuantity: json["rejected_quantity"],
    recycledQuantity: json["recycled_quantity"],
    remarks: json["remarks"],
    createdBy: json["created_by"] != null
        ? CreatedBy.fromJson(json["created_by"])
        : null,
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order": workOrder?.toJson(),
    "job_order": jobOrder?.toJson(),
    "product_id": productId?.toJson(),
    "rejected_quantity": rejectedQuantity,
    "recycled_quantity": recycledQuantity,
    "remarks": remarks,
    "created_by": createdBy?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
  };

  QcCheckDetail copyWith({
    String? id,
    WorkOrder? workOrder,
    JobOrder? jobOrder,
    ProductId? productId,
    int? rejectedQuantity,
    int? recycledQuantity,
    String? remarks,
    CreatedBy? createdBy,
    DateTime? createdAt,
  }) => QcCheckDetail(
    id: id ?? this.id,
    workOrder: workOrder ?? this.workOrder,
    jobOrder: jobOrder ?? this.jobOrder,
    productId: productId ?? this.productId,
    rejectedQuantity: rejectedQuantity ?? this.rejectedQuantity,
    recycledQuantity: recycledQuantity ?? this.recycledQuantity,
    remarks: remarks ?? this.remarks,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
}

class CreatedBy {
  String? id;
  String? username;

  CreatedBy({this.id, this.username});

  factory CreatedBy.fromJson(Map<String, dynamic> json) =>
      CreatedBy(id: json["_id"], username: json["username"]);

  Map<String, dynamic> toJson() => {"_id": id, "username": username};

  CreatedBy copyWith({String? id, String? username}) =>
      CreatedBy(id: id ?? this.id, username: username ?? this.username);
}

class JobOrder {
  String? id;
  String? jobOrderId;

  JobOrder({this.id, this.jobOrderId});

  factory JobOrder.fromJson(Map<String, dynamic> json) =>
      JobOrder(id: json["_id"], jobOrderId: json["job_order_id"]);

  Map<String, dynamic> toJson() => {"_id": id, "job_order_id": jobOrderId};

  JobOrder copyWith({String? id, String? jobOrderId}) =>
      JobOrder(id: id ?? this.id, jobOrderId: jobOrderId ?? this.jobOrderId);
}

class ProductId {
  String? id;
  String? materialCode;
  String? description;

  ProductId({this.id, this.materialCode, this.description});

  factory ProductId.fromJson(Map<String, dynamic> json) => ProductId(
    id: json["_id"],
    materialCode: json["material_code"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "material_code": materialCode,
    "description": description,
  };

  ProductId copyWith({String? id, String? materialCode, String? description}) =>
      ProductId(
        id: id ?? this.id,
        materialCode: materialCode ?? this.materialCode,
        description: description ?? this.description,
      );
}

class WorkOrder {
  String? id;
  String? workOrderNumber;

  WorkOrder({this.id, this.workOrderNumber});

  factory WorkOrder.fromJson(Map<String, dynamic> json) =>
      WorkOrder(id: json["_id"], workOrderNumber: json["work_order_number"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order_number": workOrderNumber,
  };

  WorkOrder copyWith({String? id, String? workOrderNumber}) => WorkOrder(
    id: id ?? this.id,
    workOrderNumber: workOrderNumber ?? this.workOrderNumber,
  );
}
