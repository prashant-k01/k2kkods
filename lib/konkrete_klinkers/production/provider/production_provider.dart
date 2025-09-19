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
  String _selectedFilter = 'all';

  Production? get productionData => _productionData;
  List<Downtime>? get downTimeLogs => _downTimeLogs;
  List<ProductionLog>? get productionLogs => _productionLogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get selectedDate => _selectedDate;
  String? get activeTimerJobId => _activeTimerJobId;
  bool get showTimer => _showTimer;
  String get selectedFilter => _selectedFilter;

  List<PastDpr> getFilteredPastDpr() {
    final list = _productionData?.data.pastDpr ?? [];
    return list;
  }

  List<PastDpr> getFilteredTodayDpr() {
    final list = _productionData?.data.todayDpr ?? [];
    return _applyFilter(list); // Apply filter logic
  }

  List<PastDpr> getFilteredFutureDpr() {
    final list = _productionData?.data.futureDpr ?? [];
    return list;
  }

  // NEW: Method to apply filter logic
  List<PastDpr> _applyFilter(List<PastDpr> dprList) {
    print(
      'Filtering DPR list, selectedFilter: $_selectedFilter, total items: ${dprList.length}',
    );

    // Debug: Print all DPR statuses
    for (int i = 0; i < dprList.length; i++) {
      final dpr = dprList[i];
      final Status actualStatus = dpr is PastDpr
          ? (dpr.dailyProduction?.status ?? dpr.status)
          : dpr.status;
      print('DPR $i: actualStatus = $actualStatus, id = ${dpr.id}');
    }

    switch (_selectedFilter) {
      case 'active':
        final activeList = dprList.where((dpr) {
          final Status actualStatus = dpr is PastDpr
              ? (dpr.dailyProduction?.status ?? dpr.status)
              : dpr.status;
          return actualStatus == Status.IN_PROGRESS;
        }).toList();
        print('Active filter applied, items: ${activeList.length}');
        return activeList;

      case 'inactive':
        final inactiveList = dprList.where((dpr) {
          final Status actualStatus = dpr is PastDpr
              ? (dpr.dailyProduction?.status ?? dpr.status)
              : dpr.status;
          return actualStatus == Status.PAUSED ||
              actualStatus == Status.PENDING_QC;
        }).toList();
        print('Inactive filter applied, items: ${inactiveList.length}');
        return inactiveList;

      case 'created_today':
        final today = _normalizeDate(DateTime.now());
        final createdTodayList = dprList.where((dpr) {
          final DateTime createdAt = dpr.createdAt;
          return _normalizeDate(createdAt) == today;
        }).toList();
        print(
          'Created today filter applied, items: ${createdTodayList.length}',
        );
        return createdTodayList;

      default:
        print('All filter applied, items: ${dprList.length}');
        return dprList;
    }
  }

  // NEW: Method to get appropriate empty message based on filter
  String getEmptyMessage() {
    switch (_selectedFilter) {
      case 'active':
        return 'No active production jobs found';
      case 'inactive':
        return 'No inactive production jobs found';
      case 'created_today':
        return 'No production jobs created today';
      default:
        return 'No production scheduled for selected date';
    }
  }

  // NEW: Method to set filter and notify listeners
  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      print('Filter changed to: $_selectedFilter');
      notifyListeners();
    }
  }

  void setDate(DateTime date) {
    _selectedDate = _normalizeDate(date);
    // Reset filter when date changes
    _selectedFilter = 'all';
    print('Setting selectedDate: $_selectedDate, resetting filter to all');
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
      print(
        'Production data fetched successfully: ${_productionData?.data.todayDpr.length ?? 0} items',
      );
    } catch (e) {
      _error = 'Error fetching production data: $e';
      print('Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> performProductionAction({
    required String jobOrder,
    required String productId,
    required String action,
  }) async {
    try {
      print(
        'Performing action: $action for jobOrder: $jobOrder, productId: $productId',
      );

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

      notifyListeners();
    } catch (e) {
      print('Error performing action $action: $e');
      setError('Error performing action $action: $e');
      rethrow;
    } finally {
      setLoading(false);
    }
  }

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
        // Refresh main production data after downtime changes
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
