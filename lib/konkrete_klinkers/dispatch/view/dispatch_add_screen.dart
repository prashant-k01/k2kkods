import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/date_picker.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/dispatch/view/dispatch_qrScanner.dart';
import 'package:k2k/utils/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:k2k/konkrete_klinkers/dispatch/provider/dispatch_provider.dart';

class AddDispatchFormScreen extends StatefulWidget {
  const AddDispatchFormScreen({super.key});

  @override
  State<AddDispatchFormScreen> createState() => _AddDispatchFormScreenState();
}

class _AddDispatchFormScreenState extends State<AddDispatchFormScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  File? _selectedInvoiceFile;
  String? _selectedInvoiceFileName;
  String? _invoiceFileError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProvider();
    });
  }

  void _initializeProvider() {
    final provider = Provider.of<DispatchProvider>(context, listen: false);
    provider.reset();
    _formKey.currentState?.fields['qr_code']?.reset();
    provider.loadWorkOrders();
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

  bool _validateInvoiceFile() {
    if (_selectedInvoiceFile == null) {
      setState(() => _invoiceFileError = 'Please upload an invoice file');
      return false;
    }
    setState(() => _invoiceFileError = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.go(RouteNames.dispatch);
      },
      child: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Scaffold(
          backgroundColor: AppColors.transparent,
          appBar: AppBars(
            title: TitleText(title: 'Add Dispatch'),
            leading: CustomBackButton(
              onPressed: () => context.go(RouteNames.dispatch),
            ),
            action: [],
          ),
          body: SafeArea(
            child: Consumer<DispatchProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingWorkOrders) {
                  return const Center(child: GradientLoader());
                }
                if (provider.workOrderError != null) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      provider.workOrderError!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.all(24.w),
                  child: _buildFormCard(context, provider),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, DispatchProvider provider) {
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
          _buildQrScanContainer(provider),
          SizedBox(height: 24.h),
          Text(
            'Dispatch Details',
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
          FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWorkOrderDropdown(provider),
                SizedBox(height: 24.h),
                _buildDispatchDateField(),
                SizedBox(height: 24.h),
                _buildInvoiceField(),
                SizedBox(height: 24.h),
                _buildVehicleNumberField(),
                SizedBox(height: 24.h),
                if (provider.isScanning)
                  const Center(child: GradientLoader())
                else if (provider.qrScanError != null)
                  _buildErrorText(provider.qrScanError!)
                else if (provider.qrScan != null)
                  _buildQrScanDataCard(provider.qrScan!),
                SizedBox(height: 24.h),
                _buildInvoicePicker(),
                SizedBox(height: 40.h),
                _buildSubmitButton(provider),
                SizedBox(height: 24.h),
                _buildConfidentialityNote(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderDropdown(DispatchProvider provider) {
    return CustomSearchableDropdownFormField(
      name: 'work_order_number',
      labelText: 'Work Order Number',
      hintText: 'Select work order',
      fillColor: AppTheme.white,
      prefixIcon: Icons.work,
      options: provider.workOrders.map((wo) => wo['number'] ?? '').toList(),
      validators: [
        FormBuilderValidators.required(
          errorText: 'Please select a work order number',
        ),
      ],
    );
  }

  Widget _buildDispatchDateField() {
    return ReusableDateFormField(
      name: "dispatch_date",
      labelText: "Dispatch Date",
      fillColor: AppTheme.white,

      hintText: "Select a dispatch date",
    );
  }

  Widget _buildInvoiceField() {
    return CustomTextFormField(
      name: 'invoice_sto',
      labelText: 'Invoice/STO',
      hintText: "Enter Invoice/STO",
      prefixIcon: Icons.description,
      fillColor: AppTheme.white,

      validators: [
        FormBuilderValidators.required(
          errorText: 'Please enter Invoice or STO number',
        ),
      ],
    );
  }

  Widget _buildVehicleNumberField() {
    return CustomTextFormField(
      name: 'vehicle_number',
      labelText: 'Vehicle Number',
      hintText: 'Enter Vehicle Number',
      fillColor: AppTheme.white,

      prefixIcon: Icons.directions_car,
      validators: [
        FormBuilderValidators.required(
          errorText: 'Please enter vehicle number',
        ),
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

  Widget _buildSubmitButton(DispatchProvider provider) {
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
          onTap: provider.isLoading ? null : () => _submitForm(provider),
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (provider.isLoading)
                    const GradientLoader()
                  else
                    Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  SizedBox(width: 8.w),
                  Text(
                    provider.isLoading ? 'Submitting...' : 'Add Dispatch',
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
      ),
    );
  }

  Widget _buildConfidentialityNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Confidentiality Note\n\nAll dispatch information is treated with strict confidentiality and used solely for operational purposes.',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
          ),
        ),
      ],
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

  Future<void> _submitForm(DispatchProvider provider) async {
    final isFormValid = _formKey.currentState?.saveAndValidate() ?? false;
    final isFileValid = _validateInvoiceFile();

    if (!isFormValid || !isFileValid) {
      if (!isFormValid) {
        context.showWarningSnackbar(
          'Please fill all required fields correctly',
        );
      }
      if (!isFileValid) {
        context.showWarningSnackbar('Please upload an invoice file');
      }
      return;
    }

    final formData = _formKey.currentState!.value;

    final selectedWorkOrderNumber = formData['work_order_number'] as String?;
    final workOrder = provider.workOrders.firstWhere(
      (wo) => wo['number'] == selectedWorkOrderNumber,
      orElse: () => {'id': '', 'number': ''},
    );
    final workOrderId = workOrder['id'];

    if (workOrderId == null || workOrderId.isEmpty) {
      context.showWarningSnackbar('Invalid work order selected');
      return;
    }

    // ===== Debug: QR Scan Data =====
    print('QR Scan Data in Provider: ${provider.qrScan}');
    if (provider.qrScan == null || provider.qrScan!['qr_code'] == null) {
      context.showWarningSnackbar(
        'Please scan a QR code first to get the QR code URL',
      );
      return;
    }

    final qrCodes = [provider.qrScan!['qr_code'].toString()];
    print('QR Codes to send: $qrCodes');

    if (!qrCodes.first.startsWith('https://')) {
      context.showWarningSnackbar('Invalid QR code format. Please scan again.');
      return;
    }

    String dispatchDate = '';
    final dateValue = formData['dispatch_date'];
    if (dateValue != null) {
      dispatchDate = dateValue is DateTime
          ? dateValue.toIso8601String().split('T')[0]
          : dateValue.toString();
    }

    print('Dispatch Data:');
    print('Work Order ID: $workOrderId');
    print('Invoice/STO: ${formData['invoice_sto']}');
    print('Vehicle Number: ${formData['vehicle_number']}');
    print('Dispatch Date: $dispatchDate');
    print('Invoice File Path: ${_selectedInvoiceFile?.path}');

    try {
      await provider.createDispatch(
        workOrder: workOrderId,
        invoiceOrSto: formData['invoice_sto'] ?? '',
        vehicleNumber: formData['vehicle_number'] ?? '',
        qrCodes: qrCodes,
        date: dispatchDate,
        invoiceFile: _selectedInvoiceFile!,
      );

      context.showSuccessSnackbar('Dispatch added successfully!');
      context.go(RouteNames.dispatch);
    } catch (e) {
      print('Error during createDispatch: $e');
      context.showWarningSnackbar(
        provider.error ?? 'Failed to add dispatch: $e',
      );
    }
  }
}
