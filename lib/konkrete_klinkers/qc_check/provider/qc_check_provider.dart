import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/qc_check/model/qc_check.dart';
import 'package:k2k/konkrete_klinkers/qc_check/repo/qc_check_repo.dart';

class QcCheckProvider with ChangeNotifier {
  final QcCheckRepository _repository = QcCheckRepository();

  List<QcCheckModel> _qcChecks = [];
  List<String> _jobOrders = []; // Store job order IDs
  bool _isLoading = false;
  bool _isJobOrdersLoading = false; // Separate loading state for job orders
  String? _error;
  bool _hasMore = true;
  String _searchQuery = '';

  // Loading states for specific operations
  bool _isAddQcCheckLoading = false;
  bool _isUpdateQcCheckLoading = false;
  bool _isDeleteQcCheckLoading = false;

  // Getters
  List<QcCheckModel> get qcChecks => _qcChecks;
  List<String> get jobOrders => _jobOrders; // Getter for job orders
  bool get isLoading => _isLoading;
  bool get isJobOrdersLoading =>
      _isJobOrdersLoading; // Getter for job orders loading state
  String? get error => _error;
  bool get isAddQcCheckLoading => _isAddQcCheckLoading;
  bool get isUpdateQcCheckLoading => _isUpdateQcCheckLoading;
  bool get isDeleteQcCheckLoading => _isDeleteQcCheckLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  // Clear error method
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _qcChecks = [];
    _jobOrders = []; // Reset job orders
    _isLoading = false;
    _isJobOrdersLoading = false; // Reset job orders loading state
    _error = null;
    _hasMore = true;
    _searchQuery = '';
    notifyListeners();
  }

  // Load job orders from repository
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
      _error = null; // Clear error on manual refresh
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

      // Update hasMore based on response
      _hasMore = newQcChecks.isNotEmpty;
      _error = null;

      print('Load successful - total QC checks: ${_qcChecks.length}');
    } catch (e) {
      print('Error loading QC checks: $e');
      _error = _getErrorMessage(e);

      // Don't clear existing data on error unless it's a refresh
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
      // Remove 'Exception: ' prefix if present
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

  // Method to retry loading
  Future<void> retry() async {
    print('Retrying to load QC checks and job orders');
    clearError();
    await Future.wait([
      loadQcChecks(refresh: true),
      loadJobOrders(), // Retry job orders as well
    ]);
  }
}
