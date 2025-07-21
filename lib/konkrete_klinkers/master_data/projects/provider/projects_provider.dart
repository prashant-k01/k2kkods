import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/repo/plants.repo.dart';

class PlantProvider with ChangeNotifier {
  final PlantRepository _repository = PlantRepository();

  List<PlantModel> _plants = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  final int _limit = 10;
  String _searchQuery = '';

  // Loading states for specific operations
  bool _isAddPlantLoading = false;
  bool _isUpdatePlantLoading = false;
  bool _isDeletePlantLoading = false;

  // Getters
  List<PlantModel> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddPlantLoading => _isAddPlantLoading;
  bool get isUpdatePlantLoading => _isUpdatePlantLoading;
  bool get isDeletePlantLoading => _isDeletePlantLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;

  // Load plants for current page
  Future<void> loadAllPlants({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _plants.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading plants - Page: $_currentPage, Limit: $_limit, Search: $_searchQuery');

      final response = await _repository.getAllPlants(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _plants = response.plants;
      _updatePaginationInfo(response.pagination);
      _error = null;

      print('Loaded ${_plants.length} plants, Total: $_totalItems, Pages: $_totalPages');
    } catch (e) {
      _error = _getErrorMessage(e);
      _plants.clear();
      print('Error loading plants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load specific page
  Future<void> loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;

    _currentPage = page;
    await loadAllPlants();
  }

  // Go to next page
  Future<void> nextPage() async {
    if (!_hasNextPage) return;
    await loadPage(_currentPage + 1);
  }

  // Go to previous page
  Future<void> previousPage() async {
    if (!_hasPreviousPage) return;
    await loadPage(_currentPage - 1);
  }

  // Go to first page
  Future<void> firstPage() async {
    await loadPage(1);
  }

  // Go to last page
  Future<void> lastPage() async {
    await loadPage(_totalPages);
  }

  // Search plants
  Future<void> searchPlants(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadAllPlants();
  }

  // Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadAllPlants();
  }

  // Update pagination info
  void _updatePaginationInfo(PaginationInfo pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.hasNextPage;
    _hasPreviousPage = pagination.hasPreviousPage;
    notifyListeners();
  }

  Future<bool> createPlant(String plantCode, String plantName) async {
    _isAddPlantLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPlant = await _repository.createPlant(plantCode, plantName);

      if (newPlant.id.isNotEmpty) {
        _currentPage = 1;
        await loadAllPlants();
        return true;
      } else {
        return false;
      }
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
        await loadAllPlants();
        return true;
      } else {
        _error = 'Failed to update plant';
        return false;
      }
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
        if (_plants.length == 1 && _currentPage > 1) {
          _currentPage--;
        }
        await loadAllPlants();
        return true;
      } else {
        _error = 'Failed to delete plant';
        return false;
      }
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
      _error = null;
      final plant = await _repository.getPlant(plantId);
      return plant;
    } catch (e) {
      _error = _getErrorMessage(e);
      return null;
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

  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString();
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
    }
  }
}