import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:k2k/Iron_smith/workorder/model/iron_workorder_detail.dart'
    hide FileElement;
import 'package:k2k/Iron_smith/workorder/model/iron_workorder_model.dart';
import 'package:k2k/Iron_smith/workorder/repo/ironworkorder_repo.dart';
import 'package:intl/intl.dart';

class IronWorkorderProvider with ChangeNotifier {
  final IronWorkOrderRepository _repository = IronWorkOrderRepository();

  List<Client> _clients = [];
  List<Client> get clients => _clients;

  List<Project> _projects = [];
  List<Project> get projects => _projects;

  List<Shape> _shapeCodes = [];
  List<Shape> get shapeCodes => _shapeCodes;

  List<DiameterData> _diameters = [];
  List<DiameterData> get diameters => _diameters;

  DimensionData? _dimension;
  DimensionData? get dimension => _dimension;

  IronWorkOrder? _createdWorkOrder;
  IronWorkOrder? get createdWorkOrder => _createdWorkOrder;

  bool _isLoading = false;
  bool _isLoadingClients = false;
  bool _isLoadingProjects = false;
  bool _isLoadingShapeCodes = false;
  bool _isLoadingDiameters = false;
  bool _isLoadingDimension = false;

  String? _errorMessage;
  bool? _hasMoreData;
  List<IronWorkOrderData> workOrders = []; // For all work orders
  IoWorkOrderDetail? workOrderDetail; // For single work order

  bool get isLoading => _isLoading;
  bool get isLoadingClients => _isLoadingClients;
  bool get isLoadingProjects => _isLoadingProjects;
  bool get isLoadingShapeCodes => _isLoadingShapeCodes;
  bool get isLoadingDiameters => _isLoadingDiameters;
  bool get isLoadingDimension => _isLoadingDimension;
  bool? get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  int get dimensionCount => _dimension?.dimensionCount ?? 0;

  String? selectedClient;
  String? selectedProject;
  String? selectedShapeCode;
  String? workOrderNumber;
  DateTime? workOrderDate;

  List<Map<String, dynamic>> products = [
    {
      'shapeId': null,
      'shapeCode': null,
      'memberDetail': '',
      'barMark': '',
      'deliveryDate': null,
      'quantity': 0,
      'uom': 'nos',
      'poQuantity': 0,
      'diameter': null,
      'weight': 0.0,
      'dimensions': <String, dynamic>{},
    },
  ];

  List<String> uploadedFiles = [];

  // Reset form state
  void reset() {
    selectedClient = null;
    selectedProject = null;
    selectedShapeCode = null;
    workOrderNumber = null;
    workOrderDate = null;
    products = [
      {
        'shapeId': null,
        'shapeCode': null,
        'memberDetail': '',
        'barMark': '',
        'deliveryDate': null,
        'quantity': 0,
        'uom': 'nos',
        'memberQuantity': 0,
        'diameter': null,
        'weight': 0,
        'dimensions': <String, dynamic>{},
      },
    ];
    uploadedFiles = [];
    _clients = [];
    _projects = [];
    _diameters = [];
    _shapeCodes = [];
    _dimension = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Setters
  void setClient(String? client) {
    selectedClient = client;
    if (client == null) {
      _projects = [];
      _diameters = [];
      selectedProject = null;
    }
    notifyListeners();
  }

  void setProject(String? projectId) {
    selectedProject = projectId;
    if (projectId != null) {
      loadDiameterByProject(projectId);
    } else {
      _diameters = [];
    }
    notifyListeners();
  }

  void setShapeCode(String? shapeCode) {
    selectedShapeCode = shapeCode;
    if (shapeCode != null) {
      final selectedShape = _shapeCodes.firstWhere(
        (shape) => shape.shapeCode == shapeCode,
        orElse: () => Shape(id: null, shapeCode: ''),
      );
      if (selectedShape.id != null) {
        loadDimensionByShape(selectedShape.id!);
      }
    }
    notifyListeners();
  }

  void setWorkOrderDate(DateTime? date) {
    workOrderDate = date;
    notifyListeners();
  }

  void setWorkOrderNumber(String? number) {
    workOrderNumber = number;
    notifyListeners();
  }

  void addProduct() {
    products.add({
      'shapeId': null,
      'shapeCode': null,
      'memberDetail': '',
      'barMark': '',
      'deliveryDate': null,
      'quantity': 0,
      'uom': 'nos',
      'poQuantity': 0,
      'diameter': null,
      'weight': 0.0,
      'dimensions': <String, dynamic>{},
    });
    notifyListeners();
  }

  void removeProduct(int index) {
    if (products.length > 1) {
      products.removeAt(index);
    }
    notifyListeners();
  }

  void addFiles(List<String> fileNames) {
    uploadedFiles.addAll(fileNames);
    notifyListeners();
  }

  void removeFile(String fileName) {
    uploadedFiles.remove(fileName);
    notifyListeners();
  }

  void updateProduct(int index, Map<String, dynamic> updates) {
    if (index >= products.length) {
      products.addAll(
        List.generate(
          index - products.length + 1,
          (_) => {
            'shapeId': null,
            'shapeCode': null,
            'memberDetail': '',
            'barMark': '',
            'deliveryDate': null,
            'memberQuantity': 0, // Initialize memberQuantity
            'quantity': 0,
            'uom': 'nos',
            'poQuantity': 0,
            'diameter': null,
            'weight': 0.0,
            'dimensions': <String, dynamic>{},
          },
        ),
      );
    }
    products[index] = {...products[index], ...updates};
    // Auto-fill weight when diameter is updated
    if (updates.containsKey('diameter')) {
      final value = updates['diameter'];
      if (value != null) {
        final selectedDiameter = _diameters.firstWhere(
          (d) => d.diameter.toString() == value,
          orElse: () => DiameterData(diameter: 0, qty: 0),
        );
        if (selectedDiameter.qty != null) {
          products[index]['weight'] = selectedDiameter.qty!.toDouble();
        } else {
          products[index]['weight'] = 0.0;
        }
      } else {
        products[index]['weight'] = 0.0;
      }
    }
    notifyListeners();
  }

  // Fetch clients
  Future<void> fetchAllClients() async {
    _isLoadingClients = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getAllClients();
      _clients = response.data?.clients ?? [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingClients = false;
      notifyListeners();
    }
  }

  // Fetch shape codes
  Future<void> fetchAllShapeCodes() async {
    _isLoadingShapeCodes = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getAllShapeCodes();
      _shapeCodes =
          response.data?.shapes
              ?.map((shape) => Shape(id: shape.id, shapeCode: shape.shapeCode))
              .toList() ??
          [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingShapeCodes = false;
      notifyListeners();
    }
  }

  // Fetch projects by client
  Future<void> loadProjectsByClient(String clientId) async {
    _isLoadingProjects = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getProjectsByClient(clientId);
      _projects = response.data ?? [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingProjects = false;
      notifyListeners();
    }
  }

  // Fetch diameters by project
  Future<void> loadDiameterByProject(String projectId) async {
    _isLoadingDiameters = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getDiameterByProjects(projectId);
      _diameters = response.rawMaterialData ?? [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingDiameters = false;
      notifyListeners();
    }
  }

  // Fetch dimensions by shape
  Future<void> loadDimensionByShape(String shapeId) async {
    if (shapeId.isEmpty) {
      _errorMessage = 'Invalid shape ID: Cannot be empty';
      _isLoadingDimension = false;
      notifyListeners();
      return;
    }
    _isLoadingDimension = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getDimensionByShape(shapeId);
      if (!response.success) {
        throw Exception('Failed to load dimensions');
      }
      _dimension = response.data;
    } catch (e) {
      _errorMessage = 'Failed to load dimensions: ${e.toString()}';
    } finally {
      _isLoadingDimension = false;
      notifyListeners();
    }
  }

  // Fetch work orders
  Future<void> loadWorkOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchWorkOrders();
      workOrders = result.data ?? [];
      _hasMoreData = false; // Update based on pagination logic if needed
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a single work order by ID
  // Future<void> loadWorkOrderById(String id) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   workOrderDetail = null;
  //   notifyListeners();

  //   try {
  //     final result = await _repository.fetchWorkOrderById(id);
  //     workOrderDetail = result;
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> deleteWorkOrder(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteWorkOrder(id);
      await loadWorkOrders(); // Refresh the work orders list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create work order (corrected to match IronWorkorderAddScreen)
  Future<bool> createWorkOrder({
    required String workOrderNumber,
    required String? clientId,
    required String? projectId,
    required DateTime? date,
    required List<Map<String, dynamic>> products,
    required List<FileElement> files,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate required fields
      if (clientId == null || projectId == null || date == null) {
        throw Exception('Client, project, or date is missing');
      }
      if (products.any(
        (p) => p['memberQuantity'] == null || p['memberQuantity'] <= 0,
      )) {
        throw Exception(
          'Member Quantity is required and must be positive for all products',
        );
      }
      if (files.isEmpty) {
        throw Exception('At least one file is required');
      }

      // Format workOrderDate to match backend's expected format (yyyy-MM-dd)
      final dateFormat = DateFormat('yyyy-MM-dd');
      final formattedWorkOrderDate = dateFormat.format(date);

      // Construct payload
      final payload = {
        'clientId': clientId,
        'projectId': projectId,
        'workOrderNumber': workOrderNumber,
        'workOrderDate': formattedWorkOrderDate,
        'created_by': 'user_id_placeholder',
        'updated_by': 'user_id_placeholder',
        'products': products.map((product) {
          final dimensions = <Map<String, dynamic>>[];
          for (int i = 0; i < (product['dimensionCount'] ?? 0); i++) {
            final dimensionValue = product['dimensions']['dimension_$i'];
            dimensions.add({
              'name': 'Dimension ${String.fromCharCode(65 + i)}',
              'value':
                  num.tryParse(dimensionValue?.toString() ?? '0') ??
                  0, // Send as number
            });
          }
          return {
            'shapeId': product['shapeId'],
            'uom': product['uom'] ?? 'nos',
            'quantity': product['quantity'] ?? 0, // Send as number
            'diameter':
                int.tryParse(product['diameter']?.toString() ?? '0') ??
                0, // Send as integer
            'weight':
                int.tryParse(product['weight']?.toString() ?? '0') ??
                0.0, // Send as double
            'deliveryDate': product['deliveryDate'] != null
                ? dateFormat.format(product['deliveryDate'])
                : null,
            'barMark': product['barMark'] ?? '',
            'memberDetails': product['memberDetail'] ?? '',
            'memberQuantity': product['memberQuantity'] ?? 0, // Send as number
            'dimensions': dimensions,
          };
        }).toList(),
        'files': files
            .map(
              (file) => {
                'file_name': file.fileName,
                'file_url': file.fileUrl, // Ensure valid file path
                'uploaded_at':
                    file.uploadedAt ?? DateTime.now().toIso8601String(),
                '_id': file.id ?? '',
              },
            )
            .toList(),
      };

      // Log payload for debugging
      print('DEBUG: createWorkOrder: Final Payload = ${jsonEncode(payload)}');

      final workOrder = await _repository.createWorkOrder(payload);
      _createdWorkOrder = workOrder;
      await loadWorkOrders();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('DEBUG: createWorkOrder: Error = $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";

    try {
      // Match your backend format: d/M/yyyy, h:mm:ss a
      final inputFormat = DateFormat("d/M/yyyy");
      final dateTime = inputFormat.parse(dateString);

      // Convert to your desired format (example: dd/MM/yyyy hh:mm a)
      final outputFormat = DateFormat("dd/MM/yyyy hh:mm a");
      return outputFormat.format(dateTime);
    } catch (e) {
      return "N/A"; // fallback if parsing fails
    }
  }

  // Add this method to IronWorkorderProvider
  Future<bool> updateWorkOrder({
    required String workOrderId,
    required String workOrderNumber,
    required String? clientId,
    required String? projectId,
    required DateTime? date,
    required List<Map<String, dynamic>> products,
    required List<FileElement> files,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate required fields
      if (clientId == null || projectId == null || date == null) {
        throw Exception('Client, project, or date is missing');
      }
      if (products.any(
        (p) => p['memberQuantity'] == null || p['memberQuantity'] <= 0,
      )) {
        throw Exception(
          'Member Quantity is required and must be positive for all products',
        );
      }
      if (files.isEmpty) {
        throw Exception('At least one file is required');
      }

      // Format workOrderDate to match backend's expected format (yyyy-MM-dd)
      final dateFormat = DateFormat('yyyy-MM-dd');
      final formattedWorkOrderDate = dateFormat.format(date);

      // Construct payload
      final payload = {
        'clientId': clientId,
        'projectId': projectId,
        'workOrderNumber': workOrderNumber,
        'workOrderDate': formattedWorkOrderDate,
        'updated_by': 'user_id_placeholder', // Adjust based on your auth logic
        'products': products.map((product) {
          final dimensions = <Map<String, dynamic>>[];
          for (int i = 0; i < (product['dimensionCount'] ?? 0); i++) {
            final dimensionValue = product['dimensions']['dimension_$i'];
            dimensions.add({
              'name': 'Dimension ${String.fromCharCode(65 + i)}',
              'value': num.tryParse(dimensionValue?.toString() ?? '0') ?? 0,
            });
          }
          return {
            'shapeId': product['shapeId'],
            'uom': product['uom'] ?? 'nos',
            'quantity': product['quantity'] ?? 0,
            'diameter':
                int.tryParse(product['diameter']?.toString() ?? '0') ?? 0,
            'weight': num.tryParse(product['weight']?.toString() ?? '0') ?? 0.0,
            'deliveryDate': product['deliveryDate'] != null
                ? dateFormat.format(product['deliveryDate'])
                : null,
            'barMark': product['barMark'] ?? '',
            'memberDetails': product['memberDetail'] ?? '',
            'memberQuantity': product['memberQuantity'] ?? 0,
            'dimensions': dimensions,
            '_id': product['_id'] ?? '', // Include product ID for updates
          };
        }).toList(),
        'files': files
            .map(
              (file) => {
                'file_name': file.fileName,
                'file_url': file.fileUrl,
                'uploaded_at':
                    file.uploadedAt ?? DateTime.now().toIso8601String(),
                '_id': file.id ?? '',
              },
            )
            .toList(),
      };

      // Log payload for debugging
      print('DEBUG: updateWorkOrder: Final Payload = ${jsonEncode(payload)}');

      final workOrder = await _repository.updateWorkOrder(workOrderId, payload);
      _createdWorkOrder = workOrder;
      await loadWorkOrders();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('DEBUG: updateWorkOrder: Error = $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Modify existing methods to support prefilling
  Future<void> loadWorkOrderById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    workOrderDetail = null;
    notifyListeners();

    try {
      final result = await _repository.fetchWorkOrderById(id);
      workOrderDetail = result;

      // Prefill form fields
      if (result.data != null) {
        selectedClient = result.data!.clientId?.id;
        selectedProject = result.data!.projectId?.id;
        workOrderNumber = result.data!.workOrderDetails?.workOrderNumber;
        // Parse workOrderDate in dd-MM-yyyy hh:mm a format
        // Parse workOrderDate in dd-MM-yyyy hh:mm a format
        if (result.data!.workOrderDetails?.date != null) {
          try {
            final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
            // Normalize AM/PM to uppercase
            String normalizedDateString = result.data!.workOrderDetails!.date!
                .replaceAllMapped(
                  RegExp(r'am|pm', caseSensitive: false),
                  (match) => match.group(0)!.toUpperCase(),
                );
            workOrderDate = dateFormat.parse(normalizedDateString);
          } catch (e) {
            workOrderDate = DateTime.now(); // Fallback to current date
          }
        } else {
          workOrderDate = DateTime.now(); // Fallback to current date
        }
        uploadedFiles =
            result.data!.files?.map((file) => file.fileName ?? '').toList() ??
            [];

        products =
            result.data!.products?.map((product) {
              final dimensions = <String, dynamic>{};
              product.dimensions?.asMap().forEach((index, dim) {
                dimensions['dimension_$index'] = dim.value;
              });
              DateTime? deliveryDate;
              if (product.deliveryDate != null &&
                  product.deliveryDate is String) {
                try {
                  final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
                  // Normalize AM/PM to uppercase
                  String normalizedDeliveryDate =
                      (product.deliveryDate as String).replaceAllMapped(
                        RegExp(r'am|pm', caseSensitive: false),
                        (match) => match.group(0)!.toUpperCase(),
                      );
                  print(
                    'DEBUG: Normalized deliveryDate string: $normalizedDeliveryDate',
                  );
                  deliveryDate = dateFormat.parse(normalizedDeliveryDate);
                  print('DEBUG: Parsed deliveryDate = $deliveryDate');
                } catch (e) {
                  print(
                    'DEBUG: loadWorkOrderById: Failed to parse deliveryDate "${product.deliveryDate}": $e',
                  );
                  deliveryDate = null; // Fallback to null for deliveryDate
                }
              } else {
                print(
                  'DEBUG: loadWorkOrderById: deliveryDate is null or invalid',
                );
                deliveryDate = null;
              }
              return {
                'shapeId': product.shapeId?.id,
                'shapeCode': product.shapeId?.shapeCode,
                'memberDetail': product.memberDetails ?? '',
                'barMark': product.barMark ?? '',
                'deliveryDate': deliveryDate,
                'quantity': product.quantity ?? 0,
                'uom': product.uom ?? 'nos',
                'memberQuantity': product.memberQuantity ?? 0,
                'diameter': product.diameter?.toString(),
                'weight': num.tryParse(product.weight ?? '0') ?? 0.0,
                'dimensions': dimensions,
                'dimensionCount': product.dimensions?.length ?? 0,
                '_id': product.id ?? '',
              };
            }).toList() ??
            [
              {
                'shapeId': null,
                'shapeCode': null,
                'memberDetail': '',
                'barMark': '',
                'deliveryDate': null,
                'quantity': 0,
                'uom': 'nos',
                'memberQuantity': 0,
                'diameter': null,
                'weight': 0.0,
                'dimensions': <String, dynamic>{},
              },
            ];

        // Load dependent data
        if (selectedClient != null) {
          await loadProjectsByClient(selectedClient!);
        }
        if (selectedProject != null) {
          await loadDiameterByProject(selectedProject!);
        }
        if (products.any((p) => p['shapeId'] != null)) {
          final shapeId = products.firstWhere(
            (p) => p['shapeId'] != null,
          )['shapeId'];
          await loadDimensionByShape(shapeId);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
