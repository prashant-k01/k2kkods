import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/gradient_loader.dart';
import 'package:k2k/common/widgets/searchable_dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/konkrete_klinkers/stock_management/model/stock.dart';
import 'package:k2k/konkrete_klinkers/stock_management/provider/stock_provider.dart';
import 'package:k2k/utils/theme.dart';
import 'package:k2k/app/routes_name.dart';
import 'package:provider/provider.dart';

class StockManagementFormScreen extends StatefulWidget {
  const StockManagementFormScreen({super.key});

  @override
  State<StockManagementFormScreen> createState() =>
      _StockManagementFormScreenState();
}

class _StockManagementFormScreenState extends State<StockManagementFormScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> _stockTransferFormKey =
      GlobalKey<FormBuilderState>();
  final GlobalKey<FormBuilderState> _bufferTransferFormKey =
      GlobalKey<FormBuilderState>();
  late TabController _tabController;
  final String prId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      stockProvider.loadAllProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          context.go(RouteNames.stockmanagement);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: TitleText(title: 'Create Stock Transfer'),
          leading: CustomBackButton(
            onPressed: () {
              context.go(RouteNames.stockmanagement);
            },
          ),
        ),

        body: SafeArea(
          child: Consumer<StockProvider>(
            builder: (context, stockProvider, child) {
              if (stockProvider.isLoading) {
                return const Center(child: GradientLoader());
              }
              if (stockProvider.error != null) {
                return Center(child: Text('Error: ${stockProvider.error}'));
              }

              return Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStockTransferForm(context, stockProvider),
                        _buildBufferStockForm(context, stockProvider),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedBuilder(
        // ✅ Listen to the animation so it updates immediately on tap/drag
        animation: _tabController.animation!,
        builder: (context, _) {
          final selected =
              (_tabController.animation?.value ?? _tabController.index).round();

          return TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              // ✅ Primary when "Stock Transfer" (index 0), Secondary when "Buffer Transfer" (index 1)
              gradient: selected == 0
                  ? AppTheme.primaryGradient
                  : AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.w,
            ),
            dividerColor: Colors.transparent,
            labelColor: Colors.white, // selected text & icon
            unselectedLabelColor: Colors.grey, // unselected text & icon
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              _buildTab(icon: Icons.trending_up, label: 'Stock Transfer'),
              _buildTab(icon: Icons.autorenew, label: 'Buffer Transfer'),
            ],
          );
        },
      ),
    );
  }

  Tab _buildTab({required IconData icon, required String label}) {
    return Tab(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h), // taller tabs
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 6.w),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildStockTransferForm(
    BuildContext context,
    StockProvider stockProvider,
  ) {
    return _buildFormWrapper(
      context: context,
      products: stockProvider.allProducts,
      workOrders: stockProvider.workOrders,
      isStockTransfer: true,
      title: 'Stock Transfer Details',
      subtitle: 'Configure the transfer details between work orders',
      icon: Icons.trending_up,
      formKey: _stockTransferFormKey,
      stockProvider: stockProvider,
    );
  }

  Widget _buildBufferStockForm(
    BuildContext context,
    StockProvider stockProvider,
  ) {
    return _buildFormWrapper(
      context: context,
      products: stockProvider.allProducts,
      workOrders: stockProvider.workOrders,
      isStockTransfer: false,
      title: 'Buffer Transfer Details',
      subtitle: 'Configure buffer stock details',
      icon: Icons.autorenew,
      formKey: _bufferTransferFormKey,
      stockProvider: stockProvider,
    );
  }

  Widget _buildFormWrapper({
    required BuildContext context,
    required List<Datum> products,
    required List<Data> workOrders,
    required bool isStockTransfer,
    required String title,
    required String subtitle,
    required IconData icon,
    required GlobalKey<FormBuilderState> formKey,
    required StockProvider stockProvider,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderContainer(
            isStockTransfer: isStockTransfer,
            title: title,
            subtitle: subtitle,
            icon: icon,
          ),
          _buildForm(
            context: context,
            products: products,
            workOrders: workOrders,
            isStockTransfer: isStockTransfer,
            formKey: formKey,
            stockProvider: stockProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContainer({
    required bool isStockTransfer,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: isStockTransfer
            ? AppTheme.primaryGradient
            : LinearGradient(
                colors: [Colors.purple[700]!, Colors.purple[400]!],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildForm({
    required BuildContext context,
    required StockProvider stockProvider,
    required List<Datum> products,
    required List<Data> workOrders,
    required bool isStockTransfer,
    required GlobalKey<FormBuilderState> formKey,
  }) {
    final validProducts = products
        .where((product) => product.id!.isNotEmpty)
        .toList();
    print(
      'All Products: ${products.map((p) => {'id': p.id, 'materialCode': p.materialCode, 'description': p.description}).toList()}',
    ); // Debug log
    print(
      'Valid Products: ${validProducts.map((p) => {'id': p.id, 'materialCode': p.materialCode, 'description': p.description}).toList()}',
    ); // Debug log
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: FormBuilder(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchableDropdownFormField(
              name: 'product',
              labelText: 'Product',
              hintText: 'Select product',
              prefixIcon: Icons.inventory,
              options: products
                  .map((product) => product.materialCode ?? 'Unknown')
                  .toList(),
              enabled: true,
              fillColor: Colors.white,
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              errorBorderColor: AppTheme.errorColor,
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a product',
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  final selectedProduct = validProducts.firstWhere(
                    (product) => product.materialCode == value,
                    orElse: () => Datum(id: '', materialCode: ''),
                  );
                  print(
                    'Selected Product: ID=${selectedProduct.id}, MaterialCode=$value',
                  ); // Debug log
                  if (selectedProduct.id != null &&
                      selectedProduct.id!.isNotEmpty) {
                    print(
                      'Calling fetchWorkOrdersByProductId with prId=${selectedProduct.id}, isBuffer=${isStockTransfer ? false : true}',
                    ); // Debug log
                    stockProvider.fetchWorkOrdersByProductId(
                      selectedProduct.id!,
                      isStockTransfer ? false : true,
                    );
                  }
                }
              },
            ),
            SizedBox(height: 24.h),
            CustomSearchableDropdownFormField(
              name: 'from_work_order',
              labelText: 'From Work Order',
              hintText: 'Select from work order',
              prefixIcon: Icons.work,
              options: workOrders
                  .map((workOrder) => workOrder.workOrderNumber)
                  .toList(),
              enabled:
                  !stockProvider.isWOLoading &&
                  stockProvider.errorMessage == null,
              fillColor: Colors.white,
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              errorBorderColor: AppTheme.errorColor,
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a source work order',
                ),
              ],
            ),
            SizedBox(height: 24.h),
            CustomSearchableDropdownFormField(
              name: 'to_work_order',
              labelText: 'To Work Order',
              hintText: 'Select to work order',
              prefixIcon: Icons.work,
              options: workOrders
                  .map((workOrder) => workOrder.workOrderNumber)
                  .toList(),
              enabled:
                  !stockProvider.isWOLoading &&
                  stockProvider.errorMessage == null,
              fillColor: Colors.white,
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              errorBorderColor: AppTheme.errorColor,
              borderRadius: 12.r,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please select a destination work order',
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  final selectedWorkOrder = workOrders.firstWhere(
                    (workOrder) => workOrder.workOrderNumber == value,
                    orElse: () => Data(workOrderId: '', workOrderNumber: ''),
                  );
                  if (selectedWorkOrder.workOrderId.isNotEmpty) {
                    final selectedProduct =
                        formKey.currentState?.fields['product']?.value;
                    final product = products.firstWhere(
                      (product) => product.materialCode == selectedProduct,
                      orElse: () => Datum(id: '', materialCode: ''),
                    );
                    if (product.id != null && product.id!.isNotEmpty) {
                      stockProvider.fetchAchievedQuantity(
                        workOrderId: selectedWorkOrder.workOrderId,

                        productId: product.id!,
                        isBuffer: isStockTransfer ? false : true,
                      );
                    }
                  }
                }
              },
            ),
            SizedBox(height: 24.h),
            CustomTextFormField(
              name: 'quantity',
              labelText: 'Quantity to Transfer',
              hintText: 'Enter quantity',
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Please enter quantity',
                ),
                FormBuilderValidators.numeric(
                  errorText: 'Please enter a valid number',
                ),
                FormBuilderValidators.min(
                  1,
                  errorText: 'Quantity must be greater than 0',
                ),
                FormBuilderValidators.max(
                  stockProvider.achievedQuantity?.totalAchievedQuantity
                          .toDouble() ??
                      double.infinity,
                  errorText: 'Quantity exceeds available stock',
                ),
              ],
              fillColor: Colors.white,
              borderColor: Colors.grey.shade300,
              focusedBorderColor: AppTheme.primaryBlue,
              errorBorderColor: AppTheme.errorColor,
              borderRadius: 12.r,
            ),
            SizedBox(height: 24.h),
            if (stockProvider.isWOLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(child: GradientLoader()),
              ),
            if (stockProvider.errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(
                  child: Text(
                    'Error: ${stockProvider.errorMessage}',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ),
            if (stockProvider.isQuantityLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(child: GradientLoader()),
              ),
            if (stockProvider.quantityError != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Center(
                  child: Text(
                    'Error: ${stockProvider.quantityError}',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              ),
            if (stockProvider.achievedQuantity != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                margin: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5), // Light green background
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFF6EE7B7),
                  ), // Optional subtle border
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF34D399,
                        ), // Green background for icon
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.all_inbox_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Quantity',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669), // Dark green text
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${stockProvider.achievedQuantity?.totalAchievedQuantity ?? 0}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            SizedBox(height: 40.h),
            _buildSubmitButton(
              isStockTransfer,
              stockProvider,
              validProducts,
              workOrders,
              formKey,
            ),
            SizedBox(height: 24.h),
            _buildNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    bool isStockTransfer,
    StockProvider stockProvider,
    List<Datum> validProducts,
    List<Data> workOrders,
    GlobalKey<FormBuilderState> formKey,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: isStockTransfer
              ? AppTheme.primaryGradient
              : AppTheme.secondaryGradient,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ElevatedButton(
          onPressed: stockProvider.isTransferLoading
              ? null
              : () async {
                  final currentFormKey = isStockTransfer
                      ? _stockTransferFormKey
                      : _bufferTransferFormKey;

                  if (currentFormKey.currentState?.saveAndValidate() ?? false) {
                    final formData = currentFormKey.currentState!.value;
                    final productMaterialCode = formData['product'];
                    final fromWorkOrderNumber = formData['from_work_order'];
                    final toWorkOrderNumber = formData['to_work_order'];
                    final quantity = formData['quantity'];

                    // Get product ID
                    final selectedProduct = validProducts.firstWhere(
                      (product) => product.materialCode == productMaterialCode,
                      orElse: () =>
                          Datum(id: '', materialCode: '', description: ''),
                    );

                    // Get work order IDs
                    final fromWorkOrder = workOrders.firstWhere(
                      (workOrder) =>
                          workOrder.workOrderNumber == fromWorkOrderNumber,
                      orElse: () => Data(workOrderId: '', workOrderNumber: ''),
                    );
                    final toWorkOrder = workOrders.firstWhere(
                      (workOrder) =>
                          workOrder.workOrderNumber == toWorkOrderNumber,
                      orElse: () => Data(workOrderId: '', workOrderNumber: ''),
                    );

                    // Validate form data
                    if (selectedProduct.id!.isEmpty ||
                        fromWorkOrder.workOrderId.isEmpty ||
                        toWorkOrder.workOrderId.isEmpty ||
                        quantity == null) {
                      context.showErrorSnackbar(
                        'Invalid form data. Please check your selections.',
                      );
                      return;
                    }

                    try {
                      if (isStockTransfer) {
                        await stockProvider.createBuffer(
                          fromWorkOrderId: fromWorkOrder.workOrderId,
                          toWorkOrderId: toWorkOrder.workOrderId,
                          productId: selectedProduct.id!,
                          quantityTransferred: int.parse(quantity.toString()),
                          isBufferTransfer: false,
                        );
                        context.showSuccessSnackbar(
                          'Stock Transfer Successful',
                        );
                      } else {
                        await stockProvider.createBuffer(
                          fromWorkOrderId: fromWorkOrder.workOrderId,
                          toWorkOrderId: toWorkOrder.workOrderId,
                          productId: selectedProduct.id!,
                          quantityTransferred: int.parse(quantity.toString()),
                          isBufferTransfer: true,
                        );
                        context.showSuccessSnackbar(
                          'Buffer Transfer Successful',
                        );
                      }
                      stockProvider.reset();
                      context.go(RouteNames.stockmanagement);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to ${isStockTransfer ? 'transfer stock' : 'create buffer'}: ${stockProvider.transferError}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please correct the errors in the form'),
                        duration: Duration(seconds: 2),
                      ),
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
          child: stockProvider.isTransferLoading
              ? const GradientLoader()
              : Text(
                  isStockTransfer ? 'Transfer Stock' : 'Transfer Buffer',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
    // }) {
    //     return SizedBox(
    //       width: double.infinity,
    //       child: Container(
    //         decoration: BoxDecoration(
    //           gradient: isStockTransfer
    //               ? AppTheme.primaryGradient
    //               : LinearGradient(
    //                   colors: [Colors.purple[700]!, Colors.purple[400]!],
    //                   begin: Alignment.topRight,
    //                   end: Alignment.bottomLeft,
    //                 ),
    //           borderRadius: BorderRadius.circular(12.r),
    //         ),
    //         child: ElevatedButton(
    //           onPressed: () {
    //             final currentFormKey = isStockTransfer
    //                 ? _stockTransferFormKey
    //                 : _bufferTransferFormKey;

    //             if (currentFormKey.currentState?.saveAndValidate() ?? false) {
    //               final formData = currentFormKey.currentState!.value;
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text(
    //                     isStockTransfer
    //                         ? 'Stock Transfer Submitted: $formData'
    //                         : 'Buffer Stock Submitted: $formData',
    //                   ),
    //                   duration: const Duration(seconds: 2),
    //                 ),
    //               );
    //               context.go(RouteNames.stockmanagement);
    //             } else {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 const SnackBar(
    //                   content: Text('Please correct the errors in the form'),
    //                   duration: Duration(seconds: 2),
    //                 ),
    //               );
    //             }
    //           },
    //           style: ElevatedButton.styleFrom(
    //             backgroundColor: Colors.transparent,
    //             shadowColor: Colors.transparent,
    //             foregroundColor: Colors.white,
    //             padding: EdgeInsets.symmetric(vertical: 16.h),
    //             shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(12.r),
    //             ),
    //           ),
    //           child: Text(
    //             isStockTransfer ? 'Transfer Stock' : 'Transfer Buffer',
    //             style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    //           ),
    //         ),
    //       ),
    //     );
  }

  Widget _buildNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'Note\n\nAll information is kept confidential and used only for stock management purposes',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }
}
