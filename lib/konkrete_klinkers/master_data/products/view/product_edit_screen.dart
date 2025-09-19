import 'package:flutter/material.dart';
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

class EditProductFormScreen extends StatelessWidget {
  final String productId;

  const EditProductFormScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider()..initializeEditForm(productId),
      child: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return _EditProductFormContent(productId: productId);
        },
      ),
    );
  }
}

class _EditProductFormContent extends StatelessWidget {
  final String productId;
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final ScrollController _scrollController = ScrollController();

  _EditProductFormContent({required this.productId});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    if (!productProvider.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: GradientLoader()),
      );
    }

    if (productProvider.errorMessage != null) {
      return _buildErrorScreen(context, productProvider.errorMessage!);
    }

    // Validate and adjust initial values for 'uom'
    final initialValues = Map<String, dynamic>.from(
      productProvider.initialValues,
    );

    // FIXED: Use consistent UOM values (same as add form)
    const validUomValues = ["Square Meter/No", "Meter/No"];
    if (initialValues['uom'] != null &&
        !validUomValues.contains(initialValues['uom'])) {
      // Map common variations to the correct values
      if (initialValues['uom'].toString().contains('Square M')) {
        initialValues['uom'] = "Square Meter/No";
      } else if (initialValues['uom'].toString().contains('Meter')) {
        initialValues['uom'] = "Meter/No";
      } else {
        initialValues['uom'] =
            validUomValues[0]; // Default to first valid value
      }
    }

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
            title: TitleText(title: 'Edit Product'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.products);
              },
            ),
            action: [],
          ),
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(24.w).copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                ),
                itemCount: 1,
                itemBuilder: (context, index) =>
                    _buildFormCard(context, productProvider, initialValues),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String errorMessage) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBars(
        title: _buildLogoAndTitle(),
        leading: _buildBackButton(context),
        action: [],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: const Color(0xFFF43F5E),
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Product',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.products),
              child: Text(
                'Back to Products',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () {
                Provider.of<ProductProvider>(
                  context,
                  listen: false,
                ).initializeEditForm(productId);
              },
              child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Edit Product',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 24.sp,
        color: const Color(0xFF334155),
      ),
      onPressed: () => context.go(RouteNames.products),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    ProductProvider productProvider,
    Map<String, dynamic> initialValues,
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
        initialValue: initialValues,
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
              'Edit the required information below',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 24.h),
            CustomSearchableDropdownFormField(
              name: 'plant',
              labelText: 'Plant',
              hintText: 'Select Plant',
              prefixIcon: Icons.factory,
              options: productProvider.plants.isEmpty
                  ? ['No plants available']
                  : productProvider.plants
                        .where(
                          (plant) => plant['id']!.isNotEmpty,
                        ) // FIXED: Filter out plants without IDs
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
              ), // FIXED: Enable only if valid plants exist
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
              onChanged: (value) {
                if (value != null && productProvider.showAreaPerUnit) {
                  final area = productProvider.calculateArea(value);
                  if (area != null) {
                    _formKey.currentState?.fields['area_per_unit']?.didChange(
                      area.toStringAsFixed(4),
                    );
                  }
                }
              },
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
            ),
            SizedBox(height: 18.h),
            // FIXED: Use consistent UOM values
            CustomDropdownFormField<String>(
              name: 'uom',
              labelText: 'UOM',
              initialValue: initialValues['uom'] ?? "Square Meter/No",
              items:
                  [
                        "Square Meter/No",
                        "Meter/No",
                      ] // FIXED: Consistent with add form
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
                productProvider.setShowAreaPerUnit(
                  value == "Square Meter/No",
                ); // FIXED: Consistent check
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
            if (productProvider.showAreaPerUnit)
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
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: _buildSubmitButton(context, productProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, ProductProvider provider) {
    final isLoading = provider.isUpdateProductLoading;

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
                          'Updating Product...',
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
                        Icon(Icons.edit, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Update Product',
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
      print('Edit Form plant value: $selectedPlantDisplay');

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
          await provider.initializeEditForm(productId); // Reload plants

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

          // FIXED: Actually assign the refreshed plant ID
          selectedPlant['id'] = refreshedPlant['id']!;
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
                Text(
                  'Updating Product...',
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

      // Update the product
      final success = await provider.updateProduct(
        productId: productId,
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
        context.showSuccessSnackbar("Product successfully updated");
        context.go(RouteNames.products);
      } else {
        context.showErrorSnackbar(
          "Failed to update Product: ${provider.error?.replaceFirst('Exception: ', '') ?? 'Unknown error. Please try again.'}",
        );
      }
    } else {
      context.showWarningSnackbar(
        "Please fill in all required fields correctly.",
      );
    }
  }
}
