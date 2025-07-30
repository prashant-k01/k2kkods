import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/konkrete_klinkers/job_order/repo/job_order_repo.dart';

class JobOrderProvider with ChangeNotifier {
  final JobOrderRepository _repository = JobOrderRepository();

  List<JobOrderModel> _jobOrders = [];
  bool _isLoading = false;
  String? _error;

  // Loading states for specific operations
  bool _isAddJobOrderLoading = false;
  bool _isUpdateJobOrderLoading = false;
  bool _isDeleteJobOrderLoading = false;

  bool _isInitialized = false;
  String? _errorMessage;
  JobOrderModel? _jobOrder;
  Map<String, dynamic> _initialValues = {};
  bool _showAreaPerUnit = true;

  List<String> _workOrderNumbers = [];
  List<String> get workOrderNumbers => _workOrderNumbers;

  bool _isLoadingWorkOrderNumbers = false;
  bool get isLoadingWorkOrderNumbers => _isLoadingWorkOrderNumbers;

  List<Map<String, dynamic>> _workOrderDetails = [];
  List<Map<String, dynamic>> get workOrderDetails => _workOrderDetails;

  // Products management
  final List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> get products => _products;

  String? _selectedWorkOrder;
  String? get selectedWorkOrder => _selectedWorkOrder;

  List<Map<String, dynamic>> _availableProducts = [];
  List<Map<String, dynamic>> get availableProducts => _availableProducts;

  bool _isLoadingProducts = false;
  bool get isLoadingProducts => _isLoadingProducts;


  void setSelectedWorkOrder(String? value) {
    print('🔄 setSelectedWorkOrder called with value: $value');

    if (_selectedWorkOrder != value) {
      _selectedWorkOrder = value;

      _availableProducts.clear();
      _products.clear();
      _error = null;

      print('🧹 Cleared previous state');

      if (value != null && value.isNotEmpty) {
        print('🔍 Looking for work order details for: $value');

        final selectedWO = _workOrderDetails.firstWhere(
          (e) => e['work_order_number']?.toString() == value,
        );

        print('📋 Found work order details: $selectedWO');

        final workOrderId =
            selectedWO['id']?.toString() ?? selectedWO['_id']?.toString();
        print('🆔 Extracted work order ID: $workOrderId');

        if (workOrderId != null && workOrderId.isNotEmpty) {
          print('🚀 Loading products for work order ID: $workOrderId');

          loadProductsByWorkOrder(workOrderId)
              .then((_) {
                print(
                  '✅ Products loaded, available products count: ${_availableProducts.length}',
                );
                if (_products.isEmpty) {
                  addProductSection();
                  print('➕ Added empty product section');
                }
              })
              .catchError((error) {
                print('❌ Error loading products: $error');
                if (_products.isEmpty) {
                  addProductSection();
                }
              });
        } else {
          print(
            '⚠️ No valid work order ID found, adding empty product section',
          );
          addProductSection();
        }
      } else {
        print('⚠️ No work order selected, adding empty product section');
        addProductSection();
      }

      notifyListeners();
      print('🔔 notifyListeners called');
    } else {
      print('🔄 Same work order selected, no change needed');
    }
  }

  void addProductSection() {
    _products.add({});
    print('➕ Product section added. Total sections: ${_products.length}');
    notifyListeners();
  }

  void removeProductSection(int index) {
    if (index >= 0 && index < _products.length) {
      _products.removeAt(index);
      print(
        '➖ Product section removed at index $index. Remaining: ${_products.length}',
      );
      notifyListeners();
    }
  }

  Future<void> loadWorkOrderDetails() async {
    print('🔄 Loading work order details...');
    _isLoadingWorkOrderNumbers = true;
    _error = null;
    notifyListeners();

    try {
      _workOrderDetails = await _repository.fetchWorkOrderDetailsRaw();
      print('📋 Loaded ${_workOrderDetails.length} work order details');

      _workOrderNumbers = _workOrderDetails
          .map((e) => e['work_order_number']?.toString())
          .where((v) => v != null && v.isNotEmpty)
          .cast<String>()
          .toList();

      print('📝 Extracted work order numbers: $_workOrderNumbers');
      _error = null;
    } catch (e) {
      print('❌ Error loading work order details: $e');
      _workOrderDetails = [];
      _workOrderNumbers = [];
      _error = _getErrorMessage(e);
    }

    _isLoadingWorkOrderNumbers = false;
    notifyListeners();
    print('✅ Work order details loading completed');
  }

  Future<void> loadProductsByWorkOrder(String workOrderId) async {
    print('🚀 loadProductsByWorkOrder called with ID: $workOrderId');

    _isLoadingProducts = true;
    _error = null;
    notifyListeners();
    print('🔄 Set loading state to true');

    try {
      print('📡 Calling repository to fetch products...');
      _availableProducts = await _repository.fetchProductsByWorkOrder(
        workOrderId,
      );
      print('✅ Repository returned ${_availableProducts.length} products');

      // Debug log each product
      for (int i = 0; i < _availableProducts.length; i++) {
        final product = _availableProducts[i];
        print(
          '🎯 Product $i: ${product['description']} - ${product['material_code']}',
        );
      }

      _error = null;
    } catch (e) {
      print('❌ Error in loadProductsByWorkOrder: $e');
      _availableProducts = [];
      _error = _getErrorMessage(e);
    }

    _isLoadingProducts = false;
    notifyListeners();
    print(
      '🏁 loadProductsByWorkOrder completed. Loading: false, Products: ${_availableProducts.length}',
    );
  }

  // Getters
  List<JobOrderModel> get jobOrders => _jobOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddJobOrderLoading => _isAddJobOrderLoading;
  bool get isUpdateJobOrderLoading => _isUpdateJobOrderLoading;
  bool get isDeleteJobOrderLoading => _isDeleteJobOrderLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  JobOrderModel? get jobOrder => _jobOrder;
  Map<String, dynamic> get initialValues => _initialValues;
  bool get showAreaPerUnit => _showAreaPerUnit;

  Future<void> loadAllJobOrders({bool refresh = false}) async {
    if (refresh) {
      _jobOrders.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAllJobOrder();
      if (refresh) {
        _jobOrders.clear();
      }
      _jobOrders = response.data;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      _jobOrders.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateJobOrder({
    required String jobOrderId,
    required String plantId,
    required String materialCode,
    required String description,
    required List<String> uom,
    required Map<String, double> areas,
    required int noOfPiecesPerPunch,
    required int qtyInBundle,
  }) async {
    _isUpdateJobOrderLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateJobOrder(
        jobOrderId: jobOrderId,
        plantId: plantId,
        materialCode: materialCode,
        description: description,
        uom: uom,
        areas: areas,
        noOfPiecesPerPunch: noOfPiecesPerPunch,
        qtyInBundle: qtyInBundle,
      );

      if (success) {
        await loadAllJobOrders(refresh: true);
        return true;
      } else {
        _error = 'Failed to update JobOrder';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdateJobOrderLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteJobOrder(String jobOrderId) async {
    _isDeleteJobOrderLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteJobOrder(jobOrderId);

      if (success) {
        await loadAllJobOrders(refresh: true);
        return true;
      } else {
        _error = 'Failed to delete JobOrder';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeleteJobOrderLoading = false;
      notifyListeners();
    }
  }

  Future<JobOrderModel?> getJobOrder(String jobOrderId) async {
    try {
      _error = null;
      final jobOrder = await _repository.getJobOrder(jobOrderId);
      return jobOrder;
    } catch (e) {
      _error = _getErrorMessage(e);
      return null;
    }
  }

  JobOrderModel? getJobOrderByIndex(int index) {
    if (index >= 0 && index < _jobOrders.length) {
      return _jobOrders[index];
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
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
}
