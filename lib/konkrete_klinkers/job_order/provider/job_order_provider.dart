import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/konkrete_klinkers/job_order/model/job_order.dart';
import 'package:k2k/konkrete_klinkers/job_order/repo/job_order_repo.dart';
import 'package:k2k/common/widgets/snackbar.dart';

class JobOrderProvider with ChangeNotifier {
  final JobOrderRepository _repository = JobOrderRepository();

  List<JobOrderModel> _jobOrders = [];
  bool _isLoading = false;
  String? _error;
  bool _isAddJobOrderLoading = false;
  bool _isUpdateJobOrderLoading = false;
  bool _isDeleteJobOrderLoading = false;
  bool _isInitialized = false;
  JobOrderModel? _jobOrder;
  bool _showAreaPerUnit = true;

  bool _isFormLoading = true;
  String? _formError;

  List<String> _workOrderNumbers = [];
  List<Map<String, dynamic>> _workOrderDetails = [];
  List<Map<String, dynamic>> _products = [];
  String? _selectedWorkOrder;
  List<Map<String, dynamic>> _availableProducts = [];
  bool _isLoadingProducts = false;
  bool _isLoadingWorkOrderNumbers = false; // Ensure variable is defined
  final List<List<String>> _machineNames = [];
  Map<int, List<Map<String, dynamic>>> _machineDataByProduct = {};
  final List<bool> _isLoadingMachineNames = [];

  final Map<String, FocusNode> _focusNodes = {
    'work_order': FocusNode(),
    'sales_order_number': FocusNode(),
    'batch_number': FocusNode(),
  };
  final List<Map<String, FocusNode>> _productFocusNodes = [];

  // Getters
  List<JobOrderModel> get jobOrders => _jobOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAddJobOrderLoading => _isAddJobOrderLoading;
  bool get isUpdateJobOrderLoading => _isUpdateJobOrderLoading;
  bool get isDeleteJobOrderLoading => _isDeleteJobOrderLoading;
  bool get isInitialized => _isInitialized;
  JobOrderModel? get jobOrder => _jobOrder;
  bool get showAreaPerUnit => _showAreaPerUnit;
  bool get isFormLoading => _isFormLoading;
  String? get formError => _formError;
  List<String> get workOrderNumbers => _workOrderNumbers;
  bool get isLoadingWorkOrderNumbers => _isLoadingWorkOrderNumbers;
  List<Map<String, dynamic>> get workOrderDetails => _workOrderDetails;
  List<Map<String, dynamic>> get products => _products;
  String? get selectedWorkOrder => _selectedWorkOrder;
  List<Map<String, dynamic>> get availableProducts => _availableProducts;
  bool get isLoadingProducts => _isLoadingProducts;
  List<String> getMachineNamesForProduct(int index) =>
      index < _machineNames.length ? _machineNames[index] : [];
  List<Map<String, dynamic>>? getMachineDataForProduct(int index) =>
      _machineDataByProduct[index];
  bool isLoadingMachineNames(int index) => index < _isLoadingMachineNames.length
      ? _isLoadingMachineNames[index]
      : false;

  FocusNode getFocusNode(String field) => _focusNodes[field] ?? FocusNode();
  FocusNode? getProductFocusNode(int index, String field) =>
      index < _productFocusNodes.length
      ? _productFocusNodes[index][field]
      : null;

  void initializeProductFocusNodes(int count) {
    for (var map in _productFocusNodes) {
      map.forEach((_, node) => node.dispose());
    }
    _productFocusNodes.clear();
    for (var i = 0; i < count; i++) {
      _productFocusNodes.add({
        'product': FocusNode(),
        'machine_name': FocusNode(),
        'planned_quantity': FocusNode(),
      });
    }
    notifyListeners();
  }

  Future<void> initializeFormForCreate() async {
    _isFormLoading = true;
    _formError = null;
    _selectedWorkOrder = null;
    _products.clear();
    _availableProducts.clear();
    _machineNames.clear();
    _machineDataByProduct.clear();
    _isLoadingMachineNames.clear();
    notifyListeners();

    try {
      await loadWorkOrderDetails();
      addProductSection(); // Add an empty product section by default
      _isFormLoading = false;
      _formError = null;
    } catch (e) {
      _formError = _getErrorMessage(e);
      _isFormLoading = false;
    }
    notifyListeners();
  }

  Future<JobOrderModel?> getJobOrderById(String mongoId) async {
    try {
      _error = null;
      final jobOrder = await _repository.getJobOrderById(mongoId);
      _jobOrder = jobOrder;
      notifyListeners();
      return jobOrder;
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  Future<void> submitCreateForm(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
  ) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final formData = formKey.currentState!.value;
      try {
        final selectedWO = _workOrderDetails.firstWhere(
          (e) => e['work_order_number'] == formData['work_order'],
          orElse: () => {},
        );
        final workOrderId =
            selectedWO['id']?.toString() ?? selectedWO['_id']?.toString();
        if (workOrderId == null ||
            !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(workOrderId)) {
          context.showWarningSnackbar("Invalid work order selected.");
          return;
        }

        final products = <Map<String, dynamic>>[];
        for (int index = 0; index < _products.length; index++) {
          final productData = _products[index];
          final productValue = formData['product_$index'];
          final selectedProduct = _availableProducts.firstWhere((product) {
            final description =
                product['description']?.toString() ?? 'No Description';
            final materialCode =
                product['material_code']?.toString() ?? 'No Code';
            return '$description - $materialCode' == productValue;
          }, orElse: () => {});
          final productId =
              productData['product_id']?.toString() ??
              selectedProduct['product_id']?.toString() ??
              selectedProduct['_id']?.toString();
          if (productId == null ||
              !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(productId)) {
            context.showWarningSnackbar(
              "Invalid product ID for product ${index + 1}.",
            );
            return;
          }

          final machineDisplayName = formData['machine_name_$index']
              ?.toString();
          if (machineDisplayName == null || machineDisplayName.isEmpty) {
            context.showWarningSnackbar(
              "Please select a machine for product ${index + 1}.",
            );
            return;
          }

          final machineData = getMachineDataForProduct(index);
          if (machineData == null || machineData.isEmpty) {
            context.showWarningSnackbar(
              "No machine data available for product ${index + 1}.",
            );
            return;
          }

          final selectedMachine = machineData.firstWhere(
            (machine) => machine['name']?.toString() == machineDisplayName,
            orElse: () => {},
          );
          final machineId =
              selectedMachine['id']?.toString() ??
              selectedMachine['_id']?.toString();
          if (machineId == null ||
              !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(machineId)) {
            context.showWarningSnackbar(
              "Invalid machine ID for product ${index + 1}.",
            );
            return;
          }

          final scheduledDate = formData['planned_date_$index'];
          String formattedScheduledDate = '';
          if (scheduledDate is DateTime) {
            formattedScheduledDate = scheduledDate.toUtc().toIso8601String();
          } else if (scheduledDate != null) {
            try {
              final parsedDate = DateTime.parse(
                scheduledDate.toString(),
              ).toUtc();
              formattedScheduledDate = parsedDate.toIso8601String();
            } catch (e) {
              context.showWarningSnackbar(
                "Invalid scheduled date format for product ${index + 1}.",
              );
              return;
            }
          } else {
            context.showWarningSnackbar(
              "Scheduled date is required for product ${index + 1}.",
            );
            return;
          }

          final plannedQuantityStr =
              formData['planned_quantity_$index']?.toString() ?? '0';
          final plannedQuantity = int.tryParse(plannedQuantityStr) ?? 0;
          if (plannedQuantity <= 0) {
            context.showWarningSnackbar(
              "Planned quantity must be greater than 0 for product ${index + 1}.",
            );
            return;
          }

          final uom = formData['uom_$index'];
          final formattedUom = uom == 'Square Meter/No'
              ? 'sqmt'
              : uom == 'Meter/No'
              ? 'meter'
              : null;

          products.add({
            'product': productId,
            'machine_name': machineId,
            'planned_quantity': plannedQuantity,
            'scheduled_date': formattedScheduledDate,
            'uom': formattedUom,
          });
        }
        if (products.isEmpty) {
          context.showWarningSnackbar("At least one product is required.");
          return;
        }

        final dateRange = formData['date_range'] as DateTimeRange?;
        if (dateRange == null) {
          context.showWarningSnackbar("Please select a date range.");
          return;
        }

        final batchNumberStr = formData['batch_number']?.toString() ?? '0';
        final batchNumber = int.tryParse(batchNumberStr) ?? 0;
        if (batchNumber <= 0) {
          context.showWarningSnackbar("Please enter a valid batch number.");
          return;
        }

        final payload = {
          'work_order': workOrderId,
          'sales_order_number':
              formData['sales_order_number']?.toString() ?? '',
          'batch_number': batchNumber,
          'date': {
            'from': dateRange.start.toUtc().toIso8601String(),
            'to': dateRange.end.toUtc().toIso8601String(),
          },
          'products': products,
        };

        await createJobOrder(payload);
        context.showSuccessSnackbar("Job Order created successfully");
        context.go(RouteNames.jobOrder);
      } catch (e) {
        context.showWarningSnackbar("Failed to create Job Order: $e");
      }
    } else {
      context.showWarningSnackbar(
        "Please fill in all required fields correctly.",
      );
    }
  }

  void scrollToFocusedField(
    BuildContext context,
    ScrollController controller,
    String field,
  ) {
    final focusNode = field.contains('planned_quantity')
        ? getProductFocusNode(
            int.parse(field.split('_').last),
            'planned_quantity',
          )
        : getFocusNode(field);
    if (focusNode?.hasFocus ?? false) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        controller.animateTo(
          controller.offset + renderBox.localToGlobal(Offset.zero).dy,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  Future<void> initializeForm(String mongoId) async {
    _isFormLoading = true;
    _formError = null;
    notifyListeners();

    try {
      await loadWorkOrderDetails();
      final jobOrder = await getJobOrder(mongoId);
      if (jobOrder == null) {
        _formError = _error ?? 'Invalid Job Order ID.';
        _isFormLoading = false;
        notifyListeners();
        return;
      }

      final workOrderNumber = jobOrder.actualWorkOrderNumber;
      if (workOrderNumber.isEmpty) {
        _formError = 'Work order number not found in job order data.';
        _isFormLoading = false;
        notifyListeners();
        return;
      }

      setSelectedWorkOrder(workOrderNumber);
      final workOrder = _workOrderDetails.firstWhere(
        (e) => e['work_order_number'] == workOrderNumber,
        orElse: () => {},
      );
      final workOrderId =
          workOrder['id']?.toString() ?? workOrder['_id']?.toString();

      if (workOrderId == null || workOrderId.isEmpty) {
        _formError = 'Failed to find work order ID for $workOrderNumber.';
        _isFormLoading = false;
        notifyListeners();
        return;
      }

      await loadProductsByWorkOrder(workOrderId);
      final updatedProducts = jobOrder.jobOrders.map((item) {
        final product = _availableProducts.firstWhere(
          (p) =>
              p['product_id']?.toString() == item.product ||
              p['_id']?.toString() == item.product,
          orElse: () => {},
        );
        return {
          'product_id': item.product,
          'description':
              item.description ?? product['description'] ?? 'No Description',
          'material_code':
              item.materialCode ?? product['material_code'] ?? 'No Code',
          'quantity_in_no': item.plannedQuantity,
          'machine_name': item.machineName,
          'scheduled_date': item.scheduledDate,
        };
      }).toList();
      updateProducts(updatedProducts);
      initializeProductFocusNodes(updatedProducts.length);

      for (int i = 0; i < updatedProducts.length; i++) {
        final productId = updatedProducts[i]['product_id']?.toString();
        if (productId != null && productId.isNotEmpty) {
          await loadMachineNamesByProductId(i, productId);
        }
      }

      _isFormLoading = false;
      _formError = null;
    } catch (e) {
      _formError = _getErrorMessage(e);
      _isFormLoading = false;
    }
    notifyListeners();
  }

  void updateProducts(List<Map<String, dynamic>> newProducts) {
    _products = newProducts;
    notifyListeners();
  }

  void updateMachineNames(int index, List<Map<String, dynamic>> machineData) {
    while (_machineNames.length <= index) {
      _machineNames.add([]);
      _isLoadingMachineNames.add(false);
    }
    _machineDataByProduct[index] = machineData;
    _machineNames[index] = machineData
        .map((machine) => machine['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    _isLoadingMachineNames[index] = false;
    notifyListeners();
  }

  Future<void> loadMachineNamesByProductId(int index, String productId) async {
    while (_machineNames.length <= index) {
      _machineNames.add([]);
      _isLoadingMachineNames.add(false);
    }
    _isLoadingMachineNames[index] = true;
    _error = null;
    notifyListeners();

    try {
      final machineData = await _repository.fetchMachineNamesByProductId(
        productId,
      );
      updateMachineNames(index, machineData);
    } catch (e) {
      _error = _getErrorMessage(e);
      updateMachineNames(index, []);
    }
  }

  void setSelectedWorkOrder(String? value) {
    if (_selectedWorkOrder != value) {
      _selectedWorkOrder = value;
      _availableProducts.clear();
      _products.clear();
      _machineNames.clear();
      _machineDataByProduct.clear();
      _isLoadingMachineNames.clear();
      _error = null;

      if (value != null && value.isNotEmpty) {
        final selectedWO = _workOrderDetails.firstWhere(
          (e) => e['work_order_number']?.toString() == value,
          orElse: () => {},
        );
        final workOrderId =
            selectedWO['id']?.toString() ?? selectedWO['_id']?.toString();
        if (workOrderId != null && workOrderId.isNotEmpty) {
          loadProductsByWorkOrder(workOrderId)
              .then((_) {
                if (_products.isEmpty) {
                  addProductSection();
                }
              })
              .catchError((error) {
                if (_products.isEmpty) {
                  addProductSection();
                }
              });
        } else {
          addProductSection();
        }
      } else {
        addProductSection();
      }
      notifyListeners();
    }
  }

  void addProductSection() {
    _products.add({});
    _machineNames.add([]);
    _isLoadingMachineNames.add(false);
    initializeProductFocusNodes(_products.length);
    notifyListeners();
  }

  void removeProductSection(int index) {
    if (index >= 0 && index < _products.length) {
      _products.removeAt(index);
      if (index < _machineNames.length) {
        _machineNames.removeAt(index);
        _isLoadingMachineNames.removeAt(index);
        _machineDataByProduct.remove(index);
        final newMachineData = <int, List<Map<String, dynamic>>>{};
        _machineDataByProduct.forEach((key, value) {
          if (key > index) {
            newMachineData[key - 1] = value;
          } else if (key < index) {
            newMachineData[key] = value;
          }
        });
        _machineDataByProduct = newMachineData;
      }
      initializeProductFocusNodes(_products.length);
      notifyListeners();
    }
  }

  void handleProductSelection(
    int index,
    dynamic value,
    GlobalKey<FormBuilderState> formKey,
  ) {
    if (value == null) return;
    final selectedProduct = _availableProducts.firstWhere((product) {
      final description =
          product['description']?.toString() ?? 'No Description';
      final materialCode = product['material_code']?.toString() ?? 'No Code';
      return '$description - $materialCode' == value;
    }, orElse: () => {});
    if (selectedProduct.isNotEmpty) {
      final updatedProducts = List<Map<String, dynamic>>.from(_products);
      while (updatedProducts.length <= index) {
        updatedProducts.add({});
      }
      updatedProducts[index] = {
        'product_id':
            selectedProduct['product_id']?.toString() ??
            selectedProduct['_id']?.toString(),
        'description': selectedProduct['description'],
        'material_code': selectedProduct['material_code'],
        'uom': selectedProduct['uom'],
        'quantity_in_no': selectedProduct['quantity_in_no'],
      };
      updateProducts(updatedProducts);
      final quantityInNo = selectedProduct['quantity_in_no']?.toString();
      final uom = selectedProduct['uom']?.toString();
      final mappedUom = uom == 'sqmt'
          ? 'Square Meter/No'
          : uom == 'meter'
          ? 'Meter/No'
          : null;
      formKey.currentState?.fields['planned_quantity_$index']?.didChange(
        quantityInNo,
      );
      formKey.currentState?.fields['uom_$index']?.didChange(mappedUom);
      final productId =
          selectedProduct['product_id']?.toString() ??
          selectedProduct['_id']?.toString();
      if (productId != null && productId.isNotEmpty) {
        loadMachineNamesByProductId(index, productId);
      } else {
        updateMachineNames(index, []);
      }
    }
  }

  Future<void> loadWorkOrderDetails() async {
    _isLoadingWorkOrderNumbers = true; // Use the correct variable
    _error = null;
    notifyListeners();

    try {
      _workOrderDetails = await _repository.fetchWorkOrderDetailsRaw();
      _workOrderNumbers = _workOrderDetails
          .map((e) => e['work_order_number']?.toString())
          .where((v) => v != null && v.isNotEmpty)
          .cast<String>()
          .toList();
      _error = null;
    } catch (e) {
      _workOrderDetails = [];
      _workOrderNumbers = [];
      _error = _getErrorMessage(e);
    }

    _isLoadingWorkOrderNumbers = false;
    notifyListeners();
  }

  Future<void> loadProductsByWorkOrder(String workOrderId) async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();

    try {
      _availableProducts = await _repository.fetchProductsByWorkOrder(
        workOrderId,
      );
      _error = null;
    } catch (e) {
      _availableProducts = [];
      _error = _getErrorMessage(e);
    }

    _isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> createJobOrder(Map<String, dynamic> payload) async {
    _isAddJobOrderLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jobOrder = await _repository.createJobOrder(payload);
      _jobOrders.add(jobOrder);
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      rethrow;
    } finally {
      _isAddJobOrderLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateJobOrder({
    required String mongoId,
    required Map<String, dynamic> payload,
  }) async {
    _isUpdateJobOrderLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.updateJobOrder(
        mongoId: mongoId,
        payload: payload,
      );
      if (success) {
        await loadAllJobOrders(refresh: true);
        return true;
      } else {
        _error = 'Failed to update JobOrder';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isUpdateJobOrderLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteJobOrder(String mongoId) async {
    _isDeleteJobOrderLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _repository.deleteJobOrder(mongoId);
      if (success) {
        _jobOrders.removeWhere((jobOrder) => jobOrder.mongoId == mongoId);
        await loadAllJobOrders(refresh: true);
        return true;
      } else {
        _error = 'Failed to delete JobOrder';
        return false;
      }
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isDeleteJobOrderLoading = false;
      notifyListeners();
    }
  }

  Future<JobOrderModel?> getJobOrder(String mongoId) async {
    try {
      _error = null;
      final jobOrder = await _repository.getJobOrder(mongoId);
      _jobOrder = jobOrder;
      notifyListeners();
      return jobOrder;
    } catch (e) {
      _error = _getErrorMessage(e);
      notifyListeners();
      return null;
    }
  }

  Future<void> submitForm(
    BuildContext context,
    String mongoId,
    GlobalKey<FormBuilderState> formKey,
  ) async {
    if (formKey.currentState?.saveAndValidate() ?? false) {
      final formData = formKey.currentState!.value;
      try {
        // Validate mongoId
        final isValidMongoId = RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(mongoId);
        if (!isValidMongoId) {
          context.showWarningSnackbar("Invalid job order ID format.");
          return;
        }

        final selectedWO = _workOrderDetails.firstWhere(
          (e) => e['work_order_number'] == formData['work_order'],
          orElse: () => {},
        );
        final workOrderId =
            selectedWO['id']?.toString() ?? selectedWO['_id']?.toString();
        if (workOrderId == null ||
            workOrderId.isEmpty ||
            !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(workOrderId)) {
          context.showWarningSnackbar("Invalid work order selected.");
          return;
        }

        final products = <Map<String, dynamic>>[];
        for (int index = 0; index < _products.length; index++) {
          final productData = _products[index];
          final productValue = formData['product_$index'];
          final selectedProduct = _availableProducts.firstWhere((product) {
            final description =
                product['description']?.toString() ?? 'No Description';
            final materialCode =
                product['material_code']?.toString() ?? 'No Code';
            return '$description - $materialCode' == productValue;
          }, orElse: () => {});
          final productId =
              productData['product_id']?.toString() ??
              selectedProduct['product_id']?.toString() ??
              selectedProduct['_id']?.toString();
          if (productId == null ||
              productId.isEmpty ||
              !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(productId)) {
            context.showWarningSnackbar(
              "Invalid product ID for product ${index + 1}.",
            );
            return;
          }

          final machineDisplayName = formData['machine_name_$index']
              ?.toString();
          if (machineDisplayName == null || machineDisplayName.isEmpty) {
            context.showWarningSnackbar(
              "Please select a machine for product ${index + 1}.",
            );
            return;
          }

          final machineData = getMachineDataForProduct(index);
          if (machineData == null || machineData.isEmpty) {
            context.showWarningSnackbar(
              "No machine data available for product ${index + 1}.",
            );
            return;
          }

          final selectedMachine = machineData.firstWhere(
            (machine) => machine['name']?.toString() == machineDisplayName,
            orElse: () => {},
          );
          final machineId =
              selectedMachine['id']?.toString() ??
              selectedMachine['_id']?.toString();
          if (machineId == null ||
              machineId.isEmpty ||
              !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(machineId)) {
            context.showWarningSnackbar(
              "Invalid machine ID for product ${index + 1}.",
            );
            return;
          }

          final scheduledDate = formData['planned_date_$index'];
          String formattedScheduledDate = '';
          if (scheduledDate is DateTime) {
            formattedScheduledDate = scheduledDate.toUtc().toIso8601String();
          } else if (scheduledDate != null) {
            try {
              final parsedDate = DateTime.parse(
                scheduledDate.toString(),
              ).toUtc();
              formattedScheduledDate = parsedDate.toIso8601String();
            } catch (e) {
              context.showWarningSnackbar(
                "Invalid scheduled date format for product ${index + 1}.",
              );
              return;
            }
          } else {
            context.showWarningSnackbar(
              "Scheduled date is required for product ${index + 1}.",
            );
            return;
          }

          final plannedQuantityStr =
              formData['planned_quantity_$index']?.toString() ?? '0';
          final plannedQuantity = int.tryParse(plannedQuantityStr) ?? 0;
          if (plannedQuantity <= 0) {
            context.showWarningSnackbar(
              "Planned quantity must be greater than 0 for product ${index + 1}.",
            );
            return;
          }

          products.add({
            'product': productId,
            'machine_name': machineId,
            'planned_quantity': plannedQuantity,
            'scheduled_date': formattedScheduledDate,
          });
        }
        if (products.isEmpty) {
          context.showWarningSnackbar("At least one product is required.");
          return;
        }

        final dateRange = formData['date_range'] as DateTimeRange?;
        if (dateRange == null) {
          context.showWarningSnackbar("Please select a date range.");
          return;
        }

        final batchNumberStr = formData['batch_number']?.toString() ?? '0';
        final batchNumber = int.tryParse(batchNumberStr) ?? 0;
        if (batchNumber <= 0) {
          context.showWarningSnackbar("Please enter a valid batch number.");
          return;
        }

        final payload = {
          'work_order': workOrderId,
          'sales_order_number':
              formData['sales_order_number']?.toString() ?? '',
          'batch_number': batchNumber,
          'date': {
            'from': dateRange.start.toUtc().toIso8601String(),
            'to': dateRange.end.toUtc().toIso8601String(),
          },
          'products': products,
        };

        final success = await updateJobOrder(
          mongoId: mongoId,
          payload: payload,
        );
        if (success) {
          context.showSuccessSnackbar("Job Order updated successfully");
          context.go(RouteNames.jobOrder);
        } else {
          context.showWarningSnackbar("Failed to update Job Order: $_error");
        }
      } catch (e) {
        context.showWarningSnackbar("Failed to update Job Order: $e");
      }
    } else {
      context.showWarningSnackbar(
        "Please fill in all required fields correctly.",
      );
    }
  }

  Future<void> loadAllJobOrders({bool refresh = false}) async {
    if (refresh) {
      _jobOrders.clear();
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getAllJobOrder();
      if (refresh) {
        _jobOrders.clear();
      }
      _jobOrders = response.data;
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
      _jobOrders.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
