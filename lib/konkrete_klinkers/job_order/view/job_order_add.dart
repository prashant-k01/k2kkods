import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/date_picker.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/ranger_date_pciker.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/konkrete_klinkers/job_order/provider/job_order_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class JobOrdersFormScreen extends StatefulWidget {
  const JobOrdersFormScreen({super.key});

  @override
  _JobOrdersFormScreenState createState() => _JobOrdersFormScreenState();
}

class _JobOrdersFormScreenState extends State<JobOrdersFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<JobOrderProvider>();
      provider.initializeFormForCreate(); // Initialize form for creation
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JobOrderProvider>(
      builder: (context, provider, _) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              context.go(RouteNames.jobOrder);
            }
          },
          child: Container(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: Scaffold(
              backgroundColor: AppColors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBars(
                title: TitleText(title: 'Create Job Order'),
                leading: CustomBackButton(
                  onPressed: () {
                    context.go(RouteNames.jobOrder);
                  },
                ),
              ),
              body: SafeArea(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: provider.isFormLoading
                      ? const Center(child: GradientLoader())
                      : provider.formError != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                provider.formError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () =>
                                    provider.initializeFormForCreate(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          controller: _scrollController,
                          padding: EdgeInsets.all(24.w).copyWith(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 24.h,
                          ),
                          children: [_buildFormCard(context, provider)],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormCard(BuildContext context, JobOrderProvider provider) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
            _buildWorkOrderDropdown(context, provider),
            SizedBox(height: 12.h),
            if (provider.selectedWorkOrder != null)
              _buildClientProjectDetails(context, provider),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'sales_order_number',
              labelText: 'Sales Order Number',
              hintText: 'Enter Sales Order Number',
              focusNode: provider.getFocusNode('sales_order_number'),
              prefixIcon: Icons.receipt,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              onTap: () => provider.scrollToFocusedField(
                context,
                _scrollController,
                'sales_order_number',
              ),
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'batch_number',
              labelText: 'Batch Number',
              hintText: 'Enter Batch Number',
              focusNode: provider.getFocusNode('batch_number'),
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
              onTap: () => provider.scrollToFocusedField(
                context,
                _scrollController,
                'batch_number',
              ),
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

  Widget _buildWorkOrderDropdown(
    BuildContext context,
    JobOrderProvider provider,
  ) {
    if (provider.isLoadingWorkOrderNumbers) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: const Center(child: GradientLoader()),
      );
    }
    if (provider.formError != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed to load work orders: ${provider.formError}',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () => provider.initializeFormForCreate(),
              child: const Text('Retry'),
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
        FormBuilderValidators.required(errorText: 'Please select a work order'),
      ],
      onChanged: (value) => provider.setSelectedWorkOrder(value),
    );
  }

  Widget _buildClientProjectDetails(
    BuildContext context,
    JobOrderProvider provider,
  ) {
    final selectedWO = provider.workOrderDetails.firstWhere(
      (e) => e['work_order_number'] == provider.selectedWorkOrder,
      orElse: () => {},
    );
    if (selectedWO.isEmpty) return const SizedBox.shrink();
    final clientName = selectedWO['client_id']?['name'] ?? 'Unknown Client';
    final projectName = selectedWO['project_id']?['name'] ?? 'Unknown Project';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
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
          _buildDetailSection(
            icon: Icons.business_center,
            label: 'CLIENT',
            value: clientName,
            iconColor: Colors.blue.shade700,
            backgroundColor: Colors.blue.shade50,
            borderColor: Colors.blue.shade100,
          ),
          SizedBox(height: 12.h),
          _buildDetailSection(
            icon: Icons.work_outline,
            label: 'PROJECT',
            value: projectName,
            iconColor: Colors.green.shade700,
            backgroundColor: Colors.green.shade50,
            borderColor: Colors.green.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(icon, size: 14.sp, color: iconColor),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade900,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(
    BuildContext context,
    int index,
    JobOrderProvider provider,
  ) {
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
                  onPressed: () => provider.removeProductSection(index),
                  tooltip: 'Remove Product',
                ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildProductDropdown(context, index, provider),
          SizedBox(height: 18.h),
          _buildMachineDropdown(context, index, provider),
          SizedBox(height: 18.h),
          CustomDropdownFormField<String>(
            name: 'uom_$index',
            labelText: 'UOM',
            enabled: false,
            items: ['Square Meter/No', 'Meter/No']
                .map(
                  (item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            hintText: 'Select UOM',
            prefixIcon: Icons.workspaces,
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
            focusNode: provider.getProductFocusNode(index, 'planned_quantity'),
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
            onTap: () => provider.scrollToFocusedField(
              context,
              _scrollController,
              'planned_quantity_$index',
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
                errorText:
                    'Please select a schedule date for product ${index + 1}',
              ),
              (value) {
                if (value == null) return null;
                final dateRange =
                    _formKey.currentState?.fields['date_range']?.value
                        as DateTimeRange?;
                if (dateRange == null) {
                  return 'Please select a date range first';
                }
                final selectedDate = value is DateTime
                    ? value
                    : DateTime.tryParse(value.toString());
                if (selectedDate == null) {
                  return 'Invalid date format for product ${index + 1}';
                }
                final selectedDateOnly = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                );
                final startDateOnly = DateTime(
                  dateRange.start.year,
                  dateRange.start.month,
                  dateRange.start.day,
                );
                final endDateOnly = DateTime(
                  dateRange.end.year,
                  dateRange.end.month,
                  dateRange.end.day,
                );
                if (selectedDateOnly.isBefore(startDateOnly) ||
                    selectedDateOnly.isAfter(endDateOnly)) {
                  return 'Schedule date for product ${index + 1} must be between ${startDateOnly.day}/${startDateOnly.month}/${startDateOnly.year} and ${endDateOnly.day}/${endDateOnly.month}/${endDateOnly.year}';
                }
                return null;
              },
            ],
            onChanged: (value) {
              if (value == null) return;
              final dateRange =
                  _formKey.currentState?.fields['date_range']?.value
                      as DateTimeRange?;
              if (dateRange == null) {
                context.showWarningSnackbar(
                  'Please select a date range first.',
                );
                return;
              }
              final selectedDate = value is DateTime
                  ? value
                  : DateTime.tryParse(value.toString());
              if (selectedDate == null) {
                context.showWarningSnackbar(
                  'Invalid date format for product ${index + 1}.',
                );
                return;
              }
              final selectedDateOnly = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
              );
              final startDateOnly = DateTime(
                dateRange.start.year,
                dateRange.start.month,
                dateRange.start.day,
              );
              final endDateOnly = DateTime(
                dateRange.end.year,
                dateRange.end.month,
                dateRange.end.day,
              );
              if (selectedDateOnly.isBefore(startDateOnly) ||
                  selectedDateOnly.isAfter(endDateOnly)) {
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

  Widget _buildProductDropdown(
    BuildContext context,
    int index,
    JobOrderProvider provider,
  ) {
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
    if (provider.formError != null) {
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
              provider.formError!.contains('500')
                  ? 'Server error occurred while loading products. Please try again.'
                  : provider.formError!,
              style: TextStyle(color: Colors.red.shade600, fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () {
                if (provider.selectedWorkOrder != null) {
                  final selectedWO = provider.workOrderDetails.firstWhere(
                    (e) => e['work_order_number'] == provider.selectedWorkOrder,
                    orElse: () => {},
                  );
                  final workOrderId =
                      selectedWO['id']?.toString() ??
                      selectedWO['_id']?.toString();
                  if (workOrderId != null)
                    provider.loadProductsByWorkOrder(workOrderId);
                }
              },
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
        final materialCode = product['material_code']?.toString() ?? 'No Code';
        return '$description - $materialCode';
      }).toList(),
      fillColor: const Color(0xFFF8FAFC),
      borderColor: Colors.grey.shade300,
      focusedBorderColor: const Color(0xFF3B82F6),
      borderRadius: 12.r,
      validators: [
        FormBuilderValidators.required(errorText: 'Please select a product'),
      ],
      onChanged: (value) =>
          provider.handleProductSelection(index, value, _formKey),
    );
  }

  Widget _buildMachineDropdown(
    BuildContext context,
    int index,
    JobOrderProvider provider,
  ) {
    final machineNames = provider.getMachineNamesForProduct(index);
    final isLoadingMachines = provider.isLoadingMachineNames(index);
    if (isLoadingMachines) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Center(
          child: Column(
            children: [
              const GradientLoader(),
              SizedBox(height: 12.h),
              Text(
                'Loading machines...',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }
    if (provider.formError != null && machineNames.isEmpty) {
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
                  color: AppTheme.errorColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Failed to load machines',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              provider.formError!.contains('500')
                  ? 'Server error occurred while loading machines. Please try again or contact support.'
                  : provider.formError!.contains('400')
                  ? 'Invalid material code. Please select a valid product or contact support.'
                  : provider.formError!,
              style: TextStyle(color: AppTheme.errorColor, fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () {
                final productId = provider.products.length > index
                    ? provider.products[index]['product_id']?.toString()
                    : null;
                if (productId != null)
                  provider.loadMachineNamesByProductId(index, productId);
              },
              icon: Icon(Icons.refresh, size: 16.sp),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: AppTheme.errorColor,
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
            Icon(Icons.build, color: Colors.grey.shade600, size: 20.sp),
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
      focusedBorderColor: AppTheme.primaryBlue,
      borderRadius: 12.r,
      validators: [
        FormBuilderValidators.required(errorText: 'Please select a machine'),
      ],
    );
  }

  Widget _buildAddProductButton(JobOrderProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
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
          onTap: () => provider.addProductSection(),
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
          onTap: provider.isAddJobOrderLoading
              ? null
              : () => provider.submitCreateForm(context, _formKey),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (provider.isAddJobOrderLoading)
                    const GradientLoader()
                  else
                    Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    provider.isAddJobOrderLoading
                        ? 'Submitting...'
                        : 'Submit Job Order',
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
