import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/model/clients_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/repo/cleints.dart';

class ClientsProvider with ChangeNotifier {
  final ClientRepository _repository = ClientRepository();

  List<ClientsModel> _clients = [];
  bool _isLoading = false;
  String? _error;
  bool _showAll = false;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  final int _limit = 10;
  String _searchQuery = '';

  bool _isAddClientLoading = false;
  bool _isupdateClientsLoading = false;
  bool _isdeleteClientsLoading = false;

  List<ClientsModel> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddclientsLoading => _isAddClientLoading;
  bool get isupdateClientsLoading => _isupdateClientsLoading;
  bool get isdeleteClientsLoading => _isdeleteClientsLoading;
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
    loadAllClients(refresh: true);
  }

  // Load  for current page or all
  Future<void> loadAllClients({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _clients = []; // Clear existing  for refresh
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(
        'Loading Clients - Page: $_currentPage, Limit: ${_showAll ? "all" : _limit}, ShowAll: $_showAll',
      ); // Debug print

      final response = await _repository.getAllClients(
        page: _showAll ? 1 : _currentPage, // Use page 1 for show all
        limit: _showAll ? 1000 : _limit, // Use high limit for show all
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (_showAll) {
        _clients = response.clients; // Replace all clientss
        _totalPages = 1; // Single page for all data
        _totalItems = response.clients.length;
        _hasNextPage = false;
        _hasPreviousPage = false;
      } else {
        _clients = response.clients;
        _updatePaginationInfo(response.pagination);
      }
      _error = null;

      print(
        'Loaded ${_clients.length} clients, Total: $_totalItems, Pages: $_totalPages',
      ); // Debug print
    } catch (e) {
      _error = _getErrorMessage(e);
      _clients = [];
      print('Error loading clients: $e'); // Debug print
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load specific page
  Future<void> loadPage(int page) async {
    if (_showAll || page < 1 || page > _totalPages || page == _currentPage)
      return;

    print('Loading page: $page'); // Debug print
    _currentPage = page;
    await loadAllClients();
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

  Future<void> searchClients(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadAllClients();
  }

  // Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadAllClients();
  }

  // Update pagination info
  void _updatePaginationInfo(PaginationInfo pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _hasNextPage = pagination.hasNextPage;
    _hasPreviousPage = pagination.hasPreviousPage;
  }


  Future<bool> createClient(String address, String name) async {
    _isAddClientLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPlant = await _repository.createClient(address, name);

      if (newPlant.id.isNotEmpty) {
        // After creating, go to first page to show the new plant
        _currentPage = 1;
        await loadAllClients();
        return true;
      } else {
        _error = 'Failed to create client - no ID returned';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    } finally {
      _isAddClientLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClients(
    String clientsId,
    String address,
    String name,
  ) async {
    _isupdateClientsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateClient(clientsId, address, name);

      if (success) {
        await loadAllClients();
        return true;
      } else {
        _error = 'Failed to update clients';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    } finally {
      _isupdateClientsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClients(String clientsId) async {
    _isdeleteClientsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteClient(clientsId);

      if (success) {
        // Only adjust pagination if deletion was successful
        final currentPageItemCount = _clients.length;
        final isLastItemOnPage = currentPageItemCount == 1;
        final isNotFirstPage = _currentPage > 1;

        if (isLastItemOnPage && isNotFirstPage && !_showAll) {
          // Go to previous page if current page will be empty
          _currentPage--;
        }

        // Refresh current page
        await loadAllClients();
        return true;
      } else {
        _error = 'Failed to delete clients';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    } finally {
      _isdeleteClientsLoading = false;
      notifyListeners();
    }
  }

  Future<ClientsModel?> getClients(String clientsId) async {
    try {
      _error = null; // Clear error locally, no need to notify
      final clients = await _repository.getClients(clientsId);
      return clients;
    } catch (e) {
      _error = _getErrorMessage(e); // Set error locally, no need to notify
      return null;
    }
  }

  ClientsModel? getClientsByIndex(int index) {
    if (index >= 0 && index < _clients.length) {
      return _clients[index];
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
