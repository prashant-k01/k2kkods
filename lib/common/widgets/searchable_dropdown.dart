import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CustomSearchableDropdownFormField<T> extends StatelessWidget {
  final String name;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final T? initialValue;
  final List<T>? options;
  final String Function(T)? optionLabel;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final List<String? Function(T?)>? validators;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final bool enabled;
  final String? Function(T?)? customValidator;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final double? borderWidth;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final bool filled;
  final bool dense;
  final double? menuMaxHeight;
  final Widget? disabledHint;
  final bool allowClear;
  final Widget? clearIcon;

  const CustomSearchableDropdownFormField({
    super.key,
    required this.name,
    this.labelText,
    this.hintText,
    this.helperText,
    this.initialValue,
    this.options,
    this.optionLabel,
    this.prefixIcon,
    this.suffixIcon,
    this.validators,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.customValidator,
    this.autovalidateMode,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.borderWidth,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.filled = true,
    this.dense = false,
    this.menuMaxHeight,
    this.disabledHint,
    this.allowClear = false,
    this.clearIcon,
  }) : assert(
          options != null,
          'Options must be provided for searchable dropdown',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final errorColor = theme.colorScheme.error;

    return FormBuilderField<T>(
      name: name,
      initialValue: initialValue,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      validator: customValidator ?? FormBuilderValidators.compose(validators ?? []),
      onSaved: onSaved,
      builder: (FormFieldState<T> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (labelText != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  labelText!,
                  style: labelStyle ??
                      TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                ),
              ),
            GestureDetector(
              onTap: enabled
                  ? () => _showSearchableDropdown(context, field)
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: hintText ?? 'Select option',
                    helperText: helperText,
                    hintStyle: hintStyle ??
                        TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                    prefixIcon: prefixIcon != null
                        ? Container(
                            margin: EdgeInsets.only(left: 12.w, right: 8.w),
                            child: Icon(prefixIcon, size: 20.r, color: primaryColor),
                          )
                        : null,
                    suffixIcon: allowClear && field.value != null
                        ? clearIcon ??
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                field.didChange(null);
                                if (onChanged != null) onChanged!(null);
                              },
                            )
                        : suffixIcon ?? const Icon(Icons.arrow_drop_down),
                    filled: filled,
                    fillColor: fillColor ?? theme.colorScheme.surface,
                    contentPadding: contentPadding ??
                        EdgeInsets.symmetric(
                          horizontal: prefixIcon != null ? 8.w : 16.w,
                          vertical: 16.h,
                        ),
                    isDense: dense,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                      borderSide: BorderSide(
                        color: borderColor ?? theme.colorScheme.outline.withOpacity(0.3),
                        width: borderWidth ?? 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                      borderSide: BorderSide(
                        color: borderColor ?? theme.colorScheme.outline.withOpacity(0.3),
                        width: borderWidth ?? 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                      borderSide: BorderSide(
                        color: focusedBorderColor ?? primaryColor,
                        width: (borderWidth ?? 1.5) + 1,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                      borderSide: BorderSide(
                        color: errorBorderColor ?? errorColor,
                        width: borderWidth ?? 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                      borderSide: BorderSide(
                        color: errorBorderColor ?? errorColor,
                        width: (borderWidth ?? 1.5) + 1,
                      ),
                    ),
                    errorStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: errorColor,
                    ),
                    helperStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    errorText: field.errorText,
                  ),
                  child: Text(
                    field.value != null
                        ? optionLabel?.call(field.value!) ?? field.value.toString()
                        : hintText ?? 'Select option',
                    style: textStyle ??
                        TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: field.value != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSearchableDropdown(BuildContext context, FormFieldState<T> field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SearchableDropdownDialog<T>(
          options: options!,
          optionLabel: optionLabel,
          onChanged: (T? value) {
            field.didChange(value);
            if (onChanged != null) onChanged!(value);
            Navigator.of(context).pop();
          },
          textStyle: textStyle,
          menuMaxHeight: menuMaxHeight,
        );
      },
    );
  }
}

class _SearchableDropdownDialog<T> extends StatefulWidget {
  final List<T> options;
  final String Function(T)? optionLabel;
  final void Function(T?)? onChanged;
  final TextStyle? textStyle;
  final double? menuMaxHeight;

  const _SearchableDropdownDialog({
    required this.options,
    this.optionLabel,
    this.onChanged,
    this.textStyle,
    this.menuMaxHeight,
  });

  @override
  _SearchableDropdownDialogState<T> createState() => _SearchableDropdownDialogState<T>();
}

class _SearchableDropdownDialogState<T> extends State<_SearchableDropdownDialog<T>> {
  late List<T> filteredOptions;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
    _searchController.addListener(_filterOptions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterOptions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredOptions = widget.options.where((option) {
        final label = widget.optionLabel?.call(option) ?? option.toString();
        return label.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: widget.menuMaxHeight ?? 300.h,
          maxWidth: 400.w,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 20.r),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                ),
              ),
            ),
            Expanded(
              child: filteredOptions.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredOptions.length,
                      itemBuilder: (context, index) {
                        final option = filteredOptions[index];
                        return ListTile(
                          title: Text(
                            widget.optionLabel?.call(option) ?? option.toString(),
                            style: widget.textStyle ??
                                TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurface,
                                ),
                          ),
                          onTap: () {
                            widget.onChanged?.call(option);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}