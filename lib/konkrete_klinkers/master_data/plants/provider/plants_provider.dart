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
  List<PlantModel> get allPlants => _allPlants;
  bool get isLoading => _isLoading;
  bool get isAllPlantsLoading => _isAllPlantsLoading;
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

Future<void> loadAllPlants({bool refresh = false}) async {
  if (refresh) {
    _currentPage = 1;
    _plants.clear();
  }

  _isLoading = true;
  _error = null;
  print('Starting loadAllPlants, refresh=$refresh, page=$_currentPage'); // Debug
  notifyListeners();

  try {
    print('Fetching plants: page=$_currentPage, limit=$_limit, search=$_searchQuery');
    final response = await _repository.getAllPlants(
      page: _currentPage,
      limit: _limit,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    _plants = response.plants;
    _updatePaginationInfo(response.pagination);
    _error = null;
    print('Loaded ${_plants.length} plants: ${response.plants.map((p) => p.plantName).toList()}');
  } catch (e) {
    _error = _getErrorMessage(e);
    _plants.clear();
    print('Error in loadAllPlants: $e');
  } finally {
    _isLoading = false;
    print('Finished loadAllPlants, isLoading=$_isLoading, error=$_error');
    notifyListeners();
  }
} // Load all plants for dropdown without pagination
  Future<void> loadAllPlantsForDropdown({bool refresh = false}) async {
    if (refresh) {
      _allPlants.clear();
    }

    _isAllPlantsLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading all plants for dropdown');

      // Fetch all plants with a high limit to avoid pagination
      final response = await _repository.getAllPlants(
        page: 1,
        limit: 100, // High limit to fetch all plants in one request
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _allPlants = response.plants;
      _updatePaginationInfo(response.pagination);

      print(
        'Loaded ${_allPlants.length} plants for dropdown, PlantNames: ${_allPlants.map((p) => p.plantName).toList()}',
      );

      // Validate total items
      if (_allPlants.length != response.pagination.total) {
        print(
          'Warning: Loaded ${_allPlants.length} plants, but pagination indicates ${response.pagination.total} total items',
        );
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _allPlants.clear();
      print('Error loading all plants for dropdown: $e');
    } finally {
      _isAllPlantsLoading = false;
      notifyListeners();
    }
  }

  // Load specific page
  Future<void> loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) {
      print(
        'Invalid page request: page=$page, currentPage=$_currentPage, totalPages=$_totalPages',
      );
      return;
    }

    _currentPage = page;
    await loadAllPlants();
  }

  // Go to next page
  Future<void> nextPage() async {
    if (!_hasNextPage) {
      print('No next page available');
      return;
    }
    print('Navigating to next page: ${_currentPage + 1}');
    await loadPage(_currentPage + 1);
  }

  // Go to previous page
  Future<void> previousPage() async {
    if (!_hasPreviousPage) {
      print('No previous page available');
      return;
    }
    print('Navigating to previous page: ${_currentPage - 1}');
    await loadPage(_currentPage - 1);
  }

  // Go to first page
  Future<void> firstPage() async {
    print('Navigating to first page');
    await loadPage(1);
  }

  // Go to last page
  Future<void> lastPage() async {
    print('Navigating to last page: $_totalPages');
    await loadPage(_totalPages);
  }

  // Search plants
  Future<void> searchPlants(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    print('Searching plants with query: $query');
    await loadAllPlants();
  }

  // Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    print('Clearing search query');
    await loadAllPlants();
  }

  // Update pagination info
  void _updatePaginationInfo(PaginationInfo pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.hasNextPage;
    _hasPreviousPage = pagination.hasPreviousPage;
    print(
      'Pagination updated: page=$_currentPage, totalPages=$_totalPages, totalItems=$_totalItems, hasNextPage=$_hasNextPage, hasPreviousPage=$_hasPreviousPage',
    );
    notifyListeners();
  }

  Future<bool> createPlant(String plantCode, String plantName) async {
    _isAddPlantLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Creating plant: code=$plantCode, name=$plantName');
      final newPlant = await _repository.createPlant(plantCode, plantName);

      if (newPlant.id.isNotEmpty) {
        _currentPage = 1;
        await loadAllPlants();
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
      print('Updating plant: id=$plantId, code=$plantCode, name=$plantName');
      final success = await _repository.updatePlant(
        plantId,
        plantCode,
        plantName,
      );

      if (success) {
        await loadAllPlants();
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
      print('Deleting plant: id=$plantId');
      final success = await _repository.deletePlant(plantId);

      if (success) {
        if (_plants.length == 1 && _currentPage > 1) {
          _currentPage--;
        }
        await loadAllPlants();
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
      print('Fetching plant: id=$plantId');
      final plant = await _repository.getPlant(plantId);
      if (plant != null) {
        print('Fetched plant: ${plant.plantName} (${plant.id})');
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
    print('Invalid index for getPlantByIndex: $index');
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
    print('Error cleared');
  }

  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString();
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
}}
}