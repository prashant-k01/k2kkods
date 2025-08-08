import 'dart:convert';

class JobOrderResponse {
  final List<JobOrderModel> data;
  final String message;
  final bool success;

  JobOrderResponse({
    required this.data,
    required this.message,
    required this.success,
  });

  factory JobOrderResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing JobOrderResponse with JSON: ${jsonEncode(json)}');
      final dataJson = json['data'];
      List<JobOrderModel> jobOrders = [];

      if (dataJson == null) {
        print('Error: data field is null in JSON response');
        return JobOrderResponse(
          data: [],
          message: json['message']?.toString() ?? 'No data field in response',
          success: json['success'] as bool? ?? false,
        );
      }

      if (dataJson is Map<String, dynamic> && dataJson['jobOrder'] != null) {
        try {
          print('Parsing single jobOrder: ${jsonEncode(dataJson['jobOrder'])}');
          jobOrders = [JobOrderModel.fromJson(dataJson['jobOrder'])];
        } catch (e) {
          print(
            'Error parsing single JobOrder: $e for jobOrder: ${jsonEncode(dataJson['jobOrder'])}',
          );
        }
      } else if (dataJson is Map<String, dynamic>) {
        // Handle single job order directly in data field
        try {
          print('Parsing single JobOrder from data: ${jsonEncode(dataJson)}');
          jobOrders = [JobOrderModel.fromJson(dataJson)];
        } catch (e) {
          print('Error parsing JobOrder from data: $e');
        }
      } else if (dataJson is List) {
        jobOrders = dataJson
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final item = entry.value;
              try {
                if (item is Map<String, dynamic>) {
                  print(
                    'Parsing JobOrder at index $index: ${jsonEncode(item)}',
                  );
                  return JobOrderModel.fromJson(item);
                } else {
                  print(
                    'Error: JobOrder item at index $index is not a Map: $item',
                  );
                  return null;
                }
              } catch (e) {
                print(
                  'Error parsing JobOrder at index $index: $e for item: ${jsonEncode(item)}',
                );
                return null;
              }
            })
            .where((item) => item != null)
            .cast<JobOrderModel>()
            .toList();
      } else {
        print('Error: data field is neither a Map nor a List: $dataJson');
      }

      return JobOrderResponse(
        data: jobOrders,
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool? ?? true,
      );
    } catch (e) {
      print('Error parsing JobOrderResponse: $e for JSON: ${jsonEncode(json)}');
      return JobOrderResponse(
        data: [],
        message: 'Failed to parse response: $e',
        success: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'message': message,
      'success': success,
    };
  }
}

class JobOrderModel {
  final String? workOrderNumber;
  final String salesOrderNumber;
  final int batchNumber;
  final List<JobOrderItem> jobOrders;
  final DateRange date;
  final String jobOrderId;
  final String? uom;
  final String mongoId;
  final String status;
  final String projectName;
  final String? createdBy;
  final String? createdAt; // Added createdAt field
  final ClientModel? client; // Changed to ClientModel for better structure
  final WorkOrderDetails? workOrderDetails; // Changed to WorkOrderDetails model

  JobOrderModel({
    this.workOrderNumber,
    required this.salesOrderNumber,
    required this.batchNumber,
    required this.jobOrders,
    this.client,
    this.uom,
    required this.date,
    required this.jobOrderId,
    required this.mongoId,
    required this.status,
    required this.projectName,
    this.createdBy,
    this.createdAt,
    this.workOrderDetails,
  });

  factory JobOrderModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing JobOrderModel with JSON: ${jsonEncode(json)}');
      List<JobOrderItem> jobOrderItems = [];

      final productsJson = json['products'];
      if (productsJson != null && productsJson is List) {
        jobOrderItems = productsJson
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final item = entry.value;
              try {
                if (item != null && item is Map<String, dynamic>) {
                  print(
                    'Parsing JobOrderItem at index $index: ${jsonEncode(item)}',
                  );
                  return JobOrderItem.fromJson(item);
                } else {
                  print(
                    'Warning: Product item at index $index is null or not a Map: $item',
                  );
                  return null;
                }
              } catch (e) {
                print(
                  'Error parsing JobOrderItem at index $index: $e for item: ${jsonEncode(item)}',
                );
                return null;
              }
            })
            .where((item) => item != null)
            .cast<JobOrderItem>()
            .toList();
      } else {
        print(
          'Warning: products field is missing or not a list: $productsJson',
        );
      }

      // Parse client data
      ClientModel? clientModel;
      if (json['client'] != null && json['client'] is Map<String, dynamic>) {
        try {
          clientModel = ClientModel.fromJson(json['client'] as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing client: $e');
        }
      }

      // Parse work order details
      WorkOrderDetails? workOrderDetailsModel;
      if (json['work_order_details'] != null && json['work_order_details'] is Map<String, dynamic>) {
        try {
          workOrderDetailsModel = WorkOrderDetails.fromJson(json['work_order_details'] as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing work_order_details: $e');
        }
      }

      return JobOrderModel(
        workOrderNumber: _getStringValue(json['work_order_number']),
        salesOrderNumber: _getStringValue(json['sales_order_number']) ?? '',
        batchNumber: _getIntValue(json['batch_number'], 'batch_number') ?? 0,
        jobOrders: jobOrderItems,
        date: DateRange.fromJson(json['date'] ?? {}),
        uom: _getStringValue(json['uom']),
        jobOrderId: _getStringValue(json['job_order_id']) ?? _getStringValue(json['_id']) ?? '',
        mongoId: _getStringValue(json['_id']) ?? '',
        status: _getStringValue(json['status']) ?? _getStringValue(json['job_order_status']) ?? 'Unknown',
        projectName: _getStringValue(json['project_name']) ?? 'N/A',
        createdBy: _extractUsername(json['created_by']),
        createdAt: _getStringValue(json['createdAt']),
        client: clientModel,
        workOrderDetails: workOrderDetailsModel,
      );
    } catch (e) {
      print('Error parsing JobOrderModel: $e for JSON: ${jsonEncode(json)}');
      rethrow;
    }
  }

  static String? _getStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic> && value.containsKey('\$oid')) {
      return value['\$oid']?.toString();
    }
    return value.toString();
  }

  static int? _getIntValue(dynamic value, String fieldName) {
    if (value == null) {
      print('Warning: $fieldName is null');
      return 0;
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print(
          'Error parsing integer from string for $fieldName: $value, error: $e',
        );
        return 0;
      }
    }
    print('Invalid type for $fieldName: $value (type: ${value.runtimeType})');
    return 0;
  }

  // Extract username from created_by field (handles both string and object formats)
  static String? _extractUsername(dynamic createdBy) {
    if (createdBy == null) return null;
    if (createdBy is String) return createdBy;
    if (createdBy is Map<String, dynamic>) {
      return createdBy['username']?.toString() ?? createdBy['name']?.toString();
    }
    return createdBy.toString();
  }

  String get actualWorkOrderNumber {
    // Prioritize work_order_details.work_order_number if available
    if (workOrderDetails != null &&
        workOrderDetails!.workOrderNumber != null &&
        workOrderDetails!.workOrderNumber!.isNotEmpty) {
      return workOrderDetails!.workOrderNumber!;
    }
    // Fallback to workOrderNumber
    return workOrderNumber ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'work_order_number': workOrderNumber,
      'sales_order_number': salesOrderNumber,
      'batch_number': batchNumber,
      'products': jobOrders.map((item) => item.toJson()).toList(),
      'date': date.toJson(),
      'job_order_id': jobOrderId,
      '_id': mongoId,
      'uom': uom,
      'status': status,
      'project_name': projectName,
      'created_by': createdBy,
      'createdAt': createdAt,
      'work_order_details': workOrderDetails?.toJson(),
      'client': client?.toJson(),
    };
  }
}

class JobOrderItem {
  final String product;
  final String machineName;
  final String scheduledDate;
  final int plannedQuantity;
  final String? id;
  final String? description;
  final String? materialCode;
  final String? machineId;
  final String? plantId;
  final String? plantName;
  final int? achievedQuantity;
  final int? rejectedQuantity;

  JobOrderItem({
    required this.product,
    required this.machineName,
    required this.scheduledDate,
    required this.plannedQuantity,
    this.id,
    this.description,
    this.materialCode,
    this.machineId,
    this.plantId,
    this.plantName,
    this.achievedQuantity,
    this.rejectedQuantity,
  });

  factory JobOrderItem.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing JobOrderItem with JSON: ${jsonEncode(json)}');
      return JobOrderItem(
        product: _getStringValue(json['product']) ?? '',
        machineName: _getStringValue(json['machine_name']) ?? '',
        scheduledDate: _getDateValue(json['scheduled_date']) ?? '',
        plannedQuantity:
            _getIntValue(json['planned_quantity'], 'planned_quantity') ?? 0,
        id: _getStringValue(json['_id']),
        description: _getStringValue(json['description']),
        materialCode: _getStringValue(json['material_code']),
        machineId: _getStringValue(json['machine_id']),
        plantId: _getStringValue(json['plant_id']),
        plantName: _getStringValue(json['plant_name']),
        achievedQuantity: _getIntValue(
          json['achieved_quantity'],
          'achieved_quantity',
        ),
        rejectedQuantity: _getIntValue(
          json['rejected_quantity'],
          'rejected_quantity',
        ),
      );
    } catch (e) {
      print('Error parsing JobOrderItem: $e for JSON: ${jsonEncode(json)}');
      rethrow;
    }
  }

  static String? _getStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic> && value.containsKey('\$oid')) {
      return value['\$oid']?.toString();
    }
    return value.toString();
  }

  static String? _getDateValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic> && value.containsKey('\$date')) {
      return value['\$date']?.toString();
    }
    return value.toString();
  }

  static int? _getIntValue(dynamic value, String fieldName) {
    if (value == null) {
      print('Warning: $fieldName is null');
      return null; // Changed from 0 to null to distinguish between 0 and missing values
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print(
          'Error parsing integer from string for $fieldName: $value, error: $e',
        );
        return null;
      }
    }
    print('Invalid type for $fieldName: $value (type: ${value.runtimeType})');
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'machine_name': machineName,
      'scheduled_date': scheduledDate,
      'planned_quantity': plannedQuantity,
      '_id': id,
      'description': description,
      'material_code': materialCode,
      'machine_id': machineId,
      'plant_id': plantId,
      'plant_name': plantName,
      'achieved_quantity': achievedQuantity,
      'rejected_quantity': rejectedQuantity,
    };
  }
}

class DateRange {
  final String from;
  final String to;

  DateRange({required this.from, required this.to});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing DateRange with JSON: ${jsonEncode(json)}');
      return DateRange(
        from: _getDateValue(json['from']) ?? '',
        to: _getDateValue(json['to']) ?? '',
      );
    } catch (e) {
      print('Error parsing DateRange: $e for JSON: ${jsonEncode(json)}');
      return DateRange(from: '', to: '');
    }
  }

  static String? _getDateValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic> && value.containsKey('\$date')) {
      return value['\$date']?.toString();
    }
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {'from': from, 'to': to};
  }
}

// New ClientModel class for better structure
class ClientModel {
  final String? name;
  final String? address;

  ClientModel({
    this.name,
    this.address,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      name: json['name']?.toString(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
    };
  }
}

// New WorkOrderDetails class for better structure
class WorkOrderDetails {
  final String? id;
  final String? workOrderNumber;
  final String? status;
  final String? createdAt;
  final String? createdBy;

  WorkOrderDetails({
    this.id,
    this.workOrderNumber,
    this.status,
    this.createdAt,
    this.createdBy,
  });

  factory WorkOrderDetails.fromJson(Map<String, dynamic> json) {
    return WorkOrderDetails(
      id: json['_id']?.toString(),
      workOrderNumber: json['work_order_number']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'work_order_number': workOrderNumber,
      'status': status,
      'created_at': createdAt,
      'created_by': createdBy,
    };
  }
}