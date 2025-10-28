import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CustomMultiSelectFormField<T> extends StatelessWidget {
  final String name;
  final String? labelText;
  final String? helperText;
  final List<T> options;
  final String Function(T)? optionLabel;
  final List<T>? initialValue;
  final List<String? Function(List<T>?)>? validators;
  final void Function(List<T>?)? onChanged;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double? borderRadius;
  final double? borderWidth;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;

  const CustomMultiSelectFormField({
    super.key,
    required this.name,
    required this.options,
    this.labelText,
    this.helperText,
    this.optionLabel,
    this.initialValue,
    this.validators,
    this.onChanged,
    this.enabled = true,
    this.autovalidateMode,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.borderWidth,
    this.textStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final errorColor = theme.colorScheme.error;

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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: fillColor ?? const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
            border: Border.all(
              color: borderColor ?? Colors.grey.shade300,
              width: borderWidth ?? 1.5,
            ),
          ),
          child: FormBuilderFilterChips<T>(
            name: name,
            initialValue: initialValue ?? [],
            enabled: enabled,
            autovalidateMode:
                autovalidateMode ?? AutovalidateMode.onUserInteraction,
            validator: FormBuilderValidators.compose(validators ?? []),
            onChanged: onChanged,
            spacing: 8.w,
            runSpacing: 8.h,
            selectedColor: focusedBorderColor ?? primaryColor.withOpacity(0.15),
            checkmarkColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              helperText: helperText,
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
            options: options
                .map(
                  (option) => FormBuilderChipOption<T>(
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
                .toList(),
          ),
        ),
      ],
    );
  }
}
