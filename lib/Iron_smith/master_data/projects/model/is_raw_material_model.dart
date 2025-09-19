import 'dart:convert';

/// Top-level response model
RawMaterialResponse rawMaterialResponseFromJson(String str) =>
    RawMaterialResponse.fromJson(json.decode(str));

String rawMaterialResponseToJson(RawMaterialResponse data) =>
    json.encode(data.toJson());

class RawMaterialResponse {
  final int? statusCode;
  final bool? success;
  final String? message;
  final List<RawMaterial> data;

  RawMaterialResponse({
    this.statusCode,
    this.success,
    this.message,
    required this.data,
  });

  factory RawMaterialResponse.fromJson(Map<String, dynamic> json) =>
      RawMaterialResponse(
        statusCode: json["statusCode"],
        success: json["success"],
        message: json["message"],
        data:
            (json["data"] as List<dynamic>?)
                ?.map((x) => RawMaterial.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "success": success,
    "message": message,
    "data": data.map((x) => x.toJson()).toList(),
  };
}

/// Represents a single Raw Material entity
class RawMaterial {
  final String? id;
  final String? projectId;
  final int? diameter;
  final int? quantity;
  final bool? isDeleted;
  final List<ConsumptionRecord> consumptionHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  RawMaterial({
    this.id,
    this.projectId,
    this.diameter,
    this.quantity,
    this.isDeleted,
    required this.consumptionHistory,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory RawMaterial.fromJson(Map<String, dynamic> json) => RawMaterial(
    id: json["_id"],
    projectId: json["project"],
    diameter: json["diameter"],
    quantity: json["qty"],
    isDeleted: json["isDeleted"],
    consumptionHistory:
        (json["consumptionHistory"] as List<dynamic>?)
            ?.map((x) => ConsumptionRecord.fromJson(x))
            .toList() ??
        [],
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.parse(json["updatedAt"])
        : null,
    version: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "project": projectId,
    "diameter": diameter,
    "qty": quantity,
    "isDeleted": isDeleted,
    "consumptionHistory": consumptionHistory.map((x) => x.toJson()).toList(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": version,
  };
  RawMaterial copyWith({
    String? id,
    String? projectId,
    int? diameter,
    int? quantity,
    bool? isDeleted,
    List<ConsumptionRecord>? consumptionHistory,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return RawMaterial(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      diameter: diameter ?? this.diameter,
      quantity: quantity ?? this.quantity,
      isDeleted: isDeleted ?? this.isDeleted,
      consumptionHistory: consumptionHistory ?? this.consumptionHistory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

/// Represents a record of raw material consumption
class ConsumptionRecord {
  final String? workOrderId;
  final int? quantity;
  final String? id;
  final DateTime? timestamp;
  final String? workOrderNumber;

  ConsumptionRecord({
    this.workOrderId,
    this.quantity,
    this.id,
    this.timestamp,
    this.workOrderNumber,
  });

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) =>
      ConsumptionRecord(
        workOrderId: json["workOrderId"],
        quantity: json["quantity"],
        id: json["_id"],
        workOrderNumber: json["workOrderNumber"],
        timestamp: json["timestamp"] != null
            ? DateTime.parse(json["timestamp"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "workOrderId": workOrderId,
    "quantity": quantity,
    "workOrderNumber": workOrderNumber,
    "_id": id,
    "timestamp": timestamp?.toIso8601String(),
  };
}
