import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k2k/Iron_smith/master_data/projects/model/is_raw_material_model.dart';
import 'package:k2k/Iron_smith/master_data/projects/provider/is_project_provider.dart';
import 'package:k2k/common/list_helper/custom_back_button.dart';
import 'package:k2k/common/list_helper/title.dart';
import 'package:k2k/common/list_helper/shimmer.dart';
import 'package:k2k/common/widgets/appbar/app_bar.dart';
import 'package:k2k/common/widgets/dropdown.dart';
import 'package:k2k/common/widgets/snackbar.dart';
import 'package:k2k/common/widgets/textfield.dart';
import 'package:k2k/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:k2k/app/routes_name.dart';

class IsRawMaterialScreen extends StatefulWidget {
  final String projectId; // Added required projectId
  const IsRawMaterialScreen({super.key, required this.projectId});

  @override
  State<IsRawMaterialScreen> createState() => _IsRawMaterialScreenState();
}

class _IsRawMaterialScreenState extends State<IsRawMaterialScreen> {
  GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final List<String> _diameters = [
    '8mm',
    '10mm',
    '12mm',
    '16mm',
    '20mm',
    '25mm',
    '32mm',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<IsProjectProvider>();

      // If list is empty OR loaded projectId doesn't match current project
      if (provider.rawMaterials.isEmpty ||
          provider.currentProjectId != widget.projectId) {
        print("🔄 Fetching raw materials for projectId: ${widget.projectId}");
        provider.fetchRawMaterials(widget.projectId, refresh: true);
      } else {
        print(
          "ℹ️ Raw materials already loaded for projectId: ${provider.currentProjectId}",
        );
      }
    });
  }

  Future<void> _submitForm() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    // first save & validate form
    if (!formState.saveAndValidate()) return;

    final formData = formState.value;
    final payload = {
      "diameter": int.parse(formData['diameter'].replaceAll('mm', '')),
      "id": widget.projectId,
      "qty": int.parse(formData['quantity']),
    };

    try {
      final provider = context.read<IsProjectProvider>();

      // send to backend
      await provider.addRawMaterial(payload);

      if (!mounted) return;

      // success UI
      context.showSuccessSnackbar('Raw material added successfully');
      FocusScope.of(context).unfocus();

      // refresh list from provider and wait for it
      await provider.fetchRawMaterials(widget.projectId, refresh: true);

      // --- THE KEY PART: recreate the FormBuilder by assigning a NEW GlobalKey
      // this destroys the old FormBuilderState (and its errors) and creates a fresh one
      setState(() {
        _formKey = GlobalKey<FormBuilderState>();
      });

      // optional: small delay sometimes helps UI settle (not required)
      // await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      if (!mounted) return;
      context.showErrorSnackbar('Failed to add raw material: $e');
    }
  }

  void _showDetails(RawMaterial rm) async {
    final provider = Provider.of<IsProjectProvider>(context, listen: false);

    try {
      await provider.fetchConsumption(
        dia: rm.diameter.toString(),
        projectId: rm.projectId ?? "",
        id: rm.id ?? "",
      );

      if (provider.consumption != null &&
          provider.consumption!['workOrderNumber'] != null) {}
    } catch (_) {
      // Keep default value if API fails
    }

    // Show bottom sheet as before, only change is using workOrderNumber
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<IsProjectProvider>(
          builder: (context, projectProvider, child) {
            final selected = provider.selectedConsumptionRecord ?? rm;

            final workOrderNumber = selected.consumptionHistory.isNotEmpty
                ? selected.consumptionHistory.first.workOrderNumber ?? "Work001"
                : "Work001";
            return DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.3,
              maxChildSize: 0.75,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    20 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Header
                        Text(
                          "Diameter: ${rm.diameter} mm",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Subfields card style
                        _buildDetailRow("Work Order Number", workOrderNumber),
                        _buildDetailRow("Used (tons)", rm.quantity.toString()),
                        _buildDetailRow(
                          "Date",
                          rm.createdAt != null
                              ? DateFormat("dd/MM/yyyy").format(rm.createdAt!)
                              : "—",
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Helper widget to make subfields consistent, with blue accent line
  Widget _buildDetailRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              overflow: TextOverflow.ellipsis, // prevents title overflow
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.blue[800],
              ),
              overflow: TextOverflow.ellipsis, // shows "..." if too long
              maxLines: 1, // keeps it in a single line
              softWrap: false, // avoids wrapping, enforces ellipsis
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _editRawMaterial(RawMaterial rm) {
    final TextEditingController qtyController = TextEditingController(
      text: rm.quantity.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Header
                    Text(
                      "Edit Raw Material",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Diameter (disabled)
                    TextFormField(
                      initialValue: "${rm.diameter} mm",
                      decoration: InputDecoration(
                        labelText: "Diameter",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),

                    // Quantity (editable)
                    TextFormField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Quantity (tons)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.scale_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: Colors.blue.withOpacity(0.4),
                        ),
                        onPressed: () async {
                          final provider = Provider.of<IsProjectProvider>(
                            context,
                            listen: false,
                          );
                          final payload = {
                            "diameter": rm.diameter, // keep as number
                            "qty": qtyController.text, // send as string
                          };

                          final success = await provider.updateRawMaterial(
                            rm.id ?? "",
                            payload,
                          );

                          if (success) {
                            Navigator.pop(context);
                            context.showSuccessSnackbar(
                              "Updated successfully!",
                            );
                          } else {
                            context.showErrorSnackbar(
                              "Failed to update. Please try again.",
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Save Changes",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showOptionsBottomSheet(RawMaterial rm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.ironSmithSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.straighten_outlined,
                          color: AppTheme.ironSmithSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${rm.diameter} mm Diameter',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              '${rm.quantity} tons available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: Colors.grey[200],
                ),

                // Action Options
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      _buildActionTile(
                        icon: Icons.visibility_outlined,
                        iconColor: Colors.blue[600]!,
                        backgroundColor: Colors.blue[50]!,
                        title: 'View Details',
                        subtitle:
                            'See complete information and consumption history',
                        onTap: () {
                          Navigator.pop(context);
                          _showDetails(rm);
                        },
                      ),

                      const SizedBox(height: 8),

                      _buildActionTile(
                        icon: Icons.edit_outlined,
                        iconColor: Colors.orange[600]!,
                        backgroundColor: Colors.orange[50]!,
                        title: 'Edit Material',
                        subtitle: 'Modify quantity and other details',
                        onTap: () {
                          Navigator.pop(context);
                          _editRawMaterial(rm);
                        },
                      ),
                    ],
                  ),
                ),

                // Bottom safe area padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.go(RouteNames.isProjects);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBars(
          title: const TitleText(title: 'Raw Materials'),
          leading: CustomBackButton(
            onPressed: () => context.go(RouteNames.isProjects),
          ),
        ),
        body: SafeArea(
          child: Consumer<IsProjectProvider>(
            builder: (context, provider, child) {
              return RefreshIndicator(
                onRefresh: () async {
                  await provider.fetchRawMaterials(
                    widget.projectId,
                    refresh: true,
                  );
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormCard(provider),
                      SizedBox(height: 24.h),
                      _buildExistingMaterials(provider),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(IsProjectProvider provider) {
    // Get existing diameters from rawMaterials to disable them
    final existingDiameters = provider.rawMaterials
        .map((rm) => '${rm.diameter}mm')
        .toSet();
    final availableDiameters = _diameters
        .where((d) => !existingDiameters.contains(d))
        .toList();

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
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Raw Material',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 24.h),
            CustomDropdownFormField<String>(
              name: 'diameter',
              labelText: 'Diameter (mm)',
              hintText: availableDiameters.isEmpty
                  ? 'All diameters already added'
                  : 'Select Diameter',
              prefixIcon: Icons.straighten_outlined,
              options: availableDiameters,
              optionLabel: (value) => value,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Diameter is required',
                ),
              ],
              enabled: availableDiameters
                  .isNotEmpty, // disable dropdown if none left
              fillColor: AppTheme.white,
              borderColor: AppTheme.grey,
              focusedBorderColor: AppTheme.ironSmithSecondary,
              borderRadius: 12.r,
            ),
            SizedBox(height: 24.h),
            CustomTextFormField(
              name: 'quantity',
              labelText: 'Quantity (tons)',
              hintText: '0',
              prefixIcon: Icons.scale_outlined,
              keyboardType: TextInputType.number,
              validators: [
                FormBuilderValidators.required(
                  errorText: 'Quantity is required',
                ),
                FormBuilderValidators.numeric(errorText: 'Must be a number'),
                FormBuilderValidators.min(
                  0,
                  errorText: 'Quantity cannot be negative',
                ),
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
                  color: const Color(0xFF4CAF50), // Green as in image
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save_outlined,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Add',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingMaterials(IsProjectProvider provider) {
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 64.sp,
              color: AppTheme
                  .ironSmithPrimary, // Using a less alarming color for a neutral message
            ),
            SizedBox(height: 16.h),
            Text(
              'No Raw Materials Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'It seems there are no raw materials associated with this project. You can add some by clicking the "Add" button.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      );
    }

    if (provider.isLoading && provider.rawMaterials.isEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => ShimmerCard(),
      );
    }

    if (provider.rawMaterials.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No Raw Materials Found',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add your first raw material using the form above',
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Raw Materials',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.ironSmithSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${provider.rawMaterials.length} items',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.ironSmithSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.rawMaterials.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final rm = provider.rawMaterials[index];
            return _buildMaterialCard(rm);
          },
        ),
      ],
    );
  }

  Widget _buildMaterialCard(RawMaterial rm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _showDetails(rm),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: AppTheme.ironSmithSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.straighten_outlined,
                    color: AppTheme.ironSmithSecondary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${rm.diameter} mm',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Quantity: ${rm.quantity} tons',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.ironSmithSecondary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Added: ${rm.createdAt != null ? DateFormat('dd MMM yyyy').format(rm.createdAt!) : '—'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                // Three dots menu
                Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.r),
                      onTap: () => _showOptionsBottomSheet(rm),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                        size: 20.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
