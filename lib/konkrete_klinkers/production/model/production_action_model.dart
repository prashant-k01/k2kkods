import 'package:k2k/konkrete_klinkers/production/model/common_model.dart';

class ProductionActionResponse {
  final bool success;
  final String message;
  final ActionDpr data;

  ProductionActionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductionActionResponse.fromJson(Map<String, dynamic> json) {
    print('Parsing ProductionActionResponse JSON: $json');
    return ProductionActionResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      data: ActionDpr.fromJson(json["data"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class ActionDpr {
  final String? id;
  final WorkOrder workOrder;
  final String? jobOrder;
  final List<Product> products;
  final DateTime date;
  final String? submittedBy;
  final Status status;
  final AtedBy createdBy;
  final AtedBy updatedBy;
  final List<ProductionLog> productionLogs;
  final List<Downtime> downtime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final DateTime? startedAt;

  ActionDpr({
    this.id,
    required this.workOrder,
    this.jobOrder,
    required this.products,
    required this.date,
    this.submittedBy,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.productionLogs,
    required this.downtime,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.startedAt,
  });

  factory ActionDpr.fromJson(Map<String, dynamic> json) {
    print('Parsing ActionDpr JSON: $json');
    final statusString = json['status']?.toString();
    final status = statusValues.map[statusString] ?? Status.PENDING;
    return ActionDpr(
      id: json["_id"]?.toString(),
      workOrder: WorkOrder.fromJson(
        json["work_order"] is String
            ? {"work_order_number": json["work_order"]}
            : (json["work_order"] as Map<String, dynamic>?) ??
                  {"work_order_number": "N/A"},
      ),
      jobOrder: json["job_order"]?.toString(),
      products: List<Product>.from(
        (json["products"] ?? []).map((x) => Product.fromJson(x)),
      ),
      date: DateTime.parse(json["date"] ?? DateTime.now().toIso8601String()),
      submittedBy: json["submitted_by"]?.toString(),
      status: status,
      createdBy:
          atedByValues.map[json["created_by"]?.toString()] ??
          AtedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
      updatedBy:
          atedByValues.map[json["updated_by"]?.toString()] ??
          AtedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
      productionLogs: List<ProductionLog>.from(
        (json["production_logs"] ?? []).map((x) => ProductionLog.fromJson(x)),
      ),
      downtime: List<Downtime>.from(
        (json["downtime"] ?? []).map((x) => Downtime.fromJson(x)),
      ),
      createdAt: DateTime.parse(
        json["createdAt"] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json["updatedAt"] ?? DateTime.now().toIso8601String(),
      ),
      version: json["__v"] ?? 0,
      startedAt: json["started_at"] != null
          ? DateTime.tryParse(json["started_at"])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order": workOrder.toJson(),
    "job_order": jobOrder,
    "products": products.map((x) => x.toJson()).toList(),
    "date": date.toIso8601String(),
    "submitted_by": submittedBy,
    "status": statusValues.reverse[status],
    "created_by": atedByValues.reverse[createdBy],
    "updated_by": atedByValues.reverse[updatedBy],
    "production_logs": productionLogs.map((x) => x.toJson()).toList(),
    "downtime": downtime.map((x) => x.toJson()).toList(),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": version,
    "started_at": startedAt?.toIso8601String(),
  };
}

class Product {
  final String? productId;
  final int achievedQuantity;
  final int rejectedQuantity;
  final int recycledQuantity;
  final String? id;

  Product({
    this.productId,
    required this.achievedQuantity,
    required this.rejectedQuantity,
    required this.recycledQuantity,
    this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json["product_id"]?.toString(),
    achievedQuantity: json["achieved_quantity"] ?? 0,
    rejectedQuantity: json["rejected_quantity"] ?? 0,
    recycledQuantity: json["recycled_quantity"] ?? 0,
    id: json["_id"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "achieved_quantity": achievedQuantity,
    "rejected_quantity": rejectedQuantity,
    "recycled_quantity": recycledQuantity,
    "_id": id,
  };
}

class ProductionLog {
  final String? action;
  final DateTime? timestamp;
  final String? user;
  final String? description;
  final String? id;

  ProductionLog({
    this.action,
    this.timestamp,
    this.user,
    this.description,
    this.id,
  });

  factory ProductionLog.fromJson(Map<String, dynamic> json) => ProductionLog(
    action: json["action"]?.toString(),
    timestamp: json["timestamp"] != null
        ? DateTime.tryParse(json["timestamp"])
        : null,
    user: json["user"]?.toString(),
    description: json["description"]?.toString(),
    id: json["_id"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "action": action,
    "timestamp": timestamp?.toIso8601String(),
    "user": user,
    "description": description,
    "_id": id,
  };
}
