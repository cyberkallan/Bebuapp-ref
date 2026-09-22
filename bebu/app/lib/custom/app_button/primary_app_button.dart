// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_color.dart';

class PrimaryAppButton extends StatelessWidget {
  double? height;
  double? width;
  double? borderRadius;
  TextStyle? textStyle;
  List<Color>? gradientColor;
  double? iconPadding;
  Color? color;
  Color? borderColor;
  String? text;
  Widget? widget;
  Widget? child;
  TextOverflow? overflow;
  Function()? onTap;

  PrimaryAppButton({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.textStyle,
    this.gradientColor,
    this.iconPadding,
    this.color,
    this.borderColor,
    this.text,
    this.widget,
    this.child,
    this.onTap,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          gradient: LinearGradient(
            colors: gradientColor ?? [color ?? AppColors.appColor, color ?? AppColors.appColor],
          ),
          border: Border.all(
            color: borderColor ?? AppColors.transparent,
            width: 0.8,
          ),
        ),
        child: child ??
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    text ?? "",
                    overflow: overflow,
                    style: textStyle,
                  ),
                ),
                if (widget != null) ...[
                  SizedBox(width: 8),
                  widget ?? const SizedBox.shrink(),
                ],
              ],
            ),
      ),
    );
  }
}
