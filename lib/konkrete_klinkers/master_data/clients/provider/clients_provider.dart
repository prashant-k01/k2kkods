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

  // Getters
  List<ClientsModel> get clients => _clients;
  List<ClientsModel> get allClients => _allClients;
  bool get isLoading => _isLoading;
  bool get isAllClientsLoading => _isAllClientsLoading;
  String? get error => _error;
  bool get isAddClientsLoading => _isAddClientLoading;
  bool get isUpdateClientsLoading => _isUpdateClientsLoading;
  bool get isDeleteClientsLoading => _isDeleteClientsLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

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
    print('Starting loadClients, refresh=$refresh, skip=$_skip');
    notifyListeners();

    try {
      print('Fetching clients: skip=$_skip, limit=$_limit, search=$_searchQuery');
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
      print('Loaded ${newClients.length} clients, total: ${_clients.length}, hasMore: $_hasMore');
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error in loadClients: $e');
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
      print('Loading all clients for dropdown');
      final clients = await _repository.getAllClients(
        skip: 0,
        limit: 100,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _allClients = clients;
      print('Loaded ${_allClients.length} clients for dropdown');
    } catch (e) {
      _error = _getErrorMessage(e);
      _allClients.clear();
      print('Error loading all clients for dropdown: $e');
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
      print('Creating client: $name, $address');
      final newClient = await _repository.createClient(name, address);

      if (newClient.id.isNotEmpty) {
        _skip = 0;
        await loadClients(refresh: true);
        await loadAllClientsForDropdown(refresh: true);
        return true;
      } else {
        _error = 'Failed to create client - no ID returned';
        print('Failed to create client: Invalid response');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error creating client: $e');
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
      print('Updating client: $clientsId, $name, $address');
      final success = await _repository.updateClient(clientsId, name, address);

      if (success) {
        await loadClients(refresh: true);
        await loadAllClientsForDropdown(refresh: true);
        return true;
      } else {
        _error = 'Failed to update client';
        print('Failed to update client');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error updating client: $e');
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
      print('Deleting client: $clientsId');
      final success = await _repository.deleteClient(clientsId);

      if (success) {
        await loadClients(refresh: true);
        await loadAllClientsForDropdown(refresh: true);
        return true;
      } else {
        _error = 'Failed to delete client';
        print('Failed to delete client');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error deleting client: $e');
      return false;
    } finally {
      _isDeleteClientsLoading = false;
      notifyListeners();
    }
  }

  Future<ClientsModel?> getClients(String clientsId) async {
    try {
      _error = null;
      print('Fetching client: $clientsId');
      final client = await _repository.getClients(clientsId);
      if (client != null) {
        print('Loaded client: ${client.name}');
      } else {
        print('Client $clientsId not found');
      }
      return client;
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error fetching client: $e');
      return null;
    }
  }

  ClientsModel? getClientsByIndex(int index) {
    if (index >= 0 && index < _clients.length) {
      return _clients[index];
    }
    print('Invalid index: $index');
    return null;
    }

  void clearError() {
    _error = null;
    notifyListeners();
    print('Error cleared');
  }

  Future<void> searchClients(String query) async {
    _searchQuery = query;
    _skip = 0;
    _hasMore = true;
    print('Searching clients: $query');
    await loadClients(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _skip = 0;
    _hasMore = true;
    print('Clearing search');
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
    } else {
      return 'Unexpected error occurred.';
    }
  }
}