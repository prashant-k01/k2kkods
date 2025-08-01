import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/qc_check/provider/qc_check_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class QcCheckFormScreen extends StatefulWidget {
  const QcCheckFormScreen({super.key});

  @override
  _QcCheckFormScreenState createState() => _QcCheckFormScreenState();
}

class _QcCheckFormScreenState extends State<QcCheckFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch job orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QcCheckProvider>(context, listen: false).loadJobOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true,
      appBar: AppBars(
        title: _buildLogoAndTitle(),
        leading: _buildBackButton(),
        action: [],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Consumer<QcCheckProvider>(
          builder: (context, provider, child) {
            return ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(24.w).copyWith(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              children: [
                _buildFormCard(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add QC Check',
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
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 24.sp,
        color: const Color(0xFF334155),
      ),
      onPressed: () => context.go(RouteNames.qcCheck),
    );
  }

  Widget _buildFormCard(BuildContext context, QcCheckProvider provider) {
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
              'QC Check Details',
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
            CustomSearchableDropdownFormField(
              name: 'job_order',
              labelText: 'Job Order',
              hintText: provider.isJobOrdersLoading
                  ? 'Loading Job Orders...'
                  : 'Select Job Order',
              prefixIcon: Icons.work_outline,
              options: provider.jobOrders,
              enabled: !provider.isJobOrdersLoading,
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a job order',
                ),
              ],
            ),
            if (provider.error != null) ...[
              SizedBox(height: 8.h),
              Text(
                provider.error!,
                style: TextStyle(color: Colors.red, fontSize: 12.sp),
              ),
            ],
            SizedBox(height: 18.h),
            CustomSearchableDropdownFormField(
              name: 'work_order',
              labelText: 'Work Order',
              hintText: 'Select Work Order',
              prefixIcon: Icons.work,
              options: const [
                'WO001 - Project X',
                'WO002 - Project Y',
                'WO003 - Project Z',
              ], // Replace with dynamic data if needed
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a work order',
                ),
              ],
            ),
            SizedBox(height: 18.h),
            CustomSearchableDropdownFormField(
              name: 'product_name',
              labelText: 'Product Name',
              hintText: 'Select Product',
              prefixIcon: Icons.inventory_2,
              options: const [
                'Product A - P001',
                'Product B - P002',
                'Product C - P003',
              ], 
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a product',
                ),
              ],
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'rejected_quantity',
              labelText: 'Rejected Quantity',
              hintText: 'Enter Rejected Quantity',
              prefixIcon: Icons.warning_amber_outlined,
              keyboardType: TextInputType.number,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(
                  0,
                  errorText: 'Quantity must be non-negative',
                ),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              borderRadius: 12.r,
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'recycled_quantity',
              labelText: 'Recycled Quantity',
              hintText: 'Enter Recycled Quantity',
              prefixIcon: Icons.recycling_outlined,
              keyboardType: TextInputType.number,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.numeric(),
                FormBuilderValidators.min(
                  0,
                  errorText: 'Quantity must be non-negative',
                ),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              borderRadius: 12.r,
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'rejected_reasons',
              labelText: 'Rejected Reasons',
              hintText: 'Enter Reasons for Rejection',
              prefixIcon: Icons.comment_outlined,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(
                  2,
                  errorText: 'Reason must be at least 2 characters',
                ),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              borderRadius: 12.r,
            ),
            SizedBox(height: 40.h),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
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
            if (_formKey.currentState!.saveAndValidate()) {
              // Placeholder for form submission logic
              context.showSuccessSnackbar("Form Submitted Successfully");
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
                    'Submit QC Check',
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