import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/repo/machines.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/repo/plants.repo.dart';

class MachinesProvider with ChangeNotifier {
  final MachineRepository _machineRepo;
  final PlantRepository _plantRepo;

  MachinesProvider({MachineRepository? machineRepo, PlantRepository? plantRepo})
    : _machineRepo = machineRepo ?? MachineRepository(),
      _plantRepo = plantRepo ?? PlantRepository();

  // ============================
  // State Variables
  // ============================
  List<Machine> _machines = [];
  List<PlantModel> _plants = [];

  bool _isLoading = false;
  bool _isAddLoading = false;
  bool _isUpdateLoading = false;
  bool _isDeleteLoading = false;

  String? _error;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 10;

  // Current Selected Machine
  // ============================
  Machine? _currentMachine;
  bool _isMachineLoading = false;
  String? _machineError;

  // ============================
  // Getters
  // ============================
  List<Machine> get machines => _machines;
  List<PlantModel> get plants => _plants;

  bool get isLoading => _isLoading;
  bool get isAddLoading => _isAddLoading;
  bool get isUpdateLoading => _isUpdateLoading;
  bool get isDeleteLoading => _isDeleteLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Machine? get currentMachine => _currentMachine;
  bool get isMachineLoading => _isMachineLoading;
  String? get machineError => _machineError;

  // ============================
  // Lazy Load Machines
  // ============================
  Future<void> loadMachines({bool refresh = false}) async {
    if (_isLoading || !hasMore && !refresh) return;

    if (refresh) {
      _machines.clear();
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final response = await _machineRepo.getAllMachines(
        limit: _limit,
        skip: _skip,
      );

      final List<Machine> newMachines = response.data ?? [];

      if (refresh) {
        _machines = newMachines;
      } else {
        _machines.addAll(newMachines);
      }

      _skip = _machines.length;
      _hasMore = newMachines.length == _limit;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a machine by ID (for edit screen)
  Future<void> getMachineById(String id) async {
    _isMachineLoading = true;
    _machineError = null;
    _currentMachine = null;
    notifyListeners();

    try {
      final machine = await _machineRepo.getMachine(id);
      if (machine != null) {
        _currentMachine = machine;
      } else {
        _machineError = 'Machine not found';
      }
    } catch (e) {
      _machineError = e.toString();
    } finally {
      _isMachineLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // Fetch Plants
  // ============================
  Future<void> loadPlants({bool refresh = false}) async {
    if (_plants.isNotEmpty && !refresh) return;

    _error = null;
    notifyListeners();

    try {
      final fetchedPlants = await _plantRepo.getPlants();
      _plants = fetchedPlants;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // ============================
  // Create Machine
  // ============================
  Future<bool> createMachine(String name, String plantId) async {
    _isAddLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMachine = await _machineRepo.createMachine(name, plantId);
      _machines.insert(0, newMachine); // add to top
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isAddLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // Update Machine
  // ============================
  Future<bool> updateMachine(String id, String name, String plantId) async {
    _isUpdateLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMachine = await _machineRepo.updateMachine(
        id,
        name,
        plantId,
      );
      final index = _machines.indexWhere((m) => m.id == id);
      if (index != -1) {
        _machines[index] = updatedMachine;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isUpdateLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // Delete Machine
  // ============================
  Future<bool> deleteMachine(String id) async {
    _isDeleteLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _machineRepo.deleteMachine(id);
      if (success) _machines.removeWhere((m) => m.id == id);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isDeleteLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // Clear Error
  // ============================
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentMachine() {
    _currentMachine = null;
    _machineError = null;
    notifyListeners();
  }
}
