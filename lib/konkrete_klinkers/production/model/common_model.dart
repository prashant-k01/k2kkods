enum Status { PENDING, IN_PROGRESS, PAUSED, PENDING_QC, COMPLETED }

final statusValues = EnumValues({
  "Pending": Status.PENDING,
  "In Progress": Status.IN_PROGRESS,
  "Paused": Status.PAUSED,
  "Pending QC": Status.PENDING_QC,
  "Completed": Status.COMPLETED,
});

enum AtedBy { THE_68467_BBCC6407_E1_FDF09_D18_E }

final atedByValues = EnumValues({
  "68467bbcc6407e1fdf09d18e": AtedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
});

class WorkOrder {
  final String? id;
  final String? workOrderNumber;
  final String? projectName;
  final String? clientName;

  WorkOrder({this.id, this.workOrderNumber, this.projectName, this.clientName});

  factory WorkOrder.fromJson(Map<String, dynamic> json) => WorkOrder(
    id: json["_id"]?.toString() ?? '',
    workOrderNumber: json["work_order_number"]?.toString() ?? '',
    projectName: json["project_name"]?.toString() ?? '',
    clientName: json["client_name"]?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "work_order_number": workOrderNumber,
    "project_name": projectName,
    "client_name": clientName,
  };
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

class Downtime {
  final DateTime? startTime;
  final DateTime? endTime;
  final String reason;
  final int total_duration;
  final String remarks;
  final String? id;
  final String? jobOrderId;
  final String? productId;

  Downtime({
    this.startTime,
    this.endTime,
    required this.reason,
    required this.total_duration,
    required this.remarks,
    this.id,
    this.jobOrderId,
    this.productId,
  });

  factory Downtime.fromJson(Map<String, dynamic> json) => Downtime(
    startTime: _parseDateTime(
      json["start_time"],
      referenceDate: DateTime.tryParse(json["date"] ?? ''),
    ),
    endTime: _parseDateTime(json["end_time"]),
    reason: json["reason"] ?? '',
    total_duration: int.tryParse(json["total_duration"]?.toString() ?? '') ?? 0,
    remarks: json["remarks"] ?? '',
    id: json["_id"],
    jobOrderId: json["job_order"],
    productId: json["product_id"],
  );

  Map<String, dynamic> toJson() => {
    "downtime_start_time": _formatTimeOnly(startTime),
    "reason": reason,
    "total_duration": total_duration.toString(),
    "remarks": remarks,
    "job_order": jobOrderId,
    "product_id": productId,
  };

  static DateTime? _parseDateTime(dynamic value, {DateTime? referenceDate}) {
    if (value == null) return null;
    try {
      if (value is String && value.contains(':') && !value.contains('T')) {
        final parts = value.split(":");
        return DateTime(
          referenceDate?.year ?? DateTime.now().year,
          referenceDate?.month ?? DateTime.now().month,
          referenceDate?.day ?? DateTime.now().day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  static String? _formatTimeOnly(DateTime? dt) {
    if (dt == null) return null;
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}

class DailyProduction {
  final String? id;
  final Status status;
  final DateTime? date;
  final List<Downtime>? downtime;
  final AtedBy? createdBy;
  final AtedBy? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailyProduction({
    this.id,
    required this.status,
    this.date,
    this.downtime,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory DailyProduction.fromJson(Map<String, dynamic> json) =>
      DailyProduction(
        id: json["_id"]?.toString(),
        status: statusValues.map[json["status"]?.toString()] ?? Status.PENDING,
        date: json["date"] != null ? DateTime.tryParse(json["date"]) : null,
        downtime: json["downtime"] != null
            ? List<Downtime>.from(
                json["downtime"].map((x) => Downtime.fromJson(x)),
              )
            : [],
        createdBy:
            atedByValues.map[json["created_by"]?.toString()] ??
            AtedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        updatedBy:
            atedByValues.map[json["updated_by"]?.toString()] ??
            AtedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": statusValues.reverse[status],
    "date": date?.toIso8601String(),
    "downtime": downtime?.map((x) => x.toJson()).toList(),
    "created_by": atedByValues.reverse[createdBy],
    "updated_by": atedByValues.reverse[updatedBy],
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

enum Description { MACHINE_BREAKDOWN, MATERIAL_SHORTAGE, POWER_FAILURE }

final descriptionValues = EnumValues({
  "Machine Breakdown": Description.MACHINE_BREAKDOWN,
  "Material Shortage": Description.MATERIAL_SHORTAGE,
  "Power Failure": Description.POWER_FAILURE,
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }

  Map<T, String> get reverse => reverseMap!;
}
