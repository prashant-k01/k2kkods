import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/konkrete_klinkers/dispatch/view/dispatch_qrScanner.dart';
import 'package:provider/provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/date_picker.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/utils/theme.dart';
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

  File? _selectedInvoiceFile;
  String? _selectedInvoiceFileName;
  String? _invoiceFileError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeProvider());
  }

  Future<void> _initializeProvider() async {
    final provider = Provider.of<DispatchProvider>(context, listen: false);
    setState(() => _isInitializing = true);

    try {
      await Future.wait([
        provider.loadWorkOrders(),
        provider.fetchDispatchById(widget.dispatchId),
      ]);

      if (provider.selectedDispatch == null) {
        throw Exception('Failed to load dispatch details.');
      }
    } catch (e) {
      context.showWarningSnackbar('Failed to load dispatch details: $e');
    } finally {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _pickInvoiceFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'xlsx', 'xls'],
      );

      if (result?.files.single.path != null) {
        setState(() {
          _selectedInvoiceFile = File(result!.files.single.path!);
          _selectedInvoiceFileName = result.files.single.name;
          _invoiceFileError = null;
        });
      }
    } catch (e) {
      setState(
        () => _invoiceFileError = 'Error selecting file: ${e.toString()}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) =>
          !didPop ? context.go(RouteNames.dispatch) : null,
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Edit Dispatch'),
            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.dispatch),
            ),
          ),
          body: SafeArea(child: _buildBody()),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<DispatchProvider>(
      builder: (context, provider, child) {
        if (_isInitializing || provider.isLoading) {
          return const Center(child: GradientLoader());
        }

        if (provider.error != null || provider.selectedDispatch == null) {
          return _buildErrorState(provider);
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: _buildFormCard(provider.workOrders, provider),
        );
      },
    );
  }

  Widget _buildErrorState(DispatchProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            provider.error ?? 'Error loading dispatch details',
            style: TextStyle(fontSize: 16.sp, color: AppTheme.errorColor),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _initializeProvider(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
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
          _buildHeader(),
          SizedBox(height: 24.h),
          _buildQrScanContainer(provider),
          SizedBox(height: 24.h),

          FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkOrderDropdown(provider, dispatch),
                SizedBox(height: 24.h),
                _buildDispatchDateField(dispatch),
                SizedBox(height: 24.h),
                _buildInvoiceField(dispatch),
                SizedBox(height: 24.h),
                _buildVehicleField(dispatch),
                SizedBox(height: 24.h),
                if (provider.isScanning)
                  const Center(child: GradientLoader())
                else if (provider.qrScanError != null)
                  _buildErrorText(provider.qrScanError!)
                else if (provider.qrScan != null)
                  _buildQrScanDataCard(provider.qrScan!),
                SizedBox(height: 24.h),
                _buildInvoicePicker(),
                SizedBox(height: 24.h),

                _buildUpdateButton(provider),
                SizedBox(height: 24.h),
                _buildInfoNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Upload',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickInvoiceFile,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _invoiceFileError != null
                    ? AppTheme.errorColor
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 20.sp,
                  color: const Color(0xFF64748B),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _selectedInvoiceFileName ??
                        'Upload invoice documents (PDF, images, Excel files)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _selectedInvoiceFileName == null
                          ? const Color(0xFF64748B)
                          : const Color(0xFF334155),
                    ),
                  ),
                ),
                if (_selectedInvoiceFileName != null)
                  Icon(Icons.check_circle, size: 20.sp, color: Colors.green),
              ],
            ),
          ),
        ),
        if (_invoiceFileError != null) _buildErrorText(_invoiceFileError!),
      ],
    );
  }

  Widget _buildErrorText(String message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        message,
        style: TextStyle(color: AppTheme.errorColor, fontSize: 14.sp),
      ),
    );
  }

  Widget _buildQrScanDataCard(Map<String, dynamic> qrData) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(top: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QR Scan Details',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
            ),
          ),
          SizedBox(height: 12.h),
          _buildDataRow('Product', qrData['product']?['description'] ?? 'N/A'),
          _buildDataRow('UOM', qrData['uom'] ?? 'N/A'),
          _buildDataRow('QR ID', qrData['qr_id'] ?? 'N/A'),
          _buildDataRow(
            'Product Quantity',
            qrData['product_quantity'].toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
      ],
    );
  }

  Widget _buildWorkOrderDropdown(DispatchProvider provider, dispatch) {
    return CustomSearchableDropdownFormField(
      name: 'work_order_number',
      labelText: 'Work Order Number',
      hintText: 'Select work order',
      prefixIcon: Icons.work,
      fillColor: AppTheme.white,
      initialValue: dispatch.workOrderName,
      options: provider.workOrders.map((wo) => wo['number'] ?? '').toList(),
      validators: [
        FormBuilderValidators.required(
          errorText: 'Please select a work order number',
        ),
      ],
    );
  }

  Widget _buildDispatchDateField(dispatch) {
    return ReusableDateFormField(
      name: 'dispatch_date',
      labelText: 'Dispatch Date',
      hintText: 'Select a dispatch date',
      initialValue: dispatch.dispatchDate,
      fillColor: Colors.white,
      borderColor: Colors.grey.shade300,
      focusedBorderColor: AppTheme.primaryBlue,
      errorBorderColor: AppTheme.errorColor,
      validators: [
        FormBuilderValidators.required(
          errorText: 'Please select a dispatch date',
        ),
      ],
    );
  }

  Widget _buildInvoiceField(dispatch) {
    return CustomTextFormField(
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
    );
  }

  Widget _buildVehicleField(dispatch) {
    return CustomTextFormField(
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
    );
  }

  Widget _buildUpdateButton(DispatchProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ElevatedButton(
          onPressed: () => _onUpdatePressed(provider),
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
              ? SizedBox(width: 20.w, height: 20.h, child: GradientLoader())
              : Text(
                  'Update Dispatch',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildQrScanContainer(DispatchProvider provider) {
    return GestureDetector(
      onTap: () async {
        final scannedData = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DispatchQrScannerScreen(
              onQrScanned: (qrData) {
                provider.setScannedQr(qrData);
              },
            ),
          ),
        );
        if (scannedData != null) provider.setScannedQr(scannedData);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: provider.qrScan != null
              ? AppTheme.secondaryGradient
              : AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  provider.qrScan != null
                      ? Icons.check_circle
                      : Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  provider.qrScan != null
                      ? 'QR Scanned Successfully'
                      : 'Tap to Scan QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (provider.qrScan != null)
                  GestureDetector(
                    onTap: provider.resetScannedQr,
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
              ],
            ),
            if (provider.qrScan != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  Text(
                    'Product: ${provider.qrScan!['product']?['description'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  Text(
                    'Quantity: ${provider.qrScan!['product_quantity'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                  Text(
                    'UOM: ${provider.qrScan!['uom'] ?? 'N/A'}',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Edit Mode Information\n\nOnly Invoice/STO, Vehicle Number, and Dispatch Date can be modified. Other fields are read-only.',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Future<void> _onUpdatePressed(DispatchProvider provider) async {
    final isValid = _formKey.currentState?.saveAndValidate() ?? false;
    if (!isValid) {
      context.showWarningSnackbar('Please fill all required fields correctly');
      return;
    }

    final formData = _formKey.currentState!.value;
    final dispatchDate = _formatDateForApi(formData['dispatch_date']);

    try {
      await provider.updateDispatch(
        dispatchId: widget.dispatchId,
        invoiceOrSto: formData['invoice_sto'] ?? '',
        vehicleNumber: formData['vehicle_number'] ?? '',
        date: dispatchDate,
      );

      context.showSuccessSnackbar('Dispatch updated successfully!');
      context.go(RouteNames.dispatch);
    } catch (e) {
      context.showWarningSnackbar(
        provider.error ?? 'Failed to update dispatch: $e',
      );
    }
  }

  String _formatDateTime(DateTime dateTime) =>
      '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) return parsed;

      final dashParts = dateString.split('-');
      if (dashParts.length == 3) {
        final y = int.tryParse(dashParts[0]);
        final m = int.tryParse(dashParts[1]);
        final d = int.tryParse(dashParts[2]);
        if (y != null && m != null && d != null) return DateTime(y, m, d);
      }

      final slashParts = dateString.split('/');
      if (slashParts.length == 3) {
        final d = int.tryParse(slashParts[0]);
        final m = int.tryParse(slashParts[1]);
        final y = int.tryParse(slashParts[2]);
        if (d != null && m != null && y != null) return DateTime(y, m, d);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String _formatDateForApi(dynamic dateValue) {
    if (dateValue == null) return '';
    if (dateValue is DateTime) return dateValue.toIso8601String().split('T')[0];
    return dateValue.toString();
  }
}
