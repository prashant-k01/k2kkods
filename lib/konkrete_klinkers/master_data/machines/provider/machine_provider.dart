import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/repo/machines.dart';

class MachinesProvider with ChangeNotifier {
  final MachineRepository _repository = MachineRepository();

  List<MachineElement> _machines = [];
  bool _isLoading = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _limit = 10;

  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  String _searchQuery = '';

  bool _isAddMachineLoading = false;
  bool _isUpdateMachinesLoading = false;
  bool _isDeleteMachinesLoading = false;

  // Getters
  List<MachineElement> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;
  bool get isAddMachineLoading => _isAddMachineLoading; // Fixed getter name
  bool get isUpdateMachinesLoading => _isUpdateMachinesLoading;
  bool get isDeleteMachinesLoading => _isDeleteMachinesLoading;

  // Load all machines with pagination
  Future<void> loadAllMachines({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _machines.clear();
    } else if (_currentPage > _totalPages) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'Fetching machines: page=$_currentPage, limit=$_limit, search=$_searchQuery',
      );
      final response = await _repository.getAllmachines(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      print(
        'Received ${response.machines.length} machines, pagination: ${response.pagination.toJson()}',
      );
      if (response.machines.isEmpty &&
          response.pagination.total > 0 &&
          _currentPage <= _totalPages) {
        print(
          'Empty machines list received, but total items > 0. Retrying with previous page.',
        );
        _currentPage = _currentPage > 1 ? _currentPage - 1 : 1;
        await loadAllMachines();
        return;
      }

      if (refresh) {
        _machines = response.machines;
      } else {
        _machines.addAll(response.machines);
      }
      _updatePaginationInfo(response.pagination);
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error loading machines: $_error');
      if (refresh) _machines.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pagination methods
  Future<void> loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    _currentPage = page;
    await loadAllMachines();
  }

  Future<void> nextPage() async {
    if (!_hasNextPage) return;
    await loadPage(_currentPage + 1);
  }

  Future<void> previousPage() async {
    if (!_hasPreviousPage) return;
    await loadPage(_currentPage - 1);
  }

  Future<void> firstPage() async => await loadPage(1);

  Future<void> lastPage() async => await loadPage(_totalPages);

  // Search
  Future<void> searchMachines(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    print('Searching machines with query: $query');
    await loadAllMachines(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    print('Clearing search query');
    await loadAllMachines(refresh: true);
  }

  // Create machine
  Future<bool> createMachine(String name, String plantId) async {
    try {
      _isAddMachineLoading = true;
      _error = null;
      notifyListeners();

      print('Creating machine: name=$name, plantId=$plantId');
      final machine = await _repository.createMachine(name, plantId);

      print('Created machine: ${machine.id} - ${machine.name}');
      _machines.insert(0, machine);
      _totalItems++;
      _totalPages = (_totalItems / _limit).ceil();
      _hasNextPage = _currentPage < _totalPages;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error creating machine: $_error');
      notifyListeners();
      return false;
    } finally {
      _isAddMachineLoading = false;
      notifyListeners();
    }
  }

  // Update machine
  Future<bool> updateMachines(
    String machineId,
    String name,
    PlantId plantId,
  ) async {
    _isUpdateMachinesLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'Updating machine: id=$machineId, name=$name, plantId=${plantId.id}',
      );
      final machine = await _repository.updateMachine(
        machineId,
        name,
        plantId.id,
      );

      print('Updated machine: ${machine.id} - ${machine.name}');
      final index = _machines.indexWhere((m) => m.id == machineId);
      if (index != -1) {
        _machines[index] = machine;
      } else {
        print('Machine $machineId not found in local list');
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error updating machine: $_error');
      return false;
    } finally {
      _isUpdateMachinesLoading = false;
      notifyListeners();
    }
  }

  // Delete machine
  Future<bool> deleteMachines(String machineId) async {
    _isDeleteMachinesLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Deleting machine: id=$machineId');
      final success = await _repository.deleteMachine(machineId);

      if (success) {
        print('Machine deleted: $machineId');
        _machines.removeWhere((m) => m.id == machineId);
        _totalItems--;
        _totalPages = (_totalItems / _limit).ceil();
        if (_machines.isEmpty && _currentPage > 1) {
          _currentPage--;
          print('Current page empty, loading previous page: $_currentPage');
          await loadAllMachines();
        } else {
          _hasNextPage = _currentPage < _totalPages;
          _hasPreviousPage = _currentPage > 1;
          notifyListeners();
        }
        return true;
      } else {
        _error = 'Failed to delete machine';
        print('Error: Failed to delete machine');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error deleting machine: $_error');
      return false;
    } finally {
      _isDeleteMachinesLoading = false;
      notifyListeners();
    }
  }

  // Get machine by ID
  Future<MachineElement?> getMachines(String machineId) async {
    try {
      _error = null;
      notifyListeners();
      print('Fetching machine: id=$machineId');
      final machine = await _repository.getmachines(machineId);
      if (machine != null) {
        print('Fetched machine: ${machine.id} - ${machine.name}');
      } else {
        print('Machine $machineId not found');
      }
      return machine;
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error fetching machine: $_error');
      notifyListeners();
      return null;
    }
  }

  // Get machine by index
  MachineElement? getMachinesByIndex(int index) {
    if (index >= 0 && index < _machines.length) {
      return _machines[index];
    }
    print('Invalid index for getMachinesByIndex: $index');
    return null;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
    print('Error cleared');
  }

  // Internal: update pagination
  void _updatePaginationInfo(Pagination pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.page < pagination.totalPages;
    _hasPreviousPage = pagination.page > 1;
    print(
      'Pagination updated: page=$_currentPage, totalPages=$_totalPages, totalItems=$_totalItems',
    );
  }

  // Error conversion
  String _getErrorMessage(Object error) {
    if (error is Exception) return error.toString();
    if (error is String) return error;
    return 'An unexpected error occurred';
  }
}
