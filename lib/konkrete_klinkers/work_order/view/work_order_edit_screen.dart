import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/date_picker.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/client_model.dart'
    hide CreatedBy, Username;
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/provider/work_order_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditWorkOrderScreen extends StatefulWidget {
  final String workOrderId;

  const EditWorkOrderScreen({super.key, required this.workOrderId});

  @override
  State<EditWorkOrderScreen> createState() => _EditWorkOrderScreenState();
}

class _EditWorkOrderScreenState extends State<EditWorkOrderScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<WorkOrderProvider>(context, listen: false);

      await Future.wait([
        provider.loadAllClients(refresh: true),
        provider.loadAllProducts(refresh: true),
      ]);

      await _fetchWorkOrderData(provider);

      // Wait for form initialization
      await _waitForFormInitialization();

      if (mounted) {
        _preFillMainForm(provider);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showErrorSnackbar(_getUserFriendlyError(e));
      }
    }
  }

  Future<void> _waitForFormInitialization() async {
    int retries = 5;
    const delay = Duration(milliseconds: 100);
    while (retries > 0 && mounted) {
      if (_formKey.currentState != null &&
          Provider.of<WorkOrderProvider>(context, listen: false).products.every(
            (p) =>
                (p['formKey'] as GlobalKey<FormBuilderState>).currentState !=
                null,
          )) {
        if (kDebugMode) {
          print('📝 [EditWorkOrderScreen] Form and product forms initialized');
        }
        return;
      }
      if (kDebugMode) {
        print(
          '📝 [EditWorkOrderScreen] Waiting for form initialization, retries left: $retries',
        );
      }
      await Future.delayed(delay);
      retries--;
    }
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. The server is taking too long to respond.';
    } else if (error is FormatException) {
      return 'Invalid data format received from server. Please contact support.';
    } else if (error.toString().contains('Work order not found')) {
      return 'The requested work order was not found. It may have been deleted.';
    }
    return 'An unexpected error occurred. Please try again later.';
  }

  Future<void> _fetchWorkOrderData(WorkOrderProvider provider) async {
    try {
      final workOrder = await provider.getWorkOrder(widget.workOrderId);

      if (kDebugMode) {
        print('📝 [EditWorkOrderScreen] Raw getWorkOrder response: $workOrder');
      }

      if (workOrder == null) {
        throw Exception('Work order not found or access denied');
      }

      provider.setWorkOrders([workOrder]);
      provider.setBufferStockEnabled(workOrder.bufferStock);
      provider.setUploadedFiles(List.from(workOrder.files));

      final products = workOrder.products.map((product) {
        final productId = product.productId.toString();

        final productModel = provider.allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => ProductModel(
            id: '',
            materialCode: '',
            description: 'Unknown Product',
            plant: PlantModel(
              id: '',
              plantCode: '',
              plantName: '',
              createdBy: CreatedBy(
                id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
                username: Username.ADMIN,
              ),
              isDeleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              version: 0,
            ),
            uom: [],
            areas: {},
            noOfPiecesPerPunch: 0,
            qtyInBundle: 0,
            createdBy: CreatedBy(
              id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
              username: Username.ADMIN,
            ),
            status: '',
            isDeleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 0,
          ),
        );

        if (productId.isEmpty) {
          if (kDebugMode) {
            print(
              '📝 [EditWorkOrderScreen] Warning: Empty productId for product: ${product.toJson()}',
            );
          }
        }

        return {
          'formKey': GlobalKey<FormBuilderState>(),
          'product_id': {
            'id': productId,
            'name': productModel.id.isNotEmpty
                ? '${productModel.materialCode} - ${productModel.description}'
                : 'Unknown Product',
          },
          'uom': uomValues.reverse[product.uom] ?? 'nos',
          'po_quantity': product.poQuantity.toString(),
          'qty_in_nos': product.qtyInNos.toString(),
          'qtyController': TextEditingController(
            text: product.qtyInNos.toString(),
          ),
          'qtyNotifier': ValueNotifier<int>(product.qtyInNos),
          'delivery_date': product.deliveryDate,
          'plant_code': productModel.plant.plantCode,
        };
      }).toList();

      provider.setProducts(products);

      if (!(workOrder.bufferStock)) {
        final clientId = workOrder.clientId?.toString() ?? '';
        if (clientId.isNotEmpty) {
          await provider.loadProjectsByClient(clientId);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching work order: $e\n$stackTrace');
      throw Exception('Failed to load work order details. Please try again.');
    }
  }

  void _preFillMainForm(WorkOrderProvider provider) {
    final workOrder = provider.workOrders.firstWhere(
      (wo) => wo.id == widget.workOrderId,
      orElse: () => Datum(
        id: '',
        workOrderNumber: '',
        products: [],
        status: Status.PENDING,
        clientId: null,
        projectId: null,
        date: null,
        bufferStock: false,
        files: [],
        createdBy: CreatedBy(
          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
          username: Username.ADMIN,
        ),
        updatedBy: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        bufferTransferLogs: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
        jobOrders: [],
      ),
    );

    if (workOrder.id.isEmpty) {
      if (kDebugMode) {
        print(
          '📝 [EditWorkOrderScreen] Warning: Work order not found in provider.workOrders',
        );
      }
      context.showErrorSnackbar('Failed to load work order data');
      return;
    }

    void tryPreFill() {
      if (!mounted || _formKey.currentState == null) {
        if (kDebugMode) {
          print(
            '📝 [EditWorkOrderScreen] Warning: Main form not ready for pre-filling',
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) tryPreFill();
        });
        return;
      }

      _safeFormFieldUpdate('work_order_number', workOrder.workOrderNumber);
      if (kDebugMode) {
        print(
          '📝 [EditWorkOrderScreen] Pre-filled work_order_number: ${workOrder.workOrderNumber}',
        );
      }

      if (!(workOrder.bufferStock)) {
        if (workOrder.clientId != null && workOrder.clientId!.isNotEmpty) {
          final client = provider.clients.firstWhere(
            (c) => c.id == workOrder.clientId,
          );
          _safeFormFieldUpdate('client_id', client);
          if (kDebugMode) {
            print(
              '📝 [EditWorkOrderScreen] Pre-filled client_id: ${client.id}',
            );
          }
        } else {
          if (kDebugMode) {
            print(
              '📝 [EditWorkOrderScreen] Warning: Client ID is null or empty for work order ${workOrder.id}',
            );
          }
          _safeFormFieldUpdate('client_id', null);
        }

        if (workOrder.projectId != null && workOrder.projectId!.isNotEmpty) {
          final project = provider.projects.firstWhere(
            (p) => p.id == workOrder.projectId,
            orElse: () => TId(
              id: workOrder.projectId!,
              name: provider.getProjectName(workOrder.projectId),
            ),
          );
          _safeFormFieldUpdate('project_id', project);
        } else {
          _safeFormFieldUpdate('project_id', null);
        }

        if (workOrder.date != null) {
          _safeFormFieldUpdate('work_order_date', workOrder.date);
          if (kDebugMode) {
            print(
              '📝 [EditWorkOrderScreen] Pre-filled work_order_date: ${workOrder.date}',
            );
          }
        }
      }

      for (var index = 0; index < provider.products.length; index++) {
        final product = provider.products[index];
        final formKey = product['formKey'] as GlobalKey<FormBuilderState>;

        if (product['product_id'] == null ||
            product['product_id']['id'] == null) {
          if (kDebugMode) {
            print(
              '📝 [EditWorkOrderScreen] Warning: product_id is null for product at index $index',
            );
          }
          product['product_id'] = {'id': '', 'name': 'Unknown Product'};
        }

        void preFillProductForm() {
          if (formKey.currentState != null) {
            formKey.currentState?.fields['product_id_$index']?.didChange(
              product['product_id'],
            );
            formKey.currentState?.fields['uom_$index']?.didChange(
              product['uom'],
            );
            formKey.currentState?.fields['po_quantity_$index']?.didChange(
              product['po_quantity'],
            );
            formKey.currentState?.fields['qty_in_nos_$index']?.didChange(
              product['qty_in_nos'],
            );
            formKey.currentState?.fields['delivery_date_$index']?.didChange(
              product['delivery_date'],
            );
            formKey.currentState?.fields['plant_code_$index']?.didChange(
              product['plant_code'],
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) preFillProductForm();
            });
          }
        }

        preFillProductForm();
      }
    }

    tryPreFill();
  }

  void _safeFormFieldUpdate(String fieldName, dynamic value) {
    if (_formKey.currentState?.fields[fieldName] != null) {
      _formKey.currentState?.fields[fieldName]?.didChange(value);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _formKey.currentState?.fields[fieldName] != null) {
          _formKey.currentState?.fields[fieldName]?.didChange(value);
        }
      });
    }
  }

  Widget _buildMainFormCard(
    BuildContext context,
    WorkOrderProvider workOrderProvider,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work Order Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 12.h),
            CustomTextFormField(
              name: 'work_order_number',
              labelText: 'Work Order No',
              fillColor: Colors.white,
              hintText: 'Enter Work Order No.',
              prefixIcon: Icons.format_list_numbered,
              textStyle: TextStyle(fontSize: 14.sp),
              labelStyle: TextStyle(fontSize: 14.sp),
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Work Order Number is required',
                ),
              ],
            ),
            if (!workOrderProvider.isBufferStockEnabled) ...[
              SizedBox(height: 12.h),
              _buildClientDropdown(workOrderProvider),
              SizedBox(height: 12.h),
              _buildProjectDropdown(workOrderProvider),
              SizedBox(height: 12.h),
              ReusableDateFormField(
                name: 'work_order_date',
                labelText: 'Work Order Date',
                fillColor: Colors.white,
                hintText: 'Select date',
                prefixIcon: Icons.calendar_today_outlined,
                iconSize: 18.sp,
                textStyle: TextStyle(fontSize: 14.sp),
                labelStyle: TextStyle(fontSize: 14.sp),
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Work Order Date is required',
                  ),
                ],
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                format: DateFormat('dd-MM-yyyy'),
              ),
            ],
            SizedBox(height: 16.h),
            Text(
              'Products',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 12.h),
            _buildProductForms(workOrderProvider),
            SizedBox(height: 12.h),
            _buildAddProductButton(),
            SizedBox(height: 12.h),
            _buildUploadSection(workOrderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown(WorkOrderProvider workOrderProvider) {
    if (workOrderProvider.isClientsLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          color: const Color(0xFF3B82F6),
        ),
      );
    } else if (workOrderProvider.clients.isEmpty &&
        workOrderProvider.error != null) {
      return _buildErrorContainer(
        'Error loading clients: ${workOrderProvider.error}',
      );
    } else if (workOrderProvider.clients.isEmpty) {
      return _buildErrorContainer('No clients available');
    }

    final workOrder = workOrderProvider.workOrders.firstWhere(
      (wo) => wo.id == widget.workOrderId,
      orElse: () => Datum(
        id: '',
        workOrderNumber: '',
        products: [],
        status: Status.PENDING,
        clientId: null,
        projectId: null,
        date: null,
        bufferStock: false,
        files: [],
        createdBy: CreatedBy(
          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
          username: Username.ADMIN,
        ),
        updatedBy: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        bufferTransferLogs: [],
        jobOrders: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
      ),
    );

    ClientModel? initialClient;
    if (workOrder.clientId != null && workOrder.clientId!.isNotEmpty) {
      initialClient = workOrderProvider.clients.firstWhere(
        (c) => c.id == workOrder.clientId,
      );
    }

    return CustomSearchableDropdownFormField<ClientModel>(
      name: 'client_id',
      labelText: 'Client Name',
      fillColor: Colors.white,
      prefixIcon: Icons.person_outline,
      iconSize: 18.sp,
      textStyle: TextStyle(fontSize: 14.sp),
      labelStyle: TextStyle(fontSize: 14.sp),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      initialValue: initialClient,
      options: workOrderProvider.clients,
      optionLabel: (client) => client.name,
      isEqual: (a, b) => a?.id == b?.id,
      onChanged: (client) {
        if (client != null) {
          workOrderProvider.loadProjectsByClient(client.id);
          _formKey.currentState?.fields['project_id']?.didChange(null);
          if (kDebugMode) {
            print(
              '📝 [EditWorkOrderScreen] Client changed to ${client.id}, loading projects',
            );
          }
        }
      },
      validators: [
        FormBuilderValidators.required(errorText: 'Client is required'),
      ],
      allowClear: true,
    );
  }

  Widget _buildProjectDropdown(WorkOrderProvider workOrderProvider) {
    final selectedClient =
        _formKey.currentState?.fields['client_id']?.value as ClientModel?;
    final clientId = selectedClient?.id;

    final workOrder = workOrderProvider.workOrders.firstWhere(
      (wo) => wo.id == widget.workOrderId,
      orElse: () => Datum(
        id: '',
        workOrderNumber: '',
        products: [],
        status: Status.PENDING,
        clientId: null,
        projectId: null,
        date: null,
        bufferStock: false,
        files: [],
        createdBy: CreatedBy(
          id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
          username: Username.ADMIN,
        ),
        updatedBy: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
        bufferTransferLogs: [],
        jobOrders: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        v: 0,
      ),
    );

    TId? initialProject;
    if (workOrder.projectId != null && workOrder.projectId!.isNotEmpty) {
      initialProject = workOrderProvider.projects.firstWhere(
        (p) => p.id == workOrder.projectId,
        orElse: () => TId(
          id: workOrder.projectId!,
          name: workOrderProvider.getProjectName(workOrder.projectId),
        ),
      );
    }

    if (workOrderProvider.isProjectsLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.w,
          color: const Color(0xFF3B82F6),
        ),
      );
    } else if (workOrderProvider.projects.isEmpty && clientId != null) {
      return _buildErrorContainer('No projects available for this client');
    }

    return CustomSearchableDropdownFormField<TId>(
      name: 'project_id',
      labelText: 'Project Name',
      fillColor: Colors.white,
      prefixIcon: Icons.domain,
      iconSize: 18.sp,
      textStyle: TextStyle(fontSize: 14.sp),
      labelStyle: TextStyle(fontSize: 14.sp),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      initialValue: initialProject,
      options: workOrderProvider.projects,
      optionLabel: (project) => project.name,
      isEqual: (a, b) => a?.id == b?.id,
      validators: clientId != null
          ? [FormBuilderValidators.required(errorText: 'Project is required')]
          : [],
      allowClear: true,
      enabled: clientId != null,
    );
  }

  Widget _buildProductForms(WorkOrderProvider workOrderProvider) {
    return SingleChildScrollView(
      child: Column(
        children: workOrderProvider.products.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> product = entry.value;
          final uomItems = workOrderProvider.uomListPerIndex[index] ?? [];
          final formKey = product['formKey'] as GlobalKey<FormBuilderState>;
          final qtyNotifier = product['qtyNotifier'] as ValueNotifier<int>;
          final qtyController =
              product['qtyController'] as TextEditingController;

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEDE9FE),
                  const Color(0xFFF5F3FF),
                  const Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.05),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Stack(
              children: [
                FormBuilder(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product ${index + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      if (workOrderProvider.isProductLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (workOrderProvider.allProducts.isEmpty &&
                          workOrderProvider.error != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Error loading products: ${workOrderProvider.error}',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (workOrderProvider.allProducts.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.redAccent.withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'No products available',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            CustomSearchableDropdownFormField<
                              Map<String, String>
                            >(
                              name: 'product_id_$index',
                              labelText: 'Product Name / Material Code',
                              fillColor: Colors.white,
                              prefixIcon: Icons.category,
                              iconSize: 18.sp,
                              textStyle: TextStyle(fontSize: 14.sp),
                              labelStyle: TextStyle(fontSize: 14.sp),
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              options: workOrderProvider.allProducts
                                  .map(
                                    (product) => {
                                      'id': product.id,
                                      'name':
                                          '${product.materialCode} - ${product.description}',
                                    },
                                  )
                                  .toList(),
                              optionLabel: (option) => option['name'] ?? '',
                              onChanged: (selected) {
                                if (formKey.currentState == null) {
                                  if (kDebugMode) {
                                    print(
                                      '📝 [EditWorkOrderScreen] Form state is null for index $index',
                                    );
                                  }
                                  return;
                                }
                                if (selected != null) {
                                  final selectedProduct = workOrderProvider
                                      .allProducts
                                      .firstWhere(
                                        (p) => p.id == selected['id'],
                                        orElse: () => ProductModel(
                                          id: '',
                                          materialCode: '',
                                          description: 'Unknown Product',
                                          plant: PlantModel(
                                            id: '',
                                            plantCode: '',
                                            plantName: '',
                                            createdBy: CreatedBy(
                                              id: UpdatedBy
                                                  .THE_68467_BBCC6407_E1_FDF09_D18_E,
                                              username: Username.ADMIN,
                                            ),
                                            isDeleted: false,
                                            createdAt: DateTime.now(),
                                            updatedAt: DateTime.now(),
                                            version: 0,
                                          ),
                                          uom: [],
                                          areas: {},
                                          noOfPiecesPerPunch: 0,
                                          qtyInBundle: 0,
                                          createdBy: CreatedBy(
                                            id: UpdatedBy
                                                .THE_68467_BBCC6407_E1_FDF09_D18_E,
                                            username: Username.ADMIN,
                                          ),
                                          status: '',
                                          isDeleted: false,
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                          version: 0,
                                        ),
                                      );
                                  if (selectedProduct.id.isNotEmpty) {
                                    formKey
                                        .currentState
                                        ?.fields['plant_code_$index']
                                        ?.didChange(
                                          selectedProduct.plant.plantCode,
                                        );
                                    workOrderProvider.updateUOMListForIndex(
                                      index: index,
                                      product: selectedProduct,
                                    );
                                    formKey.currentState?.fields['uom_$index']
                                        ?.didChange(null);
                                    workOrderProvider.updateQuantity(
                                      index: index,
                                      product: selectedProduct,
                                      formKey: formKey,
                                    );
                                    if (kDebugMode) {
                                      print(
                                        '📝 [EditWorkOrderScreen] Product $index changed to ${selected['id']}',
                                      );
                                      print(
                                        '📝 [EditWorkOrderScreen] Updated plant_code: ${selectedProduct.plant.plantCode}',
                                      );
                                    }
                                  }
                                }
                              },
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'Product is required',
                                ),
                              ],
                              allowClear: true,
                            ),
                            SizedBox(height: 12.h),
                            CustomDropdownFormField<String>(
                              name: 'uom_$index',
                              labelText: 'UOM',
                              initialValue: uomItems.isNotEmpty
                                  ? uomItems.first
                                  : null,
                              items: uomItems
                                  .map(
                                    (item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item),
                                    ),
                                  )
                                  .toList(),
                              hintText: uomItems.isEmpty
                                  ? 'Select a product first'
                                  : 'Select UOM',
                              prefixIcon: Icons.workspaces,
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'UOM is required',
                                ),
                              ],
                              fillColor: const Color(0xFFF8FAFC),
                              borderColor: Colors.grey.shade300,
                              focusedBorderColor: const Color(0xFF3B82F6),
                              borderRadius: 12.r,
                              onChanged: (value) {
                                if (formKey.currentState == null) {
                                  if (kDebugMode) {
                                    print(
                                      '📝 [EditWorkOrderScreen] Form state is null for index $index',
                                    );
                                  }
                                  return;
                                }
                                if (value != null) {
                                  final formData = formKey.currentState?.value;
                                  final productMap =
                                      formData?['product_id_$index'];
                                  if (productMap != null &&
                                      productMap['id'] != null) {
                                    final selectedProduct = workOrderProvider
                                        .allProducts
                                        .firstWhere(
                                          (p) => p.id == productMap['id'],
                                          orElse: () => ProductModel(
                                            id: '',
                                            materialCode: '',
                                            description: 'Unknown Product',
                                            plant: PlantModel(
                                              id: '',
                                              plantCode: '',
                                              plantName: '',
                                              createdBy: CreatedBy(
                                                id: UpdatedBy
                                                    .THE_68467_BBCC6407_E1_FDF09_D18_E,
                                                username: Username.ADMIN,
                                              ),
                                              isDeleted: false,
                                              createdAt: DateTime.now(),
                                              updatedAt: DateTime.now(),
                                              version: 0,
                                            ),
                                            uom: [],
                                            areas: {},
                                            noOfPiecesPerPunch: 0,
                                            qtyInBundle: 0,
                                            createdBy: CreatedBy(
                                              id: UpdatedBy
                                                  .THE_68467_BBCC6407_E1_FDF09_D18_E,
                                              username: Username.ADMIN,
                                            ),
                                            status: '',
                                            isDeleted: false,
                                            createdAt: DateTime.now(),
                                            updatedAt: DateTime.now(),
                                            version: 0,
                                          ),
                                        );
                                    if (selectedProduct.id.isNotEmpty) {
                                      workOrderProvider.updateQuantity(
                                        index: index,
                                        product: selectedProduct,
                                        formKey: formKey,
                                      );
                                      if (kDebugMode) {
                                        print(
                                          '📝 [EditWorkOrderScreen] UOM $index changed to $value',
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(height: 12.h),
                            CustomTextFormField(
                              name: 'po_quantity_$index',
                              labelText: 'PO Quantity',
                              fillColor: Colors.white,
                              hintText: 'Enter PO quantity',
                              prefixIcon: Icons.numbers,
                              textStyle: TextStyle(fontSize: 14.sp),
                              labelStyle: TextStyle(fontSize: 14.sp),
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              keyboardType: TextInputType.number,
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'PO Quantity is required',
                                ),
                                FormBuilderValidators.numeric(
                                  errorText: 'Must be a number',
                                ),
                                FormBuilderValidators.min(
                                  0,
                                  errorText: 'Quantity must be positive',
                                ),
                              ],
                              onChanged: (value) {
                                if (kDebugMode) {
                                  print(
                                    '📝 [AddWorkOrderScreen] PO Quantity changed for index $index: $value',
                                  );
                                }
                                // Save form state to ensure latest values
                                formKey.currentState?.save();
                                final formData = formKey.currentState?.value;
                                final productMap =
                                    formData?['product_id_$index'];
                                final uom = formData?['uom_$index'];
                                if (kDebugMode) {
                                  print(
                                    '📝 [AddWorkOrderScreen] Form data for index $index: '
                                    'productMap: $productMap, uom: $uom',
                                  );
                                }
                                if (value != null &&
                                    value.isNotEmpty &&
                                    productMap != null &&
                                    productMap['id'] != null &&
                                    uom != null) {
                                  final selectedProduct = workOrderProvider
                                      .allProducts
                                      .firstWhere(
                                        (p) => p.id == productMap['id'],
                                      );
                                  workOrderProvider.updateQuantity(
                                    index: index,
                                    product: selectedProduct,
                                    formKey: formKey,
                                    poQuantity: value,
                                  );
                                  if (kDebugMode) {
                                    print(
                                      '📝 [AddWorkOrderScreen] Updated qty_in_nos_$index: '
                                      '${qtyController.text}, Notifier: ${qtyNotifier.value}',
                                    );
                                  }
                                } else {
                                  if (value != null && value.isNotEmpty) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please select a product and UOM  ${index + 1}',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                          backgroundColor: Colors.red.shade700,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                  qtyController.text = '0';
                                  qtyNotifier.value = 0;
                                  formKey
                                      .currentState
                                      ?.fields['qty_in_nos_$index']
                                      ?.didChange('0');
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                            ValueListenableBuilder<int>(
                              valueListenable: qtyNotifier,
                              builder: (context, qty, child) {
                                qtyController.text = qty.toString();

                                return CustomTextFormField(
                                  name: 'qty_in_nos_$index',
                                  labelText: 'Quantity in Nos',
                                  fillColor: Colors.white,
                                  hintText: 'Auto-calculated',
                                  controller: qtyController,
                                  prefixIcon: Icons.format_list_numbered,
                                  textStyle: TextStyle(fontSize: 14.sp),
                                  labelStyle: TextStyle(fontSize: 14.sp),
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[400],
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  enabled: false,
                                  readOnly: true,
                                  onChanged: null,
                                );
                              },
                            ),
                            SizedBox(height: 12.h),
                            ReusableDateFormField(
                              name: 'delivery_date_$index',
                              labelText: 'Delivery Date',
                              hintText: 'Select Delivery date',
                              fillColor: Colors.white,
                              prefixIcon: Icons.calendar_today_outlined,
                              iconSize: 18.sp,
                              textStyle: TextStyle(fontSize: 14.sp),
                              labelStyle: TextStyle(fontSize: 14.sp),
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'Delivery Date is required',
                                ),
                              ],
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                              format: DateFormat('dd-MM-yyyy'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (workOrderProvider.products.length > 1)
                  Positioned(
                    top: 0.h,
                    right: 0.w,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: const Color(0xFFEF4444),
                          size: 20.sp,
                        ),
                        onPressed: () {
                          workOrderProvider.removeProductAt(index);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final provider = Provider.of<WorkOrderProvider>(
                context,
                listen: false,
              );
              provider.setProducts([
                ...provider.products,
                {
                  'formKey': GlobalKey<FormBuilderState>(),
                  'product_id': null,
                  'uom': 'nos',
                  'po_quantity': '0',
                  'qty_in_nos': '0',
                  'qtyController': TextEditingController(text: '0'),
                  'qtyNotifier': ValueNotifier<int>(0),
                  'delivery_date': null,
                  'plant_code': '',
                },
              ]);
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Add Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(WorkOrderProvider workOrderProvider) {
    return Consumer<WorkOrderProvider>(
      builder: (context, provider, _) => Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Files',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF3B82F6),
                  width: 1.5.w,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true, type: FileType.any);
                    if (result != null && context.mounted) {
                      provider.addUploadedFiles(
                        result.files
                            .map(
                              (file) => FileElement(
                                fileName: file.name,
                                fileUrl: file.path ?? '',
                                id: '',
                                uploadedAt: DateTime.now(),
                              ),
                            )
                            .where((file) => file.fileUrl.isNotEmpty)
                            .toList(),
                      );
                      if (kDebugMode) {
                        print(
                          '📝 [EditWorkOrderScreen] Added files: ${result.files.map((f) => f.name).toList()}',
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      context.showErrorSnackbar(
                        'Failed to pick files. Please try again. Error: $e',
                      );
                    }
                    if (kDebugMode) {
                      print('📝 [EditWorkOrderScreen] File picker error: $e');
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: const Color(0xFF3B82F6),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Drop files or click to upload (Image, PDF, XLSX, CSV)',
                          style: TextStyle(
                            color: const Color(0xFF3B82F6),
                            fontSize: 13.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (provider.uploadedFiles.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: provider.uploadedFiles.map((file) {
                  return Chip(
                    label: Text(
                      file.fileName,
                      style: TextStyle(fontSize: 12.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: const Color(0xFFEF4444),
                    ),
                    onDeleted: () {
                      provider.removeUploadedFile(file);
                      if (kDebugMode) {
                        print(
                          '📝 [EditWorkOrderScreen] Removed file: ${file.fileName}',
                        );
                      }
                    },
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFixedSubmitButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: Consumer<WorkOrderProvider>(
            builder: (context, provider, _) => Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: provider.isUpdateWorkOrderLoading
                      ? null
                      : () => _submitForm(context, provider),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Center(
                    child: provider.isUpdateWorkOrderLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Updating Work Order...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_alt,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Update Work Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    WorkOrderProvider provider,
  ) async {
    if (!_formKey.currentState!.saveAndValidate()) {
      context.showWarningSnackbar('Please fill all required fields correctly.');

      return;
    }

    bool allFormsValid = true;
    List<Product> validatedProducts = [];

    for (var index = 0; index < provider.products.length; index++) {
      final product = provider.products[index];
      final formKey = product['formKey'] as GlobalKey<FormBuilderState>;

      if (formKey.currentState?.saveAndValidate() ?? false) {
        final formData = formKey.currentState!.value;
        final String? productId =
            formData['product_id_$index']?['id'] as String?;

        if (productId == null || productId.isEmpty) {
          context.showWarningSnackbar(
            'Please select a product for Product ${index + 1}.',
          );

          allFormsValid = false;
          continue;
        }

        final selectedProduct = provider.allProducts.firstWhere(
          (p) => p.id == productId,
          orElse: () => ProductModel(
            id: '',
            materialCode: '',
            description: 'Unknown Product',
            plant: PlantModel(
              id: '',
              plantCode: '',
              plantName: '',
              createdBy: CreatedBy(
                id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
                username: Username.ADMIN,
              ),
              isDeleted: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              version: 0,
            ),
            uom: [],
            areas: {},
            noOfPiecesPerPunch: 0,
            qtyInBundle: 0,
            createdBy: CreatedBy(
              id: UpdatedBy.THE_68467_BBCC6407_E1_FDF09_D18_E,
              username: Username.ADMIN,
            ),
            status: '',
            isDeleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 0,
          ),
        );

        final String? selectedUom = formData['uom_$index'] as String?;
        final double poQuantityDouble =
            double.tryParse(formData['po_quantity_$index'].toString()) ?? 0.0;
        final DateTime? deliveryDate =
            formData['delivery_date_$index'] as DateTime?;

        if (selectedUom == null || deliveryDate == null) {
          context.showWarningSnackbar(
            'Please fill in all required fields for Product ${index + 1}.',
          );
          allFormsValid = false;
          continue;
        }

        final qtyInNosInt = provider.getCalculatedQtyInNos(
          formKey: formKey,
          index: index,
        );

        validatedProducts.add(
          Product(
            id:
                product['id'] ??
                '', // Preserve existing product ID if available
            productId: selectedProduct.id,
            uom: uomValues.map[selectedUom] ?? Uom.NOS,
            poQuantity: poQuantityDouble.toInt(),
            qtyInNos: qtyInNosInt,
            deliveryDate: deliveryDate,
          ),
        );
      } else {
        allFormsValid = false;
        context.showWarningSnackbar(
          'Please fill all required fields for Product ${index + 1}.',
        );
      }
    }

    if (!allFormsValid || validatedProducts.isEmpty) {
      context.showWarningSnackbar(
        'Please fill in all required product fields correctly.',
      );
      return;
    }

    final formData = _formKey.currentState!.value;
    final selectedClient = formData['client_id'] != null
        ? provider.clients.firstWhere(
            (client) => client.id == (formData['client_id'] as ClientModel).id,
          )
        : null;
    final selectedProject = formData['project_id'] != null
        ? provider.projects.firstWhere(
            (project) => project.id == (formData['project_id'] as TId).id,
          )
        : null;

    if (!provider.isBufferStockEnabled &&
        (selectedClient == null || selectedProject == null)) {
      context.showWarningSnackbar('Please select a valid client and project.');
      return;
    }

    // Prepare backend payload for logging
    final filesForBackend = provider.uploadedFiles.map((file) {
      return FileElement(
        fileName: file.fileName,
        fileUrl: file.fileUrl,
        id: file.id,
        uploadedAt: file.uploadedAt,
      );
    }).toList();

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF3B82F6),
                strokeWidth: 2.w,
              ),
              SizedBox(height: 12.h),
              Text(
                'Updating Work Order...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final success = await provider.updateWorkOrder(
        id: widget.workOrderId,
        workOrderNumber: formData['work_order_number'] as String,
        clientId: provider.isBufferStockEnabled ? null : selectedClient?.id,
        projectId: provider.isBufferStockEnabled ? null : selectedProject?.id,
        date: provider.isBufferStockEnabled
            ? null
            : (formData['work_order_date'] as DateTime?),
        bufferStock: provider.isBufferStockEnabled,
        products: validatedProducts,
        files: filesForBackend,
        status: Status.PENDING,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success && context.mounted) {
        await provider.loadAllWorkOrders(refresh: true);
        context.showSuccessSnackbar('Work Order updated successfully!');

        context.go(RouteNames.workorders);
      } else {
        if (context.mounted) {
          context.showErrorSnackbar(
            'Failed to update work order. Please try again.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        context.showErrorSnackbar('Error updating work order: ${e.toString()}');
      }
    }
  }

  Widget _buildErrorContainer(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.redAccent.withOpacity(0.4),
            width: 1.w,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Edit Work Order',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 20.sp,
        color: const Color(0xFF334155),
      ),
      onPressed: () {
        final provider = Provider.of<WorkOrderProvider>(context, listen: false);
        provider
            .loadAllWorkOrders(refresh: true)
            .then((_) {
              if (context.mounted) {
                context.go(RouteNames.workorders);
              }
            })
            .catchError((e) {
              if (context.mounted) {
                context.showErrorSnackbar('Failed to load work order: $e');
              }
            });
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          children: [
            Text(
              'Buffer Stock',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF334155)),
            ),
            SizedBox(width: 4.w),
            Consumer<WorkOrderProvider>(
              builder: (context, provider, _) => Switch(
                value: provider.isBufferStockEnabled,
                onChanged: (value) {
                  provider.setBufferStockEnabled(value);
                  if (value) {
                    _formKey.currentState?.fields['client_id']?.didChange(null);
                    _formKey.currentState?.fields['project_id']?.didChange(
                      null,
                    );
                    _formKey.currentState?.fields['work_order_date']?.didChange(
                      null,
                    );
                  }
                },
                activeColor: const Color(0xFF3B82F6),
                activeTrackColor: const Color(0xFF93C5FD),
                inactiveThumbColor: const Color(0xFF64748B),
                inactiveTrackColor: const Color(0xFFD1D5DB),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
  
    return Consumer<WorkOrderProvider>(
      builder: (context, workOrderProvider, child) {
        if (_isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: const Color(0xFF3B82F6),
              ),
            ),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBars(
            title: _buildLogoAndTitle(),
            leading: _buildBackButton(),
            action: _buildAppBarActions(),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: MediaQuery.of(context).padding.top + 12.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainFormCard(context, workOrderProvider),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: _buildFixedSubmitButton(context),
        );
      },
    );
  }
}
