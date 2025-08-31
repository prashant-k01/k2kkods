import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/job_order/model/job_order_detail.dart';
import 'package:k2k/Iron_smith/job_order/model/job_order_summary.dart';
import 'package:k2k/Iron_smith/job_order/model/workorderid.dart';
import 'package:k2k/Iron_smith/job_order/repo/job_order_repo_is.dart';
import 'package:k2k/Iron_smith/workorder/model/iron_workorder_model.dart';

class JobOrderProviderIS with ChangeNotifier {
  final JobOrderISRepository _repository = JobOrderISRepository();

  List<JobOrderData> _jobOrders = [];
  List<JobOrderData> get jobOrders => _jobOrders;

  Data? _selectedJobOrder;
  Data? get selectedJobOrder => _selectedJobOrder;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  String? _error;
  String? get error => _error;
  bool _isLoadingMachines = false;
  bool get isLoadingMachines => _isLoadingMachines;

  IronWorkOrderData? _selectedWorkOrder;
  String? _salesOrderNumber;
  DateTimeRange? _dateRange;
  String? _selectedMachine;
  List<Map<String, dynamic>> _products = [];
  List<String> _machines = [];

  JoData? _jobOrder;
  JoData? get jobOrder => _jobOrder;

  IronWorkOrderData? get selectedWorkOrder => _selectedWorkOrder;
  String? get salesOrderNumber => _salesOrderNumber;
  DateTimeRange? get dateRange => _dateRange;
  String? get selectedMachine => _selectedMachine;
  List<Map<String, dynamic>> get products => _products;
  List<String> get machines => _machines;

  Future<void> fetchWorkOrderById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getWorkorderById(id);
      _jobOrder = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch a job order by its ID
  Future<void> getJobOrderById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jobOrder = await _repository.getJobOrderById(id);
      _selectedJobOrder = jobOrder;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setWorkOrder(IronWorkOrderData? workOrder) {
    _selectedWorkOrder = workOrder;
    notifyListeners();
  }

  void setSalesOrderNumber(String number) {
    _salesOrderNumber = number;
    notifyListeners();
  }

  void setDateRange(DateTimeRange range) {
    _dateRange = range;
    notifyListeners();
  }

  void setMachine(String? machine) {
    _selectedMachine = machine;
    notifyListeners();
  }

  void addProduct() {
    _products.add({
      'shapeCode': null,
      'diameter': null,
      'plannedQuantity': 0,
      'scheduledDate': null,
      'machine': null,
    });
    notifyListeners();
  }

  void removeProduct(int index) {
    _products.removeAt(index);
    notifyListeners();
  }

  /// ✅ CREATE
  Future<bool> createJobOrder(Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final createdJobOrder = await _repository.createJobOrder(body);
      await loadAllJobOrders(refresh: true);
      return createdJobOrder != null;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ READ (already exists)
  Future<void> loadAllJobOrders({bool refresh = false}) async {
    if (refresh) {
      _jobOrders.clear();
      notifyListeners();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAllJobOrder();
      _jobOrders = response;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _jobOrders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProduct(int index, Map<String, dynamic> updates) {
    _products[index] = {..._products[index], ...updates};
    notifyListeners();
  }

  JobOrderProviderIS() {
    initializeDefaultProduct();
  }

  void initializeDefaultProduct() {
    if (_products.isEmpty) {
      _products.add({
        'shapeCode': null,
        'diameter': null,
        'plannedQuantity': 0,
        'scheduledDate': null,
        'machine': null,
      });
    }
  }

  Future<void> refreshJobOrders() async {
    await loadAllJobOrders(refresh: true);
  }

  /// ✅ UPDATE
  Future<bool> updateJobOrder(String id, Map<String, dynamic> body) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final updatedJobOrder = await _repository.updateJobOrder(id, body);
      await loadAllJobOrders(refresh: true);
      return updatedJobOrder != null;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ DELETE
  Future<bool> deleteJobOrder(String mongoId) async {
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteJobOrder(mongoId);
      if (success) {
        _jobOrders.removeWhere((jobOrder) => jobOrder.id == mongoId);
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
      notifyListeners();
    }
  }

  /// ✅ Utility
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "N/A";
    try {
      final inputFormat = DateFormat("d/M/yyyy");
      final dateTime = inputFormat.parse(dateString);
      final outputFormat = DateFormat("dd/MM/yyyy hh:mm a");
      return outputFormat.format(dateTime);
    } catch (e) {
      return "N/A";
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
}
