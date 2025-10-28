import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
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
      final machineProvider = context.read<MachinesProvider>();
      final plantProvider = context.read<PlantProvider>();

      machineProvider.getMachineById(widget.machineId);

      if (plantProvider.plants.isEmpty && !plantProvider.isAllPlantsLoading) {
        plantProvider.loadAllPlantsForDropdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.go(RouteNames.machines);
      },
      child: Consumer2<MachinesProvider, PlantProvider>(
        builder: (context, machineProvider, plantProvider, _) {
          if (machineProvider.isMachineLoading) {
            return Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: const Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: GradientLoader()),
              ),
            );
          }

          if (machineProvider.machineError != null) {
            return Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBars(
                  title: TitleText(title: 'Edit Machine'),
                  leading: CustomBackButton(
                    onPressed: () => context.go(RouteNames.machines),
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${machineProvider.machineError}',
                        style: TextStyle(fontSize: 16.sp, color: Colors.red),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          machineProvider.clearCurrentMachine();
                          machineProvider.getMachineById(widget.machineId);
                        },
                        child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (machineProvider.currentMachine == null) {
            return Container(
              decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
              child: const Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Text(
                    'Machine not found',
                    style: TextStyle(fontSize: 16, color: Colors.red),
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
                title: TitleText(title: 'Edit Machine'),
                leading: CustomBackButton(
                  onPressed: () => context.go(RouteNames.machines),
                ),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: _buildFormCard(machineProvider, plantProvider),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(
    MachinesProvider machineProvider,
    PlantProvider plantProvider,
  ) {
    final currentMachine = machineProvider.currentMachine!;
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
            if (plantProvider.isAllPlantsLoading)
              const Center(child: GradientLoader())
            else if (plantProvider.error != null)
              Column(
                children: [
                  Text(
                    'Error loading plants: ${plantProvider.error}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.red),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: plantProvider.clearError,
                    child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              )
            else if (plantProvider.allPlants.isEmpty)
              Text(
                'No plants found. Please add a plant first.',
                style: TextStyle(fontSize: 14.sp, color: Colors.red),
              )
            else
              CustomSearchableDropdownFormField<PlantModel>(
                name: 'plant',
                labelText: 'Plant Name',
                hintText: 'Select Plant Name',
                fillColor: Colors.white,
                prefixIcon: Icons.factory_outlined,
                options: plantProvider.allPlants,
                optionLabel: (plant) => plant.plantName,
                initialValue: plantProvider.plants.firstWhere(
                  (plant) => plant.id == currentMachine.plantId?.id,
                  orElse: () => plantProvider.plants.first,
                ),
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Please select a plant',
                  ),
                ],
                allowClear: true,
              ),
            SizedBox(height: 24.h),

            // Machine Name
            CustomTextFormField(
              name: 'machine_name',
              labelText: 'Machine Name',
              hintText: 'Enter machine name',
              prefixIcon: Icons.precision_manufacturing_outlined,
              initialValue: currentMachine.name,
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
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: _buildSubmitButton(machineProvider, plantProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    MachinesProvider machineProvider,
    PlantProvider plantProvider,
  ) {
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
          onTap: machineProvider.isUpdateLoading
              ? null
              : () => _submitForm(machineProvider, plantProvider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: machineProvider.isUpdateLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      GradientLoader(),
                      SizedBox(width: 12),
                      Text(
                        'Updating Machine...',
                        style: TextStyle(color: Colors.white),
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
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(
    MachinesProvider machineProvider,
    PlantProvider plantProvider,
  ) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final plant = formData['plant'] as PlantModel?;
      final machineName = formData['machine_name'] as String;

      if (plant == null) {
        context.showWarningSnackbar('Please select a plant.');
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: GradientLoader()),
      );

      final success = await machineProvider.updateMachine(
        widget.machineId,
        machineName,
        plant.id,
      );

      if (context.mounted) Navigator.of(context).pop();

      if (success && context.mounted) {
        context.showSuccessSnackbar('Machine updated successfully!');
        await machineProvider.loadMachines(refresh: true);
        context.go(RouteNames.machines);
      } else {
        context.showErrorSnackbar(
          machineProvider.machineError ??
              'Failed to update machine. Please try again.',
        );
      }
    } else {
      context.showWarningSnackbar(
        'Please fill in all required fields correctly.',
      );
    }
  }
}
