import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/user_flow/all_review_screen/controller/all_review_controller.dart';
import 'package:talk_in/ui/user_flow/all_review_screen/shimmer/all_review_shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart' show EnumLocale;
import 'package:talk_in/utils/font_style.dart';

class AllReviewAppBar extends StatelessWidget {
  const AllReviewAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtReview.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class AllReview extends StatelessWidget {
  const AllReview({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllReviewController>(
        id: Constant.idGetListenerReview,
        builder: (controller) {
          return controller.reviews?.isEmpty == true
              ? AllReviewShimmer()
              : ListView.builder(
                  itemCount: controller.reviews?.length,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.reviewBorder),
                        borderRadius: BorderRadius.circular(18),
                        color: AppColors.reviewBackground,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DottedBorder(
                                borderType: BorderType.Circle,
                                color: AppColors.black,
                                dashPattern: [3, 2],
                                strokeWidth: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    // Get.toNamed(AppRoutes.hostProfileScreen);
                                  },
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CustomListenerProfileImage(
                                      image: controller.reviews?[index].profilePic ?? '',
                                    ),
                                  ),
                                ),
                              ).paddingOnly(right: 13),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.reviews?[index].fullName ?? '',
                                    style: AppFontStyle.fontStyleW600(fontSize: 15, fontColor: AppColors.black),
                                  ),
                                  StarRating(
                                    rating: controller.reviews?[index].rating?.toDouble() ?? 0.0,
                                    size: 22,
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Color(0xffE7EBF7), borderRadius: BorderRadius.circular(34)),
                                child: Text(
                                  controller.reviews?[index].time ?? '',
                                  style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.profileLanguage),
                                ),
                              )
                            ],
                          ).paddingOnly(top: 5, bottom: 6),
                          Text(
                            controller.reviews?[index].review ?? '',
                            textAlign: TextAlign.start,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 12,
                              fontColor: AppColors.profileLanguage,
                              height: 1.8,
                            ),
                          )
                        ],
                      ),
                    ).paddingOnly(bottom: 14);
                  },
                ).paddingOnly(bottom: 16).paddingOnly(left: 16, right: 16, top: 16);
        });
  }
}

class StarRating extends StatelessWidget {
  final double rating; // e.g. 3.5
  final double size;
  final int maxStars;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 42,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        return Icon(
          Icons.star_rounded,
          size: size,
          color: index < rating ? AppColors.rateStarColor : Colors.grey.shade300,
        );
      }),
    );
  }
}
