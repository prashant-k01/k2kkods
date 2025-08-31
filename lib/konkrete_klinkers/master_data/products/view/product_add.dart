import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/master_data/products/provider/product_provider.dart';
import 'package:k2k/utils/theme.dart';
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
  final Map<String, FocusNode> _focusNodes = {
    'plant': FocusNode(),
    'material_code': FocusNode(),
    'description': FocusNode(),
    'no_of_pieces_per_punch': FocusNode(),
    'uom': FocusNode(),
    'area_per_unit': FocusNode(),
    'qty_in_bundle': FocusNode(),
  };
  final Debouncer _scrollDebouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.initializeEditForm('').then((_) {
        if (productProvider.plants.isEmpty ||
            productProvider.plants.every((plant) => plant['id']!.isEmpty)) {
          context.showErrorSnackbar(
            "No valid plants available. Please try again later.",
          );
        }
      });
    });
  }

  double? _calculateArea(String description) {
    try {
      final RegExp dimensionRegex = RegExp(
        r'(\d+)X(\d+)X(\d+)MM',
        caseSensitive: false,
      );
      final match = dimensionRegex.firstMatch(description);

      if (match != null) {
        final length = double.parse(match.group(1)!);
        final width = double.parse(match.group(2)!);
        return (length / 1000) * (width / 1000);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _scrollToFocusedField(BuildContext context, FocusNode focusNode) {
    if (focusNode.hasFocus) {
      _scrollDebouncer.debounce(
        duration: const Duration(milliseconds: 100),
        onDebounce: () {
          final RenderObject? renderObject = context.findRenderObject();
          if (renderObject is RenderBox) {
            final position = renderObject.localToGlobal(Offset.zero).dy;
            final screenHeight = MediaQuery.of(context).size.height;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

            double targetOffset = _scrollController.offset + position;
            if (position + 200.h > screenHeight - keyboardHeight) {
              targetOffset =
                  _scrollController.offset +
                  (position - (screenHeight - keyboardHeight - 200.h));
            }

            _scrollController.animateTo(
              targetOffset.clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.products);
        }
      },
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: AppBars(
            title: TitleText(title: 'Create Product'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.products);
              },
            ),
          ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(24.w).copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                ),
                child: Column(
                  children: [_buildFormCard(context, productProvider)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, ProductProvider productProvider) {
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
              labelText: 'Plant',
              hintText: 'Select Plant',
              prefixIcon: Icons.factory,
              // Remove the auto-selection logic
              initialValue: null, // Keep it empty by default

              options: productProvider.plants.isEmpty
                  ? ['No plants available']
                  : productProvider.plants
                        .where((plant) => plant['id']!.isNotEmpty)
                        .map((plant) => plant['display']!)
                        .toList(),

              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a plant',
                ),
              ],
              enabled: productProvider.plants.any(
                (plant) => plant['id']!.isNotEmpty,
              ),
              onChanged: (value) {
                print('Dropdown onChanged: $value');
                _formKey.currentState?.fields['plant']?.didChange(value);
              },
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'material_code',
              labelText: 'Material Code',
              hintText: 'Enter Material Code',
              focusNode: _focusNodes['material_code'],
              prefixIcon: Icons.business,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              onTap: () =>
                  _scrollToFocusedField(context, _focusNodes['material_code']!),
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'description',
              labelText: 'Description (e.g. 600X300X100MM)',
              hintText: 'Enter description (e.g. 600X300X100MM)',
              focusNode: _focusNodes['description'],
              prefixIcon: Icons.description,
              validators: [FormBuilderValidators.required()],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
              onChanged: (value) {
                if (value != null && productProvider.showAreaPerUnit) {
                  final area = _calculateArea(value);
                  if (area != null) {
                    _formKey.currentState?.fields['area_per_unit']?.didChange(
                      area.toStringAsFixed(4),
                    );
                  }
                }
              },
              onTap: () =>
                  _scrollToFocusedField(context, _focusNodes['description']!),
            ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'no_of_pieces_per_punch',
              keyboardType: TextInputType.number,
              labelText: 'No Of Pieces Per Punch',
              hintText: 'Enter No Of Pieces Per Punch',
              focusNode: _focusNodes['no_of_pieces_per_punch'],
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
                _focusNodes['no_of_pieces_per_punch']!,
              ),
            ),
            SizedBox(height: 18.h),
            CustomDropdownFormField<String>(
              name: 'uom',
              labelText: 'UOM',
              initialValue: 'Square Meter/No',
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
                productProvider.setShowAreaPerUnit(value == "Square Meter/No");
                if (!productProvider.showAreaPerUnit) {
                  _formKey.currentState?.fields['area_per_unit']?.didChange('');
                } else {
                  final description =
                      _formKey.currentState?.fields['description']?.value;
                  if (description != null && description.isNotEmpty) {
                    final area = productProvider.calculateArea(description);
                    if (area != null) {
                      _formKey.currentState?.fields['area_per_unit']?.didChange(
                        area.toStringAsFixed(4),
                      );
                    }
                  }
                }
              },
            ),
            SizedBox(height: 18.h),
            if (context.select<ProductProvider, bool>(
              (provider) => provider.showAreaPerUnit,
            ))
              CustomTextFormField(
                name: 'area_per_unit',
                labelText: 'Area per unit (Sqmt)',
                hintText: 'Enter or adjust area per unit',
                focusNode: _focusNodes['area_per_unit'],
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
                onTap: () => _scrollToFocusedField(
                  context,
                  _focusNodes['area_per_unit']!,
                ),
              ),
            SizedBox(height: 18.h),
            CustomTextFormField(
              name: 'qty_in_bundle',
              keyboardType: TextInputType.number,
              labelText: 'Quantity in bundle',
              hintText: 'Enter quantity in bundle',
              focusNode: _focusNodes['qty_in_bundle'],
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
              onTap: () =>
                  _scrollToFocusedField(context, _focusNodes['qty_in_bundle']!),
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
                          child: GradientLoader(),
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

      final selectedPlantDisplay = formData['plant'] as String?;
      print('Form plant value: $selectedPlantDisplay');

      // Check if plant is selected
      if (selectedPlantDisplay == null || selectedPlantDisplay.isEmpty) {
        context.showErrorSnackbar("Please select a plant.");
        return;
      }

      // Check if plants are available
      if (provider.plants.isEmpty) {
        context.showErrorSnackbar(
          "No plants available. Please refresh and try again.",
        );
        return;
      }

      print(
        'Available plants: ${provider.plants.map((p) => "${p['display']} (ID: ${p['id']})").toList()}',
      );

      // Find the selected plant
      final selectedPlant = provider.plants.firstWhere(
        (plant) => plant['display']?.trim() == selectedPlantDisplay.trim(),
        orElse: () {
          print('No plant found for display: $selectedPlantDisplay');
          return {'id': '', 'display': ''};
        },
      );

      // Validate plant ID
      if (selectedPlant['id'] == null || selectedPlant['id']!.isEmpty) {
        // Try to reload plants if all IDs are empty
        try {
          context.showInfoSnackbar("Refreshing plant data...");
          await provider.initializeEditForm(''); // This will reload plants

          if (provider.plants.isEmpty ||
              provider.plants.every((plant) => plant['id']!.isEmpty)) {
            context.showErrorSnackbar(
              "All plants have invalid IDs. Please contact support or check the plant configuration.",
            );
            return;
          }

          // Try to find the plant again after refresh
          final refreshedPlant = provider.plants.firstWhere(
            (plant) => plant['display']?.trim() == selectedPlantDisplay.trim(),
            orElse: () => {'id': '', 'display': ''},
          );

          if (refreshedPlant['id']!.isEmpty) {
            context.showErrorSnackbar(
              "Selected plant '$selectedPlantDisplay' has no valid ID even after refresh.",
            );
            return;
          }

          // Use the refreshed plant
          selectedPlant['id'];
        } catch (e) {
          context.showErrorSnackbar(
            "Failed to refresh plant data: ${e.toString()}",
          );
          return;
        }
      }

      print('Selected plant ID: ${selectedPlant['id']}');

      // Show loading dialog
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
                const GradientLoader(),
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

      // Create the product
      final success = await provider.createProduct(
        plantId: selectedPlant['id']!,
        materialCode: formData['material_code'],
        description: formData['description'],
        uom: [formData['uom']],
        areas: {
          formData['uom']:
              double.tryParse(formData['area_per_unit'] ?? '0') ?? 0.0,
        },
        noOfPiecesPerPunch:
            int.tryParse(formData['no_of_pieces_per_punch'] ?? '0') ?? 0,
        qtyInBundle: int.tryParse(formData['qty_in_bundle'] ?? '0') ?? 0,
      );

      // Close loading dialog
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
