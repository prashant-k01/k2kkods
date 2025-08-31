import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/workorder/model/iron_workorder_model.dart';
import 'package:k2k/Iron_smith/workorder/provider/iron_workorder_provider.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:k2k/common/date_picker.dart';

class IronWorkorderAddScreen extends StatefulWidget {
  const IronWorkorderAddScreen({super.key});

  @override
  State<IronWorkorderAddScreen> createState() => _IronWorkorderAddScreenState();
}

class _IronWorkorderAddScreenState extends State<IronWorkorderAddScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<IronWorkorderProvider>(
        context,
        listen: false,
      );
      provider.reset();
      provider.fetchAllClients();
      provider.fetchAllShapeCodes();
    });
  }

  @override
  void dispose() {
    _focusNodes.forEach((_, node) => node.dispose());
    super.dispose();
  }

  // Helper method to get or create FocusNode
  FocusNode _getFocusNode(String key) {
    if (!_focusNodes.containsKey(key)) {
      _focusNodes[key] = FocusNode();
    }
    return _focusNodes[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go(RouteNames.getAllIronWO);
        }
      },
      child: Consumer<IronWorkorderProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBars(
              title: TitleText(title: 'Create Work Order'),
              leading: CustomBackButton(
                onPressed: () => context.go(RouteNames.getAllIronWO),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      _buildMainFormCard(context, provider),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: _buildFixedSubmitButton(context),
          );
        },
      ),
    );
  }

  Widget _buildMainFormCard(
    BuildContext context,
    IronWorkorderProvider provider,
  ) {
    final selectedClient = provider.selectedClient;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work Order Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 12.h),
            if (provider.isLoadingClients)
              const Center(child: GradientLoader())
            else if (provider.clients.isEmpty && provider.errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Error loading clients: ${provider.errorMessage}',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.clients.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'No clients available',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              CustomSearchableDropdownFormField<Client>(
                key: ValueKey('client_id${provider.selectedClient ?? ''}'),
                name: 'client_id',
                labelText: 'Client Name',
                prefixIcon: Icons.person_outline,
                iconSize: 18.sp,
                textStyle: TextStyle(fontSize: 14.sp),
                labelStyle: TextStyle(fontSize: 14.sp),
                fillColor: AppColors.background,
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                options: provider.clients,
                optionLabel: (client) => client.name ?? '',
                initialValue: provider.selectedClient != null
                    ? provider.clients.firstWhere(
                        (client) => client.id == provider.selectedClient,
                        orElse: () => Client(),
                      )
                    : null,
                onChanged: (client) {
                  provider.setClient(client?.id);
                  if (client?.id != null) {
                    provider.loadProjectsByClient(client!.id!);
                  } else {
                    provider.setProject(null);
                    _formKey.currentState?.fields['project_id']?.didChange(
                      null,
                    );
                  }
                },
                validators: [
                  FormBuilderValidators.required(
                    errorText: 'Client is required',
                  ),
                ],
                allowClear: true,
              ),
            SizedBox(height: 12.h),
            if (provider.isLoadingProjects)
              const Center(child: GradientLoader())
            else if (provider.projects.isEmpty && selectedClient != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'No projects available for this client',
                  style: TextStyle(color: Colors.red, fontSize: 13.sp),
                ),
              )
            else
              CustomSearchableDropdownFormField<Project>(
                key: ValueKey('project_id${provider.selectedProject ?? ''}'),
                name: 'project_id',
                // hintText: 'Select Project',
                labelText: 'Project Name',
                prefixIcon: Icons.domain,
                iconSize: 18.sp,
                textStyle: TextStyle(fontSize: 14.sp),
                labelStyle: TextStyle(fontSize: 14.sp),
                fillColor: AppColors.background,
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                options: provider.projects,
                optionLabel: (project) => project.name ?? '',
                initialValue: provider.selectedProject != null
                    ? provider.projects.firstWhere(
                        (project) => project.id == provider.selectedProject,
                        orElse: () => Project(),
                      )
                    : null,
                onChanged: (project) {
                  provider.setProject(project?.id);
                  _formKey.currentState?.fields['project_id']?.didChange(
                    project,
                  );
                },
                validators: selectedClient != null
                    ? [
                        FormBuilderValidators.required(
                          errorText: 'Project is required',
                        ),
                      ]
                    : [],
                allowClear: true,
              ),
            SizedBox(height: 12.h),
            CustomTextFormField(
              name: 'work_order_number',
              labelText: 'Work Order No',
              hintText: 'Enter Work Order No.',
              fillColor: AppColors.background,
              prefixIcon: Icons.format_list_numbered,
              textStyle: TextStyle(fontSize: 14.sp),
              labelStyle: TextStyle(fontSize: 14.sp),
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Work Order Number is required',
                ),
              ],
              onChanged: (value) => provider.setWorkOrderNumber(value ?? ''),
            ),
            SizedBox(height: 12.h),
            ReusableDateFormField(
              name: 'work_order_date',
              labelText: 'Work Order Date',
              hintText: 'Select date',
              prefixIcon: Icons.calendar_today_outlined,
              iconSize: 18.sp,
              textStyle: TextStyle(fontSize: 14.sp),
              fillColor: AppColors.background,
              labelStyle: TextStyle(fontSize: 14.sp),
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Work Order Date is required',
                ),
              ],
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              format: DateFormat('dd-MM-yyyy'),
              onChanged: (date) {
                if (date != null) {
                  provider.setWorkOrderDate(date);
                }
              },
            ),
            SizedBox(height: 16.h),
            Text(
              'Products',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 12.h),
            _buildProductForms(provider),
            SizedBox(height: 12.h),
            _buildAddProductButton(provider),
            SizedBox(height: 12.h),
            _buildUploadSection(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildProductForms(IronWorkorderProvider provider) {
    Timer? _debounce;

    return SingleChildScrollView(
      child: Column(
        children: provider.products.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> product = entry.value;
          final shapeCodeOptions = provider.shapeCodes
              .map((shape) => shape.shapeCode ?? '')
              .where((code) => code.isNotEmpty)
              .toList();
          final currentShapeCode = product['shapeCode'];
          final currentShapeId = product['shapeId'];
          final dimensionCount = product['dimensionCount'] ?? 0;
          final dimensions = product['dimensions'] ?? {};

          final diameterOptions = provider.diameters
              .map((diameter) => diameter.diameter?.toString() ?? '')
              .where((dia) => dia.isNotEmpty)
              .toList();
          final currentDiameter = product['diameter'];

          return Container(
            key: ValueKey('product_$index'), // Unique key for each product
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFEDE9FE),
                  const Color(0xFFF5F3FF),
                  const Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.05),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Stack(
              children: [
                FormBuilder(
                  key: GlobalKey<FormBuilderState>(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product ${index + 1}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      if (provider.isLoadingShapeCodes)
                        const Center(child: GradientLoader())
                      else if (provider.shapeCodes.isEmpty &&
                          provider.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            'Error loading shape codes: ${provider.errorMessage}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13.sp,
                            ),
                          ),
                        )
                      else
                        CustomSearchableDropdownFormField<String>(
                          key: ValueKey(
                            'shape_code_$index${currentShapeCode ?? ''}',
                          ),
                          name: 'shape_code_$index',
                          labelText: 'Shape Code',
                          prefixIcon: Icons.category,
                          iconSize: 18.sp,
                          textStyle: TextStyle(fontSize: 14.sp),
                          labelStyle: TextStyle(fontSize: 14.sp),
                          fillColor: AppColors.background,
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          options: shapeCodeOptions,
                          optionLabel: (shapeCode) => shapeCode,
                          initialValue: currentShapeCode,
                          onChanged: (shapeCode) {
                            if (shapeCode != null) {
                              final selectedShape = provider.shapeCodes
                                  .firstWhere(
                                    (shape) => shape.shapeCode == shapeCode,
                                    orElse: () =>
                                        Shape(id: null, shapeCode: ''),
                                  );
                              if (selectedShape.id != null) {
                                provider.updateProduct(index, {
                                  'shapeId': selectedShape.id,
                                  'shapeCode': shapeCode,
                                  'dimensionCount': 0,
                                  'dimensions': <String, dynamic>{},
                                });
                                _formKey
                                    .currentState
                                    ?.fields['shape_code_$index']
                                    ?.didChange(shapeCode);
                                provider
                                    .loadDimensionByShape(selectedShape.id!)
                                    .then((_) {
                                      provider.updateProduct(index, {
                                        'dimensionCount':
                                            provider.dimensionCount,
                                      });
                                    });
                              }
                            } else {
                              provider.updateProduct(index, {
                                'shapeId': null,
                                'shapeCode': null,
                                'dimensionCount': 0,
                                'dimensions': <String, dynamic>{},
                              });
                              _formKey.currentState?.fields['shape_code_$index']
                                  ?.didChange(null);
                            }
                          },
                          validators: [
                            FormBuilderValidators.required(
                              errorText: 'Shape Code is required',
                            ),
                          ],
                          allowClear: true,
                        ),
                      SizedBox(height: 12.h),
                      if (currentShapeId != null && provider.isLoadingDimension)
                        const Center(child: GradientLoader())
                      else if (currentShapeId != null &&
                          provider.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            'Error loading dimensions: ${provider.errorMessage}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13.sp,
                            ),
                          ),
                        )
                      else if (currentShapeId != null && dimensionCount > 0)
                        ...List.generate(dimensionCount, (dimIndex) {
                          final dimensionLabel =
                              'Dimension ${String.fromCharCode(65 + dimIndex)}';
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: CustomTextFormField(
                              key: ValueKey('dimension_${index}_$dimIndex'),
                              name: 'dimension_${index}_$dimIndex',
                              labelText: dimensionLabel,
                              hintText: 'Enter $dimensionLabel',
                              prefixIcon: Icons.straighten,
                              textStyle: TextStyle(fontSize: 14.sp),
                              labelStyle: TextStyle(fontSize: 14.sp),
                              fillColor: AppColors.background,
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[400],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              initialValue: dimensions['dimension_$dimIndex']
                                  ?.toString(),
                              keyboardType: TextInputType.number,
                              focusNode: _getFocusNode(
                                'dimension_${index}_$dimIndex',
                              ),

                              onChanged: (value) {
                                if (_debounce?.isActive ?? false)
                                  _debounce!.cancel();

                                _debounce = Timer(
                                  const Duration(milliseconds: 800),
                                  () {
                                    final updatedDimensions =
                                        Map<String, dynamic>.from(dimensions);
                                    updatedDimensions['dimension_$dimIndex'] =
                                        int.tryParse(value ?? '0') ?? 0;

                                    provider.updateProduct(index, {
                                      'dimensions': updatedDimensions,
                                    });

                                    // Keep focus after update
                                    _getFocusNode(
                                      'dimension_${index}_$dimIndex',
                                    ).requestFocus();
                                  },
                                );
                              },

                              validators: [
                                FormBuilderValidators.required(
                                  errorText: '$dimensionLabel is required',
                                ),
                                FormBuilderValidators.numeric(
                                  errorText: 'Please enter a valid number',
                                ),
                              ],
                            ),
                          );
                        }),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        name: 'member_detail_$index',
                        labelText: 'Member Details',
                        hintText: 'Enter member details',
                        prefixIcon: Icons.description,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: product['memberDetail'],
                        focusNode: _getFocusNode('member_detail_$index'),
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(const Duration(seconds: 2), () {
                            provider.updateProduct(index, {
                              'memberDetail': value,
                            });
                          });
                        },
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Member Details is required',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        key: ValueKey('bar_mark_$index'),
                        name: 'bar_mark_$index',
                        labelText: 'Bar Mark',
                        hintText: 'Enter bar mark',
                        prefixIcon: Icons.tag,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: product['barMark'],
                        focusNode: _getFocusNode('bar_mark_$index'),
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(const Duration(seconds: 2), () {
                            provider.updateProduct(index, {'barMark': value});
                          });
                        },
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Bar Mark is required',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ReusableDateFormField(
                        key: ValueKey('delivery_date_$index'),
                        name: 'delivery_date_$index',
                        labelText: 'Delivery Date',
                        hintText: 'Select date',
                        prefixIcon: Icons.calendar_today_outlined,
                        iconSize: 18.sp,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: product['deliveryDate'],
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Delivery Date is required',
                          ),
                        ],
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        format: DateFormat('dd-MM-yyyy'),
                        onChanged: (date) {
                          if (date != null) {
                            provider.updateProduct(index, {
                              'deliveryDate': date,
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        key: ValueKey('member_quantity_$index'),
                        name: 'member_quantity_$index',
                        labelText: 'Member Quantity',
                        hintText: 'Member quantity',
                        prefixIcon: Icons.format_list_numbered,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: product['memberQuantity'].toString(),
                        keyboardType: TextInputType.number,
                        focusNode: _getFocusNode('member_quantity_$index'),
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();

                          _debounce = Timer(
                            const Duration(milliseconds: 1000),
                            () {
                              provider.updateProduct(index, {
                                'memberQuantity':
                                    int.tryParse(value ?? '0') ?? 0,
                              });
                            },
                          );
                        },

                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Member Quantity is required',
                          ),
                          FormBuilderValidators.numeric(
                            errorText: 'Must be a number',
                          ),
                          FormBuilderValidators.min(
                            0,
                            errorText: 'Member Quantity must be positive',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        key: ValueKey('uom_$index'),
                        name: 'uom_$index',
                        labelText: 'UOM',
                        hintText: 'Enter UOM',
                        prefixIcon: Icons.workspaces,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: 'nos',
                        readOnly: true,
                      ),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        key: ValueKey('po_quantity_$index'),
                        name: 'po_quantity_$index',
                        labelText: 'PO Quantity',
                        hintText: 'Enter PO quantity',
                        prefixIcon: Icons.numbers,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: product['quantity'].toString(),
                        keyboardType: TextInputType.number,
                        focusNode: _getFocusNode('po_quantity_$index'),
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();

                          _debounce = Timer(
                            const Duration(milliseconds: 1000),
                            () {
                              provider.updateProduct(index, {
                                'quantity': int.tryParse(value ?? '0') ?? 0,
                              });
                            },
                          );
                        },
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'PO Quantity is required',
                          ),
                          FormBuilderValidators.numeric(
                            errorText: 'Must be a number',
                          ),
                          FormBuilderValidators.min(
                            0,
                            errorText: 'PO Quantity must be positive',
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      if (provider.isLoadingDiameters)
                        const Center(child: GradientLoader())
                      else if (provider.diameters.isEmpty &&
                          provider.errorMessage != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            'Error loading diameters: ${provider.errorMessage}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13.sp,
                            ),
                          ),
                        )
                      else if (provider.diameters.isEmpty &&
                          provider.selectedProject != null)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            'No diameters available for this project',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13.sp,
                            ),
                          ),
                        )
                      else
                        CustomSearchableDropdownFormField<String>(
                          key: ValueKey(
                            'diameter_$index${currentDiameter ?? ''}',
                          ),
                          name: 'diameter_$index',
                          labelText: 'Diameter (mm)',
                          prefixIcon: Icons.circle,
                          iconSize: 18.sp,
                          textStyle: TextStyle(fontSize: 14.sp),
                          labelStyle: TextStyle(fontSize: 14.sp),
                          fillColor: AppColors.background,
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[400],
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          options: diameterOptions,
                          optionLabel: (diameter) => diameter,
                          initialValue: currentDiameter,
                          onChanged: (value) {
                            provider.updateProduct(index, {'diameter': value});
                            _formKey.currentState?.fields['diameter_$index']
                                ?.didChange(value);
                            // Update weight field
                            if (value != null) {
                              final selectedDiameter = provider.diameters
                                  .firstWhere(
                                    (d) => d.diameter.toString() == value,
                                    orElse: () =>
                                        DiameterData(diameter: 0, qty: 0),
                                  );
                              if (selectedDiameter.qty != null) {
                                _formKey.currentState?.fields['weight_$index']
                                    ?.didChange(
                                      selectedDiameter.qty!.toString(),
                                    );
                                provider.updateProduct(index, {
                                  'weight': selectedDiameter.qty!.toInt(),
                                });
                              } else {
                                _formKey.currentState?.fields['weight_$index']
                                    ?.didChange('0');
                                provider.updateProduct(index, {'weight': 0});
                              }
                            } else {
                              _formKey.currentState?.fields['weight_$index']
                                  ?.didChange('0');
                              provider.updateProduct(index, {'weight': 0});
                            }
                          },
                          validators: [
                            FormBuilderValidators.required(
                              errorText: 'Diameter is required',
                            ),
                          ],
                          allowClear: true,
                          enabled: provider.selectedProject != null,
                        ),
                      SizedBox(height: 12.h),
                      CustomTextFormField(
                        key: ValueKey(
                          'weight_$index${product['weight'] ?? ''}',
                        ),
                        name: 'weight_$index',
                        labelText: 'Weight',
                        hintText: 'Enter weight',
                        prefixIcon: Icons.fitness_center,
                        textStyle: TextStyle(fontSize: 14.sp),
                        labelStyle: TextStyle(fontSize: 14.sp),
                        fillColor: AppColors.background,
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[400],
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        initialValue: product['weight'].toString(),
                        keyboardType: TextInputType.number,
                        focusNode: _getFocusNode('weight_$index'),
                        onChanged: (value) => provider.updateProduct(index, {
                          'weight': int.tryParse(value ?? '0') ?? 0,
                        }),
                        validators: [
                          FormBuilderValidators.required(
                            errorText: 'Weight is required',
                          ),
                          FormBuilderValidators.numeric(
                            errorText: 'Must be a number',
                          ),
                          FormBuilderValidators.min(
                            0,
                            errorText: 'Weight must be positive',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (provider.products.length > 1)
                  Positioned(
                    top: 0.h,
                    right: 0.w,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: const Color(0xFFEF4444),
                          size: 20.sp,
                        ),
                        onPressed: () => provider.removeProduct(index),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddProductButton(IronWorkorderProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: provider.addProduct,
            borderRadius: BorderRadius.circular(8.r),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'Add Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
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

  Widget _buildUploadSection(IronWorkorderProvider provider) {
    return FormBuilderField<List<String>>(
      name: 'uploaded_files',
      initialValue: provider.uploadedFiles,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(
          errorText: 'At least one file is required',
        ),
        (value) => value == null || value.isEmpty
            ? 'At least one file is required'
            : null,
      ]),
      builder: (FormFieldState<List<String>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Files',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: field.errorText != null
                      ? Colors.redAccent
                      : const Color(0xFF3B82F6),
                  width: 1.5.w,
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: InkWell(
                onTap: () async {
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true, type: FileType.any);
                    if (result != null && context.mounted) {
                      final newFiles = result.files
                          .map((file) => file.name)
                          .toList();
                      provider.addFiles(
                        newFiles,
                      ); // Updated to handle multiple files
                      field.didChange(provider.uploadedFiles);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      context.showErrorSnackbar(
                        'Failed to pick files. Please try again.',
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: field.errorText != null
                            ? Colors.redAccent
                            : const Color(0xFF3B82F6),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Drop files or click to upload (Image, PDF, XLSX, CSV)',
                          style: TextStyle(
                            color: field.errorText != null
                                ? Colors.redAccent
                                : const Color(0xFF3B82F6),
                            fontSize: 13.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (field.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 12.w),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red, fontSize: 12.sp),
                ),
              ),
            if (provider.uploadedFiles.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: provider.uploadedFiles.map((file) {
                  return Chip(
                    label: Text(
                      file,
                      style: TextStyle(fontSize: 12.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                    deleteIcon: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: const Color(0xFFEF4444),
                    ),
                    onDeleted: () {
                      provider.removeFile(file);
                      field.didChange(provider.uploadedFiles);
                    },
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFixedSubmitButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: Consumer<IronWorkorderProvider>(
            builder: (context, provider, _) => Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _submitForm(context, provider),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_alt, color: Colors.white, size: 18.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'Add Work Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    IronWorkorderProvider provider,
  ) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientLoader(),
                SizedBox(height: 12.h),
                Text(
                  'Creating Work Order...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      try {
        final success = await provider.createWorkOrder(
          workOrderNumber: formData['work_order_number'] as String,
          clientId: provider.selectedClient,
          projectId: provider.selectedProject,
          date: provider.workOrderDate,
          products: provider.products,
          files: provider.uploadedFiles
              .map(
                (file) => FileElement(
                  fileName: file,
                  fileUrl: file, // Update with actual URL if available
                  id: '',
                  uploadedAt: DateTime.now().toIso8601String(),
                ),
              )
              .toList(),
        );

        Navigator.of(context).pop();

        if (success && context.mounted) {
          context.showSuccessSnackbar('Work Order created successfully!');
          context.go(RouteNames.getAllIronWO);
        } else {
          context.showErrorSnackbar(
            'Failed to create work order. Please check your input and try again.',
          );
        }
      } catch (e) {
        Navigator.of(context).pop();
        context.showErrorSnackbar('Error: $e');
      }
    } else {
      context.showWarningSnackbar(
        'Please fill in all required fields correctly.',
      );
    }
  }
}
