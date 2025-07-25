import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/model/product.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/repo/product_repo.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<ProductModel> _products = [];
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
  bool _isAddProductLoading = false;
  bool _isUpdateProductLoading = false;
  bool _isDeleteProductLoading = false;

  // Edit form specific states
  bool _isInitialized = false;
  String? _errorMessage;
  ProductModel? _product;
  Map<String, dynamic> _initialValues = {};
  bool _showAreaPerUnit = true;

  // Getters
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddProductLoading => _isAddProductLoading;
  bool get isUpdateProductLoading => _isUpdateProductLoading;
  bool get isDeleteProductLoading => _isDeleteProductLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  bool get hasNextPage => _hasNextPage;
  bool get hasPreviousPage => _hasPreviousPage;
  int get limit => _limit;
  String get searchQuery => _searchQuery;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  ProductModel? get product => _product;
  Map<String, dynamic> get initialValues => _initialValues;
  bool get showAreaPerUnit => _showAreaPerUnit;

  Future<void> initializeEditForm(String productId) async {
    _isInitialized = false;
    _errorMessage = null;
    _product = null;
    _initialValues = {};
    notifyListeners();

    final plantProvider = PlantProvider(); // Note: This should ideally be injected
    await plantProvider.loadAllPlantsForDropdown();

    if (productId.isEmpty) {
      _errorMessage = 'Invalid product ID';
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      if (plantProvider.allPlants.isEmpty) {
        _errorMessage = 'No plants available';
        _isInitialized = true;
        notifyListeners();
        return;
      }

      _product = await _repository.getProduct(productId);
      if (_product == null) {
        _errorMessage = _error ?? 'Product not found';
        _isInitialized = true;
        notifyListeners();
        return;
      }

      final selectedPlant = plantProvider.allPlants.firstWhere(
        (plant) => plant.id == _product!.plant.id,
        orElse: () => plantProvider.allPlants.first,
      );

      final plantName = selectedPlant.plantName.isNotEmpty
          ? selectedPlant.plantName
          : 'Unknown Plant';

      final uomValue = _product!.uom.isNotEmpty ? _product!.uom.first : 'Square Meter/No';

      _initialValues = {
        'plant': plantName,
        'material_code': _product!.materialCode,
        'description': _product!.description,
        'no_of_pieces_per_punch': _product!.noOfPiecesPerPunch.toString(),
        'uom': uomValue,
        'area_per_unit': _product!.areas[uomValue]?.toStringAsFixed(4) ?? '',
        'qty_in_bundle': _product!.qtyInBundle.toString(),
      };

      _showAreaPerUnit = uomValue.contains("Square Meter/No");
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      _isInitialized = true;
      notifyListeners();
    }
  }

  void setShowAreaPerUnit(bool value) {
    _showAreaPerUnit = value;
    notifyListeners();
  }

  double? calculateArea(String description) {
    try {
      final RegExp dimensionRegex = RegExp(
        r'(\d+)X(\d+)X(\d+)MM',
        caseSensitive: false,
      );
      final match = dimensionRegex.firstMatch(description);

      if (match != null) {
        final length = double.parse(match.group(1)!);
        final width = double.parse(match.group(2)!);
        return (length / 1000) * (width / 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadAllProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAllProduct(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (!refresh) {
        _products.clear();
      }
      _products = response.data;
      _updatePaginationInfo(response.pagination);
      _error = null;

      if (_products.length > _limit) {
        _products = _products.take(_limit).toList();
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      _products.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;

    _currentPage = page;
    await loadAllProducts();
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

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadAllProducts(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadAllProducts(refresh: true);
  }

  void _updatePaginationInfo(Pagination pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.page < pagination.totalPages;
    _hasPreviousPage = pagination.page > 1;
    notifyListeners();
  }

  Future<bool> createProduct({
    required String plantId,
    required String materialCode,
    required String description,
    required List<String> uom,
    required Map<String, double> areas,
    required int noOfPiecesPerPunch,
    required int qtyInBundle,
  }) async {
    _isAddProductLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProduct = await _repository.createProduct(
        plantId: plantId,
        materialCode: materialCode,
        description: description,
        uom: uom,
        areas: areas,
        noOfPiecesPerPunch: noOfPiecesPerPunch,
        qtyInBundle: qtyInBundle,
      );

      if (newProduct.id.isNotEmpty) {
        _currentPage = 1;
        await loadAllProducts(refresh: true);
        return true;
      } else {
        _error = 'Failed to create product: Invalid response';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isAddProductLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct({
    required String productId,
    required String plantId,
    required String materialCode,
    required String description,
    required List<String> uom,
    required Map<String, double> areas,
    required int noOfPiecesPerPunch,
    required int qtyInBundle,
  }) async {
    _isUpdateProductLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateProduct(
        productId: productId,
        plantId: plantId,
        materialCode: materialCode,
        description: description,
        uom: uom,
        areas: areas,
        noOfPiecesPerPunch: noOfPiecesPerPunch,
        qtyInBundle: qtyInBundle,
      );

      if (success) {
        await loadAllProducts(refresh: true);
        return true;
      } else {
        _error = 'Failed to update Product';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdateProductLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    _isDeleteProductLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteProduct(productId);

      if (success) {
        if (_products.length == 1 && _currentPage > 1) {
          _currentPage--;
        }
        await loadAllProducts(refresh: true);
        return true;
      } else {
        _error = 'Failed to delete Product';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeleteProductLoading = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> getProduct(String productId) async {
    try {
      _error = null;
      final product = await _repository.getProduct(productId);
      return product;
    } catch (e) {
      _error = _getErrorMessage(e);
      return null;
    }
  }

  ProductModel? getProductByIndex(int index) {
    if (index >= 0 && index < _products.length) {
      return _products[index];
    }
    return null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
    }
  }
}