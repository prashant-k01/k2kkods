import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/provider/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddProductFormScreen extends StatefulWidget {
  const AddProductFormScreen({super.key});

  @override
  _AddProductFormScreenState createState() => _AddProductFormScreenState();
}

class _AddProductFormScreenState extends State<AddProductFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ScrollController _scrollController = ScrollController();
  bool _showAreaPerUnit = true; // Set default to true for Square Meter/No

  // Function to parse dimensions and calculate area in square meters
  double? _calculateArea(String description) {
    try {
      // Extract dimensions using regex (e.g., 600X300X100MM)
      final RegExp dimensionRegex = RegExp(
        r'(\d+)X(\d+)X(\d+)MM',
        caseSensitive: false,
      );
      final match = dimensionRegex.firstMatch(description);

      if (match != null) {
        final length = double.parse(match.group(1)!);
        final width = double.parse(match.group(2)!);
        // Convert mm to meters and calculate area
        return (length / 1000) * (width / 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Function to scroll to the focused text field
  void _scrollToFocusedField(BuildContext context, FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        final RenderObject? object = context.findRenderObject();
        if (object is RenderBox) {
          final position = object.localToGlobal(Offset.zero);
          _scrollController.animateTo(
            position.dy - 100, // Adjust offset to keep field above keyboard
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final plantProvider = Provider.of<PlantProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: true, // Allow resizing when keyboard appears
      appBar: AppBars(
        title: _buildLogoAndTitle(),
        leading: _buildBackButton(),
        action: [],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss keyboard on tap outside
        },
        behavior: HitTestBehavior.opaque, // Capture taps everywhere
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(24.w).copyWith(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormCard(context, productProvider, plantProvider),
                  ],
                ),
              ),
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
          'Add Product',
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
            context.go(RouteNames.products);
          },
        );
      },
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    ProductProvider productProvider,
    PlantProvider plantProvider,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Details',
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
              name: 'plant',
              labelText: 'Plant Name',
              hintText: 'Select Plant Name',
              prefixIcon: Icons.person,
              options: ['Plant A', 'Plant B', 'Plant C'],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a plant',
                ),
              ],
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'material_code',
              labelText: 'Material Code',
              hintText: 'Enter Material Code',
              prefixIcon: Icons.business,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              focusNode: FocusNode(),
              onTap: () => _scrollToFocusedField(context, FocusNode()),
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'description',
              labelText: 'Description (e.g. 600X300X100MM)',
              hintText: 'Enter description (e.g. 600X300X100MM)',
              prefixIcon: Icons.description,
              validators: [FormBuilderValidators.required()],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              focusNode: FocusNode(),
              onChanged: (value) {
                if (value != null && _showAreaPerUnit) {
                  final area = _calculateArea(value);
                  if (area != null) {
                    _formKey.currentState?.fields['area_per_unit']?.didChange(
                      area.toStringAsFixed(4),
                    );
                  }
                }
              },
              onTap: () => _scrollToFocusedField(context, FocusNode()),
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'no_of_pieces_per_punch',
              keyboardType: TextInputType.number,
              labelText: 'No Of Pieces Per Punch',
              hintText: 'Enter No Of Pieces Per Punch',
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
              focusNode: FocusNode(),
              onTap: () => _scrollToFocusedField(context, FocusNode()),
            ),
            SizedBox(height: 18.h),
            CustomDropdownFormField<String>(
              name: 'uom',
              labelText: 'UOM',
              initialValue: 'Square Meter/No', // Set default to Square Meter/No
              items: ["Square Meter/No", "Meter/No"]
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
                setState(() {
                  _showAreaPerUnit = value == "Square Meter/No";
                  if (!_showAreaPerUnit) {
                    _formKey.currentState?.fields['area_per_unit']?.didChange(
                      null,
                    );
                  } else {
                    final description =
                        _formKey.currentState?.fields['description']?.value;
                    if (description != null) {
                      final area = _calculateArea(description);
                      if (area != null) {
                        _formKey.currentState?.fields['area_per_unit']
                            ?.didChange(area.toStringAsFixed(4));
                      }
                    }
                  }
                });
              },
            ),
            SizedBox(height: 18.h),
            if (_showAreaPerUnit)
              CustomTextFormField(
                name: 'area_per_unit',
                labelText: 'Area per unit (Sqmt)',
                hintText: 'Enter or adjust area per unit',
                prefixIcon: Icons.area_chart,
                keyboardType: TextInputType.number,
                validators: [
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                  FormBuilderValidators.min(
                    0,
                    errorText: 'Area must be positive',
                  ),
                ],
                fillColor: const Color(0xFFF8FAFC),
                borderColor: Colors.grey.shade300,
                focusedBorderColor: const Color(0xFF3B82F6),
                borderRadius: 12.r,
                focusNode: FocusNode(),
                onTap: () => _scrollToFocusedField(context, FocusNode()),
              ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'qty_in_bundle',
              keyboardType: TextInputType.number,
              labelText: 'Quantity in bundle',
              hintText: 'Enter quantity in bundle',
              prefixIcon: Icons.inventory,
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
              focusNode: FocusNode(),
              onTap: () => _scrollToFocusedField(context, FocusNode()),
            ),
            SizedBox(height: 40.h),
            Consumer<ProductProvider>(
              builder: (context, provider, _) => SizedBox(
                width: double.infinity,
                height: 56.h,
                child: _buildSubmitButton(context, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ProductProvider provider) {
    final isLoading = provider.isAddProductLoading;

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
          onTap: isLoading ? null : () => _submitForm(context, provider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Creating Product...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Create Product',
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

  Future<void> _submitForm(
    BuildContext context,
    ProductProvider provider,
  ) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF3B82F6)),
                SizedBox(height: 16.h),
                Text(
                  'Creating Product...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final success = await provider.createProduct(
        formData['material_code'], // Use material_code
        formData['description'], // Use description
      );

      Navigator.of(context).pop();

      if (success && context.mounted) {
        context.showSuccessSnackbar("Product successfully created");
        context.go(RouteNames.products);
      } else {
        context.showErrorSnackbar(
          "Failed to create Product: ${provider.error?.replaceFirst('Exception: ', '') ?? 'Unknown error. Please try again.'}",
        );
      }
    } else {
      context.showWarningSnackbar(
        "Please fill in all required fields correctly.",
      );
    }
  }
}
