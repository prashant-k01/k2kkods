import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/qc_check/model/qc_check.dart';
import 'package:k2k/konkrete_klinkers/qc_check/repo/qc_check_repo.dart';

class QcCheckProvider with ChangeNotifier {
  final QcCheckRepository _repository = QcCheckRepository();

  List<QcCheckModel> _qcChecks = [];
  List<Map<String, String>> _jobOrders = [];
  Map<String, String>? _workOrder;
  List<Map<String, String>> _products = [];
  bool _isLoading = false;
  bool _isJobOrdersLoading = false;
  bool _isWorkOrderAndProductsLoading = false;
  String? _error;
  bool _hasMore = true;
  String _searchQuery = '';

  bool _isAddQcCheckLoading = false;
  bool _isUpdateQcCheckLoading = false;
  bool _isDeleteQcCheckLoading = false;

  List<QcCheckModel> get qcChecks => _qcChecks;
  List<Map<String, String>> get jobOrders => _jobOrders;
  Map<String, String>? get workOrder => _workOrder;
  List<Map<String, String>> get products => _products;
  bool get isLoading => _isLoading;
  bool get isJobOrdersLoading => _isJobOrdersLoading;
  bool get isWorkOrderAndProductsLoading => _isWorkOrderAndProductsLoading;
  String? get error => _error;
  bool get isAddQcCheckLoading => _isAddQcCheckLoading;
  bool get isUpdateQcCheckLoading => _isUpdateQcCheckLoading;
  bool get isDeleteQcCheckLoading => _isDeleteQcCheckLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _qcChecks = [];
    _jobOrders = [];
    _workOrder = null;
    _products = [];
    _isLoading = false;
    _isJobOrdersLoading = false;
    _isWorkOrderAndProductsLoading = false;
    _error = null;
    _hasMore = true;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> loadJobOrders() async {
    print('Loading job orders - isJobOrdersLoading: $_isJobOrdersLoading');
    if (_isJobOrdersLoading) {
      print('Skipping job orders load - already loading');
      return;
    }

    _isJobOrdersLoading = true;
    notifyListeners();

    try {
      print('Calling repository.getJobOrders()');
      final jobOrders = await _repository.getJobOrders();
      print('Repository returned ${jobOrders.length} job orders');

      _jobOrders = jobOrders;
      _error = null;

      print(
        'Load job orders successful - total job orders: ${_jobOrders.length}',
      );
    } catch (e) {
      print('Error loading job orders: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isJobOrdersLoading = false;
      notifyListeners();
      print(
        'Load job orders completed - isJobOrdersLoading: $_isJobOrdersLoading, error: $_error',
      );
    }
  }

  Future<void> loadWorkOrderAndProducts(String jobOrderId) async {
    print(
      'Loading work order and products - isWorkOrderAndProductsLoading: $_isWorkOrderAndProductsLoading',
    );
    if (_isWorkOrderAndProductsLoading) {
      print('Skipping work order and products load - already loading');
      return;
    }

    _isWorkOrderAndProductsLoading = true;
    notifyListeners();

    try {
      print('Calling repository.getWorkOrderAndProducts($jobOrderId)');
      final data = await _repository.getWorkOrderAndProducts(jobOrderId);
      print(
        'Repository returned work order: ${data['work_order']}, products: ${data['products'].length}',
      );

      _workOrder = data['work_order'] as Map<String, String>?;
      _products = (data['products'] as List<dynamic>)
          .cast<Map<String, String>>();
      _error = null;

      print(
        'Load work order and products successful - work order: $_workOrder, products: ${_products.length}',
      );
    } catch (e) {
      print('Error loading work order and products: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isWorkOrderAndProductsLoading = false;
      notifyListeners();
      print(
        'Load work order and products completed - isWorkOrderAndProductsLoading: $_isWorkOrderAndProductsLoading, error: $_error',
      );
    }
  }

  Future<void> loadQcChecks({bool refresh = false}) async {
    print(
      'Loading QC checks - refresh: $refresh, isLoading: $_isLoading, hasMore: $_hasMore',
    );

    if (_isLoading || (!_hasMore && !refresh)) {
      print('Skipping load - already loading or no more data');
      return;
    }

    _isLoading = true;
    if (refresh) {
      _error = null;
    }
    notifyListeners();

    try {
      print('Calling repository.getQcChecks()');
      final newQcChecks = await _repository.getQcChecks();
      print('Repository returned ${newQcChecks.length} QC checks');

      if (refresh) {
        _qcChecks = newQcChecks;
        print('Refreshed QC checks list');
      } else {
        _qcChecks.addAll(newQcChecks);
        print('Added ${newQcChecks.length} new QC checks');
      }

      _hasMore = newQcChecks.isNotEmpty;
      _error = null;

      print('Load successful - total QC checks: ${_qcChecks.length}');
    } catch (e) {
      print('Error loading QC checks: $e');
      _error = _getErrorMessage(e);

      if (refresh) {
        _qcChecks = [];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      print(
        'Load QC checks completed - isLoading: $_isLoading, error: $_error',
      );
    }
  }

  String _getErrorMessage(Object error) {
    String errorMessage;

    if (error is SocketException) {
      errorMessage = 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      errorMessage = 'Network error: ${error.message}';
    } else if (error is TimeoutException) {
      errorMessage = 'Request timeout. Please try again.';
    } else if (error is FormatException) {
      errorMessage = 'Invalid response format. Please contact support.';
    } else if (error is Exception) {
      String message = error.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      errorMessage = message;
    } else if (error is String) {
      errorMessage = error;
    } else {
      errorMessage = 'An unexpected error occurred. Please try again.';
    }

    print('Error message: $errorMessage');
    return errorMessage;
  }

  Future<void> createQcCheck(Map<String, dynamic> qcCheckData) async {
    print('Creating QC check with data: $qcCheckData');

    _isAddQcCheckLoading = true;
    notifyListeners();

    try {
      final qcCheck = await _repository.createQcCheck(qcCheckData);

      final jobOrder = _jobOrders.firstWhere(
        (job) => job['_id'] == qcCheckData['job_order'],
        orElse: () => {'job_order_id': qcCheckData['job_order'] ?? 'N/A'},
      );
      final workOrder =
          _workOrder != null && _workOrder!['_id'] == qcCheckData['work_order']
          ? _workOrder
          : {'work_order_number': qcCheckData['work_order'] ?? 'N/A'};

      final enrichedQcCheck = QcCheckModel(
        id: qcCheck.id,
        workOrder: qcCheck.workOrder,
        jobOrder: qcCheck.jobOrder,
        productId: qcCheck.productId,
        rejectedQuantity: qcCheck.rejectedQuantity,
        recycledQuantity: qcCheck.recycledQuantity,
        remarks: qcCheck.remarks,
        createdBy: qcCheck.createdBy,
        updatedBy: qcCheck.updatedBy,
        status: qcCheck.status,
        createdAt: qcCheck.createdAt,
        updatedAt: qcCheck.updatedAt,
        workOrderNumber: workOrder?['work_order_number'],
        jobOrderNumber: jobOrder['job_order_id'],
      );

      _qcChecks.insert(0, enrichedQcCheck);
      _error = null;
      print('QC check created successfully: ${enrichedQcCheck.id}');
    } catch (e) {
      print('Error creating QC check: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isAddQcCheckLoading = false;
      notifyListeners();
      print(
        'Create QC check completed - isAddQcCheckLoading: $_isAddQcCheckLoading, error: $_error',
      );
    }
  }

  Future<void> deleteQcCheck(String id) async {
    print('Deleting QC check with ID: $id');

    _isDeleteQcCheckLoading = true;
    _error = null; // Clear any previous errors
    notifyListeners();

    try {
      final success = await _repository.deleteQcCheck(id);
      if (success) {
        // Remove the item from the local list
        _qcChecks.removeWhere((qc) => qc.id == id);
        _error = null;
        print('QC check deleted successfully: $id');
      } else {
        _error = 'Failed to delete QC check.';
        throw Exception('Failed to delete QC check.');
      }
    } catch (e) {
      print('Error deleting QC check: $e');
      _error = _getErrorMessage(e);
      // Re-throw the exception so the UI can handle it
      rethrow;
    } finally {
      _isDeleteQcCheckLoading = false;
      notifyListeners();
      print(
        'Delete QC check completed - isDeleteQcCheckLoading: $_isDeleteQcCheckLoading, error: $_error',
      );
    }
  }

  Future<void> updateQcCheck(
    String id,
    Map<String, dynamic> qcCheckData,
  ) async {
    print('Updating QC check with ID: $id, data: $qcCheckData');

    _isUpdateQcCheckLoading = true;
    notifyListeners();

    try {
      final updatedQcCheck = await _repository.updateQcCheck(id, qcCheckData);

      final jobOrder = _jobOrders.firstWhere(
        (job) => job['_id'] == qcCheckData['job_order'],
        orElse: () => {'job_order_id': qcCheckData['job_order'] ?? 'N/A'},
      );
      final workOrder =
          _workOrder != null && _workOrder!['_id'] == qcCheckData['work_order']
          ? _workOrder
          : {'work_order_number': qcCheckData['work_order'] ?? 'N/A'};

      final enrichedQcCheck = QcCheckModel(
        id: updatedQcCheck.id,
        workOrder: updatedQcCheck.workOrder,
        jobOrder: updatedQcCheck.jobOrder,
        productId: updatedQcCheck.productId,
        rejectedQuantity: updatedQcCheck.rejectedQuantity,
        recycledQuantity: updatedQcCheck.recycledQuantity,
        remarks: updatedQcCheck.remarks,
        createdBy: updatedQcCheck.createdBy,
        updatedBy: updatedQcCheck.updatedBy,
        status: updatedQcCheck.status,
        createdAt: updatedQcCheck.createdAt,
        updatedAt: updatedQcCheck.updatedAt,
        workOrderNumber: workOrder?['work_order_number'],
        jobOrderNumber: jobOrder['job_order_id'],
      );

      final index = _qcChecks.indexWhere((qc) => qc.id == id);
      if (index != -1) {
        _qcChecks[index] = enrichedQcCheck;
      } else {
        _qcChecks.insert(0, enrichedQcCheck);
      }

      _error = null;
      print('QC check updated successfully: ${enrichedQcCheck.id}');
    } catch (e) {
      print('Error updating QC check: $e');
      _error = _getErrorMessage(e);
    } finally {
      _isUpdateQcCheckLoading = false;
      notifyListeners();
      print(
        'Update QC check completed - isUpdateQcCheckLoading: $_isUpdateQcCheckLoading, error: $_error',
      );
    }
  }

  Future<void> retry() async {
    print('Retrying to load QC checks and job orders');
    clearError();
    await Future.wait([loadQcChecks(refresh: true), loadJobOrders()]);
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
