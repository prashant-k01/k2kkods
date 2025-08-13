import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/client_model.dart'
    hide CreatedBy, Username;
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_detail_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/repo/work_order.dart';

class WorkOrderProvider with ChangeNotifier {
  final WorkOrderRepository _repository = WorkOrderRepository();

  final List<Datum> _workOrders = [];
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

  // Getters
  WODData? get workOrderById => _workOrderById;
  bool get isWorkOrderByIdLoading => _isWorkOrderByIdLoading;
  String? get workOrderByIdError => _workOrderByIdError;

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
  bool _isScreenUtilInitialized = false;

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

  // Getters
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
  bool get isScreenUtilInitialized => _isScreenUtilInitialized;

  // New getter to find client name by ID
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

  Map<int, List<String>> _uomListPerIndex = {};
  Map<int, List<String>> get uomListPerIndex => _uomListPerIndex;

  void updateUOMListForIndex({
    required int index,
    required ProductModel product,
    String? prefilledUom,
  }) {
    if (index < 0 || index >= products.length) {
      return;
    }
    _uomListPerIndex[index] = product.uom.isNotEmpty ? product.uom : ['Nos'];
    // Only set product['uom'] if prefilledUom is valid and exists in the product's uom list
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

  // Setters
  void setScreenUtilInitialized(bool value) {
    _isScreenUtilInitialized = value;
    notifyListeners();
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
      'formKey': GlobalKey<FormBuilderState>(),
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
    notifyListeners();
  }

  void addUploadedFiles(List<FileElement> files) {
    _uploadedFiles.addAll(files);
    notifyListeners();
  }

  void removeUploadedFile(FileElement file) {
    _uploadedFiles.remove(file);
    notifyListeners();
  }

  void setUploadedFiles(List<FileElement>? files) {
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
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
    }
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
        // Load clients and projects to ensure names are available
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
    notifyListeners(); // notify loading state

    try {
      _error = null;
      final workOrder = await _repository.getWorkOrderById(id);

      if (workOrder != null) {
        await loadAllClients();

        if (workOrder.clientId.id.isNotEmpty) {
          await loadProjectsByClient(workOrder.clientId.id);
        }

        // Set the fetched data to your provider's field
        _workOrderById =
            workOrder; // make sure this exists and holds the fetched work order

        _isWorkOrderByIdLoading = false;
        notifyListeners(); // notify UI after data is ready
      } else {
        // handle null workOrder case
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

  double? calculateArea(String? description) {
    if (description == null || description.isEmpty) return null;
    try {
      final RegExp dimensionRegex = RegExp(
        r'(\d+)X(\d+)X(\d+)MM',
        caseSensitive: false,
      );
      final match = dimensionRegex.firstMatch(description);
      if (match != null) {
        final length = double.parse(match.group(1)!);
        final width = double.parse(match.group(2)!);
        return (length / 1000) * (width / 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void updateQuantity({
    required int index,
    required ProductModel product,
    required GlobalKey<FormBuilderState> formKey,
    String? poQuantity, // Direct input from onChanged
  }) {
    if (index < 0 || index >= products.length) {
      return;
    }

    if (formKey.currentState == null) {
      return;
    }

    final formData = formKey.currentState?.value;
    final poQty = poQuantity != null
        ? double.tryParse(poQuantity) ?? 0.0
        : double.tryParse(formData?['po_quantity_$index']?.toString() ?? '0') ??
              0.0;
    final uom = formData?['uom_$index'] as String? ?? 'Nos';

    // Update UOM list for the selected product
    updateUOMListForIndex(index: index, product: product);

    // Calculate qty_in_nos based on UOM and product attributes
    double? area;
    if (uom.contains("Square Meter")) {
      area = calculateArea(product.description);
    } else {
      area = product.areas[uom] ?? 1.0;
    }
    final calculatedQty = (poQty * (area ?? 1.0)).ceil();

    // Update the product map
    products[index]['po_quantity'] = poQty.toString();
    products[index]['qty_in_nos'] = calculatedQty.toString();
    products[index]['qtyController'].text = calculatedQty.toString();
    products[index]['qtyNotifier'].value = calculatedQty;

    // Update form field to ensure UI reflects the change
    formKey.currentState?.fields['qty_in_nos_$index']?.didChange(
      calculatedQty.toString(),
    );

    // Update plant code
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
      area = calculateArea(product.description ?? '');
    } else {
      area = product.areas[selectedUom] ?? 1.0;
    }
    final double totalQuantity = poQuantity * (area ?? 1.0);
    calculatedQuantities['${product.id}-$selectedUom'] = totalQuantity;
    notifyListeners();
  }

  double getCalculatedQuantity({
    required ProductModel product,
    required GlobalKey<FormBuilderState> formKey,
    required int index,
  }) {
    final String? uom =
        formKey.currentState?.fields['uom_$index']?.value as String?;
    if (uom == null) {
      return 0.0;
    }
    return calculatedQuantities['${product.id}-$uom'] ?? 0.0;
  }

  int getCalculatedQtyInNos({
    required GlobalKey<FormBuilderState> formKey,
    required int index,
  }) {
    final Map<String, dynamic>? formData = formKey.currentState?.value;
    if (formData == null) {
      return 0;
    }

    final String? productId = formData['product_id_$index']?['id'] as String?;
    final String? uom = formData['uom_$index'] as String?;
    final double poQuantity =
        double.tryParse(formData['po_quantity_$index']?.toString() ?? '0') ??
        0.0;

    if (productId == null || uom == null) {
      if (kDebugMode) {
        print(
          '❌ [WorkOrderProvider] Missing productId or uom for product at index $index',
        );
      }
      return 0;
    }

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

    if (product.id.isEmpty) {
      if (kDebugMode) {
        print('❌ [WorkOrderProvider] Invalid product at index $index');
      }
      return 0;
    }

    double? area;
    if (uom.contains("Square Meter")) {
      area = calculateArea(product.description);
    } else {
      area = product.areas[uom] ?? 1.0;
    }
    return (poQuantity * (area ?? 1.0)).ceil();
  }

  Datum? getWorkOrderByIndex(int index) {
    if (index >= 0 && index < _workOrders.length) {
      return _workOrders[index];
    }
    return null;
  }
}
