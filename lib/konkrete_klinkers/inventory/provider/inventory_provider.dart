import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/inventory/model/inventory.dart';
import 'package:k2k/konkrete_klinkers/inventory/repo/inventory_repo.dart';

class InventoryProvider with ChangeNotifier {
  // Instantiate the repository inside the provider
  final InventoryRepository _repository = InventoryRepository();

  // Inventory list related state
  List<InventoryItem> _inventoryList = [];
  List<InventoryItem> get inventoryList => _inventoryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Product detail related state
  List<dynamic> _productDetails = [];
  List<dynamic> get productDetails => _productDetails;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

  String? _detailError;
  String? get detailError => _detailError;

  // Method to fetch inventory list
  Future<void> fetchInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _repository.getInventory();
      _inventoryList = items;
    } catch (e) {
      _error = e.toString();
      _inventoryList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New method to fetch product details by productId
  Future<void> fetchProductDetails(String productId) async {
    _isDetailLoading = true;
    _detailError = null;
    notifyListeners();

    try {
      final details = await _repository.getProductDetails(productId);
      _productDetails = details;
    } catch (e) {
      _productDetails = [];
      _detailError = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // Optional: method to clear detail state if needed
  void clearProductDetails() {
    _productDetails = [];
    _detailError = null;
    _isDetailLoading = false;
    notifyListeners();
  }
}
