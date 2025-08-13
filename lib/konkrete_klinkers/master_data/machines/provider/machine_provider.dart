import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/repo/machines.dart';
<<<<<<< HEAD

class MachinesProvider with ChangeNotifier {
  final MachineRepository _repository = MachineRepository();
=======
import 'package:k2k/konkrete_klinkers/master_data/machines/repo/plants.dart';

class MachinesProvider with ChangeNotifier {
  final MachineRepository _repository;

  MachinesProvider({MachineRepository? repository})
    : _repository = repository ?? MachineRepository();

  final Map<String, CreatedBy> _userCache = {};
  final Map<String, PlantId> _plantCache = {};
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76

  List<MachineElement> _machines = [];
  bool _isLoading = false;
  String? _error;
<<<<<<< HEAD

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  final int _limit = 10;

  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  String _searchQuery = '';

=======
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 10;
  String _searchQuery = '';
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
  bool _isAddMachineLoading = false;
  bool _isUpdateMachinesLoading = false;
  bool _isDeleteMachinesLoading = false;

<<<<<<< HEAD
=======
  List<PlantId> _plants = [];

  void setPlants(List<PlantId> plants) {
    _plants = plants;
  }

>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
  // Getters
  List<MachineElement> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;
<<<<<<< HEAD
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
=======
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
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
<<<<<<< HEAD
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
=======
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
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
      }

      if (refresh) {
        _machines = response.machines;
      } else {
        _machines.addAll(response.machines);
      }
<<<<<<< HEAD
      _updatePaginationInfo(response.pagination);
=======

      _skip = _machines.length;
      _hasMore = response.machines.length == _limit;
      print('Has more machines to load: $_hasMore');
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error loading machines: $_error');
      if (refresh) _machines.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

<<<<<<< HEAD
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
=======
  // Search
  Future<void> searchMachines(String query) async {
    _searchQuery = query;
    _hasMore = true;
    _skip = 0;
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
    print('Searching machines with query: $query');
    await loadAllMachines(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
<<<<<<< HEAD
    _currentPage = 1;
=======
    _hasMore = true;
    _skip = 0;
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
    print('Clearing search query');
    await loadAllMachines(refresh: true);
  }

<<<<<<< HEAD
  // Create machine
  Future<bool> createMachine(String name, String plantId) async {
=======
  final PlantRepository _plantRepository = PlantRepository();

  List<PlantId> _plant = [];
  bool _isAllPlantsLoading = false;

  bool get isAllPlantsLoading => _isAllPlantsLoading;
  List<PlantId> get plant => _plant;
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
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
    try {
      _isAddMachineLoading = true;
      _error = null;
      notifyListeners();

<<<<<<< HEAD
      print('Creating machine: name=$name, plantId=$plantId');
      final machine = await _repository.createMachine(name, plantId);

      print('Created machine: ${machine.id} - ${machine.name}');
      _machines.insert(0, machine);
      _totalItems++;
      _totalPages = (_totalItems / _limit).ceil();
      _hasNextPage = _currentPage < _totalPages;
      notifyListeners();
=======
      print('Creating machine: name=$machineName, plant_id=$plantId');

      final machine = await _repository.createMachine(machineName, plantId);

      // ✅ Attach plant details from existing plant list
      final matchedPlant = _plants.firstWhere(
        (plant) => plant.id == plantId,
        orElse: () => PlantId(id: plantId, plantName: '', plantCode: ''),
      );

      // ✅ Set plant details
      final machines = MachineElement(
        id: machine.id,
        name: machine.name,
        plantId: matchedPlant, // Use the full PlantId object
        createdBy: machine.createdBy,
        createdAt: machine.createdAt,
        isDeleted: false,
        updatedAt: DateTime.now(),
        v: 0,
      );

      // ✅ Insert at top of the list
      _machines.insert(0, machines);
      notifyListeners();

      print('Created machine: ${machine.id} - ${machine.name}');
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
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

<<<<<<< HEAD
  // Update machine
  Future<bool> updateMachines(
    String machineId,
    String name,
    PlantId plantId,
=======
  Future<bool> updateMachines(
    String machineId,
    String machineName,
    String plantId,
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
  ) async {
    _isUpdateMachinesLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
<<<<<<< HEAD
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
=======
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

      // Find existing machine to preserve createdBy and createdAt
      _machines.firstWhere(
        (m) => m.id == machineId,
        orElse: () => MachineElement(
          id: machineId,
          name: machineName,
          plantId: matchedPlant,
          createdBy: CreatedBy(id: '', email: 'Unknown'),
          createdAt: DateTime.now(),
          isDeleted: false,
          updatedAt: DateTime.now(),
          v: 0,
        ),
      );

      // Create updated machine with full details
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

>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
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
<<<<<<< HEAD
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
=======
        notifyListeners();
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
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

<<<<<<< HEAD
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

=======
>>>>>>> 9ab28403e64048bb612375b1b7801023a8ba2d76
  // Error conversion
  String _getErrorMessage(Object error) {
    if (error is Exception) return error.toString();
    if (error is String) return error;
    return 'An unexpected error occurred';
  }
}
