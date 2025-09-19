class ProductionResponse {
  final bool success;
  final String message;
  final ProductionData data;

  ProductionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductionResponse.fromJson(Map<String, dynamic> json) {
    return ProductionResponse(
      success: json['success'],
      message: json['message'],
      data: ProductionData.fromJson(json['data']),
    );
  }
}

class ProductionData {
  final int totalAchievedQuantity;
  final String productId;
  final List<ProductionLog> productionLogs;

  ProductionData({
    required this.totalAchievedQuantity,
    required this.productId,
    required this.productionLogs,
  });

  factory ProductionData.fromJson(Map<String, dynamic> json) {
    return ProductionData(
      totalAchievedQuantity: json['total_achieved_quantity'],
      productId: json['product_id'],
      productionLogs: (json['production_logs'] as List)
          .map((e) => ProductionLog.fromJson(e))
          .toList(),
    );
  }
}

class ProductionLog {
  final String timestamp;
  final String productName;
  final int achievedQuantity;

  ProductionLog({
    required this.timestamp,
    required this.productName,
    required this.achievedQuantity,
  });

  factory ProductionLog.fromJson(Map<String, dynamic> json) {
    return ProductionLog(
      timestamp: json['timestamp'],
      productName: json['product_name'],
      achievedQuantity: json['achieved_quantity'],
    );
  }
}
