import 'dart:io';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/stock_management/model/stock.dart';
import 'package:k2k/konkrete_klinkers/stock_management/repo/stock_repo.dart';

class StockProvider with ChangeNotifier {
  final StockManagementRepository _repository = StockManagementRepository();

  List<StockManagement> _transfers = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;

  List<StockManagement> get transfers => _transfers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  final List<Datum> _allProducts = [];
  bool _isProductsLoading = false;
  bool _hasMoreProducts = true;

  List<Datum> get allProducts => _allProducts;

  List<Data> _workOrders = [];
  bool _isWOLoading = false;
  String? _errorMessage;
  bool _isBuffer = false;

  List<Data> get workOrders => _workOrders;
  bool get isWOLoading => _isWOLoading;
  String? get errorMessage => _errorMessage;
  bool get isBuffer => _isBuffer;

  DataQ? _achievedQuantity;
  bool _isQuantityLoading = false;
  String? _quantityError;

  DataQ? get achievedQuantity => _achievedQuantity;
  bool get isQuantityLoading => _isQuantityLoading;
  String? get quantityError => _quantityError;

  bool _isTransferLoading = false;
  String? _transferError;

  bool get isTransferLoading => _isTransferLoading;
  String? get transferError => _transferError;

  Stock? _stockById;
  bool _isStockByIdLoading = false;
  String? _stockByIdError;

  Stock? get stockById => _stockById;
  bool get isStockByIdLoading => _isStockByIdLoading;
  String? get stockByIdError => _stockByIdError;

  set isBuffer(bool value) {
    _isBuffer = value;
    notifyListeners();
  }

  Future<void> getStockById(String id) async {
    _isStockByIdLoading = true;
    _stockByIdError = null;
    notifyListeners();

    try {
      _stockById = await _repository.getStockById(id);
    } catch (e) {
      _stockByIdError = _getErrorMessage(e);
    } finally {
      _isStockByIdLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBuffer({
    required String fromWorkOrderId,
    required String toWorkOrderId,
    required String productId,
    required int quantityTransferred,
    required bool isBufferTransfer,
  }) async {
    print(
      'Initiating buffer creation: fromWorkOrderId=$fromWorkOrderId, toWorkOrderId=$toWorkOrderId, productId=$productId, quantity=$quantityTransferred, isBuffer=$isBufferTransfer',
    ); // Debug log
    _isTransferLoading = true;
    _transferError = null;
    notifyListeners();
    try {
      await _repository.createBuffer(
        fromWorkOrderId: fromWorkOrderId,
        toWorkOrderId: toWorkOrderId,
        productId: productId,
        quantityTransferred: quantityTransferred,
        isBufferTransfer: isBufferTransfer,
      );
      print('Buffer creation successful'); // Debug log
    } catch (e) {
      _transferError = _getErrorMessage(e);
      print('Error creating buffer: $_transferError'); // Debug log
      rethrow;
    } finally {
      _isTransferLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWorkOrdersByProductId(
    String productId,
    bool isBuffer,
  ) async {
    _isWOLoading = true;
    _errorMessage = null;
    _isBuffer = isBuffer;
    notifyListeners();

    try {
      _workOrders = await _repository.getWorkOrdersByProductId(
        productId,
        isBuffer,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isWOLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAchievedQuantity({
    required String workOrderId,

    required String productId,
    required bool isBuffer,
  }) async {
    _isQuantityLoading = true;
    _quantityError = null;
    _achievedQuantity = null;
    notifyListeners();

    try {
      _achievedQuantity = await _repository.getAchievedQuantity(
        workOrderId: workOrderId,
        productId: productId,

        isBuffer: isBuffer,
      );
    } catch (e) {
      _quantityError = _getErrorMessage(e);
    } finally {
      _isQuantityLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    _errorMessage = null;
    _quantityError = null;
    _stockByIdError = null;
    notifyListeners();
  }

  void reset() {
    _transfers = [];
    _isLoading = false;
    _error = null;
    _hasMore = true;
    _workOrders = [];
    _isWOLoading = false;
    _errorMessage = null;
    _achievedQuantity = null;
    _isQuantityLoading = false;
    _quantityError = null;
    _isTransferLoading = false;
    _transferError = null;
    _stockByIdError = null;
    notifyListeners();
  }

  Future<void> loadAllProducts({
    bool refresh = false,
    String? searchQuery,
  }) async {
    if (refresh) {
      _allProducts.clear();
      _hasMoreProducts = true;
    }

    if (!_hasMoreProducts || _isProductsLoading) return;

    _isProductsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAllProducts(
        search: searchQuery?.isNotEmpty == true ? searchQuery : null,
      
      );
      if (response.isEmpty) {
        _hasMoreProducts = false;
      } else {
        _allProducts.addAll(response as Iterable<Datum>);
      
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _allProducts.clear();
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStockManagements({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    if (refresh) _error = null;
    notifyListeners();

    try {
      final newTransfers = await _repository.getStockManagements();
      if (refresh) {
        _transfers = newTransfers;
      } else {
        _transfers.addAll(newTransfers);
      }
      _hasMore = newTransfers.isNotEmpty;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      if (refresh) _transfers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      return 'Network error: ${error.message}';
    } else if (error is Exception) {
      String message = error.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      return message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
