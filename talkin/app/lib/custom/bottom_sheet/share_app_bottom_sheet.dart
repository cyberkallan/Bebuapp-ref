import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class ShareAppBottomSheet extends StatelessWidget {
  const ShareAppBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallCutController>(builder: (controller) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Spacer(),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Image.asset(
                    AppAsset.closeFillIcon,
                    height: 26,
                  ),
                )
              ],
            ),
            DottedBorder(
              borderType: BorderType.Circle,
              color: Colors.black,
              dashPattern: [3, 2],
              strokeWidth: 1,
              child: Container(
                clipBehavior: Clip.hardEdge,
                height: Get.height * 0.1,
                width: Get.height * 0.1,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: CustomProfileImage(image: controller.receiverImage ?? ''),
              ),
            ),
            Text(
              controller.receiverName ?? '',
              style: AppFontStyle.fontStyleW700(
                fontSize: 17,
                fontColor: AppColors.black,
              ),
            ).paddingOnly(bottom: 18, top: 14),
            // Image.asset(
            //   AppAsset.ratingImage,
            //   width: 264,
            //   height: 32,
            // ).paddingOnly(bottom: 18),
            StarRating(
              onRatingChanged: (rating) {
                log('Selected rating: $rating');
              },
            ).paddingOnly(bottom: 19),
            Text(
              textAlign: TextAlign.center,
              EnumLocale.txtRatingDescription.name.tr,
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.darkGrey.withValues(alpha: 0.8),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.darkGrey.withValues(alpha: 0.3),
                  ),
                  color: AppColors.white),
              child: TextFormField(
                controller: controller.reviewCnt,
                style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.black),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your review here...",
                  hintStyle: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.darkGrey.withValues(alpha: 0.3)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ).paddingOnly(top: 16, bottom: 22),
            PrimaryAppButton(
              onTap: () {
                controller.submitListenerCallRate();
                // Get.bottomSheet(
                //   ShareAppBottomSheet(),
                //   isScrollControlled: true,
                //   backgroundColor: Colors.transparent,
                // );
              },
              height: 47,
              // borderRadius: 30,
              text: EnumLocale.txtSubmit.name.tr,
              textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
            ).paddingOnly(bottom: 10),
          ],
        ),
      );
    });
  }
}

class StarRating extends StatelessWidget {
  final int starCount;
  final double size;
  final void Function(int) onRatingChanged;

  const StarRating({
    super.key,
    this.starCount = 5,
    this.size = 42,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(starCount, (index) {
        return GetBuilder<CallCutController>(
            id: Constant.idRating,
            builder: (controller) {
              return GestureDetector(
                onTap: () {
                  controller.initialRating = index + 1; // Update the rating
                  // Pass the new rating to the callback
                  onRatingChanged(controller.initialRating);
                  // Update rating in controller
                  Get.find<CallCutController>().updateRating(controller.initialRating);
                },
                child: Icon(
                  Icons.star_rounded,
                  size: size,
                  color: index < controller.initialRating ? AppColors.rateStarColor : Colors.grey.shade300,
                ),
              );
            });
      }),
    );
  }
}
