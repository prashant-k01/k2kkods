import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/inventory/model/inventory.dart';
import 'package:k2k/konkrete_klinkers/inventory/repo/inventory_repo.dart';

class InventoryProvider with ChangeNotifier {
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

  // Tab controller and data loaded state
  bool _isDataLoaded = false;
  bool get isDataLoaded => _isDataLoaded;

  TabController? _tabController;
  TabController? get tabController => _tabController;

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

  // Method to fetch product details by productId and initialize tab controller
  Future<void> fetchProductDetails(
    String productId,
    TickerProvider vsync,
  ) async {
    _isDetailLoading = true;
    _detailError = null;
    _isDataLoaded = false;
    _tabController?.dispose(); // Dispose old controller if exists
    _tabController = null;
    notifyListeners();

    try {
      final details = await _repository.getProductDetails(productId);
      _productDetails = details;
      if (_productDetails.isNotEmpty) {
        _tabController = TabController(
          length: _productDetails.length,
          vsync: vsync,
        );
        _isDataLoaded = true;
      }
    } catch (e) {
      _productDetails = [];
      _detailError = e.toString();
      _isDataLoaded = false;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  // Method to clear product details and tab controller
  void clearProductDetails() {
    _productDetails = [];
    _detailError = null;
    _isDetailLoading = false;
    _isDataLoaded = false;
    _tabController?.dispose();
    _tabController = null;
    notifyListeners();
  }
}
