import 'dart:convert';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';

class ProductModel {
  final String id;
  final PlantModel plant;
  final String materialCode;
  final String description;
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
    required this.plant,
    required this.materialCode,
    required this.description,
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
      // Handle ID field
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      
      // Handle plant data
      final plantData = json['plant'];
      PlantModel plant;
      if (plantData is Map<String, dynamic>) {
        plant = PlantModel.fromJson(plantData);
      } else {
        // Create a default plant if plant data is missing or invalid
        plant = PlantModel(
          id: '',
          plantCode: '',
          plantName: 'Unknown Plant',
          createdBy: CreatedBy(id: '', email: '', username: ''),
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 0,
        );
      }

      // Handle basic fields
      final materialCode = json['material_code']?.toString() ?? '';
      final description = json['description']?.toString() ?? '';
      
      // Handle UOM field
      final uom = json['uom'] != null
          ? List<String>.from(json['uom'].map((x) => x.toString()))
          : <String>['Square Metre/No']; // Default UOM

      // Handle areas - this is the key fix for your API response
      final areas = <String, double>{};
      
      if (json['areas'] != null && json['areas'] is Map) {
        // New format with areas map
        final areasMap = json['areas'] as Map;
        for (var entry in areasMap.entries) {
          final key = entry.key.toString();
          final value = entry.value;
          if (value is num) {
            areas[key] = value.toDouble();
          } else if (value is String) {
            areas[key] = double.tryParse(value) ?? 0.0;
          }
        }
      } else if (json['area'] != null) {
        // Old format with single area field - this matches your API response
        final areaValue = json['area'];
        final uomKey = uom.isNotEmpty ? uom.first : 'Square Metre/No';
        
        if (areaValue is num) {
          areas[uomKey] = areaValue.toDouble();
        } else if (areaValue is String) {
          areas[uomKey] = double.tryParse(areaValue) ?? 0.0;
        }
      }
      
      // If no areas data found, set default
      if (areas.isEmpty) {
        final uomKey = uom.isNotEmpty ? uom.first : 'Square Metre/No';
        areas[uomKey] = 0.0;
      }

      // Handle numeric fields
      final noOfPiecesPerPunch = _parseIntSafely(json['no_of_pieces_per_punch']);
      final qtyInBundle = _parseIntSafely(json['qty_in_bundle']);

      // Handle created_by
      final createdByData = json['created_by'];
      CreatedBy createdBy;
      if (createdByData is Map<String, dynamic>) {
        createdBy = CreatedBy.fromJson(createdByData);
      } else {
        createdBy = CreatedBy(id: '', email: '', username: 'Unknown');
      }

      // Handle other fields
      final status = json['status']?.toString() ?? 'Active';
      final isDeleted = json['isDeleted'] as bool? ?? false;

      // Handle dates
      final createdAt = _parseDateSafely(json['createdAt']);
      final updatedAt = _parseDateSafely(json['updatedAt']);

      // Handle version
      final version = _parseIntSafely(json['__v'] ?? json['v']);

      return ProductModel(
        id: id,
        plant: plant,
        materialCode: materialCode,
        description: description,
        uom: uom,
        areas: areas,
        noOfPiecesPerPunch: noOfPiecesPerPunch,
        qtyInBundle: qtyInBundle,
        createdBy: createdBy,
        status: status,
        isDeleted: isDeleted,
        createdAt: createdAt,
        updatedAt: updatedAt,
        version: version,
      );
    } catch (e) {
      print('Error parsing ProductModel: $e');
      print('JSON data: $json');
      
      // Return a default ProductModel to prevent crashes
      return ProductModel(
        id: json['_id']?.toString() ?? '',
        plant: PlantModel(
          id: '',
          plantCode: '',
          plantName: 'Unknown Plant',
          createdBy: CreatedBy(id: '', email: '', username: ''),
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 0,
        ),
        materialCode: json['material_code']?.toString() ?? 'Unknown',
        description: json['description']?.toString() ?? '',
        uom: ['Square Metre/No'],
        areas: {'Square Metre/No': 0.0},
        noOfPiecesPerPunch: 0,
        qtyInBundle: 0,
        createdBy: CreatedBy(id: '', email: '', username: 'Unknown'),
        status: 'Active',
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 0,
      );
    }
  }

  // Helper method to safely parse integers
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to safely parse dates
  static DateTime _parseDateSafely(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'plant': plant.toJson(),
      'material_code': materialCode,
      'description': description,
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

  ProductModel copyWith({
    String? id,
    PlantModel? plant,
    String? materialCode,
    String? description,
    List<String>? uom,
    Map<String, double>? areas,
    int? noOfPiecesPerPunch,
    int? qtyInBundle,
    CreatedBy? createdBy,
    String? status,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return ProductModel(
      id: id ?? this.id,
      plant: plant ?? this.plant,
      materialCode: materialCode ?? this.materialCode,
      description: description ?? this.description,
      uom: uom ?? this.uom,
      areas: areas ?? this.areas,
      noOfPiecesPerPunch: noOfPiecesPerPunch ?? this.noOfPiecesPerPunch,
      qtyInBundle: qtyInBundle ?? this.qtyInBundle,
      createdBy: createdBy ?? this.createdBy,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

class ProductResponse {
  final List<ProductModel> data;
  final String message;
  final bool success;

  ProductResponse({
    required this.data,
    required this.message,
    required this.success,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different response structures
      List<ProductModel> products = [];
      
      // Check if it's a direct array or wrapped in data field
      List<dynamic>? dataList;
      
      if (json['data'] is List) {
        dataList = json['data'] as List<dynamic>;
      } else if (json is List) {
        dataList = json as List<dynamic>;
      }
      
      if (dataList != null) {
        products = dataList
            .where((item) => item is Map<String, dynamic>)
            .map((item) {
              try {
                return ProductModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                print('Error parsing individual product: $e');
                return null;
              }
            })
            .where((product) => product != null)
            .cast<ProductModel>()
            .toList();
      }

      return ProductResponse(
        data: products,
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool? ?? true,
      );
    } catch (e) {
      print('Error parsing ProductResponse: $e');
      print('Response JSON: $json');
      return ProductResponse(
        data: [],
        message: 'Failed to parse response',
        success: false,
      );
    }
  }
}

ProductResponse productResponseFromJson(String str) {
  try {
    final decoded = json.decode(str);
    return ProductResponse.fromJson(decoded);
  } catch (e) {
    print('Error decoding JSON string: $e');
    print('JSON string: $str');
    return ProductResponse(
      data: [],
      message: 'Invalid JSON format',
      success: false,
    );
  }
}