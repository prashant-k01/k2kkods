import 'package:flutter/material.dart';
import 'package:k2k/Iron_smith/master_data/clients/model/is_client_model.dart';
import 'package:k2k/Iron_smith/master_data/clients/repo/is_client_repo.dart';

class IsClientProvider with ChangeNotifier {
  final ClientsRepository _repository = ClientsRepository();
  List<IsClient> _clients = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedClientId;

  IsClient? _selectedClient;

  List<IsClient> get clients => _clients;
  String? get selectedClientId => _selectedClientId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  IsClient? get selectedClient => _selectedClient;

  Future<void> fetchClients({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (refresh) {
        _clients.clear();
      }
      final newClients = await _repository.fetchClients();
      print('fetchClients - Fetched ${newClients.length} clients');
      _clients = newClients;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('fetchClients - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('fetchClients - Current clients count: ${_clients.length}');
    }
  }

  Future<void> addClient(IsClient client) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    print('addClient - Starting, client: ${client.name}, ${client.address}');

    try {
      // Optimistically add to local list
      _clients.insert(0, client);
      notifyListeners();
      print(
        'addClient - Optimistically added, current count: ${_clients.length}',
      );

      await _repository.addClient(client);
      _error = null;
      print('addClient - API call successful');
      await fetchClients(refresh: true); // Sync with server
      print('addClient - After fetch, current count: ${_clients.length}');
    } catch (e) {
      _error = e.toString();
      _clients.remove(client); // Revert optimistic update
      print('addClient - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getClientById(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();
    print('getClientById - Starting, id: $id');

    try {
      final client = await _repository.getClientById(id);
      _selectedClient = client;
      _error = null;
      print(
        'getClientById - Fetched client: ${client.name}, ${client.address}',
      );
    } catch (e) {
      _error = e.toString();
      print('getClientById - Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClient(
    String clientId,
    String clientName,
    String clientAddress,
  ) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final index = _clients.indexWhere((c) => c.id == clientId);
      if (index != -1) {
        _clients[index] = IsClient(
          id: _clients[index].id,
          name: clientName,
          address: clientAddress,
          isDeleted: _clients[index].isDeleted,
          createdBy: _clients[index].createdBy,
          createdAt: _clients[index].createdAt,
          updatedAt: _clients[index].updatedAt,
          v: _clients[index].v,
        );
        notifyListeners();
      }

      await _repository.updateClient(clientId, clientName, clientAddress);
      _error = null;
      print('updateClient - API call successful');
      await fetchClients(refresh: true); // Sync with server
      print('updateClient - After fetch, current count: ${_clients.length}');
      return true;
    } catch (e) {
      _error = e.toString();
      print('updateClient - Error: $e');
      await fetchClients(refresh: true); // Revert on error
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClient(String id) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();
    print('deleteClient - Starting, id: $id');

    try {
      // Optimistically remove from local list
      _clients.removeWhere((c) => c.id == id);
      notifyListeners();
      print(
        'deleteClient - Optimistically removed, current count: ${_clients.length}',
      );

      await _repository.deleteClient(id);
      _error = null;
      print('deleteClient - API call successful');
      await fetchClients(refresh: true); // Sync with server
      print('deleteClient - After fetch, current count: ${_clients.length}');
      return true;
    } catch (e) {
      _error = e.toString();
      print('deleteClient - Error: $e');
      await fetchClients(refresh: true); // Revert on error
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedClient() {
    _selectedClient = null;
    notifyListeners();
    print('clearSelectedClient - Cleared selected client');
  }

  void clearError() {
    _error = null;
    notifyListeners();
    print('clearError - Cleared error');
  }

  Future<void> refreshClients() async {
    _clients = [];
    notifyListeners(); // optional, to clear UI immediately
    await fetchClients();
  }

  void setSelectedClient(String? clientId) {
    _selectedClientId = clientId;
    notifyListeners();
  }
}
