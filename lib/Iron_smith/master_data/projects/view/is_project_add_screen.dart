import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/utils/theme.dart';

import 'package:k2k/Iron_smith/master_data/projects/model/is_project_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/provider/is_project_provider.dart';
import 'package:k2k/Iron_smith/master_data/clients/provider/is_client_provider.dart';
import 'package:k2k/Iron_smith/master_data/clients/model/is_client_model.dart';

class IsProjectAddScreen extends StatefulWidget {
  const IsProjectAddScreen({super.key});

  @override
  State<IsProjectAddScreen> createState() => _IsProjectAddScreenState();
}

class _IsProjectAddScreenState extends State<IsProjectAddScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<IsClientProvider>(context, listen: false).fetchClients();
      Provider.of<IsProjectProvider>(context, listen: false).resetForm();
    });
  }

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;

      final project = IsProject(
        name: formData['project_name'],
        address: formData['project_address'],
        client: IsPClient(
          id: formData['client'],
          name: "",
        ), // should be clientId string
        isDeleted: false,
        v: 0,
      );

      try {
        final provider = Provider.of<IsProjectProvider>(context, listen: false);
        await provider.addProject(project);

        if (mounted) {
          context.showSuccessSnackbar('Project added successfully');
          context.go(RouteNames.isProjects);
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackbar('Failed to add project: $e');
        }
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final clients = context.watch<IsClientProvider>().clients;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.isProjects);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: TitleText(title: 'Create Project'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.isProjects),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: _buildFormCard(clients),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(List<IsClient> clients) {
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
              style: TextStyle(fontSize: 14.sp, color: AppTheme.headingform),
            ),
            SizedBox(height: 24.h),

            // Project Name
            CustomTextFormField(
              name: 'project_name',
              labelText: 'Project Name',
              hintText: 'Enter project name',
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

            // Client Dropdown (Searchable)
            Consumer<IsClientProvider>(
              builder: (context, clientProvider, child) {
                final clients = clientProvider.clients;

                return CustomSearchableDropdownFormField<String>(
                  name: 'client',
                  labelText: 'Select Client',
                  hintText: 'Search client...',
                  prefixIcon: Icons.person_outline,
                  // initialValue: clientProvider.selectedClientId,
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
                    onTap: _submitForm,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Center(
                      child: Text(
                        'Add Project',
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
