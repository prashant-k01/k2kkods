import 'package:flutter/material.dart';
import 'package:k2k/Iron_smith/master_data/machines/model/machines.dart';
import 'package:k2k/Iron_smith/master_data/machines/repo/machine_repo.dart';

class IsMachinesProvider with ChangeNotifier {
  final MachinesRepository _repository = MachinesRepository();
  List<Machines> _machines = [];
  bool _isLoading = false;
  String? _error;

  List<Machines> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMachines({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _machines.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newMachines = await _repository.fetchMachines();
      _machines.addAll(newMachines);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMachine(Machines machine) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.addMachine(machine);
      _error = null;
      await fetchMachines(refresh: true);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
