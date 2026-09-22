import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomTitle extends StatelessWidget {
  final String title;
  final TextStyle? textStyle;
  final Widget method;

  const CustomTitle({
    super.key,
    required this.title,
    required this.method,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textStyle ??
              AppFontStyle.fontStyleW600(
                fontSize: 13,
                fontColor: AppColors.black,
              ),
        ).paddingOnly(bottom: 10, left: 5),
        method,
      ],
    );
  }
}
