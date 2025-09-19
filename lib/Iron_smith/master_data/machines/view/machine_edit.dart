import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/Iron_smith/master_data/machines/model/machines.dart';
import 'package:k2k/Iron_smith/master_data/machines/provider/machine_provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class IsMachineEditScreen extends StatefulWidget {
  final String machineId;

  const IsMachineEditScreen({super.key, required this.machineId});

  @override
  State<IsMachineEditScreen> createState() => _IsMachineEditScreenState();
}

class _IsMachineEditScreenState extends State<IsMachineEditScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm(Machines machine) async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;
      final updatedMachine = Machines(
        id: machine.id,
        name: formData['machine_name'],
        role: formData['machine_role'],
        isDeleted: machine.isDeleted,
        v: machine.v,
        createdAt: machine.createdAt,
      );

      try {
        final provider = Provider.of<IsMachinesProvider>(
          context,
          listen: false,
        );
        await provider.updateMachine(
          widget.machineId,
          updatedMachine.name,
          updatedMachine.role,
        );

        if (mounted) {
          context.showSuccessSnackbar('Machine updated successfully');
          context.go(RouteNames.ismachine);
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackbar('Failed to update machine: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IsMachinesProvider>();
    final machine = provider.machines.firstWhere(
      (m) => m.id?.oid == widget.machineId,
      orElse: () => Machines(name: '', role: '', isDeleted: false, v: 0),
    );

    if (machine == null) {
      return FutureBuilder<void>(
        future: provider.getMachineById(widget.machineId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || provider.selectedMachine == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error ?? "Machine not found"}'),
                    ElevatedButton(
                      onPressed: () => context.go(RouteNames.ismachine),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildScaffold(context, provider.selectedMachine!);
        },
      );
    }

    return _buildScaffold(context, machine);
  }

  Widget _buildScaffold(BuildContext context, Machines machine) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.ismachine);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: const TitleText(title: 'Edit Machine'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.ismachine),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _buildFormCard(context, machine),
                    if (context.watch<IsMachinesProvider>().isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, Machines machine) {
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
              style: TextStyle(fontSize: 14.sp, color: AppTheme.headingform),
            ),
            SizedBox(height: 24.h),
            CustomTextFormField(
              name: 'machine_name',
              labelText: 'Machine Name',
              hintText: 'Enter machine name',
              initialValue: machine.name,
              prefixIcon: Icons.precision_manufacturing_outlined,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ],
              fillColor: AppTheme.white,
              prefixIconColor: AppTheme.ironSmithPrimary,
              borderColor: AppTheme.grey,
              focusedBorderColor: AppTheme.ironSmithSecondary,
              borderRadius: 12.r,
            ),
            SizedBox(height: 24.h),
            CustomTextFormField(
              name: 'machine_role',
              labelText: 'Machine Role',
              hintText: 'Enter machine role',
              initialValue: machine.role,
              prefixIcon: Icons.settings,
              prefixIconColor: AppTheme.ironSmithPrimary,
              validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(2),
              ],
              fillColor: AppTheme.white,
              borderColor: AppTheme.grey,
              focusedBorderColor: AppTheme.ironSmithSecondary,
              borderRadius: 12.r,
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
                    onTap: context.watch<IsMachinesProvider>().isLoading
                        ? null
                        : () => _submitForm(machine),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Center(
                      child: Text(
                        'Update Machine',
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
