import 'dart:io';
import 'package:flutter/material.dart';
import 'package:k2k/konkrete_klinkers/packing/model/packing.dart';
import 'package:k2k/konkrete_klinkers/packing/repo/packing_repo.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class PackingProvider with ChangeNotifier {
  final PackingRepository _repository = PackingRepository();

  List<PackingModel> _packings = [];
  List<Map<String, String>> _workOrders = [];
  List<Map<String, String>> _products = [];
  List<Map<String, dynamic>> _packingDetails = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String? _selectedWorkOrderId;
  String? _selectedProductId;
  int? _bundleSize;
  String? _packingId;
  bool _showQrSection = false;

  // Getters
  List<PackingModel> get packings => _packings;
  List<Map<String, String>> get workOrders => _workOrders;
  List<Map<String, String>> get products => _products;
  List<Map<String, dynamic>> get packingDetails => _packingDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String? get selectedWorkOrderId => _selectedWorkOrderId;
  String? get selectedProductId => _selectedProductId;
  int? get bundleSize => _bundleSize;
  String? get packingId => _packingId;
  bool get showQrSection => _showQrSection;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _packings = [];
    _workOrders = [];
    _products = [];
    _packingDetails = [];
    _bundleSize = null;
    _isLoading = false;
    _error = null;
    _hasMore = true;
    _selectedWorkOrderId = null;
    _selectedProductId = null;
    _packingId = null;
    _showQrSection = false;
    notifyListeners();
  }

  Future<void> loadWorkOrdersAndProducts() async {
    try {
      _workOrders = await _repository.getWorkOrders();
      _products = [];
      _packingDetails = [];
      _selectedWorkOrderId = null;
      _selectedProductId = null;
      _bundleSize = null;
      _packingId = null;
      _showQrSection = false;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadProducts(String workOrderId) async {
    try {
      _products = await _repository.getProducts(workOrderId);
      _selectedProductId = null;
      _bundleSize = null;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      _products = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadPackingDetails(String workOrderId, String productId) async {
    _isLoading = true;
    _error = null;
    _packingDetails = []; // Clear previous details
    notifyListeners();

    try {
      _packingDetails = await _repository.getPackingDetails(workOrderId, productId);
      print('Loaded packing details: $_packingDetails');
      print('Number of packing details loaded: ${_packingDetails.length}');
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      _packingDetails = [];
      print('Error loading packing details: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectWorkOrder(String? value, GlobalKey<FormBuilderState> formKey) {
    if (value != null) {
      final selectedWorkOrder = _workOrders.firstWhere(
        (wo) => wo['number'] == value,
        orElse: () => {'id': '', 'number': ''},
      );
      _selectedWorkOrderId = selectedWorkOrder['id'];
      _selectedProductId = null;
      _bundleSize = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (formKey.currentState != null) {
          formKey.currentState!.fields['product_id']?.didChange(null);
          formKey.currentState!.fields['bundle_size']?.didChange(null);
        }
      });

      loadProducts(selectedWorkOrder['id']!);
    } else {
      _selectedWorkOrderId = null;
      _selectedProductId = null;
      _bundleSize = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (formKey.currentState != null) {
          formKey.currentState!.fields['product_id']?.didChange(null);
          formKey.currentState!.fields['bundle_size']?.didChange(null);
        }
      });

      _products = [];
    }
    notifyListeners();
  }

  Future<PackingModel> createPacking(Map<String, dynamic> packingData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final packing = await _repository.createPacking(packingData);
      _packings.add(packing);
      _packingId = packing.id;
      _showQrSection = true;
      _error = null;
      return packing;
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitQrCode(String packingId, String qrCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitQrCode(packingId, qrCode);
      _error = null;
      _packingId = null;
      _showQrSection = false;
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePacking(
    String packingId, {
    String? workOrderId,
    String? productId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting to delete packing with ID: $packingId');
      print('Current packings: ${_packings.map((p) => p.id).toList()}');

      final packingExists = _packings.any((p) => p.id == packingId);
      if (!packingExists) {
        throw Exception('Packing with ID $packingId not found in local list');
      }

      if (workOrderId == null || productId == null) {
        final packing = _packings.firstWhere(
          (p) => p.id == packingId,
          orElse: () => throw Exception('Packing not found'),
        );
        workOrderId = packing.workOrderId;
        productId = packing.productId;
        print('Resolved workOrderId: $workOrderId, productId: $productId');
      }

      final success = await _repository.deletePacking(
        packingId,
        workOrderId: workOrderId,
        productId: productId,
      );

      if (success) {
        print('Packing deleted successfully: $packingId');
        _packings.removeWhere((m) => m.id == packingId);
        print('Packings after removal: ${_packings.map((p) => p.id).toList()}');

        try {
          final newPackings = await _repository.getPackings();
          _packings = newPackings;
          _hasMore = newPackings.isNotEmpty;
          _error = null;
          print('Refreshed packings: ${_packings.map((p) => p.id).toList()}');
        } catch (e) {
          _error = _getErrorMessage(e);
          print('Error refreshing packings after deletion: $_error');
          _hasMore = _packings.isNotEmpty;
        }
        return true;
      } else {
        _error = 'Failed to delete packing';
        print('Error: Failed to delete packing');
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      print('Error deleting packing: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPackings({bool refresh = false}) async {
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    if (refresh) _error = null;
    notifyListeners();

    try {
      final newPackings = await _repository.getPackings();
      if (refresh) {
        _packings = newPackings;
      } else {
        final existingIds = _packings.map((p) => p.id).toSet();
        _packings.addAll(newPackings.where((p) => !existingIds.contains(p.id)));
      }
      _hasMore = newPackings.isNotEmpty;
      _error = null;
      print('Loaded packings: ${_packings.map((p) => p.id).toList()}');
    } catch (e) {
      _error = _getErrorMessage(e);
      if (refresh && _packings.isEmpty) {
        _packings = [];
      }
      print('Error loading packings: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProduct(
    String? value,
    GlobalKey<FormBuilderState> formKey,
  ) async {
    print('selectProduct called with value: $value');
    print('Current products list: $_products');

    if (value != null && value.isNotEmpty) {
      final selectedProduct = _products.firstWhere(
        (product) => product['name'] == value,
        orElse: () {
          print('No product found with name: $value');
          return {'id': '', 'name': ''};
        },
      );

      _selectedProductId = selectedProduct['id'];
      print('Selected Product ID: $_selectedProductId');
      print('Selected Product: $selectedProduct');

      if (_selectedProductId != null && _selectedProductId!.isNotEmpty) {
        try {
          _isLoading = true;
          notifyListeners();

          _bundleSize = await _repository.getBundleSize(_selectedProductId!);
          print('Fetched Bundle Size: $_bundleSize');
          _error = null;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (formKey.currentState != null && _bundleSize != null) {
              try {
                formKey.currentState!.patchValue({
                  'bundle_size': _bundleSize.toString(),
                });
                print(
                  'Successfully patched bundle_size field with: ${_bundleSize.toString()}',
                );
              } catch (e) {
                print('patchValue failed, trying didChange: $e');
                try {
                  formKey.currentState!.fields['bundle_size']?.didChange(
                    _bundleSize.toString(),
                  );
                  print('Successfully used didChange for bundle_size field');
                } catch (e2) {
                  print('didChange also failed: $e2');
                }
              }
            } else {
              print('Form key state is null or bundle size is null');
            }
          });
        } catch (e) {
          _error = _getErrorMessage(e);
          _bundleSize = null;
          print('Error fetching bundle size: $_error');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (formKey.currentState != null) {
              try {
                formKey.currentState!.patchValue({'bundle_size': null});
              } catch (e) {
                formKey.currentState!.fields['bundle_size']?.didChange(null);
              }
            }
          });
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _bundleSize = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (formKey.currentState != null) {
            try {
              formKey.currentState!.patchValue({'bundle_size': null});
            } catch (e) {
              formKey.currentState!.fields['bundle_size']?.didChange(null);
            }
          }
        });
        print('No valid product ID, cleared bundle_size');
      }
    } else {
      _selectedProductId = null;
      _bundleSize = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (formKey.currentState != null) {
          try {
            formKey.currentState!.patchValue({'bundle_size': null});
          } catch (e) {
            formKey.currentState!.fields['bundle_size']?.didChange(null);
          }
        }
      });
      print('Product value is null, cleared bundle_size');
    }
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is HttpException) {
      return 'Network error: ${error.message}';
    } else if (error is Exception) {
      String message = error.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      return message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}