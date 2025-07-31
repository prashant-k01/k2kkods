import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/date_picker.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/ranger_date_pciker.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/konkrete_klinkers/job_order/provider/job_order_provider.dart';
import 'package:provider/provider.dart';

class JobOrdersFormScreen extends StatefulWidget {
  const JobOrdersFormScreen({super.key});

  @override
  _JobOrdersFormScreenState createState() => _JobOrdersFormScreenState();
}

class _JobOrdersFormScreenState extends State<JobOrdersFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ScrollController _scrollController = ScrollController();

  final Map<String, FocusNode> _focusNodes = {
    'work_order': FocusNode(),
    'sales_order_number': FocusNode(),
    'batch_number': FocusNode(),
  };

  final List<Map<String, FocusNode>> _productFocusNodes = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<JobOrderProvider>();
      provider.loadWorkOrderDetails();

      if (provider.products.isEmpty) {
        provider.addProductSection();
      }

      _initializeProductFocusNodes(provider.products.length);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNodes.forEach((_, node) => node.dispose());
    for (var product in _productFocusNodes) {
      product.forEach((_, node) => node.dispose());
    }
    super.dispose();
  }

  void _initializeProductFocusNodes(int count) {
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
  }

  void _scrollToFocusedField(BuildContext context, FocusNode focusNode) {
    if (focusNode.hasFocus) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _scrollController.animateTo(
          _scrollController.offset + renderBox.localToGlobal(Offset.zero).dy,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobOrderProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          resizeToAvoidBottomInset: true,
          appBar: AppBars(
            title: _buildLogoAndTitle(),
            leading: _buildBackButton(),
            action: [],
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.opaque,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(24.w).copyWith(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              children: [_buildFormCard(context, provider)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add Job Order',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 24.sp,
            color: const Color(0xFF334155),
          ),
          onPressed: () {
            context.go(RouteNames.jobOrder);
          },
        );
      },
    );
  }

  Widget _buildFormCard(BuildContext context, JobOrderProvider provider) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Order Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter the required information below',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 24.h),

            Builder(
              builder: (context) {
                if (provider.isLoadingWorkOrderNumbers) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (provider.error != null) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Failed to load work orders: ${provider.error}',
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () {
                            provider.loadWorkOrderDetails();
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.workOrderNumbers.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      'No work orders available',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  );
                }

                return CustomSearchableDropdownFormField(
                  name: 'work_order',
                  labelText: 'Work Order',
                  hintText: 'Select Work Order',
                  prefixIcon: Icons.work,
                  options: provider.workOrderNumbers,
                  fillColor: const Color(0xFFF8FAFC),
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: const Color(0xFF3B82F6),
                  borderRadius: 12.r,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a work order',
                    ),
                  ],
                  onChanged: (value) {
                    provider.setSelectedWorkOrder(value);
                  },
                );
              },
            ),

            SizedBox(height: 12.h),

            if (provider.selectedWorkOrder != null)
              Builder(
                builder: (context) {
                  final selectedWO = provider.workOrderDetails.firstWhere(
                    (e) => e['work_order_number'] == provider.selectedWorkOrder,
                    orElse: () => {},
                  );
                  if (selectedWO.isEmpty) return SizedBox.shrink();

                  final clientName =
                      selectedWO['client_id']?['name'] ?? 'Unknown Client';
                  final projectName =
                      selectedWO['project_id']?['name'] ?? 'Unknown Project';

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12.0,
                          offset: Offset(0, 4),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client Details',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.blue.shade100,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Icon(
                                      Icons.business_center,
                                      size: 14.sp,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'CLIENT',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                clientName,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade900,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.green.shade100,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Icon(
                                      Icons.work_outline,
                                      size: 14.sp,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'PROJECT',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                projectName,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade900,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            SizedBox(height: 18.h),

            CustomTextFormField(
              name: 'sales_order_number',
              labelText: 'Sales Order Number',
              hintText: 'Enter Sales Order Number',
              focusNode: _focusNodes['sales_order_number'],
              prefixIcon: Icons.receipt,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              onTap: () => _scrollToFocusedField(
                context,
                _focusNodes['sales_order_number']!,
              ),
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'batch_number',
              labelText: 'Batch Number',
              hintText: 'Enter Batch Number',
              focusNode: _focusNodes['batch_number'],
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(
                  errorText: 'Batch number must be a number',
                ),
                FormBuilderValidators.min(
                  1,
                  errorText: 'Batch number must be positive',
                ),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              onTap: () =>
                  _scrollToFocusedField(context, _focusNodes['batch_number']!),
            ),
            SizedBox(height: 18.h),
            CustomRangeDatePicker(
              name: 'date_range',
              labelText: 'Date Range (from & to)',
              hintText: 'Select Date Range (from & to)',
            ),
            SizedBox(height: 24.h),

            ...provider.products.asMap().entries.map((entry) {
              final index = entry.key;
              return _buildProductSection(context, index, provider);
            }).toList(),

            SizedBox(height: 18.h),
            _buildAddProductButton(provider),
            SizedBox(height: 40.h),
            _buildSubmitButton(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(
    BuildContext context,
    int index,
    JobOrderProvider provider,
  ) {
    if (_productFocusNodes.length < provider.products.length) {
      _initializeProductFocusNodes(provider.products.length);
    }

    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Product ${index + 1}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              if (provider.products.length > 1)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.sp,
                    color: const Color(0xFFF43F5E),
                  ),
                  onPressed: () {
                    provider.removeProductSection(index);
                    _initializeProductFocusNodes(provider.products.length);
                  },
                  tooltip: 'Remove Product',
                ),
            ],
          ),
          SizedBox(height: 16.h),

          Builder(
            builder: (context) {
              if (provider.selectedWorkOrder == null) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade700,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Please select a work order first to view available products',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (provider.isLoadingProducts) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF3B82F6),
                          ),
                        ),
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
                );
              }

              if (provider.error != null) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade200),
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
                        provider.error!.contains('500')
                            ? 'Server error occurred while loading products. Please try again.'
                            : provider.error!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (provider.selectedWorkOrder != null) {
                            final selectedWO = provider.workOrderDetails
                                .firstWhere(
                                  (e) =>
                                      e['work_order_number'] ==
                                      provider.selectedWorkOrder,
                                  orElse: () => {},
                                );
                            final workOrderId = selectedWO['id']?.toString();
                            if (workOrderId != null) {
                              provider.loadProductsByWorkOrder(workOrderId);
                            }
                          }
                        },
                        icon: Icon(Icons.refresh, size: 16.sp),
                        label: Text('Retry'),
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

              if (provider.availableProducts.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_outlined,
                        color: Colors.grey.shade600,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'No products available for this work order',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return CustomSearchableDropdownFormField(
                name: 'product_$index',
                labelText: 'Product',
                hintText: 'Select Product',
                prefixIcon: Icons.inventory_2,
                initialValue:
                    provider.products.length > index &&
                        provider.products[index]['description'] != null &&
                        provider.products[index]['material_code'] != null
                    ? '${provider.products[index]['description']} - ${provider.products[index]['material_code']}'
                    : null,
                options: provider.availableProducts.map((product) {
                  final description =
                      product['description']?.toString() ?? 'No Description';
                  final materialCode =
                      product['material_code']?.toString() ?? 'No Code';
                  return '$description - $materialCode';
                }).toList(),
                fillColor: const Color(0xFFF8FAFC),
                borderColor: Colors.grey.shade300,
                focusedBorderColor: const Color(0xFF3B82F6),
                borderRadius: 12.r,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please select a product',
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  final selectedProduct = provider.availableProducts.firstWhere(
                    (product) {
                      final description =
                          product['description']?.toString() ??
                          'No Description';
                      final materialCode =
                          product['material_code']?.toString() ?? 'No Code';
                      return '$description - $materialCode' == value;
                    },
                    orElse: () => {},
                  );

                  if (selectedProduct.isNotEmpty) {
                    final updatedProducts = List<Map<String, dynamic>>.from(
                      provider.products,
                    );

                    while (updatedProducts.length <= index) {
                      updatedProducts.add({});
                    }

                    updatedProducts[index] = {
                      'product_id': selectedProduct['product_id'],
                      'description': selectedProduct['description'],
                      'material_code': selectedProduct['material_code'],
                      'uom': selectedProduct['uom'],
                      'quantity_in_no': selectedProduct['quantity_in_no'],
                    };

                    provider.updateProducts(updatedProducts);

                    final quantityInNo = selectedProduct['quantity_in_no']
                        ?.toString();
                    final uom = selectedProduct['uom']?.toString();
                    final mappedUom = uom == 'sqmt'
                        ? 'Square Meter/No'
                        : uom == 'meter'
                        ? 'Meter/No'
                        : null;

                    _formKey.currentState?.fields['planned_quantity_$index']
                        ?.didChange(quantityInNo);
                    _formKey.currentState?.fields['uom_$index']?.didChange(
                      mappedUom,
                    );

                    final productId = selectedProduct['product_id']?.toString();
                    if (productId != null && productId.isNotEmpty) {
                      provider.loadMachineNamesByProductId(index, productId);
                    } else {
                      provider.updateMachineNames(index, []);
                    }
                  }
                },
              );
            },
          ),

          SizedBox(height: 18.h),

          Builder(
            builder: (context) {
              final machineNames = provider.getMachineNamesForProduct(index);
              final isLoadingMachines = provider.isLoadingMachineNames(index);

              if (isLoadingMachines) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Loading machines...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (provider.error != null && machineNames.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade200),
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
                              'Failed to load machines',
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
                        provider.error!.contains('500')
                            ? 'Server error occurred while loading machines. Please try again or contact support.'
                            : provider.error!.contains('400')
                            ? 'Invalid material code. Please select a valid product or contact support.'
                            : provider.error!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          final productId = provider.products.length > index
                              ? provider.products[index]['product_id']
                                    ?.toString()
                              : null;
                          if (productId != null) {
                            provider.loadMachineNamesByProductId(
                              index,
                              productId,
                            );
                          }
                        },
                        icon: Icon(Icons.refresh, size: 16.sp),
                        label: Text('Retry'),
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

              if (machineNames.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.build,
                        color: Colors.grey.shade600,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'No machines available for this product',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return CustomSearchableDropdownFormField(
                name: 'machine_name_$index',
                labelText: 'Machine Name',
                hintText: 'Select Machine Name',
                prefixIcon: Icons.build,
                options: machineNames,
                fillColor: const Color(0xFFF8FAFC),
                borderColor: Colors.grey.shade300,
                focusedBorderColor: const Color(0xFF3B82F6),
                borderRadius: 12.r,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please select a machine',
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 18.h),

          CustomDropdownFormField<String>(
            name: 'uom_$index',
            labelText: 'UOM',
            items: ['Square Meter/No', 'Meter/No']
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            hintText: 'Select UOM',
            prefixIcon: Icons.workspaces,
            validators: [FormBuilderValidators.required()],
            fillColor: const Color(0xFFF8FAFC),
            borderColor: Colors.grey.shade300,
            focusedBorderColor: const Color(0xFF3B82F6),
            borderRadius: 12.r,
            initialValue:
                provider.products.length > index &&
                    provider.products[index]['uom'] != null
                ? (provider.products[index]['uom'] == 'sqmt'
                      ? 'Square Meter/No'
                      : provider.products[index]['uom'] == 'meter'
                      ? 'Meter/No'
                      : null)
                : null,
          ),
          SizedBox(height: 18.h),
          CustomTextFormField(
            name: 'planned_quantity_$index',
            keyboardType: TextInputType.number,
            labelText: 'Planned Quantity',
            hintText: 'Enter Planned Quantity',
            focusNode: _productFocusNodes.length > index
                ? _productFocusNodes[index]['planned_quantity']
                : null,
            prefixIcon: Icons.numbers,
            initialValue:
                provider.products.length > index &&
                    provider.products[index]['quantity_in_no'] != null
                ? provider.products[index]['quantity_in_no'].toString()
                : null,
            validators: [
              FormBuilderValidators.required(),
              FormBuilderValidators.numeric(),
              FormBuilderValidators.min(
                0,
                errorText: 'Quantity must be positive',
              ),
            ],
            fillColor: const Color(0xFFF8FAFC),
            borderColor: Colors.grey.shade300,
            focusedBorderColor: const Color(0xFF3B82F6),
            borderRadius: 12.r,
            onTap: () => _scrollToFocusedField(
              context,
              _productFocusNodes.length > index
                  ? _productFocusNodes[index]['planned_quantity']!
                  : FocusNode(),
            ),
          ),

          SizedBox(height: 18.h),

          ReusableDateFormField(
            name: 'planned_date_$index',
            hintText: 'Schedule Date',
            inputType: InputType.date,
            fillColor: const Color(0xFFF8FAFC),
            borderColor: Colors.grey.shade300,
            focusedBorderColor: const Color(0xFF3B82F6),
            borderRadius: 12.r,
            validators: [
              FormBuilderValidators.required(
                errorText: 'Please select a schedule date for product ${index + 1}',
              ),
              (value) {
                if (value == null) return null;
                final dateRange = _formKey.currentState?.fields['date_range']?.value as DateTimeRange?;
                if (dateRange == null) {
                  return 'Please select a date range first';
                }
                final selectedDate = value is DateTime ? value : DateTime.tryParse(value.toString());
                if (selectedDate == null) {
                  return 'Invalid date format for product ${index + 1}';
                }
                // Strip time part to compare only dates
                final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                final startDateOnly = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
                final endDateOnly = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
                if (selectedDateOnly.isBefore(startDateOnly) || selectedDateOnly.isAfter(endDateOnly)) {
                  return 'Schedule date for product ${index + 1} must be between ${startDateOnly.day}/${startDateOnly.month}/${startDateOnly.year} and ${endDateOnly.day}/${endDateOnly.month}/${endDateOnly.year}';
                }
                return null;
              },
            ],
            onChanged: (value) {
              if (value == null) return;
              final dateRange = _formKey.currentState?.fields['date_range']?.value as DateTimeRange?;
              if (dateRange == null) {
                context.showWarningSnackbar('Please select a date range first.');
                return;
              }
              final selectedDate = value is DateTime ? value : DateTime.tryParse(value.toString());
              if (selectedDate == null) {
                context.showWarningSnackbar('Invalid date format for product ${index + 1}.');
                return;
              }
              // Strip time part to compare only dates
              final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
              final startDateOnly = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
              final endDateOnly = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
              if (selectedDateOnly.isBefore(startDateOnly) || selectedDateOnly.isAfter(endDateOnly)) {
                context.showWarningSnackbar(
                  'Schedule date for product ${index + 1} must be between ${startDateOnly.day}/${startDateOnly.month}/${startDateOnly.year} and ${endDateOnly.day}/${endDateOnly.month}/${endDateOnly.year}.',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductButton(JobOrderProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            provider.addProductSection();
            _initializeProductFocusNodes(provider.products.length);
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Another Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
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

  Widget _buildSubmitButton(BuildContext context, JobOrderProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final formData = _formKey.currentState!.value;

              try {
                // Find the selected work order's ID
                final selectedWO = provider.workOrderDetails.firstWhere(
                  (e) => e['work_order_number'] == formData['work_order'],
                  orElse: () => {},
                );
                final workOrderId =
                    selectedWO['id']?.toString() ??
                    selectedWO['_id']?.toString();

                // Validate workOrderId
                if (workOrderId == null || workOrderId.isEmpty) {
                  context.showWarningSnackbar("Invalid work order selected.");
                  return;
                }

                // Construct products list payload
                final products = <Map<String, dynamic>>[];

                for (int index = 0; index < provider.products.length; index++) {
                  final productData = provider.products[index];
                  final productValue = formData['product_$index'];

                  // Find the selected product
                  final selectedProduct = provider.availableProducts.firstWhere(
                    (product) {
                      final description =
                          product['description']?.toString() ??
                          'No Description';
                      final materialCode =
                          product['material_code']?.toString() ?? 'No Code';
                      return '$description - $materialCode' == productValue;
                    },
                    orElse: () => {},
                  );

                  // Validate product_id
                  final productId =
                      productData['product_id']?.toString() ??
                      selectedProduct['product_id']?.toString();
                  if (productId == null || productId.isEmpty) {
                    throw Exception(
                      'Invalid product ID for product ${index + 1}',
                    );
                  }

                  // Get machine ID from the machine data
                  final machineDisplayName = formData['machine_name_$index']
                      ?.toString();
                  if (machineDisplayName == null ||
                      machineDisplayName.isEmpty) {
                    throw Exception(
                      'Please select a machine for product ${index + 1}',
                    );
                  }

                  // Find the machine ID from the stored machine data
                  final machineData = provider.getMachineDataForProduct(index);
                  if (machineData == null || machineData.isEmpty) {
                    throw Exception(
                      'No machine data available for product ${index + 1}',
                    );
                  }

                  final selectedMachine = machineData.firstWhere(
                    (machine) =>
                        machine['name']?.toString() == machineDisplayName,
                    orElse: () => {},
                  );

                  final machineId =
                      selectedMachine['id']?.toString() ??
                      selectedMachine['_id']?.toString();

                  if (machineId == null || machineId.isEmpty) {
                    throw Exception(
                      'Invalid machine ID for product ${index + 1}',
                    );
                  }

                  // Format scheduled date
                  final scheduledDate = formData['planned_date_$index'];
                  String formattedScheduledDate = '';
                  if (scheduledDate is DateTime) {
                    formattedScheduledDate =
                        '${scheduledDate.toIso8601String()}Z';
                  } else if (scheduledDate != null) {
                    // Try to parse if it's a string
                    try {
                      final parsedDate = DateTime.parse(
                        scheduledDate.toString(),
                      );
                      formattedScheduledDate =
                          '${parsedDate.toIso8601String()}Z';
                    } catch (e) {
                      throw Exception(
                        'Invalid scheduled date format for product ${index + 1}',
                      );
                    }
                  } else {
                    throw Exception(
                      'Scheduled date is required for product ${index + 1}',
                    );
                  }

                  // Map UOM to backend format
                  final uom = formData['uom_$index'];
                  final formattedUom = uom == 'Square Meter/No'
                      ? 'sqmt'
                      : uom == 'Meter/No'
                      ? 'meter'
                      : null;

                  if (formattedUom == null) {
                    throw Exception(
                      'Invalid UOM selected for product ${index + 1}',
                    );
                  }

                  // Parse planned quantity
                  final plannedQuantityStr =
                      formData['planned_quantity_$index']?.toString() ?? '0';
                  final plannedQuantity = int.tryParse(plannedQuantityStr) ?? 0;

                  if (plannedQuantity <= 0) {
                    throw Exception(
                      'Planned quantity must be greater than 0 for product ${index + 1}',
                    );
                  }

                  products.add({
                    'product': productId,
                    'machine_name': machineId, // This is actually machine ID
                    'planned_quantity': plannedQuantity,
                    'scheduled_date': formattedScheduledDate,
                    'uom': formattedUom,
                  });
                }

                // Validate products
                if (products.isEmpty) {
                  context.showWarningSnackbar(
                    "At least one product is required.",
                  );
                  return;
                }

                // Construct the full payload
                final dateRange = formData['date_range'] as DateTimeRange?;
                if (dateRange == null) {
                  context.showWarningSnackbar("Please select a date range.");
                  return;
                }

                // Parse batch number
                final batchNumberStr =
                    formData['batch_number']?.toString() ?? '0';
                final batchNumber = int.tryParse(batchNumberStr) ?? 0;

                if (batchNumber <= 0) {
                  context.showWarningSnackbar(
                    "Please enter a valid batch number.",
                  );
                  return;
                }

                final payload = {
                  'work_order': workOrderId,
                  'sales_order_number':
                      formData['sales_order_number']?.toString() ?? '',
                  'batch_number': batchNumber,
                  'date': {
                    'from': '${dateRange.start.toIso8601String()}Z',
                    'to': '${dateRange.end.toIso8601String()}Z',
                  },
                  'products': products,
                };

                // Log the payload for debugging
                print('Submitting Job Order Payload: ${jsonEncode(payload)}');

                // Call the repository to create the job order
                await provider.createJobOrder(payload);
                context.showSuccessSnackbar("Job Order submitted successfully");
                context.go(RouteNames.jobOrder);
              } catch (e) {
                context.showWarningSnackbar("Failed to submit Job Order: $e");
                print('Submission Error: $e');
              }
            } else {
              context.showWarningSnackbar(
                "Please fill in all required fields correctly.",
              );
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Submit Job Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
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
}