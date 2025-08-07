import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/date_picker.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:k2k/konkrete_klinkers/dispatch/provider/dispatch_provider.dart';

class EditDispatchFormScreen extends StatefulWidget {
  final String dispatchId;
  const EditDispatchFormScreen({super.key, required this.dispatchId});

  @override
  State<EditDispatchFormScreen> createState() => _EditDispatchFormScreenState();
}

class _EditDispatchFormScreenState extends State<EditDispatchFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DispatchProvider>(context, listen: false);
      _initializeData(provider);
    });
  }

  Future<void> _initializeData(DispatchProvider provider) async {
    try {
      setState(() {
        _isInitializing = true;
      });
      await Future.wait([
        provider.loadWorkOrders(),
        provider.fetchDispatchById(widget.dispatchId),
      ]);
      if (provider.selectedDispatch == null) {
        throw Exception('Failed to load dispatch details for ID: ${widget.dispatchId}');
      }
    } catch (e) {
      print('❌ Error initializing data: $e');
      context.showWarningSnackbar('Failed to load dispatch details: $e');
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.dispatch);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: _buildLogoAndTitle(),
          leading: _buildBackButton(),
          action: [],
        ),
        body: Consumer<DispatchProvider>(
          builder: (context, provider, child) {
            if (_isInitializing || provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null || provider.selectedDispatch == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.error ?? 'Error loading dispatch details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppTheme.errorColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _initializeData(provider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.workOrderError != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        provider.workOrderError!,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  _buildFormCard(context, provider.workOrders, provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Edit Dispatch',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios,
        size: 24.sp,
        color: const Color(0xFF334155),
      ),
      onPressed: () {
        context.go(RouteNames.dispatch);
      },
      tooltip: 'Back',
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    List<Map<String, String>> workOrders,
    DispatchProvider provider,
  ) {
    final dispatch = provider.selectedDispatch!;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Dispatch Details',
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
          FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Work Order Number - Disabled
                CustomSearchableDropdownFormField(
                  name: 'work_order_number',
                  labelText: 'Work Order Number',
                  hintText: 'Work order (cannot be changed)',
                  prefixIcon: Icons.work,
                  options: workOrders.map((wo) => wo['number'] ?? '').toList(),
                  initialValue: dispatch.workOrderNumber,
                  enabled: false,
                  fillColor: Colors.grey.shade100,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: Colors.grey.shade300,
                  errorBorderColor: AppTheme.errorColor,
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),

                // Dispatch Date - Editable
                ReusableDateFormField(
                  name: 'dispatch_date',
                  labelText: 'Dispatch Date',
                  hintText: 'Select a dispatch date',
                  initialValue: _parseDate(dispatch.date),
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: AppTheme.primaryBlue,
                  errorBorderColor: AppTheme.errorColor,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a dispatch date',
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Invoice/STO - Editable
                CustomTextFormField(
                  name: 'invoice_sto',
                  labelText: 'Invoice/STO',
                  hintText: 'Enter Invoice or STO number',
                  prefixIcon: Icons.description,
                  initialValue: dispatch.invoiceOrSto,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please enter Invoice or STO number',
                    ),
                  ],
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: const Color(0xFF3B82F6),
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),

                // Vehicle Number - Editable
                CustomTextFormField(
                  name: 'vehicle_number',
                  labelText: 'Vehicle Number',
                  hintText: 'Enter vehicle number',
                  prefixIcon: Icons.directions_car,
                  initialValue: dispatch.vehicleNumber,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please enter vehicle number',
                    ),
                  ],
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: const Color(0xFF3B82F6),
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),

                // QR Code - Disabled
                CustomTextFormField(
                  name: 'qr_code',
                  labelText: 'QR Code',
                  hintText: 'QR code (cannot be changed)',
                  prefixIcon: Icons.qr_code,
                  initialValue: provider.qrScanData?['qr_code']?.toString() ?? 'N/A',
                  enabled: false,
                  fillColor: Colors.grey.shade100,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: Colors.grey.shade300,
                  errorBorderColor: AppTheme.errorColor,
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),

                // Product Names - Read Only
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Names',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 20.sp,
                                color: const Color(0xFF64748B),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Product information (read-only)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF64748B),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          if (dispatch.productNames.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            ...dispatch.productNames.map(
                              (product) => Padding(
                                padding: EdgeInsets.only(bottom: 4.h),
                                child: Text(
                                  '• ${product.name} (Qty: ${product.dispatchQuantity})',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ),
                          ] else
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                'No products available',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Client and Project Info - Read Only
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Client Name',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              dispatch.clientName.isNotEmpty
                                  ? dispatch.clientName
                                  : 'Not specified',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Name',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              dispatch.projectName.isNotEmpty
                                  ? dispatch.projectName
                                  : 'Not specified',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Created By - Read Only
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created By',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 20.sp,
                            color: const Color(0xFF64748B),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dispatch.createdBy.isNotEmpty
                                      ? dispatch.createdBy
                                      : 'Unknown',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF374151),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Created on: ${_formatDateTime(dispatch.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        bool isFormValid =
                            _formKey.currentState?.saveAndValidate() ?? false;

                        if (isFormValid) {
                          final formData = _formKey.currentState!.value;
                          final provider = Provider.of<DispatchProvider>(
                            context,
                            listen: false,
                          );

                          String dispatchDate = '';
                          final dateValue = formData['dispatch_date'];
                          if (dateValue != null) {
                            if (dateValue is DateTime) {
                              dispatchDate = dateValue.toIso8601String().split('T')[0];
                            } else {
                              dispatchDate = dateValue.toString();
                            }
                          }

                          print('🚀 UPDATE PAYLOAD TO BE SENT:');
                          print('  dispatchId: "${widget.dispatchId}"');
                          print('  invoice_or_sto: "${formData['invoice_sto'] ?? ''}"');
                          print('  vehicle_number: "${formData['vehicle_number'] ?? ''}"');
                          print('  date: "$dispatchDate"');

                          try {
                            await provider.updateDispatch(
                              dispatchId: widget.dispatchId,
                              invoiceOrSto: formData['invoice_sto'] ?? '',
                              vehicleNumber: formData['vehicle_number'] ?? '',
                              date: dispatchDate,
                            );

                            context.showSuccessSnackbar(
                              'Dispatch updated successfully!',
                            );
                            context.go(RouteNames.dispatch);
                          } catch (e) {
                            context.showWarningSnackbar(
                              provider.error ?? 'Failed to update dispatch: $e',
                            );
                          }
                        } else {
                          context.showWarningSnackbar(
                            'Please fill all required fields correctly',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: provider.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                            )
                          : Text(
                              'Update Dispatch',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Info Note
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: const Color(0xFF64748B),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Edit Mode Information\n\nOnly Invoice/STO, Vehicle Number, and Dispatch Date can be modified. Other fields are read-only.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      print('⚠️ Date string is null or empty');
      return null;
    }

    try {
      final parsedDate = DateTime.tryParse(dateString);
      if (parsedDate != null) {
        return parsedDate;
      }

      final parts = dateString.split('-');
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          return DateTime(year, month, day);
        }
      }

      final slashParts = dateString.split('/');
      if (slashParts.length == 3) {
        final day = int.tryParse(slashParts[0]);
        final month = int.tryParse(slashParts[1]);
        final year = int.tryParse(slashParts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }

      print('❌ Failed to parse date: "$dateString"');
      return null;
    } catch (e) {
      print('❌ Error parsing date "$dateString": $e');
      return null;
    }
  }
}