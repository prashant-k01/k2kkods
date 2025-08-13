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

  // Loading states for specific operations
  bool _isAddPlantLoading = false;
  bool _isUpdatePlantLoading = false;
  bool _isDeletePlantLoading = false;

  // Getters
  List<PlantModel> get plants => _plants;
  List<PlantModel> get allPlants => _allPlants;
  bool get isLoading => _isLoading;
  bool get isAllPlantsLoading => _isAllPlantsLoading;
  String? get error => _error;
  bool get isAddPlantLoading => _isAddPlantLoading;
  bool get isUpdatePlantLoading => _isUpdatePlantLoading;
  bool get isDeletePlantLoading => _isDeletePlantLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

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
    print('Starting loadPlants, refresh=$refresh, skip=$_skip');
    notifyListeners();

    try {
      print('Fetching plants: skip=$_skip, limit=$_limit, search=$_searchQuery');
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
      print('Loaded ${newPlants.length} plants, total: ${_plants.length}, hasMore: $_hasMore');
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error in loadPlants: $e');
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
      print('Loading all plants for dropdown');
      final plants = await _repository.getPlants(
        skip: 0,
        limit: 100,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _allPlants = plants;
      print('Loaded ${_allPlants.length} plants for dropdown');
    } catch (e) {
      _error = _getErrorMessage(e);
      _allPlants.clear();
      print('Error loading all plants for dropdown: $e');
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
      print('Creating plant: $plantCode, $plantName');
      final newPlant = await _repository.createPlant(plantCode, plantName);

      if (newPlant.id.isNotEmpty) {
        _skip = 0;
        await loadPlants(refresh: true);
        await loadAllPlantsForDropdown(refresh: true);
        return true;
      } else {
        print('Failed to create plant: Invalid response');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error creating plant: $e');
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
      print('Updating plant: $plantId, $plantCode, $plantName');
      final success = await _repository.updatePlant(
        plantId,
        plantCode,
        plantName,
      );

      if (success) {
        await loadPlants(refresh: true);
        await loadAllPlantsForDropdown(refresh: true);
        return true;
      } else {
        _error = 'Failed to update plant';
        print('Failed to update plant');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error updating plant: $e');
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
      print('Deleting plant: $plantId');
      final success = await _repository.deletePlant(plantId);

      if (success) {
        await loadPlants(refresh: true);
        await loadAllPlantsForDropdown(refresh: true);
        return true;
      } else {
        _error = 'Failed to delete plant';
        print('Failed to delete plant');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error deleting plant: $e');
      return false;
    } finally {
      _isDeletePlantLoading = false;
      notifyListeners();
    }
  }

  Future<PlantModel?> getPlant(String plantId) async {
    try {
      _error = null;
      print('Fetching plant: $plantId');
      final plant = await _repository.getPlant(plantId);
      if (plant != null) {
        print('Loaded plant: ${plant.plantName}');
      } else {
        print('Plant $plantId not found');
      }
      return plant;
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error fetching plant: $e');
      return null;
    }
  }

  PlantModel? getPlantByIndex(int index) {
    if (index >= 0 && index < _plants.length) {
      return _plants[index];
    }
    print('Invalid index: $index');
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
    print('Error cleared');
  }

  Future<void> searchPlants(String query) async {
    _searchQuery = query;
    _skip = 0;
    _hasMore = true;
    print('Searching plants: $query');
    await loadPlants(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _skip = 0;
    _hasMore = true;
    print('Clearing search');
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
    } else {
      return 'Unexpected error occurred.';
    }
  }
}