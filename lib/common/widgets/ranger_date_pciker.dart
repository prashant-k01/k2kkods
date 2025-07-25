import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CustomRangeDatePicker extends StatelessWidget {
  final String name;
  final String labelText;
  final String hintText;

  const CustomRangeDatePicker({
    super.key,
    required this.name,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderDateRangePicker(
      name: name,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      format: DateFormat('yyyy-MM-dd'),
      style: TextStyle(
        color: Colors.black,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(
          Icons.date_range,
          color: Colors.grey.shade600,
          size: 24.sp,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF3B82F6)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        labelStyle: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xFF334155),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
      ),
    );
  }
}