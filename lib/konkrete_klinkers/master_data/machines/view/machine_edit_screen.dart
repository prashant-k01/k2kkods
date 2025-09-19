import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MachineEditScreen extends StatefulWidget {
  final String machineId;

  const MachineEditScreen({super.key, required this.machineId});

  @override
  State<MachineEditScreen> createState() => _MachineEditScreenState();
}

class _MachineEditScreenState extends State<MachineEditScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MachinesProvider>();
      provider.fetchMachine(widget.machineId);
      if (provider.plant.isEmpty && !provider.isAllPlantsLoading) {
        provider.ensurePlantsLoaded();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final machineProvider = Provider.of<MachinesProvider>(
      context,
      listen: false,
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.machines);
        }
      },
      child: Consumer<MachinesProvider>(
        builder: (context, provider, _) {
          if (provider.isMachineLoading) {
            return Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: GradientLoader()),
              ),
            );
          }

          if (provider.machineError != null) {
            return Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: Scaffold(
                backgroundColor: AppColors.transparent,
                appBar: AppBars(
                  title: TitleText(title: 'Edit Machine'),
                  leading: CustomBackButton(
                    onPressed: () {
                      context.go(RouteNames.machines);
                    },
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${provider.machineError}',
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          provider.clearMachineError();
                          provider.fetchMachine(widget.machineId);
                        },
                        child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (provider.currentMachine == null) {
            return Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Text(
                    'Machine not found',
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: Scaffold(
              backgroundColor: AppColors.transparent,
              appBar: AppBars(
                title: TitleText(title: 'Edit Machines'),
                leading: CustomBackButton(
                  onPressed: () {
                    context.go(RouteNames.machines);
                  },
                ),
                action: [],
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildFormCard(context, machineProvider)],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    MachinesProvider machineProvider,
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
              'Machine Details',
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
            // Plant Dropdown
            Consumer<MachinesProvider>(
              builder: (context, provider, _) {
                print(
                  'Building Plant Dropdown: plants=${provider.plant.length}, isLoading=${provider.isAllPlantsLoading}, error=${provider.error}',
                );
                if (provider.isAllPlantsLoading) {
                  return const Center(child: GradientLoader());
                }
                if (provider.error != null) {
                  return Column(
                    children: [
                      Text(
                        'Error loading plants: ${provider.error}',
                        style: TextStyle(fontSize: 14.sp, color: Colors.red),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () {
                          print('Retrying to load plants');
                          provider.clearError();
                          provider.ensurePlantsLoaded();
                        },
                        child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  );
                }
                if (provider.plant.isEmpty) {
                  return Text(
                    'No plants found. Please add a plant first.',
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                  );
                }
                return CustomSearchableDropdownFormField<PlantId>(
                  name: 'plant',
                  labelText: 'Plant Name',
                  hintText: 'Select Plant Name',
                  fillColor: Colors.white,
                  prefixIcon: Icons.factory_outlined,
                  options: provider.plant,
                  optionLabel: (plant) => plant.plantName,
                  initialValue: provider.plant.firstWhere(
                    (plant) => plant.id == provider.currentMachine!.plantId.id,
                    orElse: () => provider.plant.first,
                  ),
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a plant',
                    ),
                  ],
                  allowClear: true,
                );
              },
            ),
            SizedBox(height: 24.h),
            // Machine Name
            CustomTextFormField(
              name: 'machine_name',
              labelText: 'Machine Name',
              hintText: 'Enter machine name',
              prefixIcon: Icons.precision_manufacturing_outlined,
              initialValue: machineProvider.currentMachine!.name,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ],
              fillColor: const Color(0xFFF8FAFC),
              borderColor: Colors.grey.shade300,
              focusedBorderColor: const Color(0xFF3B82F6),
              borderRadius: 12.r,
            ),
            SizedBox(height: 24.h),
            // Submit
            Consumer<MachinesProvider>(
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

  Widget _buildSubmitButton(BuildContext context, MachinesProvider provider) {
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
          onTap: provider.isUpdateMachinesLoading
              ? null
              : () => _submitForm(context, provider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: provider.isUpdateMachinesLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GradientLoader(),
                      SizedBox(width: 12.w),
                      Text(
                        'Updating Machine...',
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
                      Icon(Icons.save_alt, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Update Machine',
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

  Future<void> _submitForm(
    BuildContext context,
    MachinesProvider provider,
  ) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final plant = formData['plant'] as PlantId?;
      final machineName = formData['machine_name'] as String;

      if (plant == null) {
        print('Validation failed: No plant selected');
        context.showWarningSnackbar('Please select a plant.');
        return;
      }

      print(
        'Submitting update: machine_id=${widget.machineId}, machine_name=$machineName, plant_id=${plant.id}',
      );
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
                  'Updating Machine...',
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

      final success = await provider.updateMachines(
        widget.machineId,
        machineName,
        plant.id,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (success && context.mounted) {
        print(
          'Machine updated successfully: machine_name=$machineName, plant_id=${plant.id}',
        );
        context.showSuccessSnackbar('Machine updated successfully!');
        await provider.loadAllMachines(refresh: true);
        context.go(RouteNames.machines);
      } else {
        print('Failed to update machine: ${provider.error}');
        context.showErrorSnackbar(
          provider.error ?? 'Failed to update machine. Please try again.',
        );
      }
    } else {
      print('Form validation failed: ${_formKey.currentState?.value}');
      context.showWarningSnackbar(
        'Please fill in all required fields correctly.',
      );
    }
  }
}
