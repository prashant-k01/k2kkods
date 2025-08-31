import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/job_order/provider/job_order_provider_is.dart';
import 'package:k2k/Iron_smith/workorder/model/iron_workorder_model.dart';
import 'package:k2k/Iron_smith/workorder/provider/iron_workorder_provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/date_picker.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/ranger_date_pciker.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

extension ContextExtensions on BuildContext {
  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showWarningSnackbar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class IronJoborderAddScreen extends StatefulWidget {
  const IronJoborderAddScreen({super.key});

  @override
  State<IronJoborderAddScreen> createState() => _IronJoborderAddScreenState();
}

class _IronJoborderAddScreenState extends State<IronJoborderAddScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workOrderProvider = Provider.of<IronWorkorderProvider>(
        context,
        listen: false,
      );
      final JobOrderProviderIS jobOrderProvider =
          Provider.of<JobOrderProviderIS>(context, listen: false);
      print('DEBUG: Initializing IronJoborderAddScreen');
      print(
        'DEBUG: WorkOrderProvider workOrders length: ${workOrderProvider.workOrders.length}',
      );
      print('DEBUG: JobOrderProviderIS jobOrder: ${jobOrderProvider.jobOrder}');
      workOrderProvider.loadWorkOrders();
      jobOrderProvider.initializeDefaultProduct();
    });
  }

  @override
  void dispose() {
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  FocusNode _getFocusNode(String key) {
    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
    }
    return _focusNodes[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.getAllIronWO);
        }
      },
      child: Consumer2<JobOrderProviderIS, IronWorkorderProvider>(
        builder: (context, jobOrderProvider, workOrderProvider, child) {
          return Container(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: AppColors.transparent,
              appBar: AppBars(
                title: TitleText(title: 'Create Job Order'),
                leading: CustomBackButton(
                  onPressed: () => context.go(RouteNames.ironJobOrder),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        _buildMainFormCard(
                          context,
                          jobOrderProvider,
                          workOrderProvider,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: _buildFixedSubmitButton(
                context,
                jobOrderProvider,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainFormCard(
    BuildContext context,
    JobOrderProviderIS jobOrderProvider,
    IronWorkorderProvider workOrderProvider,
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
              'Job Order Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 12.h),
            _buildWorkOrderDropdown(
              context,
              workOrderProvider,
              jobOrderProvider,
            ),
            SizedBox(height: 12.h),
            _buildClientProjectDetails(context, jobOrderProvider),
            SizedBox(height: 12.h),
            CustomTextFormField(
              name: 'sales_order_number',
              labelText: 'Sales Order No',
              hintText: 'Enter Sales Order No.',
              fillColor: AppColors.background,
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
                  errorText: 'Sales Order Number is required',
                ),
              ],
              onChanged: (value) =>
                  jobOrderProvider.setSalesOrderNumber(value ?? ''),
            ),
            SizedBox(height: 12.h),
            CustomRangeDatePicker(
              name: 'date_range',
              labelText: 'Date Range (from & to)',
              hintText: 'Select Date Range (from & to)',
              // onChanged: (value) {
              //   if (value != null) {
              //     jobOrderProvider.setDateRange(value);
              //   }
              // },
            ),
            SizedBox(height: 12.h),
            CustomSearchableDropdownFormField<String>(
              key: ValueKey('machine${jobOrderProvider.selectedMachine ?? ''}'),
              name: 'machine',
              labelText: 'Machine',
              prefixIcon: Icons.build,
              iconSize: 18.sp,
              textStyle: TextStyle(fontSize: 14.sp),
              labelStyle: TextStyle(fontSize: 14.sp),
              fillColor: AppColors.background,
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              options: const [
                'Machine A',
                'Machine B',
                'Machine C',
                'Machine D',
              ],
              optionLabel: (machine) => machine,
              initialValue: jobOrderProvider.selectedMachine,
              onChanged: (machine) {
                jobOrderProvider.setMachine(machine);
              },
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Machine is required',
                ),
              ],
              allowClear: true,
            ),
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
            _buildProductForms(jobOrderProvider),
            SizedBox(height: 12.h),
            _buildAddProductButton(jobOrderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOrderDropdown(
    BuildContext context,
    IronWorkorderProvider workOrderProvider,
    JobOrderProviderIS jobOrderProvider,
  ) {
    if (workOrderProvider.isLoading) {
      print('DEBUG: WorkOrderProvider is loading work orders');
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: const Center(child: GradientLoader()),
      );
    }
    if (workOrderProvider.errorMessage != null) {
      print(
        'DEBUG: WorkOrderProvider error: ${workOrderProvider.errorMessage}',
      );
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed to load work orders: ${workOrderProvider.errorMessage}',
              style: TextStyle(color: Colors.red, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () => workOrderProvider.loadWorkOrders(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (workOrderProvider.workOrders.isEmpty) {
      print('DEBUG: WorkOrderProvider workOrders is empty');
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          'No work orders available',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }
    print(
      'DEBUG: WorkOrderProvider workOrders count: ${workOrderProvider.workOrders.length}',
    );
    return CustomSearchableDropdownFormField<IronWorkOrderData>(
      key: ValueKey(
        'work_order${jobOrderProvider.selectedWorkOrder?.id ?? ''}',
      ),
      name: 'work_order',
      labelText: 'Work Order',
      hintText: 'Select Work Order',
      prefixIcon: Icons.work,
      iconSize: 18.sp,
      textStyle: TextStyle(fontSize: 14.sp),
      labelStyle: TextStyle(fontSize: 14.sp),
      fillColor: const Color(0xFFF8FAFC),
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      borderColor: Colors.grey.shade300,
      focusedBorderColor: const Color(0xFF3B82F6),
      borderRadius: 12.r,
      options: workOrderProvider.workOrders,
      optionLabel: (workOrder) => workOrder.workOrderNumber ?? '',
      initialValue: jobOrderProvider.selectedWorkOrder,
      onChanged: (workOrder) async {
        print(
          'DEBUG: Selected work order: ${workOrder?.id} - ${workOrder?.workOrderNumber}',
        );
        jobOrderProvider.setWorkOrder(workOrder);
        if (workOrder != null && workOrder.id != null) {
          try {
            print('DEBUG: Fetching work order details for ID: ${workOrder.id}');
            await jobOrderProvider.fetchWorkOrderById(workOrder.id!);
            print(
              'DEBUG: fetchWorkOrderById completed, jobOrder: ${jobOrderProvider.jobOrder}',
            );
          } catch (e) {
            print('DEBUG: Error fetching work order details: $e');
            context.showErrorSnackbar('Failed to fetch work order details: $e');
          }
        } else {
          print('DEBUG: No work order ID provided');
        }
      },
      validators: [
        FormBuilderValidators.required(errorText: 'Please select a work order'),
      ],
      allowClear: true,
    );
  }

  Widget _buildClientProjectDetails(
    BuildContext context,
    JobOrderProviderIS provider,
  ) {
    print(
      'DEBUG: Building client/project details, jobOrder: ${provider.jobOrder}',
    );
    if (provider.jobOrder == null) {
      print('DEBUG: jobOrder is null, showing empty widget');
      return const SizedBox.shrink();
    }
    final clientName = provider.jobOrder?.client?.name ?? 'Unknown Client';
    final projectName = provider.jobOrder?.project?.name ?? 'Unknown Project';
    print('DEBUG: Client name: $clientName, Project name: $projectName');
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
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductForms(JobOrderProviderIS provider) {
    return SingleChildScrollView(
      child: Column(
        children: provider.products.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> product = entry.value;

          return Container(
            key: ValueKey('product_$index'),
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEDE9FE),
                  const Color(0xFFF5F3FF),
                  const Color(0xFFFFFFFF),
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
                  key: GlobalKey<FormBuilderState>(),
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
                      CustomSearchableDropdownFormField<String>(
                        key: ValueKey(
                          'shape_$index${product['shapeCode'] ?? ''}',
                        ),
                        name: 'shape_$index',
                        labelText: 'Shape',
                        prefixIcon: Icons.category,
                        iconSize: 18.sp,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        options: const [
                          'Circle',
                          'Square',
                          'Rectangle',
                          'Custom',
                        ],
                        optionLabel: (shape) => shape,
                        initialValue: product['shapeCode'],
                        onChanged: (shape) {
                          provider.updateProduct(index, {'shapeCode': shape});
                          _formKey.currentState?.fields['shape_$index']
                              ?.didChange(shape);
                        },
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Shape is required',
                          ),
                        ],
                        allowClear: true,
                      ),
                      SizedBox(height: 12.h),
                      CustomSearchableDropdownFormField<String>(
                        key: ValueKey(
                          'diameter_$index${product['diameter'] ?? ''}',
                        ),
                        name: 'diameter_$index',
                        labelText: 'Diameter (mm)',
                        prefixIcon: Icons.circle,
                        iconSize: 18.sp,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        options: const [
                          '100',
                          '150',
                          '200',
                          '250',
                          '300',
                          '350',
                          '400',
                        ],
                        optionLabel: (diameter) => diameter,
                        initialValue: product['diameter'],
                        onChanged: (diameter) {
                          provider.updateProduct(index, {'diameter': diameter});
                          _formKey.currentState?.fields['diameter_$index']
                              ?.didChange(diameter);
                        },
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Diameter is required',
                          ),
                        ],
                        allowClear: true,
                      ),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        key: ValueKey('planned_quantity_$index'),
                        name: 'planned_quantity_$index',
                        labelText: 'Planned Quantity',
                        hintText: 'Enter planned quantity',
                        prefixIcon: Icons.numbers,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: product['plannedQuantity']?.toString(),
                        keyboardType: TextInputType.number,
                        focusNode: _getFocusNode('planned_quantity_$index'),
                        onChanged: (value) {
                          provider.updateProduct(index, {
                            'plannedQuantity': int.tryParse(value ?? '0') ?? 0,
                          });
                        },
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Planned Quantity is required',
                          ),
                          FormBuilderValidators.numeric(
                            errorText: 'Must be a number',
                          ),
                          FormBuilderValidators.min(
                            0,
                            errorText: 'Planned Quantity must be positive',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ReusableDateFormField(
                        name: 'schedule_date',
                        labelText: 'Schedule Date',
                        hintText: 'Select date',
                        prefixIcon: Icons.calendar_today_outlined,
                        iconSize: 18.sp,
                        textStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
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
                            errorText: 'Schedule Date is required',
                          ),
                        ],
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        format: DateFormat('dd-MM-yyyy'),
                        // onChanged: (date) {
                        //   if (date != null) {
                        //     provider.setWorkOrderDate(date);
                        //   }
                        // },
                      ),
                      SizedBox(height: 12.h),
                      CustomSearchableDropdownFormField<String>(
                        key: ValueKey(
                          'machine_$index${product['machine'] ?? ''}',
                        ),
                        name: 'machine_$index',
                        labelText: 'Machine',
                        prefixIcon: Icons.build,
                        iconSize: 18.sp,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        options: const [
                          'Machine A',
                          'Machine B',
                          'Machine C',
                          'Machine D',
                        ],
                        optionLabel: (machine) => machine,
                        initialValue: product['machine'],
                        onChanged: (machine) {
                          provider.updateProduct(index, {'machine': machine});
                          _formKey.currentState?.fields['machine_$index']
                              ?.didChange(machine);
                        },
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Machine is required',
                          ),
                        ],
                        allowClear: true,
                      ),
                    ],
                  ),
                ),
                if (provider.products.length > 1)
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
                        onPressed: () => provider.removeProduct(index),
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

  Widget _buildAddProductButton(JobOrderProviderIS provider) {
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
            onTap: provider.addProduct,
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

  Widget _buildFixedSubmitButton(
    BuildContext context,
    JobOrderProviderIS provider,
  ) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: SizedBox(
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
                onTap: () => _submitForm(context, provider),
                borderRadius: BorderRadius.circular(8.r),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt, color: Colors.white, size: 18.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Add Job Order',
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
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    JobOrderProviderIS provider,
  ) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

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
                  'Creating Job Order...',
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
        final body = {
          'jobOrderId': provider.selectedWorkOrder?.id,
          'salesOrderNumber': formData['sales_order_number'] as String,
          'dateRange': {
            'start': provider.dateRange?.start.toIso8601String(),
            'end': provider.dateRange?.end.toIso8601String(),
          },
          'machine': formData['machine'] as String,
          'products': provider.products
              .map(
                (product) => {
                  'shapeCode': product['shapeCode'],
                  'diameter': product['diameter'],
                  'plannedQuantity': product['plannedQuantity'],
                  'scheduledDate': product['scheduledDate'] != null
                      ? {
                          'start': (product['scheduledDate'] as DateTimeRange)
                              .start
                              .toIso8601String(),
                          'end': (product['scheduledDate'] as DateTimeRange).end
                              .toIso8601String(),
                        }
                      : null,
                  'machine': product['machine'],
                },
              )
              .toList(),
        };

        print('DEBUG: Submitting job order with body: $body');
        final success = await provider.createJobOrder(body);
        print('DEBUG: createJobOrder result: $success');

        Navigator.of(context).pop();

        if (success && context.mounted) {
          context.showSuccessSnackbar('Job Order created successfully!');
          context.go(RouteNames.getAllIronWO);
        } else {
          context.showErrorSnackbar(
            'Failed to create job order. Please check your input and try again.',
          );
        }
      } catch (e) {
        print('DEBUG: Error in createJobOrder: $e');
        Navigator.of(context).pop();
        context.showErrorSnackbar('Error: $e');
      }
    } else {
      print('DEBUG: Form validation failed');
      context.showWarningSnackbar(
        'Please fill in all required fields correctly.',
      );
    }
  }
}
