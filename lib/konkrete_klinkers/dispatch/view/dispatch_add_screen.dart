import 'dart:convert';
import 'dart:io';
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
  File? _selectedInvoiceFile; // Store the actual file
  String? _selectedInvoiceFileName; // Store the filename for display
  String? _invoiceFileError; // Store validation error

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DispatchProvider>(context, listen: false);
      // Reset all provider state, including QR scan data, on screen initialization
      provider.reset(); // Use existing reset method to clear QR scan data
      _formKey.currentState?.fields['qr_code']?.reset(); // Reset QR code field
      provider.loadWorkOrders();
    });
  }

  Future<void> _pickInvoiceFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedInvoiceFile = File(result.files.single.path!);
          _selectedInvoiceFileName = result.files.single.name;
          _invoiceFileError = null; // Clear any previous error
        });
      }
    } catch (e) {
      setState(() {
        _invoiceFileError = 'Error selecting file: ${e.toString()}';
      });
    }
  }

  bool _validateInvoiceFile() {
    if (_selectedInvoiceFile == null) {
      setState(() {
        _invoiceFileError = 'Please upload an invoice file';
      });
      return false;
    }
    setState(() {
      _invoiceFileError = null;
    });
    return true;
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
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.isLoadingWorkOrders)
                    const Center(child: CircularProgressIndicator())
                  else if (provider.workOrderError != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Text(
                        provider.workOrderError!,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  else
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
          'Add Dispatch',
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
    return Builder(
      builder: (BuildContext context) {
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
      },
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    List<Map<String, String>> workOrders,
    DispatchProvider provider,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                CustomSearchableDropdownFormField(
                  name: 'work_order_number',
                  labelText: 'Work Order Number',
                  hintText: 'Select work order',
                  prefixIcon: Icons.work,
                  options: workOrders.map((wo) => wo['number'] ?? '').toList(),
                  enabled: true,
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: AppTheme.primaryBlue,
                  errorBorderColor: AppTheme.errorColor,
                  borderRadius: 12.r,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please select a work order number',
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                ReusableDateFormField(
                  name: "dispatch_date",
                  labelText: "Dispatch Date",
                  hintText: "Select a dispatch date",
                  fillColor: Colors.white,
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: AppTheme.primaryBlue,
                  errorBorderColor: AppTheme.errorColor,
                ),
                SizedBox(height: 24.h),

                CustomTextFormField(
                  name: 'invoice_sto',
                  labelText: 'Invoice/STO',
                  fillColor: Colors.white,
                  hintText: 'Enter Invoice or STO number',
                  prefixIcon: Icons.description,
                  validators: [
                    FormBuilderValidators.required(
                      errorText: 'Please enter Invoice or STO number',
                    ),
                  ],
                  borderColor: Colors.grey.shade300,
                  focusedBorderColor: const Color(0xFF3B82F6),
                  borderRadius: 12.r,
                ),
                SizedBox(height: 24.h),

                CustomTextFormField(
                  name: 'vehicle_number',
                  labelText: 'Vehicle Number',
                  hintText: 'Enter vehicle number',
                  prefixIcon: Icons.directions_car,
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
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        name: 'qr_code',
                        labelText: 'QR Code',
                        hintText: 'Enter QR code',
                        prefixIcon: Icons.qr_code,
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Please enter a QR code',
                          ),
                        ],
                        fillColor: Colors.white,
                        borderColor: Colors.grey.shade300,
                        focusedBorderColor: const Color(0xFF3B82F6),
                        borderRadius: 12.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final qrCode = _formKey
                              .currentState
                              ?.fields['qr_code']
                              ?.value
                              ?.toString();
                          if (qrCode == null || qrCode.isEmpty) {
                            context.showWarningSnackbar(
                              'Please enter a QR code to scan',
                            );
                            return;
                          }
                          await provider.scanQrCode(qrCode);
                          if (provider.qrScanError != null) {
                            context.showWarningSnackbar(provider.qrScanError!);
                          } else {
                            context.showSuccessSnackbar(
                              'QR code scanned successfully',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: provider.isLoadingQrScan
                            ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.w,
                                ),
                              )
                            : Text(
                                'Scan',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                if (provider.isLoadingQrScan)
                  const Center(child: CircularProgressIndicator())
                else if (provider.qrScanError != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      provider.qrScanError!,
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  )
                else if (provider.qrScanData != null)
                  _buildQrScanDataCard(provider.qrScanData!),
                SizedBox(height: 24.h),

                // Fixed Invoice File Picker - No longer using FormBuilderField
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Upload',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF334155),
                      ),
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
                              Icon(
                                Icons.check_circle,
                                size: 20.sp,
                                color: Colors.green,
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_invoiceFileError != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          _invoiceFileError!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ElevatedButton(
                      // Replace your entire ElevatedButton onPressed method with this complete code:
                      onPressed: () async {
                        // Validate form fields
                        bool isFormValid =
                            _formKey.currentState?.saveAndValidate() ?? false;

                        // Validate invoice file
                        bool isFileValid = _validateInvoiceFile();

                        if (isFormValid && isFileValid) {
                          final formData = _formKey.currentState!.value;
                          final provider = Provider.of<DispatchProvider>(
                            context,
                            listen: false,
                          );

                          print('📋 Form submission started...');
                          print('📋 Form data: $formData');

                          // Find work order ID
                          final selectedWorkOrderNumber =
                              formData['work_order_number'] as String?;
                          print(
                            '🔍 Selected work order number: $selectedWorkOrderNumber',
                          );

                          final workOrder = provider.workOrders.firstWhere(
                            (wo) => wo['number'] == selectedWorkOrderNumber,
                            orElse: () => {'id': '', 'number': ''},
                          );
                          final workOrderId = workOrder['id'];
                          print('🔍 Found work order ID: $workOrderId');

                          // Handle QR codes - CORRECTED LOGIC - Send QR Code URL not QR ID
                          List<String> qrCodes = [];

                          // Check if we have scanned QR data
                          if (provider.qrScanData != null &&
                              provider.qrScanData!['qr_code'] != null) {
                            // Use the QR code URL from the scanned data (NOT qr_id)
                            final qrCodeUrl = provider.qrScanData!['qr_code']
                                .toString();
                            qrCodes.add(qrCodeUrl);
                            print('✅ Using scanned QR Code URL: $qrCodeUrl');
                            print(
                              '✅ QR ID for reference: ${provider.qrScanData!['qr_id']}',
                            );
                          } else {
                            context.showWarningSnackbar(
                              'Please scan a QR code first to get the QR code URL',
                            );
                            return;
                          }

                          print('🔍 Final QR Codes array: $qrCodes');

                          if (qrCodes.isEmpty) {
                            context.showWarningSnackbar(
                              'Please scan a QR code first',
                            );
                            return;
                          }
                          if (!qrCodes.first.startsWith('https://')) {
                            context.showWarningSnackbar(
                              'Invalid QR code format. Please scan again.',
                            );
                            return;
                          }

                          // Format date properly
                          String dispatchDate = '';
                          final dateValue = formData['dispatch_date'];
                          if (dateValue != null) {
                            if (dateValue is DateTime) {
                              dispatchDate = dateValue.toIso8601String().split(
                                'T',
                              )[0];
                            } else {
                              dispatchDate = dateValue.toString();
                            }
                          }
                          print('🔍 Formatted date: $dispatchDate');
                          if (workOrderId == null || workOrderId.isEmpty) {
                            context.showWarningSnackbar(
                              'Invalid work order selected',
                            );
                            return;
                          }
                          print('🚀 PAYLOAD TO BE SENT:');
                          print('  work_order: "$workOrderId"');
                          print(
                            '  invoice_or_sto: "${formData['invoice_sto'] ?? ''}"',
                          );
                          print(
                            '  vehicle_number: "${formData['vehicle_number'] ?? ''}"',
                          );
                          print(
                            '  qr_codes: $qrCodes (JSON: ${jsonEncode(qrCodes)})',
                          );
                          print('  date: "$dispatchDate"');
                          print(
                            '  invoice_file: ${_selectedInvoiceFile!.path}',
                          );
                          print(
                            '🔍 QR Scan Data Available: ${provider.qrScanData != null}',
                          );
                          if (provider.qrScanData != null) {
                            print('🔍 QR Scan Data: ${provider.qrScanData}');
                            print(
                              '🔍 QR Code URL from scan: ${provider.qrScanData!['qr_code']}',
                            );
                            print(
                              '🔍 QR ID from scan: ${provider.qrScanData!['qr_id']}',
                            );
                            print(
                              '🔍 Packing ID from scan: ${provider.qrScanData!['_id']}',
                            );
                          }

                          try {
                            print('🚀 Starting createDispatch call...');
                            await provider.createDispatch(
                              workOrder: workOrderId,
                              invoiceOrSto:
                                  (formData['invoice_sto'] as String?) ?? '',
                              vehicleNumber:
                                  (formData['vehicle_number'] as String?) ?? '',
                              qrCodes:
                                  qrCodes, // Now sending the correct QR code URLs
                              date: dispatchDate,
                              invoiceFile: _selectedInvoiceFile!,
                            );

                            print('✅ Dispatch created successfully!');
                            context.showSuccessSnackbar(
                              'Dispatch added successfully!',
                            );
                            context.go(RouteNames.dispatch);
                          } catch (e) {
                            print('❌ Error in form submission: $e');
                            print('❌ Provider error: ${provider.error}');
                            context.showWarningSnackbar(
                              provider.error ?? 'Failed to add dispatch: $e',
                            );
                          }
                        } else {
                          if (!isFormValid) {
                            context.showWarningSnackbar(
                              'Please fill all required fields correctly',
                            );
                          }
                          if (!isFileValid) {
                            context.showWarningSnackbar(
                              'Please upload an invoice file',
                            );
                          }
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
                              'Add Dispatch',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
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
                        'Confidentiality Note\n\nAll dispatch information is treated with strict confidentiality and used solely for operational purposes.',
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
}
