import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/client_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/model/work_order_model.dart';
import 'package:k2k/konkrete_klinkers/work_order/provider/work_order_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/common/date_picker.dart';

class AddWorkOrderScreen extends StatefulWidget {
  const AddWorkOrderScreen({super.key});

  @override
  State<AddWorkOrderScreen> createState() => _AddWorkOrderScreenState();
}

class _AddWorkOrderScreenState extends State<AddWorkOrderScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final Map<String, FocusNode> _focusNodes = {
    'no_of_pieces_per_punch': FocusNode(),
    'area_per_unit': FocusNode(),
    'qty_in_bundle': FocusNode(),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Initializing AddWorkOrderScreen');
      final workOrderProvider = Provider.of<WorkOrderProvider>(
        context,
        listen: false,
      );
      workOrderProvider.loadAllClients();
      workOrderProvider.loadAllProducts();
    });
  }

  @override
  void dispose() {
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkOrderProvider>(
      builder: (context, workOrderProvider, child) {
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
              padding: EdgeInsets.symmetric(horizontal: 12.w),
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
          // : const Center(child: CircularProgressIndicator()),
          bottomNavigationBar: _buildFixedSubmitButton(context),
        );
      },
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      children: [
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Create Work Order',
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
        context.go(RouteNames.workorders);
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

  Widget _buildMainFormCard(
    BuildContext context,
    WorkOrderProvider workOrderProvider,
  ) {
    final ClientModel? selectedClient =
        _formKey.currentState?.fields['client_id']?.value as ClientModel?;
    String? clientId = selectedClient?.id;

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
              if (workOrderProvider.isClientsLoading)
                const Center(child: CircularProgressIndicator())
              else if (workOrderProvider.clients.isEmpty &&
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
                            'Error loading clients: ${workOrderProvider.error}',
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
              else if (workOrderProvider.clients.isEmpty)
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
                            'No clients available',
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
                CustomSearchableDropdownFormField<ClientModel>(
                  name: 'client_id',
                  labelText: 'Client Name',
                  prefixIcon: Icons.person_outline,
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
                  options: workOrderProvider.clients,
                  optionLabel: (client) => client.name,
                  onChanged: (client) {
                    if (client != null) {
                      workOrderProvider.loadProjectsByClient(client.id);
                    }
                  },
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Client is required',
                    ),
                  ],
                  allowClear: true,
                ),
              SizedBox(height: 12.h),
              if (workOrderProvider.isProjectsLoading)
                const Center(child: CircularProgressIndicator())
              else if (workOrderProvider.projects.isEmpty && clientId != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    'No projects available for this client',
                    style: TextStyle(color: Colors.red, fontSize: 13.sp),
                  ),
                )
              else
                CustomSearchableDropdownFormField<TId>(
                  name: 'project_id',
                  labelText: 'Project Name',
                  prefixIcon: Icons.domain,
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
                  options: workOrderProvider.projects,
                  optionLabel: (project) => project.name,
                  validators: clientId != null
                      ? [
                          FormBuilderValidators.required(
                            errorText: 'Project is required',
                          ),
                        ]
                      : [],
                  allowClear: true,
                  enabled: clientId != null,
                ),
              SizedBox(height: 12.h),
              ReusableDateFormField(
                name: 'work_order_date',
                labelText: 'Work Order Date',
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
            _buildUploadSection(),
          ],
        ),
      ),
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
                                if (selected != null) {
                                  final selectedProduct = workOrderProvider
                                      .allProducts
                                      .firstWhere(
                                        (p) => p.id == selected['id'],
                                      );
                                  formKey
                                      .currentState
                                      ?.fields['plant_code_$index']
                                      ?.didChange(
                                        selectedProduct.plant.plantCode,
                                      );
                                  // Update UOM list for the selected product
                                  workOrderProvider.updateUOMListForIndex(
                                    index: index,
                                    product: selectedProduct,
                                  );
                                  // Reset UOM to null if the product changes to force user selection
                                  formKey.currentState?.fields['uom_$index']
                                      ?.didChange(null);
                                  // Update quantity
                                  workOrderProvider.updateQuantity(
                                    index: index,
                                    product: selectedProduct,
                                    formKey: formKey,
                                  );
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
                              initialValue: uomItems.length == 1
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
                              hintText: 'Select UOM',
                              prefixIcon: Icons.workspaces,
                              validators: [FormBuilderValidators.required()],
                              fillColor: const Color(0xFFF8FAFC),
                              borderColor: Colors.grey.shade300,
                              focusedBorderColor: const Color(0xFF3B82F6),
                              borderRadius: 12.r,
                              onChanged: (value) {
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
                            CustomTextFormField(
                              name: 'plant_code_$index',
                              labelText: 'Plant Code',
                              hintText: 'Auto-fetched',
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
                              initialValue: '',
                              enabled: false,
                            ),
                            SizedBox(height: 12.h),
                            ReusableDateFormField(
                              name: 'delivery_date_$index',
                              labelText: 'Delivery Date',
                              hintText: 'Select date',
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
              Provider.of<WorkOrderProvider>(
                context,
                listen: false,
              ).addProduct();
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

  Widget _buildUploadSection() {
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
                    }
                  } catch (e) {
                    if (context.mounted) {
                      context.showErrorSnackbar(
                        'Failed to pick files. Please try again. Error: $e',
                      );
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
                  onTap: provider.isAddWorkOrderLoading
                      ? null
                      : () => _submitForm(context, provider),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Center(
                    child: provider.isAddWorkOrderLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Creating Work Order...',
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
                                'Add Work Order',
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
            uom: uomValues.map[selectedUom] ?? Uom.NOS,
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

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final selectedClient = formData['client_id'] != null
          ? provider.clients.firstWhere(
              (client) =>
                  client.name == (formData['client_id'] as ClientModel).name,
            )
          : null;
      final selectedProject = formData['project_id'] != null
          ? provider.projects.firstWhere(
              (project) => project.name == (formData['project_id'] as TId).name,
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
                CircularProgressIndicator(
                  color: const Color(0xFF3B82F6),
                  strokeWidth: 2.w,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Creating Work Order...',
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

      final success = await provider.createWorkOrder(
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
        context.showSuccessSnackbar('Work Order created successfully!');

        context.go(RouteNames.workorders);
      } else {
        context.showErrorSnackbar(
          'Failed to create work order. Please check your input and try again.',
        );
      }
    } else {
      context.showWarningSnackbar(
        'Please fill in all required fields correctly.',
      );
    }
  }
}
