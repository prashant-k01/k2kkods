import 'dart:convert';
import 'package:flutter/foundation.dart';

WorkOrderModel workOrderModelFromJson(String str) =>
    WorkOrderModel.fromJson(json.decode(str));

String workOrderModelToJson(WorkOrderModel data) => json.encode(data.toJson());

class WorkOrderModel {
  final bool success;
  final String message;
  final List<Datum> data;

  WorkOrderModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WorkOrderModel.fromJson(Map<String, dynamic> json) {
    List<Datum> dataList = [];
    if (json['data'] is Map<String, dynamic>) {
      dataList = [Datum.fromJson(json['data'] as Map<String, dynamic>)];
    } else if (json['data'] is List<dynamic>) {
      dataList = (json['data'] as List<dynamic>)
          .map((x) => Datum.fromJson(x as Map<String, dynamic>))
          .toList();
    } else {
      dataList = [];
    }

    return WorkOrderModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'Unknown error',
      data: dataList,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  final String id;
  final String? clientId;
  final String? clientName;
  final String? projectId;
  final String? projectName;
  final String workOrderNumber;
  final DateTime? date;
  final bool bufferStock;
  final List<Product> products;
  final List<FileElement> files;
  final Status status;
  final CreatedBy createdBy;
  final UpdatedBy updatedBy;
  final List<dynamic> bufferTransferLogs;
  final List<dynamic> jobOrders;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Datum({
    required this.id,
    this.clientId,
    this.clientName,
    this.projectId,
    this.projectName,
    required this.workOrderNumber,
    this.date,
    required this.bufferStock,
    required this.products,
    required this.files,
    required this.status,
    required this.createdBy,
    required this.updatedBy,
    required this.bufferTransferLogs,
    required this.jobOrders,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    try {
      String? clientId;
      String? clientName;
      if (json['client_id'] is String) {
        clientId = json['client_id'] as String?;
        clientName = 'Unknown Client';
      } else if (json['client_id'] is Map<String, dynamic>) {
        clientId = (json['client_id'] as Map<String, dynamic>)['_id']
            ?.toString();
        clientName =
            (json['client_id'] as Map<String, dynamic>)['name']?.toString() ??
            'Unknown Client';
      } else {
        clientId = '';
        clientName = 'Unknown Client';
      }

      String? projectId;
      String? projectName;
      if (json['project_id'] is String) {
        projectId = json['project_id'] as String?;
        projectName = 'Unknown Project';
      } else if (json['project_id'] is Map<String, dynamic>) {
        projectId = (json['project_id'] as Map<String, dynamic>)['_id']
            ?.toString();
        projectName =
            (json['project_id'] as Map<String, dynamic>)['name']?.toString() ??
            'Unknown Project';
      } else {
        projectId = '';
        projectName = 'Unknown Project';
      }

      String? updatedById;
      if (json['updated_by'] is String) {
        updatedById = json['updated_by'] as String?;
      } else if (json['updated_by'] is Map<String, dynamic>) {
        updatedById = (json['updated_by'] as Map<String, dynamic>)['_id']
            ?.toString();
      } else {
        updatedById = '';
      }

      return Datum(
        id: json['_id'] is String ? json['_id'] as String? ?? '' : '',
        clientId: clientId,
        clientName: clientName,
        projectId: projectId,
        projectName: projectName,
        workOrderNumber: json['work_order_number'] is String
            ? json['work_order_number'] as String? ?? ''
            : '',
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : null,
        bufferStock: json['buffer_stock'] as bool? ?? false,
        products: json['products'] is List<dynamic>
            ? (json['products'] as List<dynamic>).map((x) {
                if (kDebugMode) {
                  print('📝 [Datum] Parsing product: ${x.runtimeType}');
                }
                return Product.fromJson(x as Map<String, dynamic>);
              }).toList()
            : json['products'] is String
            ? []
            : [],
        files: json['files'] is List<dynamic>
            ? (json['files'] as List<dynamic>).map((x) {
                if (kDebugMode) {
                  print('📝 [Datum] Parsing file: ${x.runtimeType}');
                }
                return FileElement.fromJson(x as Map<String, dynamic>);
              }).toList()
            : json['files'] is String
            ? []
            : [],
        status: statusValues.map[json['status'] as String?] ?? Status.PENDING,
        createdBy: CreatedBy.fromJson(
          json['created_by'] is Map<String, dynamic>
              ? json['created_by'] as Map<String, dynamic>
              : {
                  '_id': json['created_by'] is String
                      ? json['created_by'] as String? ?? ''
                      : '',
                  'username': 'admin',
                },
        ),
        updatedBy:
            updatedByValues.map[updatedById] ??
            UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        bufferTransferLogs: json['buffer_transfer_logs'] is List<dynamic>
            ? json['buffer_transfer_logs'] as List<dynamic>
            : json['bufferTransferLogs'] is List<dynamic>
            ? json['bufferTransferLogs'] as List<dynamic>
            : json['buffer_transfer_logs'] is String
            ? []
            : [],
        jobOrders: json['job_orders'] is List<dynamic>
            ? json['job_orders'] as List<dynamic>
            : json['jobOrders'] is List<dynamic>
            ? json['jobOrders'] as List<dynamic>
            : json['job_orders'] is String
            ? []
            : [],
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        v: json['__v'] as int? ?? 0,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('📝 [Datum] Error parsing JSON: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'client_id': clientId,
    'project_id': projectId,
    'work_order_number': workOrderNumber,
    'date': date?.toIso8601String(),
    'buffer_stock': bufferStock,
    'products': List<dynamic>.from(products.map((x) => x.toJson())),
    'files': List<dynamic>.from(files.map((x) => x.toJson())),
    'status': statusValues.reverse[status],
    'created_by': createdBy.toJson(),
    'updated_by': updatedByValues.reverse[updatedBy],
    'buffer_transfer_logs': List<dynamic>.from(bufferTransferLogs),
    'job_orders': List<dynamic>.from(jobOrders),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': v,
  };
}

class TId {
  final String id;
  final String name;

  TId({required this.id, required this.name});

  factory TId.fromJson(dynamic json) {
    if (json == null || json == '') {
      return TId(id: '', name: '');
    }
    return TId(
      id: json is String ? json : json['_id'] as String? ?? '',
      name: json is Map ? json['name'] as String? ?? '' : '',
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class CreatedBy {
  final UpdatedBy id;
  final Username username;

  CreatedBy({required this.id, required this.username});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('📝 [CreatedBy] Parsing JSON: $json');
      print('📝 [CreatedBy] _id type: ${json['_id']?.runtimeType}');
      print('📝 [CreatedBy] username type: ${json['username']?.runtimeType}');
      if (json.isEmpty) {
        print('📝 [CreatedBy] Warning: Empty JSON object received');
      }
    }

    try {
      final id = json['_id'] is String ? json['_id'] as String? : '';
      final username = json['username'] is String
          ? json['username'] as String?
          : '';

      return CreatedBy(
        id:
            updatedByValues.map[id] ??
            UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        username: usernameValues.map[username] ?? Username.ADMIN,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('📝 [CreatedBy] Error parsing JSON: $e\n$stackTrace');
      }
      return CreatedBy(
        id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        username: Username.ADMIN,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    '_id': updatedByValues.reverse[id],
    'username': usernameValues.reverse[username],
  };
}

enum UpdatedBy { THE_68467_BBCC6407_E1_FDF09_D18_E }

final updatedByValues = EnumValues({
  '68467bbcc6407e1fdf09d18e': UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
});

enum Username { ADMIN }

final usernameValues = EnumValues({'admin': Username.ADMIN});

class FileElement {
  final String fileName;
  final String fileUrl;
  final String id;
  final DateTime uploadedAt;

  FileElement({
    required this.fileName,
    required this.fileUrl,
    required this.id,
    required this.uploadedAt,
  });

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
    fileName: json['file_name'] as String? ?? '',
    fileUrl: json['file_url'] as String? ?? '',
    id: json['_id'] as String? ?? '',
    uploadedAt:
        DateTime.tryParse(json['uploaded_at'] as String? ?? '') ??
        DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'file_name': fileName,
    'file_url': fileUrl,
    '_id': id,
    'uploaded_at': uploadedAt.toIso8601String(),
  };
}

class Product {
  final String productId;
  final Uom uom;
  final int poQuantity;
  final int? qtyInNos;
  final DateTime? deliveryDate;
  final String id;
  final ProductModel? product;
  final PlantModel? plant;

  Product({
    required this.productId,
    required this.uom,
    required this.poQuantity,
    this.qtyInNos,
    this.deliveryDate,
    required this.id,
    this.product,
    this.plant,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? productId;
    ProductModel? productModel;
    PlantModel? plantModel;

    try {
      if (json['product'] is String) {
        productId = json['product'] as String?;
      } else if (json['product'] is Map<String, dynamic>) {
        productModel = ProductModel.fromJson(
          json['product'] as Map<String, dynamic>,
        );
        productId = productModel.id;
      } else {
        productId = '';
      }

      if (json['plant'] is Map<String, dynamic>) {
        plantModel = PlantModel.fromJson(json['plant'] as Map<String, dynamic>);
      }

      Uom uomValue = Uom.NOS;
      if (json['uom'] is String) {
        uomValue =
            uomValues.map[json['uom'].toString().toLowerCase()] ?? Uom.NOS;
      } else if (json['uom'] is List<dynamic>) {
        final uomList = (json['uom'] as List<dynamic>).whereType<String>();
        uomValue = uomList.isNotEmpty
            ? uomValues.map[uomList.first.toLowerCase()] ?? Uom.NOS
            : Uom.NOS;
      }

      return Product(
        productId: productId ?? '',
        uom: uomValue,
        poQuantity: json['po_quantity'] as int? ?? 0,
        qtyInNos: json['qty_in_nos'] as int? ?? 0,
        deliveryDate: json['delivery_date'] == null
            ? null
            : DateTime.tryParse(json['delivery_date'] as String) ??
                  DateTime.now(),
        id: json['_id'] as String? ?? '',
        product: productModel,
        plant: plantModel,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('📝 [Product] Error parsing JSON: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'uom': uomValues.reverse[uom],
    'po_quantity': poQuantity,
    'qty_in_nos': qtyInNos,
    'delivery_date': deliveryDate?.toIso8601String(),
    '_id': id,
    'product': product?.toJson(),
    'plant': plant?.toJson(),
  };
}

enum Uom { METRE, NOS, SQMT }

final uomValues = EnumValues({
  'metre': Uom.METRE,
  'nos': Uom.NOS,
  'square metre': Uom.SQMT,
  'metre/no': Uom.METRE,
});

enum Status { PENDING }

final statusValues = EnumValues({'Pending': Status.PENDING});

class EnumValues<T> {
  final Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class PlantModel {
  final String id;
  final String plantCode;
  final String plantName;
  final CreatedBy createdBy;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  PlantModel({
    required this.id,
    required this.plantCode,
    required this.plantName,
    required this.createdBy,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['_id'] as String? ?? '',
      plantCode: json['plant_code'] as String? ?? '',
      plantName: json['plant_name'] as String? ?? '',
      createdBy: CreatedBy.fromJson(
        json['created_by'] is Map<String, dynamic>
            ? json['created_by'] as Map<String, dynamic>
            : {},
      ),
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      version: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'plant_code': plantCode,
    'plant_name': plantName,
    'created_by': createdBy.toJson(),
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': version,
  };
}

class ProductModel {
  final String id;
  final String materialCode;
  final String description;
  final PlantModel plant;
  final List<String> uom;
  final Map<String, double> areas;
  final int noOfPiecesPerPunch;
  final int qtyInBundle;
  final CreatedBy createdBy;
  final String status;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  ProductModel({
    required this.id,
    required this.materialCode,
    required this.description,
    required this.plant,
    required this.uom,
    required this.areas,
    required this.noOfPiecesPerPunch,
    required this.qtyInBundle,
    required this.createdBy,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['_id'] is String ? json['_id'] as String? ?? '' : '',
        materialCode: json['material_code'] is String
            ? json['material_code'] as String? ?? ''
            : '',
        description: json['description'] is String
            ? json['description'] as String? ?? ''
            : '',
        plant: PlantModel.fromJson(
          json['plant'] is Map<String, dynamic>
              ? json['plant'] as Map<String, dynamic>
              : {},
        ),
        uom: json['uom'] is String
            ? [json['uom'] as String]
            : (json['uom'] as List<dynamic>?)?.cast<String>() ?? [],
        areas:
            (json['areas'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ) ??
            {},
        noOfPiecesPerPunch: json['no_of_pieces_per_punch'] as int? ?? 0,
        qtyInBundle: json['qty_in_bundle'] as int? ?? 0,
        createdBy: CreatedBy.fromJson(
          json['created_by'] is Map<String, dynamic>
              ? json['created_by'] as Map<String, dynamic>
              : {},
        ),
        status: json['status'] is String ? json['status'] as String? ?? '' : '',
        isDeleted: json['isDeleted'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        version: json['__v'] as int? ?? 0,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('📝 [ProductModel] Error parsing JSON: $e\n$stackTrace');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'material_code': materialCode,
    'description': description,
    'plant': plant.toJson(),
    'uom': uom,
    'areas': areas,
    'no_of_pieces_per_punch': noOfPiecesPerPunch,
    'qty_in_bundle': qtyInBundle,
    'created_by': createdBy.toJson(),
    'status': status,
    'isDeleted': isDeleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    '__v': version,
  };
}
