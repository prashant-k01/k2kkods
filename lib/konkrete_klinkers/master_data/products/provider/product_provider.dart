import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/model/product.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/repo/product_repo.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String _searchQuery = '';

  bool _isAddProductLoading = false;
  bool _isUpdateProductLoading = false;
  bool _isDeleteProductLoading = false;

  bool _isInitialized = false;
  String? _errorMessage;
  ProductModel? _product;
  Map<String, dynamic> _initialValues = {};
  bool _showAreaPerUnit = true;
  List<Map<String, String>> _plants = [];

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddProductLoading => _isAddProductLoading;
  bool get isUpdateProductLoading => _isUpdateProductLoading;
  bool get isDeleteProductLoading => _isDeleteProductLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  ProductModel? get product => _product;
  Map<String, dynamic> get initialValues => _initialValues;
  bool get showAreaPerUnit => _showAreaPerUnit;
  List<Map<String, String>> get plants => _plants;

  Future<void> initializeEditForm(String productId) async {
    _isInitialized = false;
    _errorMessage = null;
    _product = null;
    _initialValues = {};
    _plants = [];
    notifyListeners();

    try {
      _plants = await _repository.getPlantsForDropdown();

      if (productId.isEmpty) {
        _isInitialized = true;
        notifyListeners();
        return;
      }

      if (_plants.isEmpty) {
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

      final selectedPlant = _plants.firstWhere(
        (plant) => plant['id'] == _product!.plant.id,
        orElse: () => _plants.isNotEmpty
            ? _plants.first
            : {'id': '', 'display': 'No Plant'},
      );

      final plantDisplay = selectedPlant['display']!.isNotEmpty
          ? selectedPlant['display']!
          : 'Unknown Plant';

      String uomValue = _product!.uom.isNotEmpty
          ? _product!.uom.first
          : 'Square Meter/No';

      if (uomValue.contains('Square M')) {
        uomValue = 'Square Meter/No';
      } else if (uomValue.contains('Meter') && !uomValue.contains('Square')) {
        uomValue = 'Meter/No';
      }

      _initialValues = {
        'plant': plantDisplay,
        'material_code': _product!.materialCode,
        'description': _product!.description,
        'no_of_pieces_per_punch': _product!.noOfPiecesPerPunch.toString(),
        'uom': uomValue,
        'area_per_unit':
            _product!.areas[_product!.uom.first]?.toStringAsFixed(4) ?? '',
        'qty_in_bundle': _product!.qtyInBundle.toString(),
      };

      _showAreaPerUnit = uomValue.contains("Square Meter/No");
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load data: ${_getErrorMessage(e)}';
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
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    if (refresh) {
      _products.clear();
      _hasMore = true;
      _error = null;
    }
    notifyListeners();

    try {
      final response = await _repository.getAllProduct(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (refresh) {
        _products.clear();
      }

      if (response.success && response.data.isNotEmpty) {
        _products.addAll(response.data);
        _hasMore = response.data.length == 10;
        _error = null;
      } else {
        _hasMore = false;
        _error = response.success
            ? null
            : (response.message.isNotEmpty
                  ? response.message
                  : 'Failed to load products');
      }
    } catch (e) {
      _hasMore = false;
      _error = _getErrorMessage(e);
      if (refresh) {
        _products.clear();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _hasMore = true;
    await loadAllProducts(refresh: true);
  }

  Future<void> clearSearch() async {
    _searchQuery = '';
    _hasMore = true;
    await loadAllProducts(refresh: true);
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
      String errorString = error.toString();
      errorString = errorString.replaceFirst('Exception: ', '');
      errorString = errorString.replaceFirst('FormatException: ', '');
      errorString = errorString.replaceFirst('TypeError: ', '');

      if (errorString.contains('{') ||
          errorString.contains('[') ||
          errorString.length > 100) {
        return 'Unable to load products. Please check your connection and try again.';
      }

      return errorString;
    } else if (error is String) {
      if (error.contains('{') || error.contains('[') || error.length > 100) {
        return 'Unable to load products. Please check your connection and try again.';
      }
      return error;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
