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
    'product': FocusNode(),
    'machine_name': FocusNode(),
    'planned_quantity': FocusNode(),
  };
  bool _showAdditionalFields = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  // Function to scroll to the focused text field
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
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(
            24.w,
          ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 24.h),
          itemCount: 1,
          itemBuilder: (context, index) => _buildFormCard(context),
        ),
      ),
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
            context.go(RouteNames.jobOrder); // Adjust route as needed
          },
        );
      },
    );
  }

  Widget _buildFormCard(BuildContext context) {
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
            CustomSearchableDropdownFormField(
              name: 'work_order',
              labelText: 'Work Order',
              hintText: 'Select Work Order',
              prefixIcon: Icons.work,
              options: [
                'Work Order 1',
                'Work Order 2',
                'Work Order 3',
              ], // Sample data
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a work order',
                ),
              ],
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
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
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
              labelText: 'Date Range(from & to)',
              hintText: 'Select Date Range(from & to)',
            ),
            SizedBox(height: 18.h),
            _buildAddFieldsButton(context),
            if (_showAdditionalFields) ...[
              SizedBox(height: 18.h),
              CustomSearchableDropdownFormField(
                name: 'product',
                labelText: 'Product',
                hintText: 'Select Product',
                prefixIcon: Icons.inventory_2,
                options: ['Product A', 'Product B', 'Product C'],
                fillColor: const Color(0xFFF8FAFC),
                borderColor: Colors.grey.shade300,
                focusedBorderColor: const Color(0xFF3B82F6),
                borderRadius: 12.r,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please select a product',
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              CustomSearchableDropdownFormField(
                name: 'machine_name',
                labelText: 'Machine Name',
                hintText: 'Select Machine Name',
                prefixIcon: Icons.build,
                options: ['Machine 1', 'Machine 2', 'Machine 3'], // Sample data
                fillColor: const Color(0xFFF8FAFC),
                borderColor: Colors.grey.shade300,
                focusedBorderColor: const Color(0xFF3B82F6),
                borderRadius: 12.r,
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please select a machine',
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              CustomDropdownFormField<String>(
                name: 'uom',
                labelText: 'UOM',
                initialValue: 'Square Meter/No',
                items: ['Square Meter/No', 'Meter/No']
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
              ),
              SizedBox(height: 18.h),
              CustomTextFormField(
                name: 'planned_quantity',
                keyboardType: TextInputType.number,
                labelText: 'Planned Quantity',
                hintText: 'Enter Planned Quantity',
                focusNode: _focusNodes['planned_quantity'],
                prefixIcon: Icons.numbers,
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
                  _focusNodes['planned_quantity']!,
                ),
              ),
              SizedBox(height: 18.h),
              ReusableDateFormField(
                name: 'planned_date',
                hintText: 'Schedule Date',
                inputType: InputType.date,
                fillColor: const Color(0xFFF8FAFC),
                borderColor: Colors.grey.shade300,
                focusedBorderColor: const Color(0xFF3B82F6),
                borderRadius: 12.r,
              ),

              SizedBox(height: 40.h),
              _buildSubmitButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddFieldsButton(BuildContext context) {
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
            setState(() {
              _showAdditionalFields = true;
            });
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
                    'Add Product',
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
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              context.showSuccessSnackbar("Job Order submitted successfully");
              // context.go(RouteNames.jobOrders); // Adjust route as needed
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
