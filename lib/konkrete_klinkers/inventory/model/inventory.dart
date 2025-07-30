class InventoryItem {
  final String materialCode;
  final String description;
  final String status;
  final String uom;
  final int totalProducedQuantity;
  final int totalPoQuantity;
  final String productId;
  final int balanceQuantity;
  final int workOrderCount;

  InventoryItem({
    required this.materialCode,
    required this.description,
    required this.status,
    required this.uom,
    required this.totalProducedQuantity,
    required this.totalPoQuantity,
    required this.productId,
    required this.balanceQuantity,
    required this.workOrderCount,
  });

  // From JSON
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      materialCode: json['material_code'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      uom: json['uom'] as String,
      totalProducedQuantity: json['total_produced_quantity'] as int,
      totalPoQuantity: json['total_po_quantity'] as int,
      productId: json['product_id'] as String,
      balanceQuantity: json['balance_quantity'] as int,
      workOrderCount: json['work_order_count'] as int,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'material_code': materialCode,
      'description': description,
      'status': status,
      'uom': uom,
      'total_produced_quantity': totalProducedQuantity,
      'total_po_quantity': totalPoQuantity,
      'product_id': productId,
      'balance_quantity': balanceQuantity,
      'work_order_count': workOrderCount,
    };
  }
}
