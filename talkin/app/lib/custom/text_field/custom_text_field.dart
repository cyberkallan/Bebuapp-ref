// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomTextField extends StatelessWidget {
  final bool filled;
  bool? obscureText;
  String? hintText;
  Color? fillColor;
  Color? borderColor;
  Color? hintTextColor;
  Color? cursorColor;
  Color? fontColor;
  double? hintTextSize;
  double? fontSize;
  int? maxLines;
  bool? readOnly;
  Widget? prefixIcon;
  Widget? suffixIcon;
  TextEditingController? controller;
  TextInputAction? textInputAction;
  TextInputType? textInputType;
  String? Function(String?)? validator;
  List<TextInputFormatter>? inputFormatters;
  String? Function(String?)? onChanged;
  VoidCallback? onTap;

  CustomTextField({
    super.key,
    required this.filled,
    this.obscureText,
    this.hintText,
    this.fillColor,
    this.borderColor,
    this.fontColor,
    this.cursorColor,
    this.maxLines,
    this.readOnly,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.hintTextColor,
    this.hintTextSize,
    this.fontSize,
    this.textInputAction,
    this.textInputType,
    this.validator,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      cursorColor: cursorColor,
      readOnly: readOnly ?? false,
      obscureText: obscureText ?? false,
      inputFormatters: inputFormatters,
      style: AppFontStyle.fontStyleW600(
        fontSize: fontSize ?? 13,
        fontColor: fontColor ?? AppColors.black,
      ),
      textInputAction: textInputAction,
      keyboardType: textInputType,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.transparent),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? AppColors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor ?? AppColors.black),
        ),
        fillColor: AppColors.white,
        filled: filled,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: AppFontStyle.fontStyleW500(
          fontSize: hintTextSize ?? 13,
          fontColor: hintTextColor ?? AppColors.black.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
