import 'dart:convert';

/// Decode from JSON string
InventoryDetailResponse inventoryDetailResponseFromJson(String str) =>
    InventoryDetailResponse.fromJson(json.decode(str));

/// Encode to JSON string
String inventoryDetailResponseToJson(InventoryDetailResponse data) =>
    json.encode(data.toJson());

/// Root response model for inventory detail
class InventoryDetailResponse {
  final bool? success;
  final String? message;
  final InventoryData? data;

  InventoryDetailResponse({this.success, this.message, this.data});

  factory InventoryDetailResponse.fromJson(Map<String, dynamic> json) =>
      InventoryDetailResponse(
        success: json["success"] as bool?,
        message: json["message"] as String?,
        data: json["data"] != null
            ? InventoryData.fromJson(json["data"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

/// Data container class that holds the product details list
class InventoryData {
  final List<ProductDetail>? productDetails;

  InventoryData({this.productDetails});

  factory InventoryData.fromJson(Map<String, dynamic> json) => InventoryData(
    productDetails: (json["product_details"] as List<dynamic>?)
        ?.map((x) => ProductDetail.fromJson(x))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    "product_details": productDetails?.map((x) => x.toJson()).toList() ?? [],
  };
}

/// Represents a single product item within inventory
class ProductDetail {
  final WorkOrder? workOrder;
  final ClientInfo? client;
  final ClientInfo? project;
  final String? productId;
  final String? materialCode;
  final String? description;
  final String? uom;
  final int? poQuantity;
  final int? producedQuantity;
  final int? packedQuantity;
  final int? dispatchedQuantity;
  final int? availableStock;
  final int? balanceQuantity;

  ProductDetail({
    this.workOrder,
    this.client,
    this.project,
    this.productId,
    this.materialCode,
    this.description,
    this.uom,
    this.poQuantity,
    this.producedQuantity,
    this.packedQuantity,
    this.dispatchedQuantity,
    this.availableStock,
    this.balanceQuantity,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) => ProductDetail(
    workOrder: json["work_order"] != null
        ? WorkOrder.fromJson(json["work_order"])
        : null,
    client: json["client"] != null ? ClientInfo.fromJson(json["client"]) : null,
    project: json["project"] != null
        ? ClientInfo.fromJson(json["project"])
        : null,
    productId: json["product_id"] as String?,
    materialCode: json["material_code"] as String?,
    description: json["description"] as String?,
    uom: json["uom"] as String?,
    poQuantity: json["po_quantity"] as int?,
    producedQuantity: json["produced_quantity"] as int?,
    packedQuantity: json["packed_quantity"] as int?,
    dispatchedQuantity: json["dispatched_quantity"] as int?,
    availableStock: json["available_stock"] as int?,
    balanceQuantity: json["balance_quantity"] as int?,
  );

  Map<String, dynamic> toJson() => {
    "work_order": workOrder?.toJson(),
    "client": client?.toJson(),
    "project": project?.toJson(),
    "product_id": productId,
    "material_code": materialCode,
    "description": description,
    "uom": uom,
    "po_quantity": poQuantity,
    "produced_quantity": producedQuantity,
    "packed_quantity": packedQuantity,
    "dispatched_quantity": dispatchedQuantity,
    "available_stock": availableStock,
    "balance_quantity": balanceQuantity,
  };
}

/// Represents a client or project entity
class ClientInfo {
  final String? id;
  final String? name;
  final String? address;

  ClientInfo({this.id, this.name, this.address});

  factory ClientInfo.fromJson(Map<String, dynamic> json) => ClientInfo(
    id: json["_id"] as String?,
    name: json["name"] as String?,
    address: json["address"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "address": address,
  };
}

/// Represents a work order associated with a product
class WorkOrder {
  final String? id;
  final String? workOrderNumber;
  final DateTime? createdAt;
  final String? createdBy;
  final String? status;

  WorkOrder({
    this.id,
    this.workOrderNumber,
    this.createdAt,
    this.createdBy,
    this.status,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) => WorkOrder(
    id: json["_id"] as String?,
    workOrderNumber: json["work_order_number"] as String?,
    createdAt: json["created_at"] != null
        ? DateTime.tryParse(json["created_at"])
        : null,
    createdBy: json["created_by"] as String?,
    status: json["status"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order_number": workOrderNumber,
    "created_at": createdAt?.toIso8601String(),
    "created_by": createdBy,
    "status": status,
  };
}
