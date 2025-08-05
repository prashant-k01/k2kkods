import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MachineAddScreen extends StatefulWidget {
  const MachineAddScreen({super.key});

  @override
  State<MachineAddScreen> createState() => _MachineAddScreenState();
}

class _MachineAddScreenState extends State<MachineAddScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _isScreenUtilInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Initializing ScreenUtil in MachineAddScreen');
      ScreenUtil.init(context);
      setState(() {
        _isScreenUtilInitialized = true;
      });
      print('ScreenUtil initialized: screenWidth=${ScreenUtil().screenWidth}');

      final plantProvider = context.read<PlantProvider>();
      if (plantProvider.allPlants.isEmpty &&
          plantProvider.error == null &&
          !plantProvider.isAllPlantsLoading) {
        print('Loading plants for dropdown in MachineAddScreen');
        plantProvider.loadAllPlantsForDropdown();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final plantProvider = Provider.of<PlantProvider>(context, listen: false);
    final machineProvider = Provider.of<MachinesProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add Machine'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334155),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(RouteNames.machines),
        ),
      ),
      body: _isScreenUtilInitialized
          ? SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormCard(context, machineProvider, plantProvider),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    MachinesProvider machineProvider,
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
              'Machine Details',
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
            // Plant Dropdown
            Consumer<PlantProvider>(
              builder: (context, provider, _) {
                print(
                  'Building Plant Dropdown: plants=${provider.allPlants.length}, isLoading=${provider.isAllPlantsLoading}, error=${provider.error}',
                );
                if (provider.isAllPlantsLoading) {
                  return const Center(child: CircularProgressIndicator());
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
                          provider.loadAllPlantsForDropdown(refresh: true);
                        },
                        child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  );
                }
                if (provider.allPlants.isEmpty) {
                  return const Text(
                    'No plants found. Please add a plant first.',
                    style: TextStyle(color: Colors.red),
                  );
                }
                return CustomSearchableDropdownFormField<PlantModel>(
                  name: 'plant',
                  labelText: 'Plant Name',
                  prefixIcon: Icons.factory_outlined,
                  options: provider.allPlants,
                  optionLabel: (plant) => plant.plantName,
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
          onTap: provider.isAddMachineLoading
              ? null
              : () => _submitForm(context, provider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: provider.isAddMachineLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Creating Machine...',
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
                        'Add Machine',
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
      final plant = formData['plant'] as PlantModel?;
      final machineName = formData['machine_name'] as String;

      if (plant == null) {
        print('Validation failed: No plant selected');
        context.showWarningSnackbar('Please select a valid plant.');
        return;
      }

      print(
        'Submitting machine: machine_name=$machineName, plant_id=${plant.id}',
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
                const CircularProgressIndicator(color: Color(0xFF3B82F6)),
                SizedBox(height: 16.h),
                Text(
                  'Creating Machine...',
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

      final success = await provider.createMachine(machineName, plant.id);

      Navigator.of(context).pop();

      if (success && context.mounted) {
        print(
          'Machine created successfully: machine_name=$machineName, plant_id=${plant.id}',
        );
        context.showSuccessSnackbar('Machine created successfully!');
        context.go(RouteNames.machines);
      } else {
        print('Failed to create machine: ${provider.error}');
        context.showErrorSnackbar(
          provider.error ?? 'Failed to create machine. Please try again.',
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
