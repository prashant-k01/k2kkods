class JobOrderResponse {
  final List<JobOrderModel> data;
  final Pagination pagination;
  final String message;
  final bool success;

  JobOrderResponse({
    required this.data,
    required this.pagination,
    required this.message,
    required this.success,
  });

  factory JobOrderResponse.fromJson(Map<String, dynamic> json) {
    try {
      final dataJson = json['data'];
      if (dataJson == null) {
        print('Error: data field is null in JSON response: $json');
        return JobOrderResponse(
          data: [],
          pagination: Pagination(total: 0, page: 1, limit: 10, totalPages: 1),
          message: json['message']?.toString() ?? 'No data field in response',
          success: json['success'] as bool? ?? false,
        );
      }

      // Fix: The API returns job orders directly in data array, not in data['JobOrders']
      List<JobOrderModel> jobOrders = [];

      if (dataJson is List) {
        // If data is directly a list of job orders
        jobOrders = dataJson
            .map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return JobOrderModel.fromJson(item);
                } else {
                  print('Error: JobOrder item is not a Map: $item');
                  return null;
                }
              } catch (e) {
                print('Error parsing JobOrder: $e for item: $item');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<JobOrderModel>()
            .toList();
      } else if (dataJson is Map<String, dynamic>) {
        // If data is an object with JobOrders array
        final jobOrdersJson = dataJson['JobOrders'] as List<dynamic>?;
        if (jobOrdersJson != null) {
          jobOrders = jobOrdersJson
              .map((item) {
                try {
                  if (item is Map<String, dynamic>) {
                    return JobOrderModel.fromJson(item);
                  } else {
                    print('Error: JobOrder item is not a Map: $item');
                    return null;
                  }
                } catch (e) {
                  print('Error parsing JobOrder: $e for item: $item');
                  return null;
                }
              })
              .where((item) => item != null)
              .cast<JobOrderModel>()
              .toList();
        }
      }

      return JobOrderResponse(
        data: jobOrders,
        pagination: dataJson is Map<String, dynamic>
            ? Pagination.fromJson(dataJson['pagination'] ?? {})
            : Pagination(
                total: jobOrders.length,
                page: 1,
                limit: jobOrders.length,
                totalPages: 1,
              ),
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool? ?? true,
      );
    } catch (e) {
      print('Error parsing JobOrderResponse: $e for JSON: $json');
      return JobOrderResponse(
        data: [],
        pagination: Pagination(total: 0, page: 1, limit: 10, totalPages: 1),
        message: 'Failed to parse response: $e',
        success: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'pagination': pagination.toJson(),
      'message': message,
      'success': success,
    };
  }
}

class Pagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] is num ? (json['total'] as num).toInt() : 0,
      page: json['page'] is num ? (json['page'] as num).toInt() : 1,
      limit: json['limit'] is num ? (json['limit'] as num).toInt() : 10,
      totalPages: json['totalPages'] is num
          ? (json['totalPages'] as num).toInt()
          : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}

class JobOrderModel {
  final String workOrderNumber;
  final String salesOrderNumber;
  final int batchNumber;
  final List<JobOrderItem> jobOrders; // This will contain products from API
  final DateRange date;
  final String jobOrderId;
  final String status;
  final String projectName;

  final String? createdBy; // Add this field

  JobOrderModel({
    required this.workOrderNumber,
    required this.salesOrderNumber,
    required this.batchNumber,
    required this.jobOrders,
    required this.date,
    required this.jobOrderId,
    required this.status,
    required this.projectName,
    this.createdBy, // Add this parameter
  });

  factory JobOrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Fix: Map 'products' from API to JobOrders in model with null safety
      List<JobOrderItem> jobOrderItems = [];

      final productsJson = json['products'];
      if (productsJson != null && productsJson is List) {
        jobOrderItems = productsJson
            .map((item) {
              try {
                if (item != null && item is Map<String, dynamic>) {
                  return JobOrderItem.fromJson(item);
                } else {
                  print('Warning: Product item is null or not a Map: $item');
                  return null;
                }
              } catch (e) {
                print('Error parsing JobOrderItem: $e for item: $item');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<JobOrderItem>()
            .toList();
      }

      return JobOrderModel(
        workOrderNumber:
            _getStringValue(json['work_order']?['work_order_number']) ??
            _getStringValue(json['work_order_number']) ??
            '',
        salesOrderNumber: _getStringValue(json['sales_order_number']) ?? '',
        batchNumber: _getIntValue(json['batch_number']) ?? 0,
        jobOrders: jobOrderItems, // Now guaranteed to be non-null
        date: DateRange.fromJson(json['date'] ?? {}),
        jobOrderId:
            _getStringValue(json['job_order_id']) ??
            _getStringValue(json['_id']) ??
            '',
        status: _getStringValue(json['status']) ?? 'Unknown',
        projectName: _getStringValue(json['project_name']) ?? 'N/A',
        createdBy: _extractUsername(json['created_by']),
      );
    } catch (e) {
      print('Error parsing JobOrderModel: $e for JSON: $json');
      return JobOrderModel(
        workOrderNumber: '',
        salesOrderNumber: '',
        batchNumber: 0,
        jobOrders: [], // Return empty list instead of null
        date: DateRange(from: '', to: ''),
        jobOrderId: '',
        status: 'Unknown',
        projectName: 'N/A',
        createdBy: null,
      );
    }
  }

  // Helper method to safely extract string values
  static String? _getStringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  // Helper method to extract username from created_by object
  static String? _extractUsername(dynamic createdBy) {
    if (createdBy == null) return null;

    // If it's already a string (just username)
    if (createdBy is String) return createdBy;

    // If it's an object with username field
    if (createdBy is Map<String, dynamic>) {
      return createdBy['username']?.toString() ??
          createdBy['user_name']?.toString() ??
          createdBy['name']?.toString();
    }

    return createdBy.toString();
  }

  // Helper method to safely extract int values
  static int? _getIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'work_order_number': workOrderNumber,
      'sales_order_number': salesOrderNumber,
      'batch_number': batchNumber,
      'products': jobOrders.map((item) => item.toJson()).toList(),
      'date': date.toJson(),
      'job_order_id': jobOrderId,
      'status': status,
      'project_name': projectName,
      'created_by': createdBy,
    };
  }
}

class JobOrderItem {
  final String product;
  final String machineName;
  final String scheduledDate;
  final int plannedQuantity;

  JobOrderItem({
    required this.product,
    required this.machineName,
    required this.scheduledDate,
    required this.plannedQuantity,
  });

  factory JobOrderItem.fromJson(Map<String, dynamic> json) {
    try {
      return JobOrderItem(
        product: json['product']?.toString() ?? '',
        machineName: json['machine_name']?.toString() ?? '',
        scheduledDate: json['scheduled_date']?.toString() ?? '',
        plannedQuantity: _getIntValue(json['planned_quantity']),
      );
    } catch (e) {
      print('Error parsing JobOrderItem: $e for JSON: $json');
      return JobOrderItem(
        product: '',
        machineName: '',
        scheduledDate: '',
        plannedQuantity: 0,
      );
    }
  }

  // Helper method to safely extract int values
  static int _getIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'machine_name': machineName,
      'scheduled_date': scheduledDate,
      'planned_quantity': plannedQuantity,
    };
  }
}

class DateRange {
  final String from;
  final String to;

  DateRange({required this.from, required this.to});

  factory DateRange.fromJson(Map<String, dynamic> json) {
    try {
      return DateRange(
        from: json['from']?.toString() ?? '',
        to: json['to']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing DateRange: $e for JSON: $json');
      return DateRange(from: '', to: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {'from': from, 'to': to};
  }
}
