import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/repo/plants.repo.dart';

class PlantProvider with ChangeNotifier {
  final PlantRepository _repository = PlantRepository();

  List<PlantModel> _plants = [];
  bool _isLoading = false;
  String? _error;
  bool _showAll = false; // Flag to indicate if all data should be shown

  // Pagination properties
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
  bool get showAll => _showAll;

  // Pagination getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;

  // Toggle between paginated and show all modes
  void toggleShowAll(bool value) {
    _showAll = value;
    _currentPage = 1;
    notifyListeners();
    loadAllPlants(refresh: true);
  }

  // Load plants for current page or all plants
  Future<void> loadAllPlants({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _plants = []; // Clear existing plants for refresh
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'Loading plants - Page: $_currentPage, Limit: ${_showAll ? "all" : _limit}, ShowAll: $_showAll',
      ); // Debug print

      final response = await _repository.getAllPlants(
        page: _showAll ? 1 : _currentPage, // Use page 1 for show all
        limit: _showAll ? 1000 : _limit,   // Use high limit for show all
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (_showAll) {
        _plants = response.plants; // Replace all plants
        _totalPages = 1; // Single page for all data
        _totalItems = response.plants.length;
        _hasNextPage = false;
        _hasPreviousPage = false;
      } else {
        _plants = response.plants;
        _updatePaginationInfo(response.pagination);
      }
      _error = null;

      print(
        'Loaded ${_plants.length} plants, Total: $_totalItems, Pages: $_totalPages',
      ); // Debug print
    } catch (e) {
      _error = _getErrorMessage(e);
      _plants = [];
      print('Error loading plants: $e'); // Debug print
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load specific page
  Future<void> loadPage(int page) async {
    if (_showAll || page < 1 || page > _totalPages || page == _currentPage) return;

    print('Loading page: $page'); // Debug print
    _currentPage = page;
    await loadAllPlants();
  }

  // Go to next page
  Future<void> nextPage() async {
    if (_showAll || !_hasNextPage) return;
    await loadPage(_currentPage + 1);
  }

  // Go to previous page
  Future<void> previousPage() async {
    if (_showAll || !_hasPreviousPage) return;
    await loadPage(_currentPage - 1);
  }

  // Go to first page
  Future<void> firstPage() async {
    if (_showAll) return;
    await loadPage(1);
  }

  // Go to last page
  Future<void> lastPage() async {
    if (_showAll) return;
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
    _hasNextPage = pagination.hasNextPage;
    _hasPreviousPage = pagination.hasPreviousPage;
  }

  Future<bool> createPlant(String plantCode, String plantName) async {
    _isAddPlantLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPlant = await _repository.createPlant(plantCode, plantName);

      if (newPlant.id.isNotEmpty) {
        // After creating, go to first page to show the new plant
        _currentPage = 1;
        await loadAllPlants();
        return true;
      } else {
        _error = 'Failed to create plant - no ID returned';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
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
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
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
      // Only adjust pagination if deletion was successful
      final currentPageItemCount = _plants.length;
      final isLastItemOnPage = currentPageItemCount == 1;
      final isNotFirstPage = _currentPage > 1;

      if (isLastItemOnPage && isNotFirstPage && !_showAll) {
        // Go to previous page if current page will be empty
        _currentPage--;
      }

      // Refresh current page
      await loadAllPlants();
      return true;
    } else {
      _error = 'Failed to delete plant';
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = _getErrorMessage(e);
    notifyListeners();
    return false;
  } finally {
    _isDeletePlantLoading = false;
    notifyListeners();
  }
}
Future<PlantModel?> getPlant(String plantId) async {
  try {
    _error = null; // Clear error locally, no need to notify
    final plant = await _repository.getPlant(plantId);
    return plant;
  } catch (e) {
    _error = _getErrorMessage(e); // Set error locally, no need to notify
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
