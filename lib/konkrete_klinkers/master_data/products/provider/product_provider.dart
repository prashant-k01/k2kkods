import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/model/product.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/repo/product_repo.dart';

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

  Future<void> loadAllProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Loading Products - Page: $_currentPage, Limit: $_limit, Search: $_searchQuery');

      final response = await _repository.getAllProduct(
        page: _currentPage,
        limit: _limit,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      _products = response.data;
      _updatePaginationInfo(response.pagination);
      _error = null;

      print('Loaded ${_products.length} Products, Total: $_totalItems, Pages: $_totalPages');
    } catch (e) {
      _error = _getErrorMessage(e);
      _products.clear();
      print('Error loading Products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load specific page
  Future<void> loadPage(int page) async {
    if (page < 1 || page > _totalPages || page == _currentPage) return;

    _currentPage = page;
    await loadAllProducts();
  }

  // Go to next page
  Future<void> nextPage() async {
    if (!_hasNextPage) return;
    await loadPage(_currentPage + 1);
  }

  // Go to previous page
  Future<void> previousPage() async {
    if (!_hasPreviousPage) return;
    await loadPage(_currentPage - 1);
  }

  // Go to first page
  Future<void> firstPage() async {
    await loadPage(1);
  }

  // Go to last page
  Future<void> lastPage() async {
    await loadPage(_totalPages);
  }

  // Search Products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    _currentPage = 1;
    await loadAllProducts();
  }

  // Clear search
  Future<void> clearSearch() async {
    _searchQuery = '';
    _currentPage = 1;
    await loadAllProducts();
  }

  // Update pagination info
  void _updatePaginationInfo(Pagination pagination) {
    _totalPages = pagination.totalPages;
    _totalItems = pagination.total;
    _currentPage = pagination.page;
    _hasNextPage = pagination.page < pagination.totalPages;
    _hasPreviousPage = pagination.page > 1;
    notifyListeners();
  }

  Future<bool> createProduct(String productCode, String productName) async {
    _isAddProductLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProduct = await _repository.createProduct(productCode, productName);

      if (newProduct.id.isNotEmpty) {
        _currentPage = 1;
        await loadAllProducts();
        return true;
      } else {
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

  Future<bool> updateProduct(
    String productId,
    String productCode,
    String productName,
  ) async {
    _isUpdateProductLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateProduct(
        productId,
        productCode,
        productName,
      );

      if (success) {
        await loadAllProducts();
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
        await loadAllProducts();
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