import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/utils/theme.dart';
import 'package:k2k/app/routes_name.dart';

class StockManagementFormScreen extends StatefulWidget {
  const StockManagementFormScreen({super.key});

  @override
  State<StockManagementFormScreen> createState() => _StockManagementFormScreenState();
}

class _StockManagementFormScreenState extends State<StockManagementFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.dispatch); // Adjust route as needed
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
            children: [
              _buildFormCard(context),
            ],
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
          'Stock Management',
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
            context.go(RouteNames.dispatch); // Adjust route as needed
          },
          tooltip: 'Back',
        );
      },
    );
  }

  Widget _buildFormCard(BuildContext context) {
    // Placeholder lists for dropdown options (to be replaced with actual data)
    const List<String> products = ['Product A', 'Product B', 'Product C'];
    const List<String> workOrders = ['WO001', 'WO002', 'WO003'];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Transfer Details',
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
          FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchableDropdownFormField(
                  name: 'product',
                  labelText: 'Product',
                  hintText: 'Select product',
                  prefixIcon: Icons.inventory,
                  options: products,
                  enabled: true,
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: AppTheme.primaryBlue,
                  errorBorderColor: AppTheme.errorColor,
                  borderRadius: 12.r,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a product',
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                CustomSearchableDropdownFormField(
                  name: 'from_work_order',
                  labelText: 'From Work Order',
                  hintText: 'Select source work order',
                  prefixIcon: Icons.work,
                  options: workOrders,
                  enabled: true,
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: AppTheme.primaryBlue,
                  errorBorderColor: AppTheme.errorColor,
                  borderRadius: 12.r,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a source work order',
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                CustomSearchableDropdownFormField(
                  name: 'to_work_order',
                  labelText: 'To Work Order',
                  hintText: 'Select destination work order',
                  prefixIcon: Icons.work,
                  options: workOrders,
                  enabled: true,
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: AppTheme.primaryBlue,
                  errorBorderColor: AppTheme.errorColor,
                  borderRadius: 12.r,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a destination work order',
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                CustomTextFormField(
                  name: 'quantity',
                  labelText: 'Quantity to Transfer',
                  hintText: 'Enter quantity',
                  prefixIcon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please enter quantity',
                    ),
                    FormBuilderValidators.numeric(
                      errorText: 'Please enter a valid number',
                    ),
                    FormBuilderValidators.min(
                      1,
                      errorText: 'Quantity must be greater than 0',
                    ),
                  ],
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: AppTheme.primaryBlue,
                  errorBorderColor: AppTheme.errorColor,
                  borderRadius: 12.r,
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
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          // Form submission logic to be implemented later
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
                      child: Text(
                        'Transfer Stock',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: const Color(0xFF64748B),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        ' Note\n\nAll information is kept confidential and used only for stock management purposes',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}