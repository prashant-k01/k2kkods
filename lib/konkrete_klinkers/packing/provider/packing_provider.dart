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
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  String? _selectedWorkOrderId;
  String? _selectedProductId;
  int? _bundleSize; // Store the fetched bundle size

  List<PackingModel> get packings => _packings;
  List<Map<String, String>> get workOrders => _workOrders;
  List<Map<String, String>> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String? get selectedWorkOrderId => _selectedWorkOrderId;
  String? get selectedProductId => _selectedProductId;
  int? get bundleSize => _bundleSize;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _packings = [];
    _workOrders = [];
    _products = [];
    _bundleSize = null;

    _isLoading = false;
    _error = null;
    _hasMore = true;
    _selectedWorkOrderId = null;
    _selectedProductId = null;
    notifyListeners();
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
        _packings.addAll(newPackings);
      }
      _hasMore = newPackings.isNotEmpty;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      if (refresh) _packings = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkOrdersAndProducts() async {
    try {
      _workOrders = await _repository.getWorkOrders();
      _products = [];
      _selectedWorkOrderId = null;
      _selectedProductId = null;
      _bundleSize = null;
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

  void selectWorkOrder(String? value, GlobalKey<FormBuilderState> formKey) {
    if (value != null) {
      final selectedWorkOrder = _workOrders.firstWhere(
        (wo) => wo['number'] == value,
        orElse: () => {'id': '', 'number': ''},
      );
      _selectedWorkOrderId = selectedWorkOrder['id'];
      _selectedProductId = null;
      _bundleSize = null; // Reset bundle size when work order changes

      // Clear dependent fields
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

  Future<void> createPacking(Map<String, dynamic> packingData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final packing = await _repository.createPacking(packingData);
      _packings.add(packing); // Add the new packing to the list
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProduct(
    String? value,
    GlobalKey<FormBuilderState> formKey,
  ) async {
    print('selectProduct called with value: $value'); // Debug log
    print('Current products list: $_products'); // Debug log

    if (value != null && value.isNotEmpty) {
      final selectedProduct = _products.firstWhere(
        (product) => product['name'] == value,
        orElse: () {
          print('No product found with name: $value'); // Debug log
          return {'id': '', 'name': ''};
        },
      );

      _selectedProductId = selectedProduct['id'];
      print('Selected Product ID: $_selectedProductId'); // Debug log
      print('Selected Product: $selectedProduct'); // Debug log

      if (_selectedProductId != null && _selectedProductId!.isNotEmpty) {
        try {
          _isLoading = true;
          notifyListeners();

          _bundleSize = await _repository.getBundleSize(_selectedProductId!);
          print('Fetched Bundle Size: $_bundleSize'); // Debug log
          _error = null;

          // Update the form field with the fetched bundle size using WidgetsBinding
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (formKey.currentState != null && _bundleSize != null) {
              // Method 1: Try patchValue first
              try {
                formKey.currentState!.patchValue({
                  'bundle_size': _bundleSize.toString(),
                });
                print(
                  'Successfully patched bundle_size field with: ${_bundleSize.toString()}',
                );
              } catch (e) {
                print('patchValue failed, trying didChange: $e');
                // Method 2: Try didChange if patchValue fails
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
          print('Error fetching bundle size: $_error'); // Debug log

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
        print('No valid product ID, cleared bundle_size'); // Debug log
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
      print('Product value is null, cleared bundle_size'); // Debug log
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
