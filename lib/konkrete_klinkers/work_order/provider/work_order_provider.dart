import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/client_model.dart'
    hide CreatedBy, Username;
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_detail_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/repo/work_order.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';

class WorkOrderProvider with ChangeNotifier {
  final WorkOrderRepository _repository = WorkOrderRepository();

  final List<Datum> _workOrders = [];
  WODData? _workOrderDetails;
  List<TId> _projects = [];
  bool _isLoading = false;
  bool _isProjectsLoading = false;
  String? _error;
  bool _isAddWorkOrderLoading = false;
  bool _isUpdateWorkOrderLoading = false;
  bool _isDeleteWorkOrderLoading = false;
  String _searchQuery = '';
  bool _hasMoreData = true;
  int _skip = 0;
  final int _limit = 10;

  WODData? _workOrderById;
  bool _isWorkOrderByIdLoading = false;
  String? _workOrderByIdError;
  WODData? get workOrderDetails => _workOrderDetails;

  List<Map<String, dynamic>> _products = [
    {
      'formKey': GlobalKey<FormBuilderState>(),
      'qtyController': TextEditingController(text: '0'),
      'qtyNotifier': ValueNotifier<int>(0),
      'plant_code': '',
    },
  ];
  bool _isBufferStockEnabled = false;
  List<FileElement> _uploadedFiles = [];
  String? _uploadError;

  List<ClientModel> _clients = [];
  bool _isClientsLoading = false;
  bool _hasMoreClients = true;
  int _clientSkip = 0;
  final int _clientLimit = 10;

  List<ProductModel> _allProducts = [];
  bool _isProductsLoading = false;
  bool _hasMoreProducts = true;
  int _productSkip = 0;
  final int _productLimit = 10;

  Map<String, double> calculatedQuantities = {};

  final GlobalKey<FormBuilderState> _editFormKey =
      GlobalKey<FormBuilderState>();
  bool _isEditScreenLoading = true;
  String? _editScreenError;

  // Getters
  WODData? get workOrderById => _workOrderById;
  bool get isWorkOrderByIdLoading => _isWorkOrderByIdLoading;
  String? get workOrderByIdError => _workOrderByIdError;
  List<Datum> get workOrders => _workOrders;
  List<TId> get projects => _projects;
  bool get isLoading => _isLoading;
  bool get isProjectsLoading => _isProjectsLoading;
  String? get error => _error;
  bool get isAddWorkOrderLoading => _isAddWorkOrderLoading;
  bool get isUpdateWorkOrderLoading => _isUpdateWorkOrderLoading;
  bool get isDeleteWorkOrderLoading => _isDeleteWorkOrderLoading;
  String get searchQuery => _searchQuery;
  bool get hasMoreData => _hasMoreData;
  List<ClientModel> get clients => _clients;
  bool get isClientsLoading => _isClientsLoading;
  List<ProductModel> get allProducts => _allProducts;
  bool get isProductLoading => _isProductsLoading;
  List<Map<String, dynamic>> get products => _products;
  bool get isBufferStockEnabled => _isBufferStockEnabled;
  List<FileElement> get uploadedFiles => _uploadedFiles;
  String? get uploadError => _uploadError;
  GlobalKey<FormBuilderState> get editFormKey => _editFormKey;
  bool get isEditScreenLoading => _isEditScreenLoading;
  String? get editScreenError => _editScreenError;

  String getClientName(String? clientId) {
    if (clientId == null || clientId.isEmpty) return 'Unknown Client';
    final workOrder = _workOrders.firstWhere(
      (wo) => wo.clientId == clientId,
      orElse: () => Datum(
        id: '',
        clientId: '',
        clientName: 'Unknown Client',
        projectId: '',
        projectName: 'Unknown Project',
        workOrderNumber: '',
        date: null,
        bufferStock: false,
        products: [],
        files: [],
        status: Status.PENDING,
        createdBy: CreatedBy(
          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
          username: Username.ADMIN,
        ),
        updatedBy: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        bufferTransferLogs: [],
        jobOrders: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
      ),
    );
    return workOrder.clientName ?? 'Unknown Client';
  }

  String getProjectName(String? projectId) {
    if (projectId == null || projectId.isEmpty) return 'Unknown Project';
    final workOrder = _workOrders.firstWhere(
      (wo) => wo.projectId == projectId,
      orElse: () => Datum(
        id: '',
        clientId: '',
        clientName: 'Unknown Client',
        projectId: '',
        projectName: 'Unknown Project',
        workOrderNumber: '',
        date: null,
        bufferStock: false,
        products: [],
        files: [],
        status: Status.PENDING,
        createdBy: CreatedBy(
          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
          username: Username.ADMIN,
        ),
        updatedBy: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        bufferTransferLogs: [],
        jobOrders: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
      ),
    );
    return workOrder.projectName ?? 'Unknown Project';
  }

  final Map<int, List<String>> _uomListPerIndex = {};
  Map<int, List<String>> get uomListPerIndex => _uomListPerIndex;

  void updateUOMListForIndex({
    required int index,
    required ProductModel product,
    String? prefilledUom,
  }) {
    if (index < 0 || index >= products.length) return;
    _uomListPerIndex[index] = product.uom.isNotEmpty ? product.uom : ['Nos'];
    if (prefilledUom != null &&
        _uomListPerIndex[index]!.contains(prefilledUom)) {
      products[index]['uom'] = prefilledUom;
    } else {
      products[index]['uom'] = _uomListPerIndex[index]!.isNotEmpty
          ? _uomListPerIndex[index]!.first
          : null;
    }
    notifyListeners();
  }

  bool validateUploads() {
    if (_uploadedFiles.isEmpty) {
      _uploadError = "At least one file is required";
      notifyListeners();
      return false;
    }
    _uploadError = null;
    notifyListeners();
    return true;
  }

  void setWorkOrders(List<Datum> newWorkOrders) {
    _workOrders.clear();
    _workOrders.addAll(newWorkOrders);
    if (kDebugMode) {
      print(
        '📦 [WorkOrderProvider] Updated workOrders: ${_workOrders.length} items',
      );
    }
    notifyListeners();
  }

  void addProduct() {
    _products.add({
      // 'formKey': GlobalKey<FormBuilderState>(),
      'product_id': {'id': '', 'name': ''},
      'uom': 'nos',
      'po_quantity': '',
      'qty_in_nos': '0',
      'qtyController': TextEditingController(text: '0'),
      'qtyNotifier': ValueNotifier<int>(0),
      'delivery_date': null,
      'plant_code': '',
    });
    notifyListeners();
  }

  void removeProductAt(int index) {
    if (index >= 0 && index < _products.length) {
      _products[index]['qtyController']?.dispose();
      _products[index]['qtyNotifier']?.dispose();
      _products.removeAt(index);
      notifyListeners();
    }
  }

  void setBufferStockEnabled(bool value) {
    _isBufferStockEnabled = value;
    if (value) {
      _editFormKey.currentState?.fields['client_id']?.didChange(null);
      _editFormKey.currentState?.fields['project_id']?.didChange(null);
      _editFormKey.currentState?.fields['work_order_date']?.didChange(null);
    }
    notifyListeners();
  }

  void addUploadedFiles(List<FileElement> files) {
    _uploadedFiles.addAll(files);
    _uploadError = null;
    notifyListeners();
  }

  void removeUploadedFile(FileElement file) {
    _uploadedFiles.remove(file);
    notifyListeners();
  }

  void setUploadedFiles(List<WODFileElement>? files) {
    _uploadedFiles = files != null ? List.from(files) : [];
    notifyListeners();
  }

  void setProducts(Iterable<Map<String, dynamic>>? newProducts) {
    for (var product in _products) {
      product['qtyController']?.dispose();
      product['qtyNotifier']?.dispose();
    }
    _products = newProducts != null && newProducts.isNotEmpty
        ? newProducts.map((product) {
            final qtyInNos = product['qty_in_nos']?.toString() ?? '0';
            final productId = product['product_id']?['id']?.toString() ?? '';
            final plantCode =
                product['plant_code']?.toString() ??
                (_allProducts
                    .firstWhere(
                      (p) => p.id == productId,
                      orElse: () => ProductModel(
                        id: '',
                        materialCode: '',
                        description: '',
                        plant: PlantModel(
                          id: '',
                          plantCode: '',
                          plantName: '',
                          createdBy: CreatedBy(
                            id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
                            username: Username.ADMIN,
                          ),
                          isDeleted: false,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          version: 0,
                        ),
                        uom: [],
                        areas: {},
                        noOfPiecesPerPunch: 0,
                        qtyInBundle: 0,
                        createdBy: CreatedBy(
                          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
                          username: Username.ADMIN,
                        ),
                        status: '',
                        isDeleted: false,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        version: 0,
                      ),
                    )
                    .plant
                    .plantCode);
            return {
              'formKey': product['formKey'] ?? GlobalKey<FormBuilderState>(),
              'product_id': product['product_id'] ?? {'id': '', 'name': ''},
              'uom': product['uom']?.toString() ?? 'nos',
              'po_quantity': product['po_quantity']?.toString() ?? '',
              'qty_in_nos': qtyInNos,
              'qtyController': TextEditingController(text: qtyInNos),
              'qtyNotifier': ValueNotifier<int>(int.tryParse(qtyInNos) ?? 0),
              'delivery_date': product['delivery_date'] as DateTime?,
              'plant_code': plantCode,
            };
          }).toList()
        : [
            {
              'formKey': GlobalKey<FormBuilderState>(),
              'product_id': {'id': '', 'name': ''},
              'uom': 'nos',
              'po_quantity': '',
              'qty_in_nos': '0',
              'qtyController': TextEditingController(text: '0'),
              'qtyNotifier': ValueNotifier<int>(0),
              'delivery_date': null,
              'plant_code': '',
            },
          ];
    notifyListeners();
  }

  Future<void> loadAllProducts({
    bool refresh = false,
    String? searchQuery,
  }) async {
    if (refresh) {
      _allProducts.clear();
      _productSkip = 0;
      _hasMoreProducts = true;
    }
    if (!_hasMoreProducts || _isProductsLoading) return;
    _isProductsLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _repository.getAllProducts(
        search: searchQuery?.isNotEmpty == true ? searchQuery : null,
        skip: _productSkip,
        limit: _productLimit,
      );
      if (response.isEmpty) {
        _hasMoreProducts = false;
      } else {
        _allProducts.addAll(response as Iterable<ProductModel>);
        _productSkip += response.length;
        _hasMoreProducts = response.length == _productLimit;
      }
      if (kDebugMode) {
        print('✅ [WorkOrderProvider] Loaded ${_allProducts.length} products');
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _allProducts.clear();
      if (kDebugMode) {
        print('❌ [WorkOrderProvider] Error loading products: $_error');
      }
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllClients({
    bool refresh = false,
    String? searchQuery,
  }) async {
    if (refresh) {
      _clients.clear();
      _clientSkip = 0;
      _hasMoreClients = true;
    }
    if (!_hasMoreClients || _isClientsLoading) return;
    _isClientsLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _repository.getAllClients(
        search: searchQuery?.isNotEmpty == true ? searchQuery : null,
        skip: _clientSkip,
        limit: _clientLimit,
      );
      if (response.isEmpty) {
        _hasMoreClients = false;
      } else {
        _clients.addAll(response);
        _clientSkip += response.length;
        _hasMoreClients = response.length == _clientLimit;
      }
      if (kDebugMode) {
        print('✅ [WorkOrderProvider] Loaded ${_clients.length} clients');
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _clients.clear();
      if (kDebugMode) {
        print('❌ [WorkOrderProvider] Error loading clients: $_error');
      }
    } finally {
      _isClientsLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. The server is taking too long to respond.';
    } else if (error is FormatException) {
      return 'Invalid data format received from server. Please contact support.';
    } else if (error.toString().contains('Work order not found')) {
      return 'The requested work order was not found. It may have been deleted.';
    }
    return 'An unexpected error occurred';
  }

  Future<void> loadAllWorkOrders({bool refresh = false}) async {
    if (refresh) {
      _workOrders.clear();
      _skip = 0;
      _hasMoreData = true;
    }
    if (!_hasMoreData || _isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (kDebugMode) {
        print(
          'Loading Work Orders - Skip: $_skip, Limit: $_limit, Search: $_searchQuery',
        );
      }
      final response = await _repository.getAllWorkOrders(
        skip: _skip,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      if (response.isEmpty) {
        _hasMoreData = false;
      } else {
        _workOrders.addAll(response);
        _skip += response.length;
        _hasMoreData = response.length == _limit;
        _workOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      _error = null;
      if (kDebugMode) {
        print('✅ [WorkOrderProvider] Loaded ${_workOrders.length} work orders');
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      if (kDebugMode) {
        print('❌ [WorkOrderProvider] Error loading work orders: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchWorkOrders(String query) async {
    _searchQuery = query;
    _workOrders.clear();
    _skip = 0;
    _hasMoreData = true;
    await loadAllWorkOrders();
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _workOrders.clear();
    _skip = 0;
    _hasMoreData = true;
    await loadAllWorkOrders();
  }

  Future<bool> createWorkOrder({
    required String workOrderNumber,
    String? clientId,
    String? projectId,
    DateTime? date,
    required bool bufferStock,
    required List<Product> products,
    required List<FileElement> files,
    required Status status,
  }) async {
    _isAddWorkOrderLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newWorkOrder = await _repository.createWorkOrder(
        workOrderNumber: workOrderNumber,
        clientId: clientId,
        projectId: projectId,
        date: date,
        bufferStock: bufferStock,
        products: products,
        files: files,
        status: status,
      );
      if (kDebugMode) {
        print('✅ [WorkOrderProvider] Created work order: ${newWorkOrder.id}');
      }
      _resetFormState();
      _workOrders.insert(0, newWorkOrder);
      _workOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _error = _getErrorMessage(e);
      if (kDebugMode) {
        print('❌ [WorkOrderProvider] Error creating work order: $_error');
        print(stackTrace);
      }
      return false;
    } finally {
      _isAddWorkOrderLoading = false;
      notifyListeners();
    }
  }

  void _resetFormState() {
    for (var product in _products) {
      product['qtyController']?.dispose();
      product['qtyNotifier']?.dispose();
    }
    _products = [
      {
        'formKey': GlobalKey<FormBuilderState>(),
        'product_id': {'id': '', 'name': ''},
        'uom': 'nos',
        'po_quantity': '',
        'qty_in_nos': '0',
        'qtyController': TextEditingController(text: '0'),
        'qtyNotifier': ValueNotifier<int>(0),
        'delivery_date': null,
        'plant_code': '',
      },
    ];
    _uploadedFiles.clear();
    _isBufferStockEnabled = false;
    calculatedQuantities.clear();
  }

  Future<bool> updateWorkOrder({
    required String id,
    required String workOrderNumber,
    String? clientId,
    String? projectId,
    DateTime? date,
    required bool bufferStock,
    int? bufferStockQuantity,
    required List<Product> products,
    required List<FileElement> files,
    required Status status,
  }) async {
    _isUpdateWorkOrderLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (kDebugMode) {
        print('🔄 [WorkOrderProvider] Updating work order $id');
      }
      final success = await _repository.updateWorkOrder(
        id: id,
        workOrderNumber: workOrderNumber,
        clientId: clientId,
        projectId: projectId,
        date: date,
        bufferStock: bufferStock,
        bufferStockQuantity: bufferStock ? bufferStockQuantity : null,
        products: products,
        files: files,
        status: status,
      );
      if (!success) {
        throw Exception('Server returned false for update operation');
      }
      await _refreshWorkOrdersList();
      _resetFormState();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdateWorkOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshWorkOrdersList() async {
    _workOrders.clear();
    _skip = 0;
    _hasMoreData = true;
    await loadAllWorkOrders();
  }

  Future<bool> deleteWorkOrder(String id) async {
    _isDeleteWorkOrderLoading = true;
    _error = null;
    notifyListeners();
    try {
      final success = await _repository.deleteWorkOrder(id);
      if (success) {
        await _refreshWorkOrdersList();
        return true;
      } else {
        _error = 'Failed to delete work order: Server returned false';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeleteWorkOrderLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjectsByClient(String clientId) async {
    _isProjectsLoading = true;
    _error = null;
    notifyListeners();
    try {
      final projects = await _repository.getProjectsByClient(clientId);
      _projects = projects;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      _projects = [];
    } finally {
      _isProjectsLoading = false;
      notifyListeners();
    }
  }

  Future<Datum?> getWorkOrder(String id) async {
    try {
      _error = null;
      final workOrder = await _repository.getWorkOrder(id);
      if (workOrder != null) {
        await loadAllClients();
        if (workOrder.clientId != null && workOrder.clientId!.isNotEmpty) {
          await loadProjectsByClient(workOrder.clientId!);
        }
      }
      return workOrder;
    } catch (e) {
      _error = _getErrorMessage(e);
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<WODData?> getWorkOrderById(String id) async {
    _isWorkOrderByIdLoading = true;
    _workOrderByIdError = null;
    notifyListeners();
    try {
      _error = null;
      final workOrder = await _repository.getWorkOrderById(id);
      if (workOrder != null) {
        await loadAllClients();
        if (workOrder.clientId.id.isNotEmpty) {
          await loadProjectsByClient(workOrder.clientId.id);
        }
        _workOrderById = workOrder;
        _isWorkOrderByIdLoading = false;
        notifyListeners();
      } else {
        _isWorkOrderByIdLoading = false;
        _workOrderByIdError = 'Work order not found';
        notifyListeners();
      }
      return workOrder;
    } catch (e) {
      _isWorkOrderByIdLoading = false;
      _workOrderByIdError = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  void updateQuantity({
    required int index,
    required ProductModel product,
    required GlobalKey<FormBuilderState> formKey,
    String? poQuantity,
  }) {
    if (index < 0 || index >= products.length) return;
    if (formKey.currentState == null) return;
    final formData = formKey.currentState?.value;
    final poQty = poQuantity != null
        ? double.tryParse(poQuantity) ?? 0.0
        : double.tryParse(formData?['po_quantity_$index']?.toString() ?? '0') ??
              0.0;
    final uom = formData?['uom_$index'] as String? ?? 'Nos';
    updateUOMListForIndex(index: index, product: product);
    double? area;
    if (uom.contains("Square Meter")) {
      area = calculateDimension(product.description, isArea: true);
    } else if (uom.contains("Meter")) {
      area = calculateDimension(product.description, isArea: false);
    } else if (uom.contains("No")) {
      area = 1.0;
    } else {
      area = product.areas[uom] ?? 1.0;
    }
    final calculatedQty = (poQty / (area ?? 1.0)).ceil();
    products[index]['po_quantity'] = poQty.toString();
    products[index]['qty_in_nos'] = calculatedQty.toString();
    products[index]['qtyController'].text = calculatedQty.toString();
    products[index]['qtyNotifier'].value = calculatedQty;
    formKey.currentState?.fields['qty_in_nos_$index']?.didChange(
      calculatedQty.toString(),
    );
    formKey.currentState?.fields['plant_code_$index']?.didChange(
      product.plant.plantCode,
    );
    notifyListeners();
  }

  void calculateProductQuantity({
    required ProductModel product,
    required int poQuantity,
    required String selectedUom,
  }) {
    double? area;
    if (selectedUom.contains("Square Meter")) {
      area = calculateDimension(product.description, isArea: true);
      calculatedQuantities['${product.id}-$selectedUom'] =
          poQuantity * (area ?? 1.0);
    } else if (selectedUom.contains("Meter")) {
      area = calculateDimension(product.description, isArea: false);
      calculatedQuantities['${product.id}-$selectedUom'] =
          (area == null || area == 0) ? 0.0 : poQuantity / area;
    } else if (selectedUom.contains("No")) {
      area = 1.0;
      calculatedQuantities['${product.id}-$selectedUom'] =
          poQuantity * (area ?? 1.0);
    } else {
      area = product.areas[selectedUom] ?? 1.0;
      calculatedQuantities['${product.id}-$selectedUom'] =
          poQuantity * (area ?? 1.0);
    }
    notifyListeners();
  }

  double? calculateDimension(String? description, {bool isArea = true}) {
    if (description == null || description.isEmpty) {
      debugPrint("❌ Description is null/empty");
      return null;
    }
    try {
      final RegExp dimensionRegex = RegExp(
        r'(\d+)[Xx*](\d+)[Xx*](\d+)MM',
        caseSensitive: false,
      );
      final match = dimensionRegex.firstMatch(description);
      if (match != null) {
        final length = double.parse(match.group(1)!);
        final width = double.parse(match.group(2)!);
        debugPrint(
          "📐 Parsed dimensions → length: $length mm, width: $width mm",
        );
        if (isArea) {
          final area = (length / 1000) * (width / 1000);
          debugPrint("✅ Calculated area: $area m²");
          return area;
        } else {
          final len = length / 1000;
          debugPrint("✅ Calculated length: $len m");
          return len;
        }
      } else {
        debugPrint("❌ Regex did not match description: $description");
      }
      return null;
    } catch (e) {
      debugPrint("⚠️ Error in calculateDimension: $e");
      return null;
    }
  }

  int getCalculatedQtyInNos({
    required GlobalKey<FormBuilderState> formKey,
    required int index,
  }) {
    final Map<String, dynamic>? formData = formKey.currentState?.value;
    if (formData == null) return 0;
    final String? productId = formData['product_id_$index']?['id'] as String?;
    final String? uom = formData['uom_$index'] as String?;
    final double poQuantity =
        double.tryParse(formData['po_quantity_$index']?.toString() ?? '0') ??
        0.0;
    if (productId == null || uom == null) return 0;
    final ProductModel product = _allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductModel(
        id: '',
        materialCode: '',
        description: '',
        plant: PlantModel(
          id: '',
          plantCode: '',
          plantName: '',
          createdBy: CreatedBy(
            id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
            username: Username.ADMIN,
          ),
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          version: 0,
        ),
        uom: [],
        areas: {},
        noOfPiecesPerPunch: 0,
        qtyInBundle: 0,
        createdBy: CreatedBy(
          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
          username: Username.ADMIN,
        ),
        status: '',
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 0,
      ),
    );
    if (product.id.isEmpty) return 0;
    double? area;
    if (uom.contains("Square Meter")) {
      area = calculateDimension(product.description);
      return (poQuantity * (area ?? 1.0)).ceil();
    } else if (uom.contains("Meter")) {
      area = calculateDimension(product.description);
      return (area == null || area == 0) ? 0 : (poQuantity / area).ceil();
    } else if (uom.contains("No")) {
      return poQuantity.ceil();
    } else {
      area = product.areas[uom] ?? 1.0;
      return (poQuantity * (area ?? 1.0)).ceil();
    }
  }

  Datum? getWorkOrderByIndex(int index) {
    if (index >= 0 && index < _workOrders.length) {
      return _workOrders[index];
    }
    return null;
  }

  // Edit Screen Specific Methods
  Future<void> initializeEditScreen(String workOrderId) async {
    _isEditScreenLoading = true;
    _editScreenError = null;
    notifyListeners();
    try {
      await Future.wait([
        loadAllClients(refresh: true),
        loadAllProducts(refresh: true),
      ]);
      await _fetchWorkOrderData(workOrderId);
      await _waitForFormInitialization();
      _preFillMainForm();
      _isEditScreenLoading = false;
      notifyListeners();
    } catch (e) {
      _editScreenError = _getErrorMessage(e);
      _isEditScreenLoading = false;
      notifyListeners();
    }
  }

  Future<void> _waitForFormInitialization() async {
    int retries = 5;
    const delay = Duration(milliseconds: 100);
    while (retries > 0) {
      if (_editFormKey.currentState != null &&
          _products.every(
            (p) =>
                (p['formKey'] as GlobalKey<FormBuilderState>).currentState !=
                null,
          )) {
        if (kDebugMode) {
          print('📝 [WorkOrderProvider] Form and product forms initialized');
        }
        return;
      }
      if (kDebugMode) {
        print(
          '📝 [WorkOrderProvider] Waiting for form initialization, retries left: $retries',
        );
      }
      await Future.delayed(delay);
      retries--;
    }
  }

  // Utility function to map backend uom String to UI-friendly String
  String mapStringToUom(String uomString) {
    const uomValues = {
      'nos': 'Nos',
      'sqmt': 'Square Meter/Nos',
      'meter': 'Meter/Nos',
      // Add other mappings as needed
    };

    final result = uomValues[uomString.toLowerCase()];
    if (result == null) {
      debugPrint('Warning: Unknown UOM: $uomString');
    }
    return result ?? 'Square Meter'; // Fallback to 'Square Meter'
  }

  List<String> parseProductUom(List<String> uomList) {
    final result = <String>{};
    for (final uom in uomList) {
      // Split combined UOMs like "Square Meter/No"
      final splitUoms = uom.split('/');
      for (final splitUom in splitUoms) {
        final trimmedUom = splitUom.trim();
        if (trimmedUom.isNotEmpty) {
          result.add(trimmedUom);
        }
      }
    }
    return result.isNotEmpty
        ? result.toList()
        : ['Square Meter', 'Nos', 'Meter'];
  }

  // Utility function to map updatedBy ID String to UpdatedBy enum
  UpdatedBy mapStringToUpdatedBy(String? updatedById) {
    if (updatedById == null || updatedById.isEmpty) {
      return UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E; // Fallback
    }
    try {
      return UpdatedBy.values.firstWhere(
        (e) => e.toString().split('.').last == updatedById,
        orElse: () => UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
      );
    } catch (e) {
      debugPrint('Warning: Unknown UpdatedBy ID: $updatedById');
      return UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E;
    }
  }

  Future<void> _fetchWorkOrderData(String workOrderId) async {
    try {
      final workOrderDetails = await getWorkOrderById(
        workOrderId,
      ); // Returns WODWorkOrderDetails
      if (workOrderDetails == null) {
        throw Exception('Work order not found or access denied');
      }
      workOrderDetails.clear();
      workOrderDetails.add(workOrderDetails);
      setBufferStockEnabled(workOrderDetails.bufferStock);
      setUploadedFiles(List.from(workOrderDetails.files));
      final products = workOrderDetails.products.asMap().entries.map((entry) {
        final index = entry.key;
        final product = entry.value;
        final productId = product.product.id;
        final productModel = _allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => ProductModel(
            id: '',
            materialCode: '',
            description: 'Unknown Product',
            plant: PlantModel(
              id: '',
              plantCode: '',
              plantName: '',
              createdBy: CreatedBy(
                id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
                username: Username.ADMIN,
              ),
              isDeleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              version: 0,
            ),
            uom: ['Square Meter', 'Nos', 'Meter'],
            areas: {},
            noOfPiecesPerPunch: 0,
            qtyInBundle: 0,
            createdBy: CreatedBy(
              id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
              username: Username.ADMIN,
            ),
            status: '',
            isDeleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 0,
          ),
        );
        final uom = mapStringToUom(product.uom); // e.g., "Square Meter"
        // Update uomListPerIndex with parsed product.uom
        updateUOMListForIndex(
          index: index,
          product: productModel,
          prefilledUom: uom,
        );
        return {
          'formKey': GlobalKey<FormBuilderState>(),
          'product_id': {
            'id': productId,
            'name': productModel.id.isNotEmpty
                ? '${productModel.materialCode} - ${productModel.description}'
                : 'Unknown Product',
          },
          'uom': uom,
          'po_quantity': product.poQuantity.toString(),
          'qty_in_nos': product.qtyInNos.toString(),
          'qtyController': TextEditingController(
            text: product.qtyInNos.toString(),
          ),
          'qtyNotifier': ValueNotifier<int>(product.qtyInNos),
          'delivery_date': product.deliveryDate,
          'plant_code': product.plant.plantCode,
        };
      }).toList();
      setProducts(products);
      if (!workOrderDetails.bufferStock) {
        final clientId = workOrderDetails.clientId.id;
        if (clientId.isNotEmpty) {
          await loadProjectsByClient(clientId);
        }
      }
      _workOrderById = workOrderDetails;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error fetching work order: $e\n$stackTrace');
      throw Exception('Failed to load work order details. Please try again.');
    }
  }

  void _preFillMainForm() {
    final workOrder = _workOrders.firstWhere(
      (wo) => wo.id == _workOrderById?.id,
      orElse: () => Datum(
        id: '',
        workOrderNumber: '',
        products: [],
        status: Status.PENDING,
        clientId: null,
        projectId: null,
        date: null,
        bufferStock: false,
        files: [],
        createdBy: CreatedBy(
          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
          username: Username.ADMIN,
        ),
        updatedBy: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        bufferTransferLogs: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
        jobOrders: [],
      ),
    );
    if (workOrder.id.isEmpty) {
      _editScreenError = 'Failed to load work order data';
      notifyListeners();
      return;
    }
    void tryPreFill() {
      if (_editFormKey.currentState == null) {
        if (kDebugMode) {
          print(
            '📝 [WorkOrderProvider] Warning: Main form not ready for pre-filling',
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => tryPreFill());
        return;
      }
      _safeFormFieldUpdate('work_order_number', workOrder.workOrderNumber);
      if (kDebugMode) {
        print(
          '📝 [WorkOrderProvider] Pre-filled work_order_number: ${workOrder.workOrderNumber}',
        );
      }
      if (!(workOrder.bufferStock)) {
        if (workOrder.clientId != null && workOrder.clientId!.isNotEmpty) {
          final client = _clients.firstWhere((c) => c.id == workOrder.clientId);
          _safeFormFieldUpdate('client_id', client);
          if (kDebugMode) {
            print('📝 [WorkOrderProvider] Pre-filled client_id: ${client.id}');
          }
        } else {
          if (kDebugMode) {
            print(
              '📝 [WorkOrderProvider] Warning: Client ID is null or empty for work order ${workOrder.id}',
            );
          }
          _safeFormFieldUpdate('client_id', null);
        }
        if (workOrder.projectId != null && workOrder.projectId!.isNotEmpty) {
          final project = _projects.firstWhere(
            (p) => p.id == workOrder.projectId,
            orElse: () => TId(
              id: workOrder.projectId!,
              name: getProjectName(workOrder.projectId),
            ),
          );
          _safeFormFieldUpdate('project_id', project);
        } else {
          _safeFormFieldUpdate('project_id', null);
        }
        if (workOrder.date != null) {
          _safeFormFieldUpdate('work_order_date', workOrder.date);
          if (kDebugMode) {
            print(
              '📝 [WorkOrderProvider] Pre-filled work_order_date: ${workOrder.date}',
            );
          }
        }
      }
      for (var index = 0; index < _products.length; index++) {
        final product = _products[index];
        final formKey = product['formKey'] as GlobalKey<FormBuilderState>;
        if (product['product_id'] == null ||
            product['product_id']['id'] == null) {
          if (kDebugMode) {
            print(
              '📝 [WorkOrderProvider] Warning: product_id is null for product at index $index',
            );
          }
          product['product_id'] = {'id': '', 'name': 'Unknown Product'};
        }
        void preFillProductForm() {
          if (formKey.currentState != null) {
            formKey.currentState?.fields['product_id_$index']?.didChange(
              product['product_id'],
            );
            formKey.currentState?.fields['uom_$index']?.didChange(
              product['uom'],
            );
            formKey.currentState?.fields['po_quantity_$index']?.didChange(
              product['po_quantity'],
            );
            formKey.currentState?.fields['qty_in_nos_$index']?.didChange(
              product['qty_in_nos'],
            );
            formKey.currentState?.fields['delivery_date_$index']?.didChange(
              product['delivery_date'],
            );
            formKey.currentState?.fields['plant_code_$index']?.didChange(
              product['plant_code'],
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => preFillProductForm(),
            );
          }
        }

        preFillProductForm();
      }
    }

    tryPreFill();
  }

  void _safeFormFieldUpdate(String fieldName, dynamic value) {
    if (_editFormKey.currentState?.fields[fieldName] != null) {
      _editFormKey.currentState?.fields[fieldName]?.didChange(value);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_editFormKey.currentState?.fields[fieldName] != null) {
          _editFormKey.currentState?.fields[fieldName]?.didChange(value);
        }
      });
    }
  }

  Future<void> pickFiles(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null) {
        addUploadedFiles(
          result.files
              .map(
                (file) => FileElement(
                  fileName: file.name,
                  fileUrl: file.path ?? '',
                  id: '',
                  uploadedAt: DateTime.now(),
                ),
              )
              .where((file) => file.fileUrl.isNotEmpty)
              .toList(),
        );
        if (kDebugMode) {
          print(
            '📝 [WorkOrderProvider] Added files: ${result.files.map((f) => f.name).toList()}',
          );
        }
      }
    } catch (e) {
      _editScreenError = 'Failed to pick files. Please try again. Error: $e';
      notifyListeners();
      if (kDebugMode) {
        print('📝 [WorkOrderProvider] File picker error: $e');
      }
    }
  }

  Future<void> submitEditForm(BuildContext context, String workOrderId) async {
    if (!_editFormKey.currentState!.saveAndValidate()) {
      _editScreenError = 'Please fill all required fields correctly.';
      notifyListeners();
      return;
    }
    bool allFormsValid = true;
    List<Product> validatedProducts = [];
    for (var index = 0; index < _products.length; index++) {
      final product = _products[index];
      final formKey = product['formKey'] as GlobalKey<FormBuilderState>;
      if (formKey.currentState?.saveAndValidate() ?? false) {
        final formData = formKey.currentState!.value;
        final String? productId =
            formData['product_id_$index']?['id'] as String?;
        if (productId == null || productId.isEmpty) {
          _editScreenError =
              'Please select a product for Product ${index + 1}.';
          allFormsValid = false;
          notifyListeners();
          continue;
        }
        final selectedProduct = _allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => ProductModel(
            id: '',
            materialCode: '',
            description: 'Unknown Product',
            plant: PlantModel(
              id: '',
              plantCode: '',
              plantName: '',
              createdBy: CreatedBy(
                id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
                username: Username.ADMIN,
              ),
              isDeleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              version: 0,
            ),
            uom: [],
            areas: {},
            noOfPiecesPerPunch: 0,
            qtyInBundle: 0,
            createdBy: CreatedBy(
              id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
              username: Username.ADMIN,
            ),
            status: '',
            isDeleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 0,
          ),
        );
        final String? selectedUom = formData['uom_$index'] as String?;
        final double poQuantityDouble =
            double.tryParse(formData['po_quantity_$index'].toString()) ?? 0.0;
        final DateTime? deliveryDate =
            formData['delivery_date_$index'] as DateTime?;
        if (selectedUom == null || deliveryDate == null) {
          _editScreenError =
              'Please fill in all required fields for Product ${index + 1}.';
          allFormsValid = false;
          notifyListeners();
          continue;
        }
        final qtyInNosInt = getCalculatedQtyInNos(
          formKey: formKey,
          index: index,
        );
        validatedProducts.add(
          Product(
            id: product['id'] ?? '',
            productId: selectedProduct.id,
            uom: uomValues.map[selectedUom] ?? Uom.nos,
            poQuantity: poQuantityDouble.toInt(),
            qtyInNos: qtyInNosInt,
            deliveryDate: deliveryDate,
          ),
        );
      } else {
        allFormsValid = false;
        _editScreenError =
            'Please fill all required fields for Product ${index + 1}.';
        notifyListeners();
      }
    }
    if (!allFormsValid || validatedProducts.isEmpty) {
      _editScreenError =
          'Please fill in all required product fields correctly.';
      notifyListeners();
      return;
    }
    final formData = _editFormKey.currentState!.value;
    final selectedClient = formData['client_id'] != null
        ? _clients.firstWhere(
            (client) => client.id == (formData['client_id'] as ClientModel).id,
          )
        : null;
    final selectedProject = formData['project_id'] != null
        ? _projects.firstWhere(
            (project) => project.id == (formData['project_id'] as TId).id,
          )
        : null;
    if (!_isBufferStockEnabled &&
        (selectedClient == null || selectedProject == null)) {
      _editScreenError = 'Please select a valid client and project.';
      notifyListeners();
      return;
    }
    final filesForBackend = _uploadedFiles.map((file) {
      return FileElement(
        fileName: file.fileName,
        fileUrl: file.fileUrl,
        id: file.id,
        uploadedAt: file.uploadedAt,
      );
    }).toList();
    _isUpdateWorkOrderLoading = true;
    notifyListeners();
    try {
      final success = await updateWorkOrder(
        id: workOrderId,
        workOrderNumber: formData['work_order_number'] as String,
        clientId: _isBufferStockEnabled ? null : selectedClient?.id,
        projectId: _isBufferStockEnabled ? null : selectedProject?.id,
        date: _isBufferStockEnabled
            ? null
            : (formData['work_order_date'] as DateTime?),
        bufferStock: _isBufferStockEnabled,
        products: validatedProducts,
        files: filesForBackend,
        status: Status.PENDING,
      );
      if (success) {
        await loadAllWorkOrders(refresh: true);
        context.go(RouteNames.workorders);
      } else {
        _editScreenError = 'Failed to update work order. Please try again.';
      }
    } catch (e) {
      _editScreenError = 'Error updating work order: ${e.toString()}';
    } finally {
      _isUpdateWorkOrderLoading = false;
      notifyListeners();
    }
  }
}
