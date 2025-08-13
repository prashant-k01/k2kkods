class QcCheckModel {
  final String id;
  final String? workOrder;
  final String? jobOrder;
  final String? productId;
  final int rejectedQuantity;
  final int recycledQuantity;
  final String? remarks;
  final CreatedBy createdBy;
  final String? updatedBy;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? workOrderNumber;
  final String? jobOrderNumber;

  QcCheckModel({
    required this.id,
    this.workOrder,
    this.jobOrder,
    this.productId,
    required this.rejectedQuantity,
    required this.recycledQuantity,
    this.remarks,
    required this.createdBy,
    this.updatedBy,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.workOrderNumber,
    this.jobOrderNumber,
  });

  factory QcCheckModel.fromJson(Map<String, dynamic> json) {
    return QcCheckModel(
      id: json['_id']?.toString() ?? '',
      workOrder: _extractStringValue(json['work_order']),
      jobOrder: _extractStringValue(json['job_order']),
      productId: json['product_id']?.toString(),
      rejectedQuantity: _parseIntValue(json['rejected_quantity']) ?? 0,
      recycledQuantity: _parseIntValue(json['recycled_quantity']) ?? 0,
      remarks: json['remarks']?.toString(),
      createdBy: _parseCreatedBy(json['created_by']),
      updatedBy: json['updated_by']?.toString(),
      status: json['status']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      workOrderNumber: json['work_order_number']?.toString(),
      jobOrderNumber: json['job_order_number']?.toString(),
    );
  }

  static CreatedBy _parseCreatedBy(dynamic value) {
    if (value == null) {
      return CreatedBy(id: '', email: '', username: 'Unknown');
    }
    if (value is String) {
      return CreatedBy(id: value, email: '', username: 'Unknown');
    }
    if (value is Map<String, dynamic>) {
      return CreatedBy.fromJson(value);
    }
    print('Unexpected created_by type: ${value.runtimeType}, value: $value');
    return CreatedBy(id: value.toString(), email: '', username: 'Unknown');
  }

  static String? _extractStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString() ??
          value['id']?.toString() ??
          value['number']?.toString() ??
          value.toString();
    }
    return value.toString();
  }

  static int? _parseIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date: $value - $e');
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'work_order': workOrder,
      'job_order': jobOrder,
      'product_id': productId,
      'rejected_quantity': rejectedQuantity,
      'recycled_quantity': recycledQuantity,
      'remarks': remarks,
      'created_by': createdBy.toJson(),
      'updated_by': updatedBy,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'work_order_number': workOrderNumber,
      'job_order_number': jobOrderNumber,
    };
  }

  String get displayWorkOrder => workOrderNumber ?? workOrder ?? 'N/A';
  String get displayJobOrder => jobOrderNumber ?? jobOrder ?? 'N/A';
  String get displayRemarks => remarks ?? 'No Remarks';
  String get displayCreatedBy => createdBy.username.isNotEmpty ? createdBy.username : createdBy.id;
  String get displayStatus => status ?? 'Unknown';

  String get displayCreatedAt {
    if (createdAt == null) return 'N/A';
    return '${createdAt!.day.toString().padLeft(2, '0')}/${createdAt!.month.toString().padLeft(2, '0')}/${createdAt!.year}';
  }
}

class CreatedBy {
  final String id;
  final String email;
  final String username;

  CreatedBy({
    required this.id,
    required this.email,
    required this.username,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final username = json['username']?.toString() ?? 'Unknown';
      return CreatedBy(id: id, email: email, username: username);
    } catch (e) {
      print('Error parsing CreatedBy: $e for JSON: $json');
      return CreatedBy(id: '', email: '', username: 'Unknown');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
    };
  }
}