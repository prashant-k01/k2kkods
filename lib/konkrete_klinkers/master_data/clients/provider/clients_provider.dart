import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/model/clients_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/repo/cleints.dart';

class ClientsProvider with ChangeNotifier {
  final ClientRepository _repository = ClientRepository();

  List<ClientsModel> _clients = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  bool _hasNextPage = false;
  bool _hasPreviousPage = false;
  final int _limit = 10;
  String _searchQuery = '';

  bool _isAddClientLoading = false;
  bool _isUpdateClientsLoading = false;
  bool _isDeleteClientsLoading = false;

  List<ClientsModel> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddClientsLoading => _isAddClientLoading;
  bool get isUpdateClientsLoading => _isUpdateClientsLoading;
  bool get isDeleteClientsLoading => _isDeleteClientsLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;

  Future<void> loadAllClients({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _clients.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading clients - Page: $_currentPage, Limit: $_limit, Search: $_searchQuery');

      final response = await _repository.getAllClients(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _clients = response.clients;
      _updatePaginationInfo(response.pagination);
      _error = null;

      print('Loaded ${_clients.length} clients, Total: $_totalItems, Pages: $_totalPages');
    } catch (e) {
      _error = _getErrorMessage(e);
      _clients.clear();
      print('Error loading clients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;

    _currentPage = page;
    await loadAllClients();
  }

  Future<void> nextPage() async {
    if (!_hasNextPage) return;
    await loadPage(_currentPage + 1);
  }

  Future<void> previousPage() async {
    if (!_hasPreviousPage) return;
    await loadPage(_currentPage - 1);
  }

  Future<void> firstPage() async {
    await loadPage(1);
  }

  Future<void> lastPage() async {
    await loadPage(_totalPages);
  }

  Future<void> searchClients(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadAllClients();
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadAllClients();
  }

  void _updatePaginationInfo(PaginationInfo pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.hasNextPage;
    _hasPreviousPage = pagination.hasPreviousPage;
    notifyListeners();
  }

  Future<bool> createClient(String name, String address) async {
    _isAddClientLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newClient = await _repository.createClient(name, address);

      if (newClient.id.isNotEmpty) {
        _currentPage = 1;
        await loadAllClients();
        return true;
      } else {
        _error = 'Failed to create client - no ID returned';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isAddClientLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClients(
    String clientsId,
    String name,
    String address,
  ) async {
    _isUpdateClientsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateClient(clientsId, name, address);

      if (success) {
        await loadAllClients();
        return true;
      } else {
        _error = 'Failed to update client';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdateClientsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClients(String clientsId) async {
    _isDeleteClientsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteClient(clientsId);

      if (success) {
        if (_clients.length == 1 && _currentPage > 1) {
          _currentPage--;
        }
        await loadAllClients();
        return true;
      } else {
        _error = 'Failed to delete client';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeleteClientsLoading = false;
      notifyListeners();
    }
  }

  Future<ClientsModel?> getClients(String clientsId) async {
    try {
      _error = null;
      final client = await _repository.getClients(clientsId);
      return client;
    } catch (e) {
      _error = _getErrorMessage(e);
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