import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/Iron_smith/master_data/shapes/provider/shape_provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';

class ShapeAddScreen extends StatefulWidget {
  const ShapeAddScreen({super.key});

  @override
  State<ShapeAddScreen> createState() => _ShapeAddScreenState();
}

class _ShapeAddScreenState extends State<ShapeAddScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && mounted) {
      _initializeData();
    }
  }

  void _initializeData() {
    if (!_isInitialized) {
      _isInitialized = true;
      final provider = context.read<ShapesProvider>();
      provider.resetForm(); // Reset immediately to prevent pre-fill
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          provider.fetchDimensions();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.allshapes);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: TitleText(title: 'Add Shape'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.allshapes),
          ),
        ),
        body: Consumer<ShapesProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const SizedBox.expand(
                child: Center(child: GradientLoader()),
              );
            }
            if (provider.error != null) {
              return SizedBox.expand(
                child: Center(
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
                        'Error Loading Dimensions',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () => provider.fetchDimensions(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ironSmithPrimary,
                          foregroundColor: AppTheme.lightGray,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildFormCard(context, provider)],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, ShapesProvider provider) {
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
        key: provider.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shape Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter the required information below',
              style: TextStyle(fontSize: 14.sp, color: AppTheme.headingform),
            ),
            SizedBox(height: 24.h),
            CustomDropdownFormField<String>(
              name: 'dimension',
              labelText: 'Dimension',
              hintText: 'Select Dimension',
              initialValue: provider.selectedDimensionId,
              options: provider.dimensions.map((dim) => dim['id']!).toList(),
              optionLabel: (id) => provider.dimensions.firstWhere(
                (dim) => dim['id'] == id,
              )['dimension_name']!,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a dimension',
                ),
              ],
              onChanged: (value) => provider.updateDimensionId(value),
              fillColor: AppTheme.white,
              borderRadius: 12,
              prefixIcon: Icons.widgets_outlined,
            ),
            SizedBox(height: 24.h),
            FormBuilderTextField(
              name: 'description',
              controller: provider.descriptionController,
              maxLines: 2,
              minLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: AppTheme.white,
              ),
              validator: FormBuilderValidators.required(
                errorText: 'Enter description',
              ),
            ),
            SizedBox(height: 24.h),
            FormBuilderTextField(
              name: 'shape_code',
              controller: provider.shapeCodeController,
              decoration: InputDecoration(
                labelText: 'Shape Code',
                hintText: 'Enter Shape Code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: AppTheme.white,
              ),
              validator: FormBuilderValidators.required(
                errorText: 'Enter shape code',
              ),
            ),
            SizedBox(height: 24.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => provider.pickImage(context),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Shape Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ironSmithPrimary,
                      foregroundColor: AppTheme.lightGray,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                if (provider.selectedImage != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.selectedImage!.split('/').last,
                          style: TextStyle(fontSize: 14.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: AppTheme.ironSmithPrimary,
                        ),
                        onPressed: () => provider.clearSelectedImage(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.ironSmithGradient,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.ironSmithPrimary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      if (provider.formKey.currentState!.saveAndValidate()) {
                        await provider.submitForm(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: Center(
                      child: Text(
                        provider.isLoading ? 'Adding...' : 'Add Shape',
                        style: TextStyle(
                          color: AppTheme.lightGray,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
