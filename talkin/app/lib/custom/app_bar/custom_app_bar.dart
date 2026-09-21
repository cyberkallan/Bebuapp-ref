// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomAppBar extends StatelessWidget {
  String? title;
  List<Widget>? action;
  List<Color>? gradientColor;
  Color? textColor;
  Color? appBarColor;
  Color? iconColor;
  final bool showLeadingIcon;
  final bool showBoxShadow;
  Function()? onTap;
  Widget? child;

  CustomAppBar({
    super.key,
    this.title,
    this.action,
    this.appBarColor,
    required this.showLeadingIcon,
    this.gradientColor,
    this.textColor,
    this.iconColor,
    this.onTap,
    this.child,
    this.showBoxShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0,
      toolbarHeight: 120,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          boxShadow: showBoxShadow
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    spreadRadius: 0.08,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 2.0,
                  ),
                ]
              : null,
          color: appBarColor ?? AppColors.white,
        ),
      ),
      leading: showLeadingIcon == true
          ? GestureDetector(
              onTap: onTap ??
                  () {
                    Get.back();
                  },
              child: Container(
                color: AppColors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    AppAsset.backArrowIcon,
                    color: iconColor ?? AppColors.black,
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
      actions: action,
      title: child ??
          Text(
            title ?? '',
            style: AppFontStyle.fontStyleW600(
              fontSize: 20,
              fontColor: textColor ?? AppColors.black,
            ),
          ),
    );
  }
}
