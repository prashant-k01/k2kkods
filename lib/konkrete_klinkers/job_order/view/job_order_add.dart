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
  };
  final List<Map<String, FocusNode>> _productFocusNodes = [];
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    // Initialize with one product section
    _addProductSection();
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

  void _addProductSection() {
    setState(() {
      _products.add({});
      _productFocusNodes.add({
        'product': FocusNode(),
        'machine_name': FocusNode(),
        'planned_quantity': FocusNode(),
      });
    });
  }

  void _removeProductSection(int index) {
    setState(() {
      _products.removeAt(index);
      _productFocusNodes[index].forEach((_, node) => node.dispose());
      _productFocusNodes.removeAt(index);
    });
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
          padding: EdgeInsets.all(24.w).copyWith(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
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
            context.go(RouteNames.jobOrder);
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
              options: ['Work Order 1', 'Work Order 2', 'Work Order 3'],
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
              labelText: 'Date Range (from & to)',
              hintText: 'Select Date Range (from & to)',
            ),
            SizedBox(height: 24.h),
            ..._products.asMap().entries.map((entry) {
              final index = entry.key;
              return _buildProductSection(context, index);
            }).toList(),
            SizedBox(height: 18.h),
            _buildAddProductButton(),
            SizedBox(height: 40.h),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(BuildContext context, int index) {
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
              if (_products.length > 1)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.sp,
                    color: const Color(0xFFF43F5E),
                  ),
                  onPressed: () => _removeProductSection(index),
                  tooltip: 'Remove Product',
                ),
            ],
          ),
          SizedBox(height: 16.h),
          CustomSearchableDropdownFormField(
            name: 'product_$index',
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
            name: 'machine_name_$index',
            labelText: 'Machine Name',
            hintText: 'Select Machine Name',
            prefixIcon: Icons.build,
            options: ['Machine 1', 'Machine 2', 'Machine 3'],
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
            name: 'uom_$index',
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
            name: 'planned_quantity_$index',
            keyboardType: TextInputType.number,
            labelText: 'Planned Quantity',
            hintText: 'Enter Planned Quantity',
            focusNode: _productFocusNodes[index]['planned_quantity'],
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
              _productFocusNodes[index]['planned_quantity']!,
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
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductButton() {
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
          onTap: _addProductSection,
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
              // Process form data
              final formData = _formKey.currentState!.value;
              _products.asMap().entries.map((entry) {
                final index = entry.key;
                return {
                  'product': formData['product_$index'],
                  'machine_name': formData['machine_name_$index'],
                  'uom': formData['uom_$index'],
                  'planned_quantity': formData['planned_quantity_$index'],
                  'planned_date': formData['planned_date_$index'],
                };
              }).toList();

              // Here you can handle the submission of formData and products
              context.showSuccessSnackbar("Job Order submitted successfully");
              context.go(RouteNames.jobOrder);
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
