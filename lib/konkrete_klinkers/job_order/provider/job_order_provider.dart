import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/konkrete_klinkers/job_order/repo/job_order_repo.dart';

class JobOrderProvider with ChangeNotifier {
  final JobOrderRepository _repository = JobOrderRepository();

  List<JobOrderModel> _jobOrders = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  final int _limit = 10;
  String _searchQuery = '';

  // Loading states for specific operations
  bool _isAddJobOrderLoading = false;
  bool _isUpdateJobOrderLoading = false;
  bool _isDeleteJobOrderLoading = false;

  // Edit form specific states
  bool _isInitialized = false;
  String? _errorMessage;
  JobOrderModel? _jobOrder;
  Map<String, dynamic> _initialValues = {};
  bool _showAreaPerUnit = true;

  // Getters
  List<JobOrderModel> get jobOrders => _jobOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddJobOrderLoading => _isAddJobOrderLoading;
  bool get isUpdateJobOrderLoading => _isUpdateJobOrderLoading;
  bool get isDeleteJobOrderLoading => _isDeleteJobOrderLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  JobOrderModel? get jobOrder => _jobOrder;
  Map<String, dynamic> get initialValues => _initialValues;
  bool get showAreaPerUnit => _showAreaPerUnit;

Future<void> loadAllJobOrders({bool refresh = false}) async {
  if (refresh) {
    _currentPage = 1;
    _jobOrders.clear();
  }

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final response = await _repository.getAllJobOrder(
      page: _currentPage,
      limit: _limit, // Keep limit as 10
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    if (refresh) {
      _jobOrders.clear();
    }
    _jobOrders = response.data; // Directly assign the response data
    _updatePaginationInfo(response.pagination);
    _error = null;
  } catch (e) {
    _error = _getErrorMessage(e);
    _jobOrders.clear();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
 Future<void> loadPage(int page) async {
  if (page < 1 || page > _totalPages || page == _currentPage) return;

  _currentPage = page;
  await loadAllJobOrders();
}

Future<void> nextPage() async {
  if (!_hasNextPage) return;
  await loadPage(_currentPage + 1);
}

Future<void> previousPage() async {
  if (!_hasPreviousPage) return;
  await loadPage(_currentPage - 1);
}

Future<void> firstPage() async {
  await loadPage(1);
}

Future<void> lastPage() async {
  await loadPage(_totalPages);
}

  void _updatePaginationInfo(Pagination pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.page < pagination.totalPages;
    _hasPreviousPage = pagination.page > 1;
    notifyListeners();
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
        if (_jobOrders.length == 1 && _currentPage > 1) {
          _currentPage--;
        }
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