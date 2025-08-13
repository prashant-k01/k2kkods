class PackingModel {
  final String id;
  final String workOrderId;
  final String workOrderNumber;
  final String productId;
  final String productName;
  final int totalBundles;
  final int totalQuantity;
  final String uom;
  final int rejectedQuantity;
  final String createdBy;
  final String status;
  final List<QrCode> qrCodes;
  final List<PackingDetail> packings;
  final DateTime createdAt;

  const PackingModel({
    required this.id,
    required this.workOrderId,
    required this.workOrderNumber,
    required this.productId,
    required this.productName,
    required this.totalBundles,
    required this.totalQuantity,
    required this.uom,
    required this.rejectedQuantity,
    required this.createdBy,
    required this.status,
    required this.qrCodes,
    required this.packings,
    required this.createdAt,
  });

  factory PackingModel.fromJson(Map<String, dynamic> json) {
    return PackingModel(
      id: json['_id'] as String? ?? '',
      workOrderId: json['work_order_id'] as String? ?? '',
      workOrderNumber: json['work_order_number'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      totalBundles: json['total_bundles'] as int? ?? 0,
      totalQuantity: json['total_quantity'] as int? ?? 0,
      uom: json['uom'] as String? ?? '',
      rejectedQuantity: json['rejected_quantity'] as int? ?? 0,
      createdBy: json['created_by'] as String? ?? '',
      status: json['status'] as String? ?? '',
      qrCodes:
          (json['qr_codes'] as List<dynamic>?)
              ?.map((qr) => QrCode.fromJson(qr as Map<String, dynamic>))
              .toList() ??
          [],
      packings:
          (json['packings'] as List<dynamic>?)
              ?.map((p) => PackingDetail.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'work_order_id': workOrderId,
      'work_order_number': workOrderNumber,
      'product_id': productId,
      'product_name': productName,
      'total_bundles': totalBundles,
      'total_quantity': totalQuantity,
      'uom': uom,
      'rejected_quantity': rejectedQuantity,
      'created_by': createdBy,
      'status': status,
      'qr_codes': qrCodes.map((qr) => qr.toJson()).toList(),
      'packings': packings.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get displayWorkOrderNumber =>
      workOrderNumber.isEmpty ? 'N/A' : workOrderNumber;
  String get displayProductName => productName.isEmpty ? 'N/A' : productName;
  String get displayTotalBundles => totalBundles.toString();
  String get displayTotalQuantity => totalQuantity.toString();
  String get displayCreatedBy => createdBy.isEmpty ? 'Unknown' : createdBy;
  String get displayCreatedAt {
    final date = createdAt.toLocal();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class QrCode {
  final String qrCodeId;
  final String qrCode;

  QrCode({required this.qrCodeId, required this.qrCode});

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      qrCodeId: json['qr_code_id'] as String? ?? '',
      qrCode: json['qr_code'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'qr_code_id': qrCodeId, 'qr_code': qrCode};
  }
}

class PackingDetail {
  final String packingId;
  final String workOrderNumber;
  final String productName;
  final int productQuantity;
  final int bundleSize;
  final String qrCodeId;
  final String qrCode;
  final int rejectedQuantity;
  final String uom;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PackingDetail({
    required this.packingId,
    required this.workOrderNumber,
    required this.productName,
    required this.productQuantity,
    required this.bundleSize,
    required this.qrCodeId,
    required this.qrCode,
    required this.rejectedQuantity,
    required this.uom,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackingDetail.fromJson(Map<String, dynamic> json) {
    return PackingDetail(
      packingId: json['packing_id'] as String? ?? '',
      workOrderNumber: json['work_order_number'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      productQuantity: json['product_quantity'] as int? ?? 0,
      bundleSize: json['bundle_size'] as int? ?? 0,
      qrCodeId: json['qr_code_id'] as String? ?? '',
      qrCode: json['qr_code'] as String? ?? '',
      rejectedQuantity: json['rejected_quantity'] as int? ?? 0,
      uom: json['uom'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'packing_id': packingId,
      'work_order_number': workOrderNumber,
      'product_name': productName,
      'product_quantity': productQuantity,
      'bundle_size': bundleSize,
      'qr_code_id': qrCodeId,
      'qr_code': qrCode,
      'rejected_quantity': rejectedQuantity,
      'uom': uom,
      'status': status,
      'created_by': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
