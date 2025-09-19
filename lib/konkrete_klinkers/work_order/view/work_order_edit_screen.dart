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
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/client_model.dart'
    hide CreatedBy, Username;
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_detail_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/provider/work_order_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';

class EditWorkOrderScreen extends StatefulWidget {
  final String workOrderId;

  const EditWorkOrderScreen({super.key, required this.workOrderId});

  @override
  State<EditWorkOrderScreen> createState() => _EditWorkOrderScreenState();
}

class _EditWorkOrderScreenState extends State<EditWorkOrderScreen> {
  String? mapStringToUom(String? uomString) {
    if (uomString == null) return null;
    switch (uomString.toLowerCase()) {
      case 'nos':
        return 'nos';
      case 'Meter':
        return 'meter';
      case 'Square Meter':
        return 'sqmt';
      default:
        return 'Nos';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workOrderProvider = Provider.of<WorkOrderProvider>(
        context,
        listen: false,
      );
      workOrderProvider.initializeEditScreen(widget.workOrderId);
      workOrderProvider.loadAllClients();
      workOrderProvider.loadAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.workorders);
        }
      },
      child: Consumer<WorkOrderProvider>(
        builder: (context, workOrderProvider, child) {
          if (workOrderProvider.isEditScreenLoading) {
            return Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: Scaffold(
                backgroundColor: AppColors.transparent,
                body: const Center(child: GradientLoader()),
              ),
            );
          }
          if (workOrderProvider.editScreenError != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.showErrorSnackbar(workOrderProvider.editScreenError);
            });
          }
          return Container(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppColors.transparent,
              appBar: AppBars(
                title: const Text(
                  'Edit Work Order',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 20.sp,
                    color: const Color(0xFF334155),
                  ),
                  onPressed: () {
                    context.go(RouteNames.workorders);
                  },
                ),
                action: _buildAppBarActions(workOrderProvider),
              ),
              body: SafeArea(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _buildMainFormCard(context, workOrderProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions(WorkOrderProvider workOrderProvider) {
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
            Switch(
              value: workOrderProvider.isBufferStockEnabled,
              onChanged: (value) {
                workOrderProvider.setBufferStockEnabled(value);
              },
              activeColor: const Color(0xFF3B82F6),
              activeTrackColor: const Color(0xFF93C5FD),
              inactiveThumbColor: const Color(0xFF64748B),
              inactiveTrackColor: const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildMainFormCard(
    BuildContext context,
    WorkOrderProvider workOrderProvider,
  ) {
    final workOrder = workOrderProvider.workOrderById;

    if (workOrder == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'No work order available',
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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
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
        key: workOrderProvider.editFormKey,
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
            SizedBox(height: 8.h),
            Text(
              'Edit the required information below',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 12.h),
            CustomTextFormField(
              name: 'work_order_number',
              labelText: 'Work Order No',
              hintText: 'Enter Work Order No.',
              initialValue: workOrder.workOrderNumber,
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
              fillColor: AppColors.background,
            ),
            if (!workOrderProvider.isBufferStockEnabled) ...[
              SizedBox(height: 12.h),
              _buildClientDropdown(workOrderProvider, workOrder),
              SizedBox(height: 12.h),
              _buildProjectDropdown(workOrderProvider, workOrder),
              SizedBox(height: 12.h),
              ReusableDateFormField(
                name: 'work_order_date',
                labelText: 'Work Order Date',
                hintText: 'Select date',
                initialValue: workOrder.date,
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
                fillColor: AppColors.background,
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
            SizedBox(height: 8.h),
            Text(
              'Edit product details below',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 12.h),
            _buildProductForms(workOrderProvider),
            SizedBox(height: 12.h),
            _buildAddProductButton(workOrderProvider),
            SizedBox(height: 12.h),
            _buildUploadSection(context, workOrderProvider),
            SizedBox(height: 12.h),
            _buildSubmitButton(context, workOrderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown(
    WorkOrderProvider workOrderProvider,
    WODData workOrder,
  ) {
    if (workOrderProvider.isClientsLoading) {
      return const Center(child: GradientLoader());
    }
    if (workOrderProvider.clients.isEmpty && workOrderProvider.error != null) {
      return _buildErrorContainer(
        'Error loading clients: ${workOrderProvider.error}',
      );
    }
    if (workOrderProvider.clients.isEmpty) {
      return _buildErrorContainer('No clients available');
    }
    ClientModel? initialClient;
    if (workOrder.clientId.id.isNotEmpty) {
      initialClient = workOrderProvider.clients.firstWhere(
        (c) => c.id == workOrder.clientId.id,
        // orElse: () => ClientModel(id: '', name: 'Unknown Client', address: '', createdBy: null, isDeleted: false, createdAt: null, updatedAt: null, v: null),
      );
    }
    return CustomSearchableDropdownFormField<ClientModel>(
      name: 'client_id',
      labelText: 'Client Name',
      hintText: 'Select Client',
      initialValue: initialClient,
      prefixIcon: Icons.person_outline,
      iconSize: 18.sp,
      textStyle: TextStyle(fontSize: 14.sp),
      labelStyle: TextStyle(fontSize: 14.sp),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      options: workOrderProvider.clients,
      optionLabel: (client) => client.name,
      isEqual: (a, b) => a?.id == b?.id,
      onChanged: (client) {
        if (client != null) {
          workOrderProvider.loadProjectsByClient(client.id);
          workOrderProvider.editFormKey.currentState?.fields['project_id']
              ?.didChange(null);
        }
      },
      validators: [
        FormBuilderValidators.required(errorText: 'Client is required'),
      ],
      allowClear: true,
      fillColor: AppColors.background,
    );
  }

  Widget _buildProjectDropdown(
    WorkOrderProvider workOrderProvider,
    WODData workOrder,
  ) {
    final selectedClient =
        workOrderProvider.editFormKey.currentState?.fields['client_id']?.value
            as ClientModel?;
    final clientId = selectedClient?.id;
    TId? initialProject;
    if (workOrder.projectId != null && workOrder.projectId!.id.isNotEmpty) {
      initialProject = workOrderProvider.projects.firstWhere(
        (p) => p.id == workOrder.projectId!.id,
        orElse: () => TId(
          id: workOrder.projectId!.id,
          name: workOrderProvider.getProjectName(workOrder.projectId!.id),
        ),
      );
    }
    if (workOrderProvider.isProjectsLoading) {
      return const Center(child: GradientLoader());
    }
    if (workOrderProvider.projects.isEmpty && clientId != null) {
      return _buildErrorContainer('No projects available for this client');
    }
    return CustomSearchableDropdownFormField<TId>(
      name: 'project_id',
      labelText: 'Project Name',
      hintText: 'Select Project',
      initialValue: initialProject,
      prefixIcon: Icons.domain,
      iconSize: 18.sp,
      textStyle: TextStyle(fontSize: 14.sp),
      labelStyle: TextStyle(fontSize: 14.sp),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      options: workOrderProvider.projects,
      optionLabel: (project) => project.name,
      isEqual: (a, b) => a?.id == b?.id,
      validators: clientId != null
          ? [FormBuilderValidators.required(errorText: 'Project is required')]
          : [],
      allowClear: true,
      enabled: clientId != null,
      fillColor: AppColors.background,
    );
  }

  Widget _buildProductForms(WorkOrderProvider workOrderProvider) {
    final workOrder = workOrderProvider.workOrderById;
    if (workOrder == null) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      child: Column(
        children: workOrderProvider.products.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> product = entry.value;
          final uomItems = workOrderProvider.uomListPerIndex[index] ?? [];
          // Create a new GlobalKey for each product form
          final formKey = GlobalKey<FormBuilderState>();
          final qtyNotifier = product['qtyNotifier'] as ValueNotifier<int>;
          final qtyController =
              product['qtyController'] as TextEditingController;

          // Initialize form fields with product data
          final productData = workOrder.products.length > index
              ? workOrder.products[index]
              : null;

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEDE9FE),
                  Color(0xFFF5F3FF),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Product ${index + 1}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (workOrderProvider.isProductLoading)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Center(
                            child: Column(
                              children: [
                                const GradientLoader(),
                                SizedBox(height: 12.h),
                                Text(
                                  'Loading products...',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
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
                                  color: Colors.red.shade700,
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
                                  color: Colors.red.shade700,
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
                            _buildProductDropdown(
                              index,
                              workOrderProvider,
                              formKey,
                              productData,
                            ),
                            SizedBox(height: 12.h),
                            CustomDropdownFormField<String>(
                              name: 'uom_$index',
                              labelText: 'UOM',
                              initialValue: () {
                                if (productData?.uom != null) {
                                  return mapStringToUom(productData!.uom) ??
                                      "Nos";
                                }
                                return "Nos"; // fallback default
                              }(),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: "Nos",
                                  child: Text("Nos"),
                                ),
                                ...uomItems.map(
                                  (item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  ),
                                ),
                              ],
                              hintText: uomItems.isEmpty
                                  ? 'Select a product first'
                                  : 'Select UOM',
                              prefixIcon: Icons.workspaces,
                              textStyle: TextStyle(fontSize: 14.sp),
                              labelStyle: TextStyle(fontSize: 14.sp),
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              validators: [
                                FormBuilderValidators.required(
                                  errorText: 'UOM is required',
                                ),
                              ],
                              fillColor: AppColors.background,
                              borderColor: Colors.grey.shade300,
                              focusedBorderColor: const Color(0xFF3B82F6),
                              borderRadius: 12.r,
                              onChanged: (value) {
                                if (kDebugMode) {
                                  print(
                                    'UOM Dropdown for index $index: Selected value=$value',
                                  );
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
                                        );
                                    workOrderProvider.updateQuantity(
                                      index: index,
                                      product: selectedProduct,
                                      formKey: formKey,
                                    );
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 12.h),
                            CustomTextFormField(
                              name: 'po_quantity_$index',
                              labelText: 'PO Quantity',
                              hintText: 'Enter PO quantity',
                              initialValue:
                                  productData?.poQuantity.toString() ?? '',
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
                              fillColor: AppColors.background,
                              onChanged: (value) {
                                if (kDebugMode) {
                                  print(
                                    '📝 [EditWorkOrderScreen] PO Quantity changed for index $index: $value',
                                  );
                                }
                                formKey.currentState?.save();
                                final formData = formKey.currentState?.value;
                                final productMap =
                                    formData?['product_id_$index'];
                                final uom = formData?['uom_$index'];
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
                                } else {
                                  if (value != null && value.isNotEmpty) {
                                    if (context.mounted) {
                                      context.showWarningSnackbar(
                                        'Please select a product and UOM for Product ${index + 1}',
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
                                  fillColor: AppColors.background,
                                );
                              },
                            ),
                            SizedBox(height: 12.h),
                            CustomTextFormField(
                              name: 'plant_code_$index',
                              labelText: 'Plant Code',
                              hintText: 'Auto-fetched',
                              initialValue: productData != null
                                  ? productData.plant.plantCode
                                  : '',
                              prefixIcon: Icons.factory,
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
                              fillColor: AppColors.background,
                            ),
                            SizedBox(height: 12.h),
                            ReusableDateFormField(
                              name: 'delivery_date_$index',
                              labelText: 'Delivery Date',
                              hintText: 'Select date',
                              initialValue: productData?.deliveryDate,
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
                              fillColor: AppColors.background,
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

  Widget _buildProductDropdown(
    int index,
    WorkOrderProvider workOrderProvider,
    GlobalKey<FormBuilderState> formKey,
    WODDataProduct? productData,
  ) {
    if (workOrderProvider.isProductLoading) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Column(
            children: [
              const GradientLoader(),
              SizedBox(height: 12.h),
              Text(
                'Loading products...',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }
    if (workOrderProvider.allProducts.isEmpty &&
        workOrderProvider.error != null) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade700,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Failed to load products',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              workOrderProvider.error!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () => workOrderProvider.loadAllProducts(),
              icon: Icon(Icons.refresh, size: 16.sp),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade700,
                elevation: 0,
              ),
            ),
          ],
        ),
      );
    }
    if (workOrderProvider.allProducts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20.sp),
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
      );
    }
    Map<String, String>? initialProduct;
    if (productData != null) {
      final selectedProduct = workOrderProvider.allProducts.firstWhere(
        (p) => p.id == productData.product.id,
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
      initialProduct = {
        'id': selectedProduct.id,
        'name':
            '${selectedProduct.materialCode} - ${selectedProduct.description}',
      };
    }
    return CustomSearchableDropdownFormField<Map<String, String>>(
      name: 'product_id_$index',
      labelText: 'Product Name / Material Code',
      hintText: 'Select Product',
      initialValue: initialProduct,
      prefixIcon: Icons.category,
      iconSize: 18.sp,
      textStyle: TextStyle(fontSize: 14.sp),
      labelStyle: TextStyle(fontSize: 14.sp),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      options: workOrderProvider.allProducts
          .map(
            (product) => {
              'id': product.id,
              'name': '${product.materialCode} - ${product.description}',
            },
          )
          .toList(),
      optionLabel: (option) => option['name'] ?? '',
      validators: [
        FormBuilderValidators.required(errorText: 'Product is required'),
      ],
      onChanged: (selected) {
        if (selected != null) {
          final selectedProduct = workOrderProvider.allProducts.firstWhere(
            (p) => p.id == selected['id'],
          );
          formKey.currentState?.fields['plant_code_$index']?.didChange(
            selectedProduct.plant.plantCode,
          );
          workOrderProvider.updateUOMListForIndex(
            index: index,
            product: selectedProduct,
            prefilledUom: productData?.uom != null
                ? workOrderProvider
                      .mapStringToUom(productData!.uom)
                      .toLowerCase()
                : null,
          );
          // Reset UOM field to ensure valid initial value
          formKey.currentState?.fields['uom_$index']?.reset();
          formKey.currentState?.fields['uom_$index']?.didChange(
            workOrderProvider.uomListPerIndex[index]?.isNotEmpty == true
                ? workOrderProvider.uomListPerIndex[index]!.first
                : 'nos',
          );
          workOrderProvider.updateQuantity(
            index: index,
            product: selectedProduct,
            formKey: formKey,
          );
        }
      },
      allowClear: true,
      fillColor: AppColors.background,
    );
  }

  Widget _buildAddProductButton(WorkOrderProvider workOrderProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
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
          onTap: () => workOrderProvider.addProduct(),
          borderRadius: BorderRadius.circular(8.r),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Another Product',
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

  Widget _buildUploadSection(
    BuildContext context,
    WorkOrderProvider workOrderProvider,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
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
              border: Border.all(color: const Color(0xFF3B82F6), width: 1.5.w),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: InkWell(
              onTap: () async {
                try {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(allowMultiple: true, type: FileType.any);
                  if (result != null && context.mounted) {
                    workOrderProvider.addUploadedFiles(
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
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorSnackbar(
                      'Failed to pick files. Please try again.',
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
          if (workOrderProvider.uploadedFiles.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: workOrderProvider.uploadedFiles.map((file) {
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
                  onDeleted: () => workOrderProvider.removeUploadedFile(file),
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                );
              }).toList(),
            ),
          ],
          if (workOrderProvider.uploadError != null) ...[
            SizedBox(height: 6.h),
            Text(
              workOrderProvider.uploadError!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    WorkOrderProvider workOrderProvider,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
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
          onTap: workOrderProvider.isUpdateWorkOrderLoading
              ? null
              : () => _submitForm(context, workOrderProvider),
          borderRadius: BorderRadius.circular(8.r),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (workOrderProvider.isUpdateWorkOrderLoading)
                    const GradientLoader()
                  else
                    Icon(Icons.check_circle, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    workOrderProvider.isUpdateWorkOrderLoading
                        ? 'Updating Work Order...'
                        : 'Update Work Order',
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

  Future<void> _submitForm(
    BuildContext context,
    WorkOrderProvider provider,
  ) async {
    bool allFormsValid = true;
    List<Product> validatedProducts = [];

    for (var product in provider.products) {
      final formKey = product['formKey'] as GlobalKey<FormBuilderState>;
      final index = provider.products.indexOf(product);
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
            productId: selectedProduct.id,
            uom: uomValues.map[selectedUom] ?? Uom.nos,
            poQuantity: poQuantityDouble.toInt(),
            qtyInNos: qtyInNosInt,
            deliveryDate: deliveryDate,
            id: '',
          ),
        );
      } else {
        allFormsValid = false;
      }
    }

    if (!allFormsValid || validatedProducts.isEmpty) {
      context.showWarningSnackbar(
        'Please fill in all required product fields correctly.',
      );
      return;
    }
    if (!provider.validateUploads()) {
      return;
    }
    if (provider.editFormKey.currentState?.saveAndValidate() ?? false) {
      final formData = provider.editFormKey.currentState!.value;
      final selectedClient = formData['client_id'] != null
          ? provider.clients.firstWhere(
              (client) =>
                  client.id == (formData['client_id'] as ClientModel).id,
            )
          : null;
      final selectedProject = formData['project_id'] != null
          ? provider.projects.firstWhere(
              (project) => project.id == (formData['project_id'] as TId).id,
            )
          : null;

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
                const GradientLoader(),
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

      final filesForBackend = provider.uploadedFiles.map((file) {
        return FileElement(
          fileName: file.fileName,
          fileUrl: file.fileUrl,
          id: file.id,
          uploadedAt: file.uploadedAt,
        );
      }).toList();

      final success = await provider.updateWorkOrder(
        id: widget.workOrderId,
        workOrderNumber: formData['work_order_number'] as String,
        clientId: !provider.isBufferStockEnabled ? selectedClient?.id : null,
        projectId: !provider.isBufferStockEnabled ? selectedProject?.id : null,
        date: !provider.isBufferStockEnabled
            ? (formData['work_order_date'] as DateTime?)
            : null,
        bufferStock: provider.isBufferStockEnabled,
        products: validatedProducts,
        files: filesForBackend,
        status: Status.PENDING,
      );

      Navigator.of(context).pop();

      if (success && context.mounted) {
        await provider.loadAllWorkOrders(refresh: true);
        context.showSuccessSnackbar('Work Order updated successfully!');
        context.go(RouteNames.workorders);
      } else {
        context.showErrorSnackbar(
          'Failed to update work order. Please check your input and try again.',
        );
      }
    } else {
      context.showWarningSnackbar(
        'Please fill in all required fields correctly.',
      );
    }
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20.sp),
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
    );
  }
}
