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
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      if (id.isEmpty) {
        print('Warning: Product ID is empty in JSON: $json');
      }

      final plantData = json['plant'];
      if (plantData == null) {
        print('Error: plant field is null in JSON: $json');
      }
      final plant = plantData is Map<String, dynamic>
          ? PlantModel.fromJson(plantData)
          : PlantModel(
              id: '',
              plantCode: '',
              plantName: '',
              createdBy: CreatedBy(id: '', email: '', username: ''),
              isDeleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              version: 0,
            );

      final materialCode = json['material_code']?.toString() ?? '';
      if (materialCode.isEmpty) {
        print('Warning: material_code is empty in JSON: $json');
      }

      final description = json['description']?.toString() ?? '';
      final uom = json['uom'] != null
          ? List<String>.from(json['uom'].map((x) => x.toString()))
          : <String>[];
      final areas = json['areas'] != null
          ? Map<String, double>.from(
              (json['areas'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  value is num ? value.toDouble() : (double.tryParse(value.toString()) ?? 0.0),
                ),
              ),
            )
          : <String, double>{};
      final noOfPiecesPerPunch = json['no_of_pieces_per_punch'] is num
          ? (json['no_of_pieces_per_punch'] as num).toInt()
          : 0;
      final qtyInBundle = json['qty_in_bundle'] is num
          ? (json['qty_in_bundle'] as num).toInt()
          : 0;

      final createdByData = json['created_by'];
      final createdBy = createdByData is Map<String, dynamic>
          ? CreatedBy.fromJson(createdByData)
          : CreatedBy(id: '', email: '', username: '');

      final status = json['status']?.toString() ?? '';
      final isDeleted = json['isDeleted'] as bool? ?? false;

      DateTime createdAt;
      try {
        final createdAtStr = json['createdAt']?.toString();
        createdAt = createdAtStr != null
            ? DateTime.parse(createdAtStr)
            : DateTime.now();
      } catch (e) {
        print('Error parsing createdAt: $e for JSON: $json');
        createdAt = DateTime.now();
      }

      DateTime updatedAt;
      try {
        final updatedAtStr = json['updatedAt']?.toString();
        updatedAt = updatedAtStr != null
            ? DateTime.parse(updatedAtStr)
            : DateTime.now();
      } catch (e) {
        print('Error parsing updatedAt: $e for JSON: $json');
        updatedAt = DateTime.now();
      }

      final version = json['__v'] is num
          ? (json['__v'] as num).toInt()
          : (json['v'] is num ? (json['v'] as num).toInt() : 0);

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
      print('Error parsing ProductModel: $e for JSON: $json');
      rethrow;
    }
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
  final Pagination pagination;
  final String message;
  final bool success;

  ProductResponse({
    required this.data,
    required this.pagination,
    required this.message,
    required this.success,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    try {
      final dataJson = json['data'];
      if (dataJson == null) {
        print('Error: data field is null in JSON response: $json');
        return ProductResponse(
          data: [],
          pagination: Pagination(total: 0, page: 1, limit: 10, totalPages: 1),
          message: json['message']?.toString() ?? 'No data field in response',
          success: json['success'] as bool? ?? false,
        );
      }

      final productsJson = dataJson['products'] as List<dynamic>?;
      if (productsJson == null) {
        print('Error: products field is null or not a list in JSON: $json');
        return ProductResponse(
          data: [],
          pagination: Pagination.fromJson(dataJson['pagination'] ?? {}),
          message: json['message']?.toString() ?? 'No products field in response',
          success: json['success'] as bool? ?? false,
        );
      }

      final products = productsJson
          .map((item) {
            try {
              if (item is Map<String, dynamic>) {
                return ProductModel.fromJson(item);
              } else {
                print('Error: Product item is not a Map: $item');
                return null;
              }
            } catch (e) {
              print('Error parsing product: $e for item: $item');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<ProductModel>()
          .toList();

      return ProductResponse(
        data: products,
        pagination: Pagination.fromJson(dataJson['pagination'] ?? {}),
        message: json['message']?.toString() ?? '',
        success: json['success'] as bool? ?? true,
      );
    } catch (e) {
      print('Error parsing ProductResponse: $e for JSON: $json');
      return ProductResponse(
        data: [],
        pagination: Pagination(total: 0, page: 1, limit: 10, totalPages: 1),
        message: 'Failed to parse response: $e',
        success: false,
      );
    }
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
      totalPages: json['totalPages'] is num ? (json['totalPages'] as num).toInt() : 1,
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

ProductResponse productResponseFromJson(String str) =>
    ProductResponse.fromJson(json.decode(str));