import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/production/model/common_model.dart';
import 'package:k2k/konkrete_klinkers/production/model/production_logs_model.dart';
import 'package:k2k/konkrete_klinkers/production/model/production_model.dart';
import 'package:k2k/konkrete_klinkers/production/repo/production.dart';

class ProductionProvider with ChangeNotifier {
  final ProductionRepository _repository = ProductionRepository();
  Production? _productionData;
  List<Downtime>? _downTimeLogs;
  List<ProductionLog>? _productionLogs;
  bool _isLoading = false;
  String? _error;
  DateTime? _selectedDate;
  String? _activeTimerJobId;
  final Map<String, int> _timers = {};
  bool _showTimer = false;

  Production? get productionData => _productionData;
  List<Downtime>? get downTimeLogs => _downTimeLogs;
  List<ProductionLog>? get productionLogs => _productionLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get selectedDate => _selectedDate;
  String? get activeTimerJobId => _activeTimerJobId;
  bool get showTimer => _showTimer;
  
  List<PastDpr> getFilteredPastDpr() {
    final list = _productionData?.data.pastDpr ?? [];
    return list;
  }

  List<PastDpr> getFilteredTodayDpr() {
    final list = _productionData?.data.todayDpr ?? [];
    return list;
  }

  List<PastDpr> getFilteredFutureDpr() {
    final list = _productionData?.data.futureDpr ?? [];
    return list;
  }

  void setDate(DateTime date) {
    _selectedDate = _normalizeDate(date);
    print('Setting selectedDate: $_selectedDate');
    notifyListeners();
  }

  void resetTab(int index) {
    notifyListeners();
  }

  Color getStatusColor(Status status) => {
    Status.IN_PROGRESS: Colors.blue[700]!,
    Status.PAUSED: Colors.red[700]!,
    Status.PENDING: Colors.grey[500]!,
    Status.PENDING_QC: Colors.grey[500]!,
    Status.COMPLETED: Colors.green[700]!,
  }[status]!;

  String formatTimer(String jobOrderId) {
    final seconds = _timers[jobOrderId] ?? 0;
    return '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Future<void> fetchProductionJobOrderByDate() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final today = _normalizeDate(DateTime.now());
      print('Fetching production data for date: ${_selectedDate ?? today}');
      _productionData = await _repository.fetchProductionJobOrderByDate(
        date: _selectedDate ?? today,
      );
      print('Production data fetched successfully: ${_productionData?.data.todayDpr.length ?? 0} items');
    } catch (e) {
      _error = 'Error fetching production data: $e';
      print('Error: $_error');
    } finally {
      _isLoading = false;
      // FIXED: Always notify listeners after data fetch
      notifyListeners();
    }
  }

  // FIXED: Enhanced performProductionAction with better error handling and UI updates
  Future<void> performProductionAction({
    required String jobOrder,
    required String productId,
    required String action,
  }) async {
    try {
      print('Performing action: $action for jobOrder: $jobOrder, productId: $productId');

      // Set loading state
      setLoading(true);

      // Perform the action
      final result = await _repository.performAction(
        jobOrder: jobOrder,
        productId: productId,
        action: action,
      );

      print('Action $action completed successfully. Result: $result');

      // Clear any previous errors
      setError(null);

      // Always refresh the data after a successful action
      await fetchProductionJobOrderByDate();

      print('Data refreshed after action: $action');
      
      // FIXED: Explicit notification after successful action
      notifyListeners();
      
    } catch (e) {
      print('Error performing action $action: $e');
      setError('Error performing action $action: $e');
      rethrow; // Re-throw so the UI can handle it
    } finally {
      setLoading(false);
    }
  }

  // FIXED: Enhanced helper methods with proper notifications
  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  Future<void> addDownTime(
    String productId,
    String jobOrder,
    Map<String, dynamic> downtimeData,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (await _repository.addDownTime(productId, jobOrder, downtimeData)) {
        await fetchDownTimeLogs(productId, jobOrder);
        // FIXED: Refresh main production data after downtime changes
        await fetchProductionJobOrderByDate();
      }
    } catch (e) {
      _error = 'Error adding downtime: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDownTimeLogs(String productId, String jobOrder) async {
    _isLoading = true;
    notifyListeners();
    try {
      _downTimeLogs = await _repository.fetchDownTimeLogs(productId, jobOrder);
    } catch (e) {
      _error = 'Error fetching downtime logs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductionLogs(String productId, String jobOrder) async {
    _isLoading = true;
    notifyListeners();
    try {
      _productionLogs = await _repository.fetchProductionLogs(
        productId,
        jobOrder,
      );
    } catch (e) {
      _error = 'Error fetching production logs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Enhanced updateProduction with proper data refresh
  Future<void> updateProduction(String productId, String jobOrder) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (await _repository.updateProduction(productId, jobOrder)) {
        await fetchProductionJobOrderByDate();
        print('Production updated and data refreshed successfully');
      }
    } catch (e) {
      _error = 'Error updating production: $e';
      print('Error updating production: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTimer() {
    _showTimer = !_showTimer;
    notifyListeners();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
    void forceRefresh() {
    print('Force refreshing UI');
    notifyListeners();
  }
}