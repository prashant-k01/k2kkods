import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/master_data/machines/model/machines_model.dart'
    hide CreatedBy;
import 'package:k2k/konkrete_klinkers/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/model/plants_model.dart';
import 'package:k2k/konkrete_klinkers/master_data/plants/provider/plants_provider.dart';
import 'package:provider/provider.dart';

class MachineEditScreen extends StatefulWidget {
  final String machineId;

  const MachineEditScreen({super.key, required this.machineId});

  @override
  State<MachineEditScreen> createState() => _MachineEditScreenState();
}

class _MachineEditScreenState extends State<MachineEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final machineProvider = context.read<MachinesProvider>();
          final plantProvider = context.read<PlantProvider>();

          if (plantProvider.plants.isEmpty && plantProvider.error == null) {
            plantProvider.loadAllPlants().then((_) {
              if (mounted) {
                _loadMachineData(machineProvider, plantProvider);
              }
            });
          } else {
            _loadMachineData(machineProvider, plantProvider);
          }
        }
      });
    }
  }

  void _loadMachineData(
    MachinesProvider machineProvider,
    PlantProvider plantProvider,
  ) {
    machineProvider.getMachines(widget.machineId).then((machine) {
      if (machine != null && mounted) {
        final selectedPlant = plantProvider.plants.firstWhere(
          (plant) => plant.id == machine.plantId.id,
          orElse: () => PlantModel(
            id: '',
            plantCode: '',
            plantName: 'Unknown',
            createdBy: CreatedBy(id: '', email: '', username: ''),
            isDeleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            version: 0,
          ),
        );
        setState(() {
          _formKey.currentState?.fields['machine_name']?.didChange(
            machine.name,
          );
          _formKey.currentState?.fields['plant']?.didChange(selectedPlant);
        });
      }
    });
  }

  Future<void> _updateMachine() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final provider = context.read<MachinesProvider>();
      final formData = _formKey.currentState!.value;
      final name = formData['machine_name'] as String;
      final plant = formData['plant'] as PlantModel?;

      if (plant == null || plant.id.isEmpty) {
        context.showWarningSnackbar('Please select a valid plant.');
        return;
      }

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
        name,
        PlantId(
          id: plant.id,
          plantCode: plant.plantCode,
          plantName: plant.plantName,
        ),
      );

      Navigator.of(context).pop();

      if (success && context.mounted) {
        context.showSuccessSnackbar("Machine updated successfully!");
        context.go(RouteNames.machines);
      } else if (context.mounted) {
        context.showErrorSnackbar(
          provider.error ?? "Failed to update machine. Please try again.",
        );
      }
    } else {
      context.showWarningSnackbar(
        "Please fill in all required fields correctly.",
      );
    }
  }

  Widget _buildFormCard() {
    return Consumer2<MachinesProvider, PlantProvider>(
      builder: (context, machineProvider, plantProvider, child) {
        if (machineProvider.isLoading || plantProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (machineProvider.error != null || plantProvider.error != null) {
          return Center(
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
                  machineProvider.error ??
                      plantProvider.error ??
                      'Error loading data',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF334155),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: _buildRetryButton(),
                ),
              ],
            ),
          );
        }

        if (plantProvider.plants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  size: 64.sp,
                  color: const Color(0xFFF59E0B),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No plants available. Please add plants first.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF334155),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: _buildRetryButton(),
                ),
              ],
            ),
          );
        }

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
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomSearchableDropdownFormField<PlantModel>(
                  name: 'plant',
                  labelText: 'Plant Name',
                  prefixIcon: Icons.factory_outlined,
                  options: plantProvider.plants,
                  optionLabel: (plant) => plant.plantName,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a plant',
                    ),
                  ],
                  allowClear: true,
                ),
                SizedBox(height: 24.h),
                CustomTextFormField(
                  name: 'machine_name',
                  labelText: 'Machine Name',
                  hintText: 'Enter machine name',
                  prefixIcon: Icons.precision_manufacturing_outlined,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Machine name is required',
                    ),
                    FormBuilderValidators.minLength(
                      2,
                      errorText: 'Name must be at least 2 characters',
                    ),
                  ],
                  fillColor: const Color(0xFFF8FAFC),
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: const Color(0xFF3B82F6),
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: _buildSubmitButton(machineProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(MachinesProvider provider) {
    return Container(
      constraints: BoxConstraints(minWidth: ScreenUtil().screenWidth * 0.8),
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
          onTap: provider.isUpdateMachinesLoading ? null : _updateMachine,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: provider.isUpdateMachinesLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          'Updating Machine...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_alt, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          'Update Machine',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
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
          onTap: _initializeData,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Retry',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edit Machine'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF334155),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go(RouteNames.machines),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildFormCard()],
        ),
      ),
    );
  }
}
