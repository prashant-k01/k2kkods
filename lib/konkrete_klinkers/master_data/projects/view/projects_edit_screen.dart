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
import 'package:k2k/konkrete_klinkers/master_data/clients/provider/clients_provider.dart';
import 'package:k2k/konkrete_klinkers/master_data/projects/provider/projects_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProjectFormScreen extends StatefulWidget {
  final String projectId;

  const EditProjectFormScreen({super.key, required this.projectId});

  @override
  State<EditProjectFormScreen> createState() => _EditProjectFormScreenState();
}

class _EditProjectFormScreenState extends State<EditProjectFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load project data AFTER first frame
      final projectProvider = context.read<ProjectProvider>();
      projectProvider.loadEditProject(widget.projectId);

      // Load clients
      final clientsProvider = context.read<ClientsProvider>();
      clientsProvider.loadAllClientsForDropdown(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final clientsProvider = context.watch<ClientsProvider>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.projects);
        }
      },
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Edit Project'),
            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.projects),
            ),
          ),
          body: _buildBody(projectProvider, clientsProvider),
        ),
      ),
    );
  }

  Widget _buildBody(
    ProjectProvider projectProvider,
    ClientsProvider clientsProvider,
  ) {
    if (projectProvider.isLoadingEditForm) {
      return const Center(child: GradientLoader());
    }

    if (projectProvider.editProjectError != null) {
      return _buildErrorState(projectProvider.editProjectError!);
    }

    if (projectProvider.editProject == null) {
      return const Center(child: Text("No project data available"));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildFormCard(context, projectProvider, clientsProvider)],
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
            error,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.projects),
            child: const Text('Back to Projects'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    ProjectProvider projectProvider,
    ClientsProvider clientsProvider,
  ) {
    final project =
        projectProvider.editProject!; // Safe now because null handled earlier

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
          'name': project.name,
          'address': project.address,
          'client': project.client.name,
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Project Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Update the Project information below',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 24.h),
            _buildClientDropdown(clientsProvider),
            SizedBox(height: 24.h),
            _buildProjectNameField(),
            SizedBox(height: 24.h),
            _buildAddressField(),
            SizedBox(height: 40.h),
            Consumer<ProjectProvider>(
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

  Widget _buildClientDropdown(ClientsProvider clientsProvider) {
    final clients = clientsProvider.allClients;
    final clientNames = clients.map((c) => c.name).toList();

    return CustomSearchableDropdownFormField(
      name: 'client',
      labelText: 'Client Name',
      hintText: 'Select Client Name',
      prefixIcon: Icons.person,
      options: clientsProvider.isAllClientsLoading
          ? ['Loading...']
          : clientNames.isEmpty
          ? ['No clients available']
          : clientNames,
      fillColor: const Color(0xFFF8FAFC),
      borderColor: Colors.grey.shade300,
      focusedBorderColor: const Color(0xFF3B82F6),
      borderRadius: 12.r,
      validators: [
        FormBuilderValidators.required(errorText: 'Please select a client'),
      ],
      enabled: !clientsProvider.isAllClientsLoading && clientNames.isNotEmpty,
    );
  }

  Widget _buildProjectNameField() {
    return CustomTextFormField(
      name: 'name',
      labelText: 'Project Name',
      hintText: 'Enter Project Name',
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
    );
  }

  Widget _buildAddressField() {
    return CustomTextFormField(
      name: 'address',
      labelText: 'Address',
      hintText: 'Enter Address',
      prefixIcon: Icons.business,
      validators: [
        FormBuilderValidators.required(),
        FormBuilderValidators.minLength(2),
      ],
      fillColor: const Color(0xFFF8FAFC),
      borderColor: Colors.grey.shade300,
      focusedBorderColor: const Color(0xFF3B82F6),
      borderRadius: 12.r,
    );
  }

  Widget _buildSubmitButton(BuildContext context, ProjectProvider provider) {
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
          onTap: provider.isUpdateProjectLoading
              ? null
              : () => _submitForm(context, provider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: provider.isUpdateProjectLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GradientLoader(),
                      SizedBox(width: 12.w),
                      Text(
                        'Updating Project...',
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
                        'Update Project',
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
    ProjectProvider provider,
  ) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final clientsProvider = context.read<ClientsProvider>();

      final selectedClientName = formData['client'] as String?;
      if (selectedClientName == null) {
        context.showErrorSnackbar("Please select a client.");
        return;
      }

      final selectedClient = clientsProvider.allClients.firstWhere(
        (client) => client.name == selectedClientName,
        orElse: () => throw Exception("Selected client not found"),
      );

      if (selectedClient.id.isEmpty) {
        context.showErrorSnackbar(
          "Selected client not found. Please try again.",
        );
        return;
      }

      _showLoadingDialog();

      final success = await provider.updateProject(
        widget.projectId,
        formData['name'],
        formData['address'],
        selectedClient.id,
      );

      Navigator.of(context).pop();

      if (success && context.mounted) {
        context.showSuccessSnackbar("Project updated successfully!");
        context.go(RouteNames.projects);
      } else {
        context.showErrorSnackbar(
          provider.error ?? "Failed to update Project. Please try again.",
        );
      }
    } else {
      context.showWarningSnackbar(
        "Please fill in all required fields correctly.",
      );
    }
  }

  void _showLoadingDialog() {
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
                'Updating Project...',
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
  }
}
