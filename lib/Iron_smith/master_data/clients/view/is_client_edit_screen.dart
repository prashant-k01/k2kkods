import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/Iron_smith/master_data/clients/model/is_client_model.dart';
import 'package:k2k/Iron_smith/master_data/clients/provider/is_client_provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';

class IsClientEditScreen extends StatefulWidget {
  final String clientId;

  const IsClientEditScreen({super.key, required this.clientId});

  @override
  State<IsClientEditScreen> createState() => _IsClientEditScreenState();
}

class _IsClientEditScreenState extends State<IsClientEditScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm(IsClient client) async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;
      final updatedClient = IsClient(
        id: client.id,
        name: formData['client_name'],
        address: formData['client_address'],
        isDeleted: client.isDeleted,
        v: client.v,
        createdAt: client.createdAt,
      );

      try {
        final provider = Provider.of<IsClientProvider>(context, listen: false);
        await provider.updateClient(
          widget.clientId,
          updatedClient.name!,
          updatedClient.address!,
        );

        if (mounted) {
          context.showSuccessSnackbar('Client updated successfully');
          context.go(RouteNames.isclients);
        }
      } catch (e) {
        if (mounted) {
          context.showErrorSnackbar('Failed to update client: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IsClientProvider>();
    final client = provider.clients.firstWhere(
      (c) => c.id == widget.clientId,
      orElse: () => IsClient(name: '', isDeleted: false, v: 0),
    );

    if (client == null) {
      return FutureBuilder<void>(
        future: provider.getClientById(widget.clientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || provider.selectedClient == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error ?? "Client not found"}'),
                    ElevatedButton(
                      onPressed: () => context.go(RouteNames.isclients),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildScaffold(context, provider.selectedClient!);
        },
      );
    }

    return _buildScaffold(context, client);
  }

  Widget _buildScaffold(BuildContext context, IsClient client) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.isclients);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: const TitleText(title: 'Edit Client'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.isclients),
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
                    _buildFormCard(context, client),
                    if (context.watch<IsClientProvider>().isLoading)
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

  Widget _buildFormCard(BuildContext context, IsClient client) {
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
              'Client Details',
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
              name: 'client_name',
              labelText: 'Client Name',
              hintText: 'Enter client name',
              initialValue: client.name,
              prefixIcon: Icons.person_outline,
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
              name: 'client_address',
              labelText: 'Client Address',
              hintText: 'Enter client address',
              initialValue: client.address,
              prefixIcon: Icons.location_city_outlined,
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
                    onTap: context.watch<IsClientProvider>().isLoading
                        ? null
                        : () => _submitForm(client),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Center(
                      child: Text(
                        'Update Client',
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
