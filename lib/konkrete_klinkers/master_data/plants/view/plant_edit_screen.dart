import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditPlantFormScreen extends StatefulWidget {
  final String plantId;

  const EditPlantFormScreen({super.key, required this.plantId});

  @override
  State<EditPlantFormScreen> createState() => _EditPlantFormScreenState();
}

class _EditPlantFormScreenState extends State<EditPlantFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantProvider>().getPlant(widget.plantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.plants);
        }
      },
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Edit Plant'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.plants);
              },
            ),
          ),
          body:
              context.select<PlantProvider, bool>(
                (provider) => provider.isPlantLoading,
              )
              ? const Center(child: GradientLoader())
              : context.select<PlantProvider, String?>(
                      (provider) => provider.plantError,
                    ) !=
                    null
              ? Center(
                  child: Consumer<PlantProvider>(
                    builder: (context, provider, _) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: const Color(0xFFF43F5E),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          provider.plantError!,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearPlantError();
                            provider.getPlant(widget.plantId);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : context.select<PlantProvider, PlantModel?>(
                      (provider) => provider.currentPlant,
                    ) ==
                    null
              ? Center(
                  child: Text(
                    'Plant not found',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF43F5E),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormCard(context, context.read<PlantProvider>()),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, PlantProvider provider) {
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
          'plant_code': provider.currentPlant!.plantCode,
          'plant_name': provider.currentPlant!.plantName,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Plant Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Update the plant information below',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 24.h),
            // Plant Code
            CustomTextFormField(
              name: 'plant_code',
              labelText: 'Plant Code',
              hintText: 'Enter plant code',
              prefixIcon: Icons.code,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(3),
                FormBuilderValidators.maxLength(20),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
            ),
            SizedBox(height: 24.h),
            // Plant Name
            CustomTextFormField(
              name: 'plant_name',
              labelText: 'Plant Name',
              hintText: 'Enter plant name',
              prefixIcon: Icons.business,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
                FormBuilderValidators.maxLength(50),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF8B5CF6),
              borderRadius: 12.r,
            ),
            SizedBox(height: 40.h),
            // Submit
            Consumer<PlantProvider>(
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

  Widget _buildSubmitButton(BuildContext context, PlantProvider provider) {
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
          onTap: provider.isUpdatePlantLoading
              ? null
              : () => _submitForm(context, provider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: provider.isUpdatePlantLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GradientLoader(),
                      SizedBox(width: 12.w),
                      Text(
                        'Updating Plant...',
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
                      Icon(Icons.save, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Update Plant',
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
  }

  Future<void> _submitForm(BuildContext context, PlantProvider provider) async {
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
                const GradientLoader(),
                SizedBox(height: 16.h),
                Text(
                  'Updating Plant...',
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

      final success = await provider.updatePlant(
        widget.plantId,
        formData['plant_code'],
        formData['plant_name'],
      );

      if (!context.mounted) return;

      Navigator.of(context).pop();
      if (success) {
        context.showSuccessSnackbar('Plant updated successfully!');
        context.go(RouteNames.plants);
      } else {
        context.showErrorSnackbar(
          provider.error ?? 'Failed to update plant. Please try again.',
        );
      }
    } else {
      context.showWarningSnackbar(
        'Please fill in all required fields correctly.',
      );
    }
  }
}
