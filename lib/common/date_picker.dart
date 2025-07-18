import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

class ReusableDateFormField extends StatelessWidget {
  final String name;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final DateTime? initialValue;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final InputType inputType;
  final DateFormat? format;
  final List<String? Function(DateTime?)>? validators;
  final void Function(DateTime?)? onChanged;
  final void Function(DateTime?)? onSaved;
  final bool enabled;
  final bool readOnly;
  final String? Function(DateTime?)? customValidator;
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
  final Locale? locale;

  const ReusableDateFormField({
    super.key,
    required this.name,
    this.labelText,
    this.hintText,
    this.helperText,
    this.initialValue,
    this.firstDate,
    this.lastDate,
    this.prefixIcon,
    this.suffixIcon,
    this.inputType = InputType.date,
    this.format,
    this.validators,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.readOnly = false,
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
    this.locale,
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
          child: FormBuilderDateTimePicker(
            name: name,
            initialValue: initialValue,
            firstDate: firstDate ?? DateTime(1900),
            lastDate: lastDate ?? DateTime(2100),
            inputType: inputType,
            format: format ?? DateFormat('dd/MM/yyyy'),
            enabled: enabled,
            locale: locale,
            autovalidateMode:
                autovalidateMode ?? AutovalidateMode.onUserInteraction,
            validator:
                customValidator ??
                FormBuilderValidators.compose(validators ?? []),
            onChanged: onChanged,
            onSaved: onSaved,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
            decoration: InputDecoration(
              hintText: hintText ?? 'Select date',
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
                  : Container(
                      margin: EdgeInsets.only(left: 12.w, right: 8.w),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 20.r,
                        color: primaryColor,
                      ),
                    ),
              suffixIcon: suffixIcon,
              filled: filled,
              fillColor: fillColor ?? theme.colorScheme.surface,
              contentPadding:
                  contentPadding ??
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
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
