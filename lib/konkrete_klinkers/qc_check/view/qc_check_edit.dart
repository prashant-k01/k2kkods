import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/qc_check/model/qc_check.dart';
import 'package:k2k/konkrete_klinkers/qc_check/provider/qc_check_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class QcCheckEditScreen extends StatefulWidget {
  final String qcCheckId;

  const QcCheckEditScreen({super.key, required this.qcCheckId});

  @override
  _QcCheckEditScreenState createState() => _QcCheckEditScreenState();
}

class _QcCheckEditScreenState extends State<QcCheckEditScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<QcCheckProvider>(context, listen: false);
      final qcCheck = provider.qcChecks.firstWhere(
        (qc) => qc.id == widget.qcCheckId,
        orElse: () => throw Exception('QC check not found'),
      );
      provider.loadWorkOrderAndProducts(qcCheck.jobOrder ?? '');
      provider.loadJobOrders();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.qcCheck);
        }
      },
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBars(
            title: TitleText(title: 'Edit QC Check'),
            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.qcCheck),
            ),
          ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Consumer<QcCheckProvider>(
                builder: (context, provider, child) {
                  final qcCheck = provider.qcChecks.firstWhere(
                    (qc) => qc.id == widget.qcCheckId,
                    orElse: () => throw Exception('QC check not found'),
                  );
                  return ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w).copyWith(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                    ),
                    children: [_buildFormCard(context, provider, qcCheck)],
                  );
                },
              ),
            ),
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
          'Edit QC Check',
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

  Widget _buildFormCard(
    BuildContext context,
    QcCheckProvider provider,
    QcCheckModel qcCheck,
  ) {
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
          'job_order': qcCheck.jobOrderNumber,
          'work_order': qcCheck.workOrderNumber,
          'rejected_quantity': qcCheck.rejectedQuantity.toString(),
          'recycled_quantity': qcCheck.recycledQuantity.toString(),
          'rejected_reasons': qcCheck.remarks,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit QC Check Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Update the required information below',
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
              options: provider.jobOrders
                  .map((job) => job['job_order_id']!)
                  .toList(),
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
              onChanged: (value) {
                if (value != null) {
                  final selectedJob = provider.jobOrders.firstWhere(
                    (job) => job['job_order_id'] == value,
                  );
                  provider.loadWorkOrderAndProducts(selectedJob['_id']!);
                }
              },
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
              hintText: provider.isWorkOrderAndProductsLoading
                  ? 'Loading Work Order...'
                  : provider.workOrder == null
                  ? 'Select Job Order First'
                  : 'Select Work Order',
              prefixIcon: Icons.work,
              options: provider.workOrder != null
                  ? [provider.workOrder!['work_order_number']!]
                  : [],
              enabled:
                  !provider.isWorkOrderAndProductsLoading &&
                  provider.workOrder != null,
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
            CustomTextFormField(
              name: 'product_name',
              labelText: 'Product Name',
              hintText: 'Product cannot be changed',
              prefixIcon: Icons.inventory_2,
              enabled: false,
              initialValue: '',
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              borderRadius: 12.r,
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
            _buildSubmitButton(context, qcCheck),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, QcCheckModel qcCheck) {
    return Consumer<QcCheckProvider>(
      builder: (context, provider, child) {
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
              onTap: provider.isUpdateQcCheckLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.saveAndValidate()) {
                        final formData = _formKey.currentState!.value;
                        final selectedJob = provider.jobOrders.firstWhere(
                          (job) => job['job_order_id'] == formData['job_order'],
                          orElse: () => {
                            '_id': qcCheck.jobOrder ?? '',
                            'job_order_id': formData['job_order'] ?? 'N/A',
                          },
                        );

                        final qcCheckData = {
                          'job_order': selectedJob['_id'],
                          'work_order':
                              provider.workOrder?['_id'] ??
                              qcCheck.workOrder ??
                              '',
                          'product_id': qcCheck.productId ?? '',
                          'rejected_quantity': int.parse(
                            formData['rejected_quantity'],
                          ),
                          'recycled_quantity': int.parse(
                            formData['recycled_quantity'],
                          ),
                          'remarks': formData['rejected_reasons'],
                          'updated_by': qcCheck.updatedBy ?? '',
                        };

                        try {
                          await provider.updateQcCheck(
                            widget.qcCheckId,
                            qcCheckData,
                          );
                          if (provider.error == null) {
                            context.showSuccessSnackbar(
                              'QC Check updated successfully',
                            );
                            context.go(RouteNames.qcCheck);
                          } else {
                            context.showErrorSnackbar(provider.error!);
                          }
                        } catch (e) {
                          context.showErrorSnackbar(
                            'Failed to update QC check: $e',
                          );
                        }
                      }
                    },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.isUpdateQcCheckLoading)
                      SizedBox(
                        width: 20.sp,
                        height: 20.sp,
                        child: GradientLoader(),
                      )
                    else
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    SizedBox(width: 8.w),
                    Text(
                      provider.isUpdateQcCheckLoading
                          ? 'Updating...'
                          : 'Update QC Check',
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
        );
      },
    );
  }
}
