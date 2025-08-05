import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/packing/provider/packing_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class AddPackingFormScreen extends StatefulWidget {
  const AddPackingFormScreen({super.key});

  @override
  State<AddPackingFormScreen> createState() => _AddPackingFormScreenState();
}

class _AddPackingFormScreenState extends State<AddPackingFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _qrFormKey = GlobalKey<FormBuilderState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        context.read<PackingProvider>().loadWorkOrdersAndProducts();
      }
    });
  }

  void _showQrCodeDialog(String packingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Enter QR Code',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: FormBuilder(
          key: _qrFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                name: 'qr_code',
                labelText: 'Bundle 1',
                hintText: 'Enter QR code',
                prefixIcon: Icons.qr_code,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please enter a QR code',
                  ),
                ],
                fillColor: const Color(0xFFF8FAFC),
                borderColor: Colors.grey.shade300,
                focusedBorderColor: const Color(0xFF3B82F6),
                borderRadius: 12.r,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_qrFormKey.currentState?.saveAndValidate() ?? false) {
                final qrCode = _qrFormKey.currentState!.value['qr_code'];
                try {
                  await context.read<PackingProvider>().submitQrCode(
                    packingId,
                    qrCode,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.showSuccessSnackbar(
                      'QR code submitted successfully!',
                    );
                    context.go(RouteNames.packing);
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorSnackbar('Failed to submit QR code: $e');
                  }
                }
              } else {
                if (context.mounted) {
                  context.showWarningSnackbar('Please enter a valid QR code');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Submit QR Code', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.packing);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: _buildLogoAndTitle(),
          leading: _buildBackButton(),
          action: [],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildFormCard(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add Packing',
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
            context.go(RouteNames.packing);
          },
          tooltip: 'Back',
        );
      },
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Consumer<PackingProvider>(
      builder: (context, provider, _) {
        print('Form key state: ${_formKey.currentState}'); // Debug log
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
            initialValue: {
              'bundle_size': provider.bundleSize?.toString() ?? '',
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Packing Details',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Enter the required information below',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (provider.error != null) ...[
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      provider.error!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFF43F5E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                SizedBox(height: 24.h),

                // Work Order Dropdown
                CustomSearchableDropdownFormField(
                  name: 'work_order_id',
                  labelText: 'Work Order',
                  hintText: provider.workOrders.isEmpty
                      ? 'No work orders available'
                      : 'Search work order',
                  prefixIcon: Icons.work,
                  options: provider.workOrders
                      .map((wo) => wo['number'] ?? '')
                      .toList(),
                  enabled: provider.workOrders.isNotEmpty,
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
                    provider.selectWorkOrder(value, _formKey);
                  },
                ),
                SizedBox(height: 24.h),

                // Product Name Dropdown
                CustomSearchableDropdownFormField(
                  name: 'product',
                  labelText: 'Product Name',
                  hintText: provider.products.isEmpty
                      ? 'Select a work order first'
                      : 'Search product',
                  prefixIcon: Icons.inventory,
                  options: provider.products
                      .map((product) => product['name'] ?? '')
                      .toList(),
                  enabled: provider.products.isNotEmpty,
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
                    provider.selectProduct(value, _formKey);
                  },
                ),
                SizedBox(height: 24.h),
                CustomTextFormField(
                  name: 'product_quantity',
                  labelText: 'Total Quantity',
                  hintText: 'Enter total quantity',
                  prefixIcon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please enter total quantity',
                    ),
                    FormBuilderValidators.numeric(
                      errorText: 'Must be a valid number',
                    ),
                    FormBuilderValidators.min(
                      1,
                      errorText: 'Must be at least 1',
                    ),
                  ],
                  fillColor: const Color(0xFFF8FAFC),
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: const Color(0xFF3B82F6),
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),
                CustomTextFormField(
                  name: 'bundle_size',
                  labelText: 'Quantity per Bundle',
                  hintText: provider.isLoading
                      ? 'Fetching bundle size...'
                      : provider.bundleSize != null
                      ? provider.bundleSize.toString()
                      : 'Select a product to see bundle size',
                  prefixIcon: Icons.widgets,
                  keyboardType: TextInputType.number,
                  enabled: false,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Bundle size is required',
                    ),
                    FormBuilderValidators.numeric(
                      errorText: 'Must be a number',
                    ),
                    FormBuilderValidators.min(
                      1,
                      errorText: 'Must be at least 1',
                    ),
                  ],
                  fillColor: const Color(0xFFF1F5F9),
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: const Color(0xFF3B82F6),
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),
                FormBuilderDropdown<String>(
                  name: 'uom',
                  decoration: InputDecoration(
                    labelText: 'Unit of Measure',
                    hintText: 'Select unit of measure',
                    prefixIcon: Icon(Icons.straighten, size: 20.sp),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                    ),
                  ),
                  items: ['sqmt', 'nos']
                      .map(
                        (uom) => DropdownMenuItem(
                          value: uom,
                          child: Text(uom, style: TextStyle(fontSize: 14.sp)),
                        ),
                      )
                      .toList(),
                  validator: FormBuilderValidators.required(
                    errorText: 'Please select a unit of measure',
                  ),
                  dropdownColor: Colors.white,
                  isExpanded: true,
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState?.saveAndValidate() ??
                                  false) {
                                final formData = _formKey.currentState!.value;
                                final packingData = {
                                  'work_order': provider.selectedWorkOrderId,
                                  'product': provider.selectedProductId,
                                  'product_quantity':
                                      int.tryParse(
                                        formData['product_quantity'].toString(),
                                      ) ??
                                      0,
                                  'bundle_size': provider.bundleSize ?? 0,
                                  'uom': formData['uom'],
                                };
                                print(
                                  'Submitting Packing Data: $packingData',
                                ); // Debug log

                                try {
                                  final packing = await provider.createPacking(
                                    packingData,
                                  );
                                  if (provider.error == null) {
                                    context.showSuccessSnackbar(
                                      "'Packing added successfully!'",
                                    );
                                    _showQrCodeDialog(packing.id);
                                  } else {
                                    context.showErrorSnackbar("Error");
                                  }
                                } catch (e) {
                                  print('Error during packing creation: $e');
                                  context.showErrorSnackbar(
                                    "Failed to add packing: $e",
                                  );
                                }
                              } else {
                                print('Form validation failed'); // Debug log
                                context.showWarningSnackbar(
                                  "Please fill all required fields correctly",
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: provider.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Add Packing',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
