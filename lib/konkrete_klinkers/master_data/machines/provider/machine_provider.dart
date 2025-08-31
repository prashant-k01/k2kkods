import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/repo/machines.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/repo/plants.dart';

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
  MachineElement? _currentMachine;
  bool _isMachineLoading = false;
  String? _machineError;

  List<PlantId> _plant = [];
  bool _isAllPlantsLoading = false;

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
  MachineElement? get currentMachine => _currentMachine;
  bool get isMachineLoading => _isMachineLoading;
  String? get machineError => _machineError;
  List<PlantId> get plant => _plant;
  bool get isAllPlantsLoading => _isAllPlantsLoading;

  // Set plants
  void setPlants(List<PlantId> plants) {
    _plant = plants;
    notifyListeners();
  }

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

  // Fetch plants
  final PlantRepository _plantRepository = PlantRepository();

  Future<void> ensurePlantsLoaded({bool refresh = false}) async {
    if (_isAllPlantsLoading) return;

    _isAllPlantsLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (refresh || _plant.isEmpty) {
        print('[PlantProvider] Fetching all plants...');
        final plants = await _plantRepository.fetchAllPlants();
        _plant = plants;
        print('[PlantProvider] Loaded ${_plant.length} plants');
      } else {
        print(
          '[PlantProvider] Using cached plant list with ${_plant.length} items',
        );
      }
    } catch (e, stackTrace) {
      _error = 'Failed to load plants: $e';
      _plant = [];
      print('[PlantProvider] Error: $e');
      print(stackTrace);
    } finally {
      _isAllPlantsLoading = false;
      notifyListeners();
    }
  }

  // Create machine
  Future<bool> createMachine(String machineName, String plantId) async {
    try {
      _isAddMachineLoading = true;
      _error = null;
      notifyListeners();

      print('Creating machine: name=$machineName, plant_id=$plantId');

      final machine = await _repository.createMachine(machineName, plantId);

      final matchedPlant = _plant.firstWhere(
        (plant) => plant.id == plantId,
        orElse: () => PlantId(id: plantId, plantName: '', plantCode: ''),
      );

      final machines = MachineElement(
        id: machine.id,
        name: machine.name,
        plantId: matchedPlant,
        createdBy: machine.createdBy,
        createdAt: machine.createdAt,
        isDeleted: false,
        updatedAt: DateTime.now(),
        v: 0,
      );

      _machines.insert(0, machines);
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

      print(
        'API response machine: id=${machine.id}, name=${machine.name}, '
        'createdBy=${machine.createdBy?.email}, createdAt=${machine.createdAt}',
      );

      final matchedPlant = _plant.firstWhere(
        (plant) => plant.id == plantId,
        orElse: () => PlantId(id: plantId, plantName: 'Unknown', plantCode: ''),
      );

      final updatedMachine = MachineElement(
        id: machine.id,
        name: machine.name,
        plantId: matchedPlant,
        createdBy: machine.createdBy,
        createdAt: machine.createdAt,
        isDeleted: false,
        updatedAt: DateTime.now(),
        v: machine.v,
      );

      print(
        'Updated machine: id=${updatedMachine.id}, name=${updatedMachine.name}, '
        'plantName=${updatedMachine.plantId.plantName}, '
        'createdBy=${updatedMachine.createdBy?.email}, createdAt=${updatedMachine.createdAt}',
      );

      final index = _machines.indexWhere((m) => m.id == machineId);
      if (index != -1) {
        _machines.removeAt(index);
        _machines.insert(0, updatedMachine);
      } else {
        print(
          'Machine $machineId not found in local list, refreshing machines',
        );
        await loadAllMachines(refresh: true);
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

  // Fetch machine by ID
  Future<void> fetchMachine(String machineId) async {
    try {
      _isMachineLoading = true;
      _machineError = null;
      _currentMachine = null;
      notifyListeners();
      print('Fetching machine: id=$machineId');
      final machine = await _repository.getmachines(machineId);
      if (machine != null) {
        _currentMachine = machine;
        print('Fetched machine: ${machine.id} - ${machine.name}');
      } else {
        _machineError = 'Machine not found';
        print('Machine $machineId not found');
      }
    } catch (e) {
      _machineError = _getErrorMessage(e);
      print('Error fetching machine: $_machineError');
    } finally {
      _isMachineLoading = false;
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

  // Clear machine-specific error
  void clearMachineError() {
    _machineError = null;
    _currentMachine = null;
    notifyListeners();
    print('Machine error cleared');
  }

  // Error conversion
  String _getErrorMessage(Object error) {
    if (error is Exception) return error.toString();
    if (error is String) return error;
    return 'An unexpected error occurred';
  }
}
