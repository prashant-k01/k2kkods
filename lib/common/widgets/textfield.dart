import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CustomTextFormField extends StatelessWidget {
  final String name;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? initialValue;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final Color? prefixIconColor;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final List<String? Function(String?)>? validators;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? Function(String?)? customValidator;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;
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

  const CustomTextFormField({
    super.key,
    required this.name,
    this.labelText,
    this.hintText,
    this.helperText,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconColor,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.validators,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.focusNode,
    this.controller,
    this.customValidator,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
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
          child: FormBuilderTextField(
            name: name,
            controller: controller,
            focusNode: focusNode,
            initialValue: initialValue,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            enabled: enabled,
            readOnly: readOnly,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            autovalidateMode:
                autovalidateMode ?? AutovalidateMode.onUserInteraction,
            validator:
                customValidator ??
                FormBuilderValidators.compose(validators ?? []),
            onChanged: onChanged,
            onSaved: onSaved,
            onTap: onTap,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface,
                ),
            decoration: InputDecoration(
              hintText: hintText,
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
                      child: Icon(
                        prefixIcon,
                        size: 20.r,
                        color:
                            prefixIconColor ?? primaryColor, // <-- now dynamic
                      ),
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
