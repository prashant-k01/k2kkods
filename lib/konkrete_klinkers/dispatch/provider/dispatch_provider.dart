import 'dart:io';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch.dart';
import 'package:k2k/konkrete_klinkers/dispatch/model/dispatch_detail.dart';
import 'package:k2k/konkrete_klinkers/dispatch/repo/dispatch_repo.dart';

class DispatchProvider with ChangeNotifier {
  final DispatchRepository _repository = DispatchRepository();

  // Dispatch List State
  List<DispatchModel> _dispatches = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  DispatchData? _selectedDispatch;

  // Work Orders State
  List<Map<String, String>> _workOrders = [];
  bool _isLoadingWorkOrders = false;
  String? _workOrderError;

  // QR Scan State
  Map<String, dynamic>? _scannedQrData;
  bool _isScanning = false;
  String? _qrScanError;

  // ========= Getters =========
  List<DispatchModel> get dispatches => _dispatches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  DispatchData? get selectedDispatch => _selectedDispatch;

  List<Map<String, String>> get workOrders => _workOrders;
  bool get isLoadingWorkOrders => _isLoadingWorkOrders;
  String? get workOrderError => _workOrderError;

  Map<String, dynamic>? get qrScan => _scannedQrData;
  bool get isScanning => _isScanning;
  String? get qrScanError => _qrScanError;

  // ========= Error & Reset =========
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

    _selectedDispatch = null;

    _scannedQrData = null;
    _isScanning = false;
    _qrScanError = null;

    notifyListeners();
  }

  // ========= Dispatch List =========
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

  Future<void> fetchDispatchById(String dispatchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dispatch = await _repository.fetchDispatchById(dispatchId);
      _selectedDispatch = dispatch.data;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      _selectedDispatch = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========= Work Orders =========
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

  // ========= QR Scan =========
  Future<void> fetchQrDetails(String qrId) async {
    if (_isScanning) return;

    _isScanning = true;
    _qrScanError = null;
    notifyListeners();

    try {
      final qrData = await _repository.fetchQrScanData(qrId);

      if (qrData != null) {
        _scannedQrData = qrData;
      }
      _qrScanError = null;
      notifyListeners();
    } catch (e) {
      _qrScanError = _getErrorMessage(e);
      _scannedQrData = null;
      notifyListeners();
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  void setScannedQr(Map<String, dynamic>? data) {
    _scannedQrData = data;
    _qrScanError = null; // clear any previous error

    notifyListeners();
  }

  // Reset
  void resetScannedQr() {
    _scannedQrData = null;
    _qrScanError = null; // clear any previous error

    notifyListeners();
  }

  void setScanning(bool value) {
    _isScanning = value;
    notifyListeners();
  }

  // ========= Create / Update Dispatch =========
  Future<void> createDispatch({
    required String workOrder,
    required String invoiceOrSto,
    required String vehicleNumber,
    required String date,
    required File invoiceFile,
    required List<String> qrCodes,
  }) async {
    // Validate inputs
    if (workOrder.isEmpty) throw Exception('Work order is required');
    if (invoiceOrSto.isEmpty) throw Exception('Invoice/STO is required');
    if (vehicleNumber.isEmpty) throw Exception('Vehicle number is required');
    if (date.isEmpty) throw Exception('Dispatch date is required');
    if (!await invoiceFile.exists()) {
      throw Exception('Invoice file does not exist');
    }
    if (qrCodes.isEmpty) throw Exception('At least one QR code is required');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call repository method (repository handles API/network logic)
      await _repository.createDispatch(
        workOrder: workOrder,
        invoiceOrSto: invoiceOrSto,
        vehicleNumber: vehicleNumber,
        date: date,
        invoiceFile: invoiceFile,
        qrCodes: qrCodes,
      );
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDispatch({
    required String dispatchId,
    required String invoiceOrSto,
    required String vehicleNumber,
    required String date,
  }) async {
    if (invoiceOrSto.isEmpty) throw Exception('Invoice/STO is required');
    if (vehicleNumber.isEmpty) throw Exception('Vehicle number is required');
    if (date.isEmpty) throw Exception('Dispatch date is required');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateDispatch(
        dispatchId: dispatchId,
        invoiceOrSto: invoiceOrSto,
        vehicleNumber: vehicleNumber,
        date: date,
      );
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========= Error Handling =========
  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      return 'Network error: ${error.message}';
    } else if (error is Exception) {
      String msg = error.toString();
      if (msg.startsWith('Exception: ')) msg = msg.substring(11);
      return msg;
    } else {
      return error.toString();
    }
  }
}
