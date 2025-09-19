import 'dart:convert';

WODWorkOrderDetails wodWorkOrderDetailsFromJson(String str) =>
    WODWorkOrderDetails.fromJson(json.decode(str));

String wodWorkOrderDetailsToJson(WODWorkOrderDetails data) =>
    json.encode(data.toJson());

class WODWorkOrderDetails {
  bool success;
  String message;
  WODData? data;

  WODWorkOrderDetails({
    required this.success,
    required this.message,
    this.data,
  });

  factory WODWorkOrderDetails.fromJson(Map<String, dynamic> json) =>
      WODWorkOrderDetails(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null ? WODData.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class WODData {
  String id;
  WODClientId clientId;
  WODProjectId? projectId;
  String workOrderNumber;
  DateTime? date;
  bool bufferStock;
  List<WODDataProduct> products;
  List<WODFileElement> files;
  String status;
  WODTedBy createdBy;
  WODUpdatedBy? updatedBy;
  List<dynamic> bufferTransferLogs;
  List<WODJobOrder> jobOrders;
  DateTime? createdAt;
  DateTime? updatedAt;
  int v;
  List<WODPacking> packings;
  List<WODDispatch> dispatches;
  List<WODQcDetail> qcDetails;

  WODData({
    required this.id,
    required this.clientId,
    this.projectId,
    required this.workOrderNumber,
    this.date,
    required this.bufferStock,
    required this.products,
    required this.files,
    required this.status,
    required this.createdBy,
    this.updatedBy,
    required this.bufferTransferLogs,
    required this.jobOrders,
    this.createdAt,
    this.updatedAt,
    required this.v,
    required this.packings,
    required this.dispatches,
    required this.qcDetails,
  });

  factory WODData.fromJson(Map<String, dynamic> json) => WODData(
    id: json["_id"] ?? '',
    clientId: WODClientId.fromJson(json["client_id"] ?? {}),
    projectId: json["project_id"] != null
        ? WODProjectId.fromJson(json["project_id"])
        : null,
    workOrderNumber: json["work_order_number"] ?? '',
    date: json["date"] != null ? _parseDateTime(json["date"]) : null,
    bufferStock: json["buffer_stock"] ?? false,
    products:
        (json["products"] as List<dynamic>?)
            ?.map((x) => WODDataProduct.fromJson(x))
            .toList() ??
        [],
    files:
        (json["files"] as List<dynamic>?)
            ?.map((x) => WODFileElement.fromJson(x))
            .toList() ??
        [],
    status: json["status"] ?? '',
    createdBy: WODTedBy.fromJson(json["created_by"] ?? {}),
    updatedBy: json["updated_by"] != null
        ? WODUpdatedBy.fromJson(json["updated_by"])
        : null,
    bufferTransferLogs:
        (json["buffer_transfer_logs"] as List<dynamic>?)?.toList() ?? [],
    jobOrders:
        (json["job_orders"] as List<dynamic>?)
            ?.map((x) => WODJobOrder.fromJson(x))
            .toList() ??
        [],
    createdAt: json["created_at"] != null
        ? _parseDateTime(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? _parseDateTime(json["updated_at"])
        : null,
    v: json["__v"] ?? 0,
    packings:
        (json["packings"] as List<dynamic>?)
            ?.map((x) => WODPacking.fromJson(x))
            .toList() ??
        [],
    dispatches:
        (json["dispatches"] as List<dynamic>?)
            ?.map((x) => WODDispatch.fromJson(x))
            .toList() ??
        [],
    qcDetails:
        (json["qc_details"] as List<dynamic>?)
            ?.map((x) => WODQcDetail.fromJson(x))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "client_id": clientId.toJson(),
    "project_id": projectId?.toJson(),
    "work_order_number": workOrderNumber,
    "date": date?.toIso8601String(),
    "buffer_stock": bufferStock,
    "products": products.map((x) => x.toJson()).toList(),
    "files": files.map((x) => x.toJson()).toList(),
    "status": status,
    "created_by": createdBy.toJson(),
    "updated_by": updatedBy?.toJson(),
    "buffer_transfer_logs": bufferTransferLogs,
    "job_orders": jobOrders.map((x) => x.toJson()).toList(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "__v": v,
    "packings": packings.map((x) => x.toJson()).toList(),
    "dispatches": dispatches.map((x) => x.toJson()).toList(),
    "qc_details": qcDetails.map((x) => x.toJson()).toList(),
  };

  void clear() {}

  void add(WODData workOrder) {}
}

DateTime? _parseDateTime(String? dateStr) {
  if (dateStr == null) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    print('Error parsing DateTime: $e for string: $dateStr');
    return null;
  }
}

class WODClientId {
  String id;
  String name;
  String address;

  WODClientId({required this.id, required this.name, required this.address});

  factory WODClientId.fromJson(Map<String, dynamic> json) => WODClientId(
    id: json["_id"] ?? '',
    name: json["name"] ?? '',
    address: json["address"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
  };
}

class WODTedBy {
  String id;
  String username;
  String userType;

  WODTedBy({required this.id, required this.username, required this.userType});

  factory WODTedBy.fromJson(Map<String, dynamic> json) => WODTedBy(
    id: json["_id"] ?? '',
    username: json["username"] ?? '',
    userType: json["userType"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "username": username,
    "userType": userType,
  };
}

class WODUpdatedBy {
  String id;
  String username;

  WODUpdatedBy({required this.id, required this.username});

  factory WODUpdatedBy.fromJson(Map<String, dynamic> json) =>
      WODUpdatedBy(id: json["_id"] ?? '', username: json["username"] ?? '');

  Map<String, dynamic> toJson() => {"_id": id, "username": username};
}

class WODProjectId {
  String id;
  String name;
  WODClient client;

  WODProjectId({required this.id, required this.name, required this.client});

  factory WODProjectId.fromJson(Map<String, dynamic> json) => WODProjectId(
    id: json["_id"] ?? '',
    name: json["name"] ?? '',
    client: WODClient.fromJson(json["client"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "client": client.toJson(),
  };
}

class WODClient {
  String id;
  String name;

  WODClient({required this.id, required this.name});

  factory WODClient.fromJson(Map<String, dynamic> json) =>
      WODClient(id: json["_id"] ?? '', name: json["name"] ?? '');

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class WODDataProduct {
  String uom;
  int poQuantity;
  int qtyInNos;
  String id;
  WODFluffyProduct product;
  WODPlant plant;
  int achievedQuantity;
  int packedQuantity;
  int dispatchedQuantity;
  DateTime? deliveryDate;

  WODDataProduct({
    required this.uom,
    required this.poQuantity,
    required this.qtyInNos,
    required this.id,
    required this.product,
    required this.plant,
    required this.achievedQuantity,
    required this.packedQuantity,
    required this.dispatchedQuantity,
    this.deliveryDate,
  });

  factory WODDataProduct.fromJson(Map<String, dynamic> json) => WODDataProduct(
    uom: json["uom"] ?? '',
    poQuantity: (json["po_quantity"] as num?)?.toInt() ?? 0,
    qtyInNos: (json["qty_in_nos"] as num?)?.toInt() ?? 0,
    id: json["_id"] ?? '',
    product: WODFluffyProduct.fromJson(json["product"] ?? {}),
    plant: WODPlant.fromJson(json["plant"] ?? {}),
    achievedQuantity: (json["achieved_quantity"] as num?)?.toInt() ?? 0,
    packedQuantity: (json["packed_quantity"] as num?)?.toInt() ?? 0,
    dispatchedQuantity: (json["dispatched_quantity"] as num?)?.toInt() ?? 0,
    deliveryDate: json["delivery_date"] != null
        ? _parseDateTime(json["delivery_date"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "uom": uom,
    "po_quantity": poQuantity,
    "qty_in_nos": qtyInNos,
    "_id": id,
    "product": product.toJson(),
    "plant": plant.toJson(),
    "achieved_quantity": achievedQuantity,
    "packed_quantity": packedQuantity,
    "dispatched_quantity": dispatchedQuantity,
    "delivery_date": deliveryDate?.toIso8601String(),
  };
}

class WODFluffyProduct {
  String id;
  WODPlant plant;
  String materialCode;
  String description;
  List<String> uom;

  WODFluffyProduct({
    required this.id,
    required this.plant,
    required this.materialCode,
    required this.description,
    required this.uom,
  });

  factory WODFluffyProduct.fromJson(Map<String, dynamic> json) =>
      WODFluffyProduct(
        id: json["_id"] ?? '',
        plant: WODPlant.fromJson(json["plant"] ?? {}),
        materialCode: json["material_code"] ?? '',
        description: json["description"] ?? '',
        uom: (json["uom"] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "plant": plant.toJson(),
    "material_code": materialCode,
    "description": description,
    "uom": uom,
  };
}

class WODPlant {
  String id;
  String plantCode;

  WODPlant({required this.id, required this.plantCode});

  factory WODPlant.fromJson(Map<String, dynamic> json) =>
      WODPlant(id: json["_id"] ?? '', plantCode: json["plant_code"] ?? '');

  Map<String, dynamic> toJson() => {"_id": id, "plant_code": plantCode};
}

class WODFileElement {
  String fileName;
  String fileUrl;
  String id;
  DateTime? uploadedAt;

  WODFileElement({
    required this.fileName,
    required this.fileUrl,
    required this.id,
    this.uploadedAt,
  });

  factory WODFileElement.fromJson(Map<String, dynamic> json) => WODFileElement(
    fileName: json["file_name"] ?? '',
    fileUrl: json["file_url"] ?? '',
    id: json["_id"] ?? '',
    uploadedAt: json["uploaded_at"] != null
        ? _parseDateTime(json["uploaded_at"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "file_name": fileName,
    "file_url": fileUrl,
    "_id": id,
    "uploaded_at": uploadedAt?.toIso8601String(),
  };
}

class WODJobOrder {
  String id;
  String jobOrderId;
  String workOrder;
  String salesOrderNumber;
  List<WODJobOrderProduct> products;
  int batchNumber;
  WODDate date;
  WODTedBy createdBy;
  WODUpdatedBy updatedBy;
  String status;
  DateTime? createdAt;
  DateTime? updatedAt;

  WODJobOrder({
    required this.id,
    required this.jobOrderId,
    required this.workOrder,
    required this.salesOrderNumber,
    required this.products,
    required this.batchNumber,
    required this.date,
    required this.createdBy,
    required this.updatedBy,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory WODJobOrder.fromJson(Map<String, dynamic> json) => WODJobOrder(
    id: json["_id"] ?? '',
    jobOrderId: json["job_order_id"] ?? '',
    workOrder: json["work_order"] ?? '',
    salesOrderNumber: json["sales_order_number"] ?? '',
    products:
        (json["products"] as List<dynamic>?)
            ?.map((x) => WODJobOrderProduct.fromJson(x))
            .toList() ??
        [],
    batchNumber: (json["batch_number"] as num?)?.toInt() ?? 0,
    date: WODDate.fromJson(json["date"] ?? {}),
    createdBy: WODTedBy.fromJson(json["created_by"] ?? {}),
    updatedBy: WODUpdatedBy.fromJson(json["updated_by"] ?? {}),
    status: json["status"] ?? '',
    createdAt: json["created_at"] != null
        ? _parseDateTime(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? _parseDateTime(json["updated_at"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "job_order_id": jobOrderId,
    "work_order": workOrder,
    "sales_order_number": salesOrderNumber,
    "products": products.map((x) => x.toJson()).toList(),
    "batch_number": batchNumber,
    "date": date.toJson(),
    "created_by": createdBy.toJson(),
    "updated_by": updatedBy.toJson(),
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class WODDate {
  DateTime? from;
  DateTime? to;

  WODDate({this.from, this.to});

  factory WODDate.fromJson(Map<String, dynamic> json) => WODDate(
    from: json["from"] != null ? _parseDateTime(json["from"]) : null,
    to: json["to"] != null ? _parseDateTime(json["to"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "from": from?.toIso8601String(),
    "to": to?.toIso8601String(),
  };
}

class WODJobOrderProduct {
  WODPurpleProduct product;
  WODClient machineName;
  int plannedQuantity;
  DateTime? scheduledDate;
  String id;
  String uom;
  int poQuantity;
  WODDailyProduction dailyProduction;

  WODJobOrderProduct({
    required this.product,
    required this.machineName,
    required this.plannedQuantity,
    this.scheduledDate,
    required this.id,
    required this.uom,
    required this.poQuantity,
    required this.dailyProduction,
  });

  factory WODJobOrderProduct.fromJson(Map<String, dynamic> json) =>
      WODJobOrderProduct(
        product: WODPurpleProduct.fromJson(json["product"] ?? {}),
        machineName: WODClient.fromJson(json["machine_name"] ?? {}),
        plannedQuantity: (json["planned_quantity"] as num?)?.toInt() ?? 0,
        scheduledDate: json["scheduled_date"] != null
            ? _parseDateTime(json["scheduled_date"])
            : null,
        id: json["_id"] ?? '',
        uom: json["uom"] ?? '',
        poQuantity: (json["po_quantity"] as num?)?.toInt() ?? 0,
        dailyProduction: WODDailyProduction.fromJson(
          json["daily_production"] ?? {},
        ),
      );

  Map<String, dynamic> toJson() => {
    "product": product.toJson(),
    "machine_name": machineName.toJson(),
    "planned_quantity": plannedQuantity,
    "scheduled_date": scheduledDate?.toIso8601String(),
    "_id": id,
    "uom": uom,
    "po_quantity": poQuantity,
    "daily_production": dailyProduction.toJson(),
  };
}

class WODPurpleProduct {
  String id;
  String materialCode;
  String description;

  WODPurpleProduct({
    required this.id,
    required this.materialCode,
    required this.description,
  });

  factory WODPurpleProduct.fromJson(Map<String, dynamic> json) =>
      WODPurpleProduct(
        id: json["_id"] ?? '',
        materialCode: json["material_code"] ?? '',
        description: json["description"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "material_code": materialCode,
    "description": description,
  };
}

class WODDailyProduction {
  String id;
  List<WODDailyProductionProduct> products;
  DateTime? date;
  WODTedBy submittedBy;
  String status;
  String createdBy;
  String updatedBy;
  List<dynamic> downtime;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? startedAt;
  dynamic qcCheckedBy;

  WODDailyProduction({
    required this.id,
    required this.products,
    this.date,
    required this.submittedBy,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.downtime,
    this.createdAt,
    this.updatedAt,
    this.startedAt,
    this.qcCheckedBy,
  });

  factory WODDailyProduction.fromJson(Map<String, dynamic> json) =>
      WODDailyProduction(
        id: json["_id"] ?? '',
        products:
            (json["products"] as List<dynamic>?)
                ?.map((x) => WODDailyProductionProduct.fromJson(x))
                .toList() ??
            [],
        date: json["date"] != null ? _parseDateTime(json["date"]) : null,
        submittedBy: WODTedBy.fromJson(json["submitted_by"] ?? {}),
        status: json["status"] ?? '',
        createdBy: json["created_by"] ?? '',
        updatedBy: json["updated_by"] ?? '',
        downtime: (json["downtime"] as List<dynamic>?)?.toList() ?? [],
        createdAt: json["created_at"] != null
            ? _parseDateTime(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? _parseDateTime(json["updated_at"])
            : null,
        startedAt: json["started_at"] != null
            ? _parseDateTime(json["started_at"])
            : null,
        qcCheckedBy: json["qc_checked_by"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "products": products.map((x) => x.toJson()).toList(),
    "date": date?.toIso8601String(),
    "submitted_by": submittedBy.toJson(),
    "status": status,
    "created_by": createdBy,
    "updated_by": updatedBy,
    "downtime": downtime,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "started_at": startedAt?.toIso8601String(),
    "qc_checked_by": qcCheckedBy,
  };
}

class WODDailyProductionProduct {
  int achievedQuantity;
  int rejectedQuantity;
  int recycledQuantity;
  String id;
  WODPurpleProduct product;

  WODDailyProductionProduct({
    required this.achievedQuantity,
    required this.rejectedQuantity,
    required this.recycledQuantity,
    required this.id,
    required this.product,
  });

  factory WODDailyProductionProduct.fromJson(Map<String, dynamic> json) =>
      WODDailyProductionProduct(
        achievedQuantity: (json["achieved_quantity"] as num?)?.toInt() ?? 0,
        rejectedQuantity: (json["rejected_quantity"] as num?)?.toInt() ?? 0,
        recycledQuantity: (json["recycled_quantity"] as num?)?.toInt() ?? 0,
        id: json["_id"] ?? '',
        product: WODPurpleProduct.fromJson(json["product"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "achieved_quantity": achievedQuantity,
    "rejected_quantity": rejectedQuantity,
    "recycled_quantity": recycledQuantity,
    "_id": id,
    "product": product.toJson(),
  };
}

class WODPacking {
  int slNo;
  String product;
  String date;
  int totalQty;
  int rejectedQuantity;
  String createdBy;

  WODPacking({
    required this.slNo,
    required this.product,
    required this.date,
    required this.totalQty,
    required this.rejectedQuantity,
    required this.createdBy,
  });

  factory WODPacking.fromJson(Map<String, dynamic> json) => WODPacking(
    slNo: (json["sl_no"] as num?)?.toInt() ?? 0,
    product: json["product"] ?? '',
    date: json["date"] ?? '',
    totalQty: (json["total_qty"] as num?)?.toInt() ?? 0,
    rejectedQuantity: (json["rejected_quantity"] as num?)?.toInt() ?? 0,
    createdBy: json["created_by"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "sl_no": slNo,
    "product": product,
    "date": date,
    "total_qty": totalQty,
    "rejected_quantity": rejectedQuantity,
    "created_by": createdBy,
  };
}

class WODDispatch {
  int slNo;
  String product;
  String date;
  int totalQty;
  List<String> uom;
  String vehicleNumber;

  WODDispatch({
    required this.slNo,
    required this.product,
    required this.date,
    required this.totalQty,
    required this.uom,
    required this.vehicleNumber,
  });

  factory WODDispatch.fromJson(Map<String, dynamic> json) => WODDispatch(
    slNo: (json["sl_no"] as num?)?.toInt() ?? 0,
    product: json["product"] ?? '',
    date: json["date"] ?? '',
    totalQty: (json["total_qty"] as num?)?.toInt() ?? 0,
    uom: (json["uom"] as List<dynamic>?)?.cast<String>() ?? [],
    vehicleNumber: json["vehicle_number"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "sl_no": slNo,
    "product": product,
    "date": date,
    "total_qty": totalQty,
    "uom": uom,
    "vehicle_number": vehicleNumber,
  };
}

class WODQcDetail {
  int slNo;
  String product;
  int recycledQuantity;
  int rejectedQuantity;
  String remarks;

  WODQcDetail({
    required this.slNo,
    required this.product,
    required this.recycledQuantity,
    required this.rejectedQuantity,
    required this.remarks,
  });

  factory WODQcDetail.fromJson(Map<String, dynamic> json) => WODQcDetail(
    slNo: (json["sl_no"] as num?)?.toInt() ?? 0,
    product: json["product"] ?? '',
    recycledQuantity: (json["recycled_quantity"] as num?)?.toInt() ?? 0,
    rejectedQuantity: (json["rejected_quantity"] as num?)?.toInt() ?? 0,
    remarks: json["remarks"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "sl_no": slNo,
    "product": product,
    "recycled_quantity": recycledQuantity,
    "rejected_quantity": rejectedQuantity,
    "remarks": remarks,
  };
}
