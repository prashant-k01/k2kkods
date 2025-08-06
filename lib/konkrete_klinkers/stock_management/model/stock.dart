class StockManagement {
  final String id;
  final String fromWorkOrderId;
  final String toWorkOrderId;
  final int quantityTransferred;
  final String transferredBy;
  final DateTime transferDate;
  final bool isBufferTransfer;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productName;

  StockManagement({
    required this.id,
    required this.fromWorkOrderId,
    required this.toWorkOrderId,
    required this.quantityTransferred,
    required this.transferredBy,
    required this.transferDate,
    required this.isBufferTransfer,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.productName,
  });

  factory StockManagement.fromJson(Map<String, dynamic> json) {
    return StockManagement(
      id: json['_id'] ?? '',
      fromWorkOrderId: json['from_work_order_id'] ?? '',
      toWorkOrderId: json['to_work_order_id'] ?? '',
      quantityTransferred: json['quantity_transferred'] ?? 0,
      transferredBy: json['transferred_by'] ?? '',
      transferDate: DateTime.parse(json['transfer_date']),
      isBufferTransfer: json['isBufferTransfer'] ?? false,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productName: json['product_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from_work_order_id': fromWorkOrderId,
      'to_work_order_id': toWorkOrderId,
      'quantity_transferred': quantityTransferred,
      'transferred_by': transferredBy,
      'transfer_date': transferDate.toIso8601String(),
      'isBufferTransfer': isBufferTransfer,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'product_name': productName,
    };
  }
}
