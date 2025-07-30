import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/konkrete_klinkers/job_order/repo/job_order_repo.dart';

class JobOrderProvider with ChangeNotifier {
  final JobOrderRepository _repository = JobOrderRepository();

  List<JobOrderModel> _jobOrders = [];
  bool _isLoading = false;
  String? _error;

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

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> get products => _products;

  String? _selectedWorkOrder;
  String? get selectedWorkOrder => _selectedWorkOrder;

  List<Map<String, dynamic>> _availableProducts = [];
  List<Map<String, dynamic>> get availableProducts => _availableProducts;

  bool _isLoadingProducts = false;
  bool get isLoadingProducts => _isLoadingProducts;

  final List<List<String>> _machineNames = [];
  List<String> getMachineNamesForProduct(int index) =>
      index < _machineNames.length ? _machineNames[index] : [];

  final List<bool> _isLoadingMachineNames = [];
  bool isLoadingMachineNames(int index) =>
      index < _isLoadingMachineNames.length ? _isLoadingMachineNames[index] : false;

  bool _isUpdatingProducts = false;

  void updateProducts(List<Map<String, dynamic>> newProducts) {
    _products = newProducts;
    if (!_isUpdatingProducts) {
      _isUpdatingProducts = true;
      notifyListeners();
      _isUpdatingProducts = false;
    }
  }

  void updateMachineNames(int index, List<String> machineNames) {
    while (_machineNames.length <= index) {
      _machineNames.add([]);
      _isLoadingMachineNames.add(false);
    }
    _machineNames[index] = machineNames;
    _isLoadingMachineNames[index] = false;
    notifyListeners();
  }
Map<int, List<Map<String, dynamic>>> _machineDataByProduct = {};

List<Map<String, dynamic>>? getMachineDataForProduct(int index) {
  return _machineDataByProduct[index];
}

  Future<void> loadMachineNamesByProductId(int index, String productId) async {
    while (_machineNames.length <= index) {
      _machineNames.add([]);
      _isLoadingMachineNames.add(false);
    }
    _isLoadingMachineNames[index] = true;
    _error = null;
    notifyListeners();

    try {
      final machineNames = await _repository.fetchMachineNamesByProductId(productId);
      updateMachineNames(index, machineNames);
    } catch (e) {
      _error = _getErrorMessage(e);
      updateMachineNames(index, []);
    }
  }

  void setSelectedWorkOrder(String? value) {
    if (_selectedWorkOrder != value) {
      _selectedWorkOrder = value;
      _availableProducts.clear();
      _products.clear();
      _machineNames.clear();
      _isLoadingMachineNames.clear();
      _error = null;

      if (value != null && value.isNotEmpty) {
        final selectedWO = _workOrderDetails.firstWhere(
          (e) => e['work_order_number']?.toString() == value,
          orElse: () => {},
        );
        final workOrderId = selectedWO['id']?.toString() ?? selectedWO['_id']?.toString();
        if (workOrderId != null && workOrderId.isNotEmpty) {
          loadProductsByWorkOrder(workOrderId).then((_) {
            if (_products.isEmpty) {
              addProductSection();
            }
          }).catchError((error) {
            if (_products.isEmpty) {
              addProductSection();
            }
          });
        } else {
          addProductSection();
        }
      } else {
        addProductSection();
      }
      notifyListeners();
    }
  }

  void addProductSection() {
    _products.add({});
    _machineNames.add([]);
    _isLoadingMachineNames.add(false);
    notifyListeners();
  }

  void removeProductSection(int index) {
    if (index >= 0 && index < _products.length) {
      _products.removeAt(index);
      if (index < _machineNames.length) {
        _machineNames.removeAt(index);
        _isLoadingMachineNames.removeAt(index);
      }
      notifyListeners();
    }
  }

  Future<void> loadWorkOrderDetails() async {
    _isLoadingWorkOrderNumbers = true;
    _error = null;
    notifyListeners();

    try {
      _workOrderDetails = await _repository.fetchWorkOrderDetailsRaw();
      _workOrderNumbers = _workOrderDetails
          .map((e) => e['work_order_number']?.toString())
          .where((v) => v != null && v.isNotEmpty)
          .cast<String>()
          .toList();
      _error = null;
    } catch (e) {
      _workOrderDetails = [];
      _workOrderNumbers = [];
      _error = _getErrorMessage(e);
    }

    _isLoadingWorkOrderNumbers = false;
    notifyListeners();
  }

  Future<void> loadProductsByWorkOrder(String workOrderId) async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();

    try {
      _availableProducts = await _repository.fetchProductsByWorkOrder(workOrderId);
      _error = null;
    } catch (e) {
      _availableProducts = [];
      _error = _getErrorMessage(e);
    }

    _isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> createJobOrder(Map<String, dynamic> payload) async {
    _isAddJobOrderLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jobOrder = await _repository.createJobOrder(payload);
      _jobOrders.add(jobOrder);
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isAddJobOrderLoading = false;
      notifyListeners();
    }
  }

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