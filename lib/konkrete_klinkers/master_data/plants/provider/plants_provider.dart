import 'dart:io';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/repo/plants.repo.dart';

class PlantProvider with ChangeNotifier {
  final PlantRepository _repository = PlantRepository();

  List<PlantModel> _plants = [];
  List<PlantModel> _allPlants = [];
  bool _isLoading = false;
  bool _isAllPlantsLoading = false;
  String? _error;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 10;
  String _searchQuery = '';
  bool _isAddPlantLoading = false;
  bool _isUpdatePlantLoading = false;
  bool _isDeletePlantLoading = false;
  bool _isPlantLoading = false; // New: For single plant loading
  PlantModel? _currentPlant; // New: For single plant data
  String? _plantError; // New: For single plant error

  // Getters
  List<PlantModel> get plants => _plants;
  List<PlantModel> get allPlants => _allPlants;
  bool get isLoading => _isLoading;
  bool get isAllPlantsLoading => _isAllPlantsLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  bool get isAddPlantLoading => _isAddPlantLoading;
  bool get isUpdatePlantLoading => _isUpdatePlantLoading;
  bool get isDeletePlantLoading => _isDeletePlantLoading;
  bool get isPlantLoading => _isPlantLoading;
  PlantModel? get currentPlant => _currentPlant;
  String? get plantError => _plantError;

  Future<void> loadPlants({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _skip = 0;
      _plants.clear();
      _hasMore = true;
    } else {
      _skip += _limit;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPlants = await _repository.getPlants(
        skip: _skip,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (refresh) {
        _plants = newPlants;
      } else {
        _plants.addAll(newPlants);
      }

      _hasMore = newPlants.length >= _limit;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllPlantsForDropdown({bool refresh = false}) async {
    if (_isAllPlantsLoading) return;

    if (refresh) {
      _allPlants.clear();
    }

    _isAllPlantsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final plants = await _repository.getPlants(
        skip: 0,
        limit: 100,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _allPlants = plants;
    } catch (e) {
      _error = _getErrorMessage(e);
      _allPlants.clear();
    } finally {
      _isAllPlantsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlant(String plantCode, String plantName) async {
    _isAddPlantLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPlant = await _repository.createPlant(plantCode, plantName);
      if (newPlant.id.isNotEmpty) {
        _skip = 0;
        await loadPlants(refresh: true);
        await loadAllPlantsForDropdown(refresh: true);
        return true;
      }
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isAddPlantLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePlant(
    String plantId,
    String plantCode,
    String plantName,
  ) async {
    _isUpdatePlantLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updatePlant(
        plantId,
        plantCode,
        plantName,
      );

      if (success) {
        await loadPlants(refresh: true);
        await loadAllPlantsForDropdown(refresh: true);
        return true;
      }
      _error = 'Failed to update plant';
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdatePlantLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePlant(String plantId) async {
    _isDeletePlantLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deletePlant(plantId);
      if (success) {
        await loadPlants(refresh: true);
        await loadAllPlantsForDropdown(refresh: true);
        return true;
      }
      _error = 'Failed to delete plant';
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeletePlantLoading = false;
      notifyListeners();
    }
  }

  Future<PlantModel?> getPlant(String plantId) async {
    try {
      _isPlantLoading = true;
      _plantError = null;
      _currentPlant = null;
      notifyListeners();

      final plant = await _repository.getPlant(plantId);
      _currentPlant = plant;
      if (plant == null) {
        _plantError = 'Plant not found';
      }
      return plant;
    } catch (e) {
      _plantError = _getErrorMessage(e);
      return null;
    } finally {
      _isPlantLoading = false;
      notifyListeners();
    }
  }

  PlantModel? getPlantByIndex(int index) {
    if (index >= 0 && index < _plants.length) {
      return _plants[index];
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearPlantError() {
    _plantError = null;
    _currentPlant = null;
    _isPlantLoading = false;
    notifyListeners();
  }

  Future<void> searchPlants(String query) async {
    _searchQuery = query;
    _skip = 0;
    _hasMore = true;
    await loadPlants(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _skip = 0;
    _hasMore = true;
    await loadPlants(refresh: true);
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      return 'Network error: $error';
    } else if (error is FormatException) {
      return 'Invalid response format. Please contact support.';
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      return error;
    }
    return 'Unexpected error occurred.';
  }
}
