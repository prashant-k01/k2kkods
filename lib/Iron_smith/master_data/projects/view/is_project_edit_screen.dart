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

    // Fetch clients and reset project form
    Future.microtask(() {
      final clientProvider = Provider.of<IsClientProvider>(
        context,
        listen: false,
      );
      clientProvider.fetchClients();
      Provider.of<IsProjectProvider>(context, listen: false).resetForm();

      // If editing, set selected client after project is loaded
      final projectProvider = Provider.of<IsProjectProvider>(
        context,
        listen: false,
      );
      final project = projectProvider.projects.firstWhere(
        (p) => p.id == widget.projectId,
        orElse: () => IsProject(name: '', address: '', isDeleted: false, v: 0),
      );

      if (project != null && project.client?.id != null) {
        clientProvider.setSelectedClient(project.client!.id!);
      }
    });
  }

  Future<void> _submitForm(IsProject project) async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;

      final updatedProject = IsProject(
        address: formData['project_address'],
        client: IsPClient(id: formData['client'], name: ""),
        name: formData['project_name'],
      );

      print("✅ Form Data: $formData");
      print("✅ Payload: ${updatedProject.toJson()}");

      try {
        final provider = Provider.of<IsProjectProvider>(context, listen: false);
        await provider.updateProject(
          widget.projectId,
          updatedProject.name ?? '',
          updatedProject.address ?? '',
          updatedProject.client?.id ?? '', // send clientId
        );

        if (mounted) {
          context.showSuccessSnackbar('Project updated successfully');
          context.go(RouteNames.isProjects);
        }
      } catch (e, stack) {
        print("❌ Error: $e");
        print("❌ Stacktrace: $stack");
        if (mounted) {
          context.showErrorSnackbar('Failed to update project: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<IsClientProvider>().clients;
    final projectProvider = context.watch<IsProjectProvider>();

    final project = projectProvider.projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => IsProject(name: '', address: '', isDeleted: false, v: 0),
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
            child: _buildFormCard(project, clients),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(IsProject project, List<IsClient> clients) {
    final clientProvider = context.read<IsClientProvider>();
    clientProvider.setSelectedClient(project.client?.id);

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

            // Client Dropdown
            Consumer<IsClientProvider>(
              builder: (context, clientProvider, child) {
                final clients = clientProvider.clients;

                return CustomSearchableDropdownFormField<String>(
                  name: 'client',
                  labelText: 'Select Client',
                  hintText: 'Search client...',
                  prefixIcon: Icons.person_outline,
                  initialValue: clientProvider.selectedClientId,
                  options: clients.map((c) => c.id ?? "").toList(),
                  optionLabel: (id) =>
                      clients
                          .firstWhere(
                            (c) => c.id == id,
                            orElse: () => IsClient(id: '', name: 'Unknown'),
                          )
                          .name ??
                      "Unnamed Client",
                  validators: [FormBuilderValidators.required()],
                  onChanged: (value) => clientProvider.setSelectedClient(value),
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
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(5),
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
                    onTap: () => _submitForm(project),
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
