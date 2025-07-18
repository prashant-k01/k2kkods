import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String name;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final T? initialValue;
  final List<DropdownMenuItem<T>>? items;
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

  const CustomDropdownFormField({
    super.key,
    required this.name,
    this.labelText,
    this.hintText,
    this.helperText,
    this.initialValue,
    this.items,
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
         items != null || options != null,
         'Either items or options must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final errorColor = theme.colorScheme.error;

    // Build items from options if provided
    final dropdownItems =
        items ??
        options
            ?.map(
              (option) => DropdownMenuItem<T>(
                value: option,
                child: Text(
                  optionLabel?.call(option) ?? option.toString(),
                  style:
                      textStyle ??
                      TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface,
                      ),
                ),
              ),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              labelText!,
              style:
                  labelStyle ??
                  TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
            ),
          ),

        Container(
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
          child: FormBuilderDropdown<T>(
            name: name,
            initialValue: initialValue,
            items: dropdownItems ?? [],
            enabled: enabled,
            autovalidateMode:
                autovalidateMode ?? AutovalidateMode.onUserInteraction,
            validator:
                customValidator ??
                FormBuilderValidators.compose(validators ?? []),
            onChanged: onChanged,
            onSaved: onSaved,
            menuMaxHeight: menuMaxHeight,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
            decoration: InputDecoration(
              hintText: hintText ?? 'Select option',
              helperText: helperText,
              hintStyle:
                  hintStyle ??
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
              suffixIcon: suffixIcon,
              filled: filled,
              fillColor: fillColor ?? theme.colorScheme.surface,
              contentPadding:
                  contentPadding ??
                  EdgeInsets.symmetric(
                    horizontal: prefixIcon != null ? 8.w : 16.w,
                    vertical: 16.h,
                  ),
              isDense: dense,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                borderSide: BorderSide(
                  color:
                      borderColor ?? theme.colorScheme.outline.withOpacity(0.3),
                  width: borderWidth ?? 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                borderSide: BorderSide(
                  color:
                      borderColor ?? theme.colorScheme.outline.withOpacity(0.3),
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
            ),
          ),
        ),
      ],
    );
  }
}
