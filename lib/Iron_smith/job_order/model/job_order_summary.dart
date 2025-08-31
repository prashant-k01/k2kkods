import 'dart:convert';

JobOrderResponse jobOrderFromJson(String str) =>
    JobOrderResponse.fromJson(json.decode(str));

String jobOrderToJson(JobOrderResponse data) => json.encode(data.toJson());

class JobOrderResponse {
  final int? statusCode;
  final List<JobOrderData>? data;
  final String? message;
  final bool? success;

  JobOrderResponse({this.statusCode, this.data, this.message, this.success});

  factory JobOrderResponse.fromJson(Map<String, dynamic> json) =>
      JobOrderResponse(
        statusCode: json["statusCode"],
        data: (json["data"] as List<dynamic>?)
            ?.map((x) => JobOrderData.fromJson(x))
            .toList(),
        message: json["message"],
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "data": data?.map((x) => x.toJson()).toList(),
    "message": message,
    "success": success,
  };
}

class JobOrderData {
  final String? id;
  final String? jobOrderNumber;
  final WorkOrder? workOrder;
  final Client? project;
  final Client? client;
  final String? createdAt;
  final String? updatedAt;

  JobOrderData({
    this.id,
    this.jobOrderNumber,
    this.workOrder,
    this.project,
    this.client,
    this.createdAt,
    this.updatedAt,
  });

  factory JobOrderData.fromJson(Map<String, dynamic> json) => JobOrderData(
    id: json["_id"],
    jobOrderNumber: json["job_order_number"],
    workOrder: json["work_order"] != null
        ? WorkOrder.fromJson(json["work_order"])
        : null,
    project: json["project"] != null ? Client.fromJson(json["project"]) : null,
    client: json["client"] != null ? Client.fromJson(json["client"]) : null,
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "job_order_number": jobOrderNumber,
    "work_order": workOrder?.toJson(),
    "project": project?.toJson(),
    "client": client?.toJson(),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Client {
  final String? id;
  final String? name;

  Client({this.id, this.name});

  factory Client.fromJson(Map<String, dynamic> json) =>
      Client(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class WorkOrder {
  final String? id;
  final String? workOrderNumber;

  WorkOrder({this.id, this.workOrderNumber});

  factory WorkOrder.fromJson(Map<String, dynamic> json) =>
      WorkOrder(id: json["_id"], workOrderNumber: json["workOrderNumber"]);

  Map<String, dynamic> toJson() => {
    "_id": id,
    "workOrderNumber": workOrderNumber,
  };
}
