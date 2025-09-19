class DispatchModel {
  final String id;
  final String workOrderNumber;
  final String clientName;
  final String projectName;
  final List<ProductName> productNames;
  final String createdBy;
  final DateTime createdAt;
  final String invoiceOrSto;
  final String vehicleNumber;
  final String date;

  DispatchModel({
    required this.id,
    required this.workOrderNumber,
    required this.clientName,
    required this.projectName,
    required this.productNames,
    required this.createdBy,
    required this.createdAt,
    required this.invoiceOrSto,
    required this.vehicleNumber,
    required this.date,
  });

  factory DispatchModel.fromJson(Map<String, dynamic> json) {
    return DispatchModel(
      id: json['_id'] ?? '',
      workOrderNumber: json['work_order_number'] ?? '',
      clientName: json['client_name'] ?? '',
      projectName: json['project_name'] ?? '',
      productNames: (json['product_names'] as List? ?? [])
          .map((e) => ProductName.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      invoiceOrSto: json['invoice_or_sto'] ?? '',
      vehicleNumber: json['vehicle_number'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'work_order_number': workOrderNumber,
      'client_name': clientName,
      'project_name': projectName,
      'product_names': productNames.map((e) => e.toJson()).toList(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'invoice_or_sto': invoiceOrSto,
      'vehicle_number': vehicleNumber,
      'date': date,
    };
  }
}

class ProductName {
  final String name;
  final int dispatchQuantity;

  ProductName({required this.name, required this.dispatchQuantity});

  factory ProductName.fromJson(Map<String, dynamic> json) {
    return ProductName(
      name: json['name'] ?? '',
      dispatchQuantity: json['dispatch_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'dispatch_quantity': dispatchQuantity};
  }
}
