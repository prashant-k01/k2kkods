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

class AddProjectFormScreen extends StatefulWidget {
  const AddProjectFormScreen({super.key});

  @override
  _AddProjectFormScreenState createState() => _AddProjectFormScreenState();
}

class _AddProjectFormScreenState extends State<AddProjectFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    // Defer loading clients until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientsProvider = Provider.of<ClientsProvider>(
        context,
        listen: false,
      );
      clientsProvider.loadAllClientsForDropdown(
        refresh: true,
      ); // Load all clients for dropdown
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(
      context,
      listen: false,
    );
    final clientsProvider = Provider.of<ClientsProvider>(context);

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
            title: TitleText(title: 'Create Project'),
            leading: CustomBackButton(
              onPressed: () {
                context.go(RouteNames.products);
              },
            ),
            action: [],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormCard(context, projectProvider, clientsProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    ProjectProvider projectProvider,
    ClientsProvider clientsProvider,
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
              'Project Details',
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
            Consumer<ClientsProvider>(
              builder: (context, clientsProvider, _) {
                final clients = clientsProvider
                    .allClients; // Use allClients instead of clients
                final clientNames = clients
                    .map((client) => client.name)
                    .toList();

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
                    FormBuilderValidators.required(
                      errorText: 'Please select a client',
                    ),
                  ],
                  enabled:
                      !clientsProvider.isAllClientsLoading &&
                      clientNames.isNotEmpty,
                );
              },
            ),
            SizedBox(height: 24.h),

            CustomTextFormField(
              name: 'name',
              labelText: ' Project Name',
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
            ),
            SizedBox(height: 24.h),
            CustomTextFormField(
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
            ),
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
          onTap: provider.isAddProjectLoading
              ? null
              : () => _submitForm(context, provider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: provider.isAddProjectLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GradientLoader(),
                      SizedBox(width: 12.w),
                      Text(
                        'Creating Project...',
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
                      Icon(Icons.add_circle, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Create Project',
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
      final clientsProvider = Provider.of<ClientsProvider>(
        context,
        listen: false,
      );

      final selectedClientName = formData['client'] as String?;
      if (selectedClientName == null) {
        context.showErrorSnackbar("Please select a client.");
        return;
      }

      final selectedClient = clientsProvider.allClients.firstWhere(
        (client) => client.name == selectedClientName,
      );

      if (selectedClient.id.isEmpty) {
        context.showErrorSnackbar(
          "Selected client not found. Please try again.",
        );
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
                const GradientLoader(),
                SizedBox(height: 16.h),
                Text(
                  'Creating Project...',
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

      final success = await provider.createProject(
        formData['name'],
        formData['address'],
        selectedClient.id,
      );

      Navigator.of(context).pop();

      if (success && context.mounted) {
        context.showSuccessSnackbar("Project successfully created");
        context.go(RouteNames.projects);
      } else {
        context.showErrorSnackbar(
          "Failed to create project: ${provider.error?.replaceFirst('Exception: ', '') ?? 'Unknown error. Please try again.'}",
        );
      }
    } else {
      context.showWarningSnackbar(
        "Please fill in all required fields correctly.",
      );
    }
  }
}
