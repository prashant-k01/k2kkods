import 'package:flutter/material.dart';
import 'package:k2k/Iron_smith/master_data/machines/model/machines.dart';
import 'package:k2k/Iron_smith/master_data/machines/repo/machine_repo.dart';

class IsMachinesProvider with ChangeNotifier {
  final MachinesRepository _repository = MachinesRepository();
  List<Machines> _machines = [];
  bool _isLoading = false;
  String? _error;
  Machines? _selectedMachine;

  List<Machines> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Machines? get selectedMachine => _selectedMachine;

  Future<void> fetchMachines({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    print('fetchMachines - Starting fetch, refresh: $refresh');

    try {
      if (refresh) {
        _machines.clear();
        print('fetchMachines - Cleared machines list');
      }

      final newMachines = await _repository.fetchMachines();
      print('fetchMachines - Fetched ${newMachines.length} machines');
      _machines.addAll(newMachines);
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('fetchMachines - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('fetchMachines - Current machines count: ${_machines.length}');
    }
  }

  Future<void> addMachine(Machines machine) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    print('addMachine - Starting, machine: ${machine.name}, ${machine.role}');

    try {
      // Optimistically add to local list
      _machines.insert(0, machine);
      notifyListeners();
      print(
        'addMachine - Optimistically added, current count: ${_machines.length}',
      );

      await _repository.addMachine(machine);
      _error = null;
      print('addMachine - API call successful');
      await fetchMachines(refresh: true); // Sync with server
      print('addMachine - After fetch, current count: ${_machines.length}');
    } catch (e) {
      _error = e.toString();
      _machines.remove(machine); // Revert optimistic update
      print('addMachine - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMachineById(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    print('getMachineById - Starting, id: $id');

    try {
      final machine = await _repository.getMachineById(id);
      _selectedMachine = machine;
      _error = null;
      print(
        'getMachineById - Fetched machine: ${machine.name}, ${machine.role}',
      );
    } catch (e) {
      _error = e.toString();
      print('getMachineById - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMachine(
    String machineId,
    String machineName,
    String machineRole,
  ) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final index = _machines.indexWhere((m) => m.id?.oid == machineId);
      if (index != -1) {
        _machines[index] = Machines(
          id: _machines[index].id,
          name: machineName,
          role: machineRole,
          isDeleted: _machines[index].isDeleted,
          v: _machines[index].v,
          createdAt: _machines[index].createdAt,
        );
        notifyListeners();
      }

      await _repository.updateMachine(machineId, machineName, machineRole);
      _error = null;
      print('updateMachine - API call successful');
      await fetchMachines(refresh: true); // Sync with server
      print('updateMachine - After fetch, current count: ${_machines.length}');
      return true;
    } catch (e) {
      _error = e.toString();
      print('updateMachine - Error: $e');
      await fetchMachines(refresh: true); // Revert on error
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMachine(String id) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();
    print('deleteMachine - Starting, id: $id');

    try {
      // Optimistically remove from local list
      _machines.removeWhere((m) => m.id?.oid == id);
      notifyListeners();
      print(
        'deleteMachine - Optimistically removed, current count: ${_machines.length}',
      );

      await _repository.deleteMachine(id);
      _error = null;
      print('deleteMachine - API call successful');
      await fetchMachines(refresh: true); // Sync with server
      print('deleteMachine - After fetch, current count: ${_machines.length}');
      return true;
    } catch (e) {
      _error = e.toString();
      print('deleteMachine - Error: $e');
      await fetchMachines(refresh: true); // Revert on error
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedMachine() {
    _selectedMachine = null;
    notifyListeners();
    print('clearSelectedMachine - Cleared selected machine');
  }

  void clearError() {
    _error = null;
    notifyListeners();
    print('clearError - Cleared error');
  }
}
