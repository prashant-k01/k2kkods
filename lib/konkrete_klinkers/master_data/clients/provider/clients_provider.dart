import 'dart:io';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/model/clients_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/clients/repo/cleints.dart';

class ClientsProvider with ChangeNotifier {
  final ClientRepository _repository = ClientRepository();

  List<ClientsModel> _clients = [];
  List<ClientsModel> _allClients = [];
  bool _isLoading = false;
  bool _isAllClientsLoading = false;
  String? _error;
  bool _hasMore = true;
  int _skip = 0;
  final int _limit = 10;
  String _searchQuery = '';
  bool _isAddClientLoading = false;
  bool _isUpdateClientsLoading = false;
  bool _isDeleteClientsLoading = false;
  bool _isClientLoading = false; // New: For single client loading
  ClientsModel? _currentClient; // New: For single client data
  String? _clientError; // New: For single client error

  // Getters
  List<ClientsModel> get clients => _clients;
  List<ClientsModel> get allClients => _allClients;
  bool get isLoading => _isLoading;
  bool get isAllClientsLoading => _isAllClientsLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  bool get isAddClientsLoading => _isAddClientLoading;
  bool get isUpdateClientsLoading => _isUpdateClientsLoading;
  bool get isDeleteClientsLoading => _isDeleteClientsLoading;
  bool get isClientLoading => _isClientLoading;
  ClientsModel? get currentClient => _currentClient;
  String? get clientError => _clientError;

  Future<void> loadClients({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    if (refresh) {
      _skip = 0;
      _clients.clear();
      _hasMore = true;
    } else {
      _skip += _limit;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newClients = await _repository.getAllClients(
        skip: _skip,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (refresh) {
        _clients = newClients;
      } else {
        _clients.addAll(newClients);
      }

      _hasMore = newClients.length >= _limit;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllClientsForDropdown({bool refresh = false}) async {
    if (_isAllClientsLoading) return;

    if (refresh) {
      _allClients.clear();
    }

    _isAllClientsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final clients = await _repository.getAllClients(
        skip: 0,
        limit: 100,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _allClients = clients;
    } catch (e) {
      _error = _getErrorMessage(e);
      _allClients.clear();
    } finally {
      _isAllClientsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClient(String name, String address) async {
    _isAddClientLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newClient = await _repository.createClient(name, address);
      if (newClient.id.isNotEmpty) {
        _skip = 0;
        await loadClients(refresh: true);
        await loadAllClientsForDropdown(refresh: true);
        return true;
      }
      _error = 'Failed to create client - no ID returned';
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isAddClientLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClients(
    String clientId,
    String name,
    String address,
  ) async {
    _isUpdateClientsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateClient(clientId, name, address);
      if (success) {
        await loadClients(refresh: true);
        await loadAllClientsForDropdown(refresh: true);
        return true;
      }
      _error = 'Failed to update client';
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdateClientsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClients(String clientId) async {
    _isDeleteClientsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteClient(clientId);
      if (success) {
        await loadClients(refresh: true);
        await loadAllClientsForDropdown(refresh: true);
        return true;
      }
      _error = 'Failed to delete client';
      return false;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeleteClientsLoading = false;
      notifyListeners();
    }
  }

  Future<ClientsModel?> getClients(String clientId) async {
    try {
      _isClientLoading = true;
      _clientError = null;
      _currentClient = null;
      notifyListeners();

      final client = await _repository.getClients(clientId);
      _currentClient = client;
      if (client == null) {
        _clientError = 'Client not found';
      }
      return client;
    } catch (e) {
      _clientError = _getErrorMessage(e);
      return null;
    } finally {
      _isClientLoading = false;
      notifyListeners();
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

  void clearClientError() {
    _clientError = null;
    _currentClient = null;
    _isClientLoading = false;
    notifyListeners();
  }

  Future<void> searchClients(String query) async {
    _searchQuery = query;
    _skip = 0;
    _hasMore = true;
    await loadClients(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _skip = 0;
    _hasMore = true;
    await loadClients(refresh: true);
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
