import 'dart:convert';

import 'package:k2k/konkrete_klinkers/production/model/common_model.dart';

Production productionFromJson(String str) =>
    Production.fromJson(json.decode(str));
String productionToJson(Production data) => json.encode(data.toJson());

class Production {
  final bool success;
  final String message;
  final Data data;

  Production({
    required this.success,
    required this.message,
    required this.data,
  });

  factory Production.fromJson(Map<String, dynamic> json) {
    print('Parsing ProductionListResponse JSON: $json');
    return Production(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      data: Data.fromJson(json["data"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final List<PastDpr> pastDpr;
  final List<PastDpr> todayDpr;
  final List<PastDpr> futureDpr;

  Data({
    required this.pastDpr,
    required this.todayDpr,
    required this.futureDpr,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    print('Parsing Data JSON: $json');
    return Data(
      pastDpr: List<PastDpr>.from(
        (json["pastDPR"] ?? []).map((x) => PastDpr.fromJson(x)),
      ),
      todayDpr: List<PastDpr>.from(
        (json["todayDPR"] ?? []).map((x) => PastDpr.fromJson(x)),
      ),
      futureDpr: List<PastDpr>.from(
        (json["futureDPR"] ?? []).map((x) => PastDpr.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "pastDPR": pastDpr.map((x) => x.toJson()).toList(),
    "todayDPR": todayDpr.map((x) => x.toJson()).toList(),
    "futureDPR": futureDpr.map((x) => x.toJson()).toList(),
  };
}

class PastDpr {
  final String? id;
  final WorkOrder workOrder;
  final String? salesOrderNumber;
  final String? batchNumber;
  final Date date;
  final Status status;
  final AtedBy createdBy;
  final AtedBy updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? jobOrder;
  final String? jobOrderId;
  final String? productId;
  final String? plantName;
  final String? machineName;
  final String? materialCode;
  final String? description;
  final int poQuantity;
  final int plannedQuantity;
  final DateTime scheduledDate;
  final int achievedQuantity;
  final int rejectedQuantity;
  final int recycledQuantity;
  final DateTime? startedAt;
  final DateTime? stoppedAt;
  final String? submittedBy;
  final DailyProduction? dailyProduction;
  final DateTime latestDate;

  PastDpr({
    this.id,
    required this.workOrder,
    this.salesOrderNumber,
    this.batchNumber,
    required this.date,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.jobOrder,
    this.jobOrderId,
    this.productId,
    this.plantName,
    this.machineName,
    this.materialCode,
    this.description,
    required this.poQuantity,
    required this.plannedQuantity,
    required this.scheduledDate,
    required this.achievedQuantity,
    required this.rejectedQuantity,
    required this.recycledQuantity,
    this.startedAt,
    this.stoppedAt,
    this.submittedBy,
    this.dailyProduction,
    required this.latestDate,
  });

  factory PastDpr.fromJson(Map<String, dynamic> json) {
    print('Parsing PastDpr JSON: $json');
    final statusString = json['status']?.toString();
    final status = statusValues.map[statusString] ?? Status.PENDING;
    final dailyProductionJson = json["daily_production"];
    final dailyProductionStatus = dailyProductionJson != null
        ? statusValues.map[dailyProductionJson["status"]?.toString()] ??
              Status.PENDING
        : null;
    if (status != dailyProductionStatus && dailyProductionStatus != null) {
      print(
        'Status mismatch: PastDpr.status=$status, daily_production.status=$dailyProductionStatus',
      );
    }
    return PastDpr(
      id: json["_id"]?.toString(),
      workOrder: WorkOrder.fromJson(
        json["work_order"] is String
            ? {"work_order_number": json["work_order"]}
            : (json["work_order"] as Map<String, dynamic>?) ??
                  {"work_order_number": "N/A"},
      ),
      salesOrderNumber: json["sales_order_number"]?.toString() ?? 'N/A',
      batchNumber: json["batch_number"]?.toString() ?? 'N/A',
      date: Date.fromJson(json["date"] ?? {}),
      status: status,
      createdBy:
          atedByValues.map[json["created_by"]?.toString()] ??
          AtedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
      updatedBy:
          atedByValues.map[json["updated_by"]?.toString()] ??
          AtedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
      createdAt: DateTime.parse(
        json["createdAt"] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json["updatedAt"] ?? DateTime.now().toIso8601String(),
      ),
      jobOrder: json["job_order"]?.toString(),
      jobOrderId: json["job_order_id"]?.toString(),
      productId: json["product_id"]?.toString(),
      plantName: json["plant_name"]?.toString(),
      machineName: json["machine_name"]?.toString(),
      materialCode: json["material_code"]?.toString(),
      description: json["description"]?.toString(),
      poQuantity: json["po_quantity"] ?? 0,
      plannedQuantity: json["planned_quantity"] ?? 0,
      scheduledDate: DateTime.parse(
        json["scheduled_date"] ?? DateTime.now().toIso8601String(),
      ),
      achievedQuantity: json["achieved_quantity"] ?? 0,
      rejectedQuantity: json["rejected_quantity"] ?? 0,
      recycledQuantity: json["recycled_quantity"] ?? 0,
      startedAt: json["started_at"] != null
          ? DateTime.tryParse(json["started_at"])
          : null,
      stoppedAt: json["stopped_at"] != null
          ? DateTime.tryParse(json["stopped_at"])
          : null,
      submittedBy: json["submitted_by"]?.toString(),
      dailyProduction: dailyProductionJson != null
          ? DailyProduction.fromJson(dailyProductionJson)
          : null,
      latestDate: DateTime.parse(
        json["latestDate"] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order": workOrder.toJson(),
    "sales_order_number": salesOrderNumber,
    "batch_number": batchNumber,
    "date": date.toJson(),
    "status": statusValues.reverse[status],
    "created_by": atedByValues.reverse[createdBy],
    "updated_by": atedByValues.reverse[updatedBy],
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "job_order": jobOrder,
    "job_order_id": jobOrderId,
    "product_id": productId,
    "plant_name": plantName,
    "machine_name": machineName,
    "material_code": materialCode,
    "description": description,
    "po_quantity": poQuantity,
    "planned_quantity": plannedQuantity,
    "scheduled_date": scheduledDate.toIso8601String(),
    "achieved_quantity": achievedQuantity,
    "rejected_quantity": rejectedQuantity,
    "recycled_quantity": recycledQuantity,
    "started_at": startedAt?.toIso8601String(),
    "stopped_at": stoppedAt?.toIso8601String(),
    "submitted_by": submittedBy,
    "daily_production": dailyProduction?.toJson(),
    "latestDate": latestDate.toIso8601String(),
  };
  get startTime => null;
  get jobOrderIdGetter => jobOrderId ?? "N/A";
  get endTime => null;
}
