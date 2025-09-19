import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/Iron_smith/master_data/clients/model/is_client_model.dart';
import 'package:k2k/Iron_smith/master_data/clients/provider/is_client_provider.dart';
import 'package:k2k/Iron_smith/master_data/projects/model/is_project_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/provider/is_project_provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class IsProjectEditScreen extends StatefulWidget {
  final String projectId;

  const IsProjectEditScreen({super.key, required this.projectId});

  @override
  State<IsProjectEditScreen> createState() => _IsProjectEditScreenState();
}

class _IsProjectEditScreenState extends State<IsProjectEditScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();

    // Initialize data after the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final clientProvider = context.read<IsClientProvider>();
        final projectProvider = context.read<IsProjectProvider>();

        // Fetch clients if not already loaded
        if (clientProvider.clients.isEmpty) {
          clientProvider.fetchClients();
        }

        // Reset project form
        projectProvider.resetForm();

        // Set selected client based on project
        final project = projectProvider.projects.firstWhere(
          (p) => p.id == widget.projectId,
          orElse: () =>
              IsProject(id: '', name: '', address: '', isDeleted: false, v: 0),
        );

        if (project.client?.id != null) {
          clientProvider.setSelectedClient(project.client!.id!);
        }
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;

      final updatedProject = IsProject(
        id: widget.projectId,
        address: formData['project_address'] as String,
        client: IsPClient(id: formData['client'] as String, name: ''),
        name: formData['project_name'] as String,
      );

      try {
        final provider = context.read<IsProjectProvider>();
        final success = await provider.updateProject(
          widget.projectId,
          updatedProject.address ?? '',
          updatedProject.client?.id ?? '',
          updatedProject.name ?? '',
        );

        if (success && mounted) {
          context.showSuccessSnackbar('Project updated successfully');
          context.go(RouteNames.isProjects);
        } else if (mounted) {
          context.showErrorSnackbar('Failed to update project');
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackbar('Failed to update project: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<IsProjectProvider>();
    final project = projectProvider.projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () =>
          IsProject(id: '', name: '', address: '', isDeleted: false, v: 0),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.go(RouteNames.isProjects);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: const TitleText(title: 'Edit Project'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.isProjects),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: _buildFormCard(project),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(IsProject project) {
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
              'Project Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 24.h),

            // Project Name
            CustomTextFormField(
              name: 'project_name',
              labelText: 'Project Name',
              hintText: 'Enter project name',
              initialValue: project.name,
              prefixIcon: Icons.work_outline,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Project name is required',
                ),
                FormBuilderValidators.minLength(
                  2,
                  errorText: 'Name must be at least 2 characters',
                ),
              ],
              fillColor: AppTheme.white,
              prefixIconColor: AppTheme.ironSmithPrimary,
              borderColor: AppTheme.grey,
              focusedBorderColor: AppTheme.ironSmithSecondary,
              borderRadius: 12.r,
            ),
            SizedBox(height: 24.h),

            // Client Dropdown
            Consumer<IsClientProvider>(
              builder: (context, clientProvider, child) {
                return CustomSearchableDropdownFormField<String>(
                  name: 'client',
                  labelText: 'Select Client',
                  hintText: 'Search client...',
                  prefixIcon: Icons.person_outline,
                  initialValue: clientProvider.selectedClientId,
                  options: clientProvider.clients
                      .map((c) => c.id ?? '')
                      .toList(),
                  optionLabel: (id) =>
                      clientProvider.clients
                          .firstWhere(
                            (c) => c.id == id,
                            orElse: () => IsClient(id: '', name: 'Unknown'),
                          )
                          .name ??
                      'Unnamed Client',
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Client is required',
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      clientProvider.setSelectedClient(value);
                    }
                  },
                  fillColor: AppTheme.white,
                  borderColor: AppTheme.grey,
                  focusedBorderColor: AppTheme.ironSmithSecondary,
                  borderRadius: 12.r,
                );
              },
            ),
            SizedBox(height: 24.h),

            // Project Address
            CustomTextFormField(
              name: 'project_address',
              labelText: 'Project Address',
              hintText: 'Enter project address',
              initialValue: project.address,
              prefixIcon: Icons.location_on_outlined,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Address is required',
                ),
                FormBuilderValidators.minLength(
                  5,
                  errorText: 'Address must be at least 5 characters',
                ),
              ],
              fillColor: AppTheme.white,
              prefixIconColor: AppTheme.ironSmithPrimary,
              borderColor: AppTheme.grey,
              focusedBorderColor: AppTheme.ironSmithSecondary,
              borderRadius: 12.r,
            ),
            SizedBox(height: 24.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.ironSmithGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _submitForm,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Center(
                      child: Text(
                        'Update Project',
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
