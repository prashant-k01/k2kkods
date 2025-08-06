import 'dart:io';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch.dart';
import 'package:k2k/konkrete_klinkers/dispatch/repo/dispatch_repo.dart';

class DispatchProvider with ChangeNotifier {
  final DispatchRepository _repository = DispatchRepository();

  List<DispatchModel> _dispatches = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  List<String> qrCodes = [];
  DispatchModel? _selectedDispatch;

  List<Map<String, String>> _workOrders = [];
  bool _isLoadingWorkOrders = false;
  String? _workOrderError;

  Map<String, dynamic>? _qrScanData;
  bool _isLoadingQrScan = false;
  String? _qrScanError;

  List<DispatchModel> get dispatches => _dispatches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  DispatchModel? get selectedDispatch => _selectedDispatch;

  List<Map<String, String>> get workOrders => _workOrders;
  bool get isLoadingWorkOrders => _isLoadingWorkOrders;
  String? get workOrderError => _workOrderError;

  Map<String, dynamic>? get qrScanData => _qrScanData;
  bool get isLoadingQrScan => _isLoadingQrScan;
  String? get qrScanError => _qrScanError;

  void clearError() {
    _error = null;
    _workOrderError = null;
    _qrScanError = null;
    notifyListeners();
  }

  void reset() {
    _dispatches = [];
    _isLoading = false;
    _error = null;
    _hasMore = true;
    _workOrders = [];
    _isLoadingWorkOrders = false;
    _workOrderError = null;
    _qrScanData = null;
    _isLoadingQrScan = false;
    _qrScanError = null;
    _selectedDispatch = null;
    notifyListeners();
  }

  Future<void> loadDispatches({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    if (refresh) _error = null;
    notifyListeners();

    try {
      final newDispatches = await _repository.getDispatches();
      if (refresh) {
        _dispatches = newDispatches;
      } else {
        _dispatches.addAll(newDispatches);
      }
      _hasMore = newDispatches.isNotEmpty;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      if (refresh) _dispatches = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkOrders({bool refresh = false}) async {
    if (_isLoadingWorkOrders) return;

    _isLoadingWorkOrders = true;
    if (refresh) _workOrderError = null;
    notifyListeners();

    try {
      final workOrders = await _repository.getWorkOrders();
      _workOrders = workOrders;
      _workOrderError = null;
    } catch (e) {
      _workOrderError = _getErrorMessage(e);
      if (refresh) _workOrders = [];
    } finally {
      _isLoadingWorkOrders = false;
      notifyListeners();
    }
  }

  Future<void> scanQrCode(String qrId) async {
    if (_isLoadingQrScan) return;

    _isLoadingQrScan = true;
    _qrScanError = null;
    notifyListeners();

    try {
      final qrData = await _repository.fetchQrScanData(qrId);
      _qrScanData = qrData;
      _qrScanError = null;
    } catch (e) {
      _qrScanError = _getErrorMessage(e);
      _qrScanData = null;
    } finally {
      _isLoadingQrScan = false;
      notifyListeners();
    }
  }

  Future<void> fetchDispatchById(String dispatchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dispatch = await _repository.fetchDispatchById(dispatchId);
      _selectedDispatch = dispatch;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      _selectedDispatch = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDispatch({
    required String workOrder,
    required String invoiceOrSto,
    required String vehicleNumber,
    required List<String> qrCodes,
    required String date,
    required File invoiceFile,
  }) async {
    print('🔄 DispatchProvider: Starting createDispatch...');
    print('📋 Parameters received:');
    print('  - workOrder: "$workOrder"');
    print('  - invoiceOrSto: "$invoiceOrSto"');
    print('  - vehicleNumber: "$vehicleNumber"');
    print('  - qrCodes: $qrCodes');
    print('  - date: "$date"');
    print('  - invoiceFile path: "${invoiceFile.path}"');
    print('  - invoiceFile exists: ${await invoiceFile.exists()}');

    if (workOrder.isEmpty) {
      _error = 'Work order is required';
      print('❌ Error: Work order is empty');
      notifyListeners();
      throw Exception('Work order is required');
    }

    if (invoiceOrSto.isEmpty) {
      _error = 'Invoice/STO is required';
      print('❌ Error: Invoice/STO is empty');
      notifyListeners();
      throw Exception('Invoice/STO is required');
    }

    if (vehicleNumber.isEmpty) {
      _error = 'Vehicle number is required';
      print('❌ Error: Vehicle number is empty');
      notifyListeners();
      throw Exception('Vehicle number is required');
    }

    if (date.isEmpty) {
      _error = 'Dispatch date is required';
      print('❌ Error: Date is empty');
      notifyListeners();
      throw Exception('Dispatch date is required');
    }

    if (!await invoiceFile.exists()) {
      _error = 'Invoice file does not exist';
      print(
        '❌ Error: Invoice file does not exist at path: ${invoiceFile.path}',
      );
      notifyListeners();
      throw Exception('Invoice file does not exist');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🚀 Calling repository.createDispatch...');

      await _repository.createDispatch(
        workOrder: workOrder,
        invoiceOrSto: invoiceOrSto,
        vehicleNumber: vehicleNumber,
        qrCodes: qrCodes,
        date: date,
        invoiceFile: invoiceFile,
      );

      print('✅ DispatchProvider: Dispatch created successfully!');
      _error = null;
    } catch (e) {
      print('❌ DispatchProvider: Error in createDispatch: $e');
      print('🔍 Error type: ${e.runtimeType}');
      print('📝 Error details: ${e.toString()}');

      _error = _getErrorMessage(e);
      print('🚨 Formatted error message: $_error');

      rethrow;
    } finally {
      _isLoading = false;
      print(
        '🏁 DispatchProvider: createDispatch completed, loading: $_isLoading',
      );
      notifyListeners();
    }
  }

  Future<void> updateDispatch({
    required String dispatchId,
    required String invoiceOrSto,
    required String vehicleNumber,
    required String date,
  }) async {
    print('🔄 DispatchProvider: Starting updateDispatch...');
    print('📋 Parameters received:');
    print('  - dispatchId: "$dispatchId"');
    print('  - invoiceOrSto: "$invoiceOrSto"');
    print('  - vehicleNumber: "$vehicleNumber"');
    print('  - date: "$date"');

    if (invoiceOrSto.isEmpty) {
      _error = 'Invoice/STO is required';
      print('❌ Error: Invoice/STO is empty');
      notifyListeners();
      throw Exception('Invoice/STO is required');
    }

    if (vehicleNumber.isEmpty) {
      _error = 'Vehicle number is required';
      print('❌ Error: Vehicle number is empty');
      notifyListeners();
      throw Exception('Vehicle number is required');
    }

    if (date.isEmpty) {
      _error = 'Dispatch date is required';
      print('❌ Error: Date is empty');
      notifyListeners();
      throw Exception('Dispatch date is required');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🚀 Calling repository.updateDispatch...');

      await _repository.updateDispatch(
        dispatchId: dispatchId,
        invoiceOrSto: invoiceOrSto,
        vehicleNumber: vehicleNumber,
        date: date,
      );

      print('✅ DispatchProvider: Dispatch updated successfully!');
      _error = null;
    } catch (e) {
      print('❌ DispatchProvider: Error in updateDispatch: $e');
      print('🔍 Error type: ${e.runtimeType}');
      print('📝 Error details: ${e.toString()}');

      _error = _getErrorMessage(e);
      print('🚨 Formatted error message: $_error');

      rethrow;
    } finally {
      _isLoading = false;
      print(
        '🏁 DispatchProvider: updateDispatch completed, loading: $_isLoading',
      );
      notifyListeners();
    }
  }

  String _getErrorMessage(Object error) {
    print('🔍 _getErrorMessage called with: $error');
    print('🔍 Error type: ${error.runtimeType}');

    String message;

    if (error is SocketException) {
      message = 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      message = 'Network error: ${error.message}';
    } else if (error is Exception) {
      String errorString = error.toString();
      if (errorString.startsWith('Exception: ')) {
        message = errorString.substring(11);
      } else {
        message = errorString;
      }
    } else {
      message = error.toString();
    }

    print('🚨 Final error message: $message');
    return message;
  }
}