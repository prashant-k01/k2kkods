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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _transfers = [];
    _isLoading = false;
    _error = null;
    _hasMore = true;
    notifyListeners();
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