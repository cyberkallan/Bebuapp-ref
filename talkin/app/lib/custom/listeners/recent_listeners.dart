import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class RecentListeners extends StatelessWidget {
  final String name;
  final String age;
  final String image;
  final String status;
  final String language;
  final String callCount;
  final Function() onTap;
  final Function()? onCloseTap;
  final bool closIcon;

  const RecentListeners(
      {super.key,
      required this.name,
      required this.age,
      required this.image,
      required this.status,
      required this.language,
      required this.callCount,
      required this.onTap,
      this.onCloseTap,
      this.closIcon = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: AppColors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  height: Get.height * 0.07,
                  width: Get.height * 0.07,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                  child: CustomProfileImage(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ).paddingOnly(right: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$name ,$age",
                        style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.appDarkColor),
                      ).paddingOnly(bottom: 6),
                      Row(
                        children: [
                          Image.asset(
                            AppAsset.speakingBoy,
                            height: 15,
                          ).paddingOnly(right: 5),
                          Text(
                            language,
                            // overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.appTextColor),
                          ).paddingOnly(right: 16),
                          Image.asset(
                            AppAsset.callIcon,
                            height: 15,
                          ).paddingOnly(right: 5),
                          Text(
                            callCount.toString(),
                            style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.appTextColor),
                          ).paddingOnly(right: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                closIcon == true
                    ? GestureDetector(
                        onTap: onCloseTap,
                        child: Image.asset(
                          AppAsset.closeIcon,
                          height: 20,
                          width: 20,
                        ).paddingOnly(right: 4),
                      )
                    : SizedBox.shrink(),
              ],
            ).paddingOnly(left: 16, right: 16),
          ),
        ),
      ],
    );
  }
}
