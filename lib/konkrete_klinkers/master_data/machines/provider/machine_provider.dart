import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/repo/machines.dart';

class MachinesProvider with ChangeNotifier {
  final MachineRepository _repository;

  MachinesProvider({MachineRepository? repository})
    : _repository = repository ?? MachineRepository();

  List<MachineElement> _machines = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 10;
  String _searchQuery = '';
  bool _isAddMachineLoading = false;
  bool _isUpdateMachinesLoading = false;
  bool _isDeleteMachinesLoading = false;

  List<PlantId> _plants = [];

  void setPlants(List<PlantId> plants) {
    _plants = plants;
  }

  // Getters
  List<MachineElement> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get limit => _limit;
  String get searchQuery => _searchQuery;
  bool get isAddMachineLoading => _isAddMachineLoading;
  bool get isUpdateMachinesLoading => _isUpdateMachinesLoading;
  bool get isDeleteMachinesLoading => _isDeleteMachinesLoading;

  // Load machines with lazy loading
  Future<void> loadAllMachines({bool refresh = false}) async {
    if (!_hasMore && !refresh) {
      print('No more machines to load');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'Fetching machines: limit=$_limit, skip=$_skip, search=$_searchQuery',
      );
      final response = await _repository.getAllmachines(
        limit: _limit,
        skip: refresh ? 0 : _skip,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      print('Received ${response.machines.length} machines');

      if (response.machines.length > _limit) {
        print(
          'Warning: Received ${response.machines.length} machines, expected up to $_limit',
        );
      }

      final newMachineIds = response.machines.map((m) => m.id).toSet();
      final existingMachineIds = _machines.map((m) => m.id).toSet();
      final duplicates = newMachineIds.intersection(existingMachineIds);
      if (duplicates.isNotEmpty) {
        print('Warning: Duplicate machine IDs detected: $duplicates');
      }

      if (refresh) {
        _machines = response.machines;
      } else {
        _machines.addAll(response.machines);
      }

      _skip = _machines.length;
      _hasMore = response.machines.length == _limit;
      print('Has more machines to load: $_hasMore');
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error loading machines: $_error');
      if (refresh) _machines.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search
  Future<void> searchMachines(String query) async {
    _searchQuery = query;
    _hasMore = true;
    _skip = 0;
    print('Searching machines with query: $query');
    await loadAllMachines(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _hasMore = true;
    _skip = 0;
    print('Clearing search query');
    await loadAllMachines(refresh: true);
  }

  // Create machine
  Future<bool> createMachine(String machineName, String plantId) async {
    try {
      _isAddMachineLoading = true;
      _error = null;
      notifyListeners();

      print('Creating machine: name=$machineName, plant_id=$plantId');

      final machine = await _repository.createMachine(machineName, plantId);

      // ✅ Attach plant details from existing plant list
      final matchedPlant = _plants.firstWhere(
        (plant) => plant.id == plantId,
        orElse: () => PlantId(id: plantId, plantName: '', plantCode: ''),
      );

      // ✅ Set plant details
      machine.plantId = PlantId(
        id: matchedPlant.id,
        plantName: matchedPlant.plantName,
        plantCode: matchedPlant.plantCode,
      );

      // ✅ Insert at top of the list
      _machines.insert(0, machine);
      notifyListeners();

      print('Created machine: ${machine.id} - ${machine.name}');
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
    String machineName,
    String plantId,
  ) async {
    _isUpdateMachinesLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'Updating machine: id=$machineId, machine_name=$machineName, plant_id=$plantId',
      );
      final machine = await _repository.updateMachine(
        machineId,
        machineName,
        plantId,
      );

      print('Updated machine: ${machine.id} - ${machine.name}');
      final index = _machines.indexWhere((m) => m.id == machineId);
      if (index != -1) {
        // _machines[index] = machine;
        _machines.removeAt(index); // Remove from current position
        _machines.insert(0, machine);
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
        notifyListeners();
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

  // Error conversion
  String _getErrorMessage(Object error) {
    if (error is Exception) return error.toString();
    if (error is String) return error;
    return 'An unexpected error occurred';
  }
}
