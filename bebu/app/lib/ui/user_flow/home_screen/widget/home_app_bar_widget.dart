import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HomeAppBarWidget extends StatelessWidget {
  HomeAppBarWidget({super.key});

  final controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GetBuilder<EditProfileController>(
          id: Constant.idProfile,
          builder: (controller) {
            return Expanded(
              child: Row(
                children: [
                  DottedBorder(
                    borderType: BorderType.Circle,
                    color: Colors.black,
                    dashPattern: [3, 2],
                    strokeWidth: 1,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.myProfileScreen)?.then(
                          (value) {
                            Utils.onChangeStatusBar(brightness: Brightness.dark);
                          },
                        );
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: Get.height * 0.06,
                        width: Get.height * 0.06,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: CustomProfileImage(
                          image: Database.loginUserProfilePic,
                        ),
                      ),
                    ),
                  ).paddingOnly(right: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            maxLines: 1,
                            Database.loginUserName,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                          ).paddingOnly(right: 5, bottom: 3),
                        ],
                      ),
                      GetBuilder<HomeScreenController>(
                        builder: (controller) {
                          return GestureDetector(
                            onTap: () {
                              if (!controller.isToastVisible) {
                                Utils.copyText(Database.fetchLoginUserProfileModel?.user?.uniqueId ?? "1556578425");
                                Utils.showToast(context, "copied");

                                controller.isToastVisible = true;

                                Future.delayed(Duration(seconds: 3), () {
                                  controller.isToastVisible = false;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.only(bottom: 3, left: 6, right: 6, top: 3),
                              decoration: BoxDecoration(color: AppColors.idContainerColor, borderRadius: BorderRadius.circular(60)),
                              child: Row(
                                children: [
                                  SizedBox(
                                    // width: Get.width * 0.15,
                                    child: Text("ID: ${Database.fetchLoginUserProfileModel?.user?.uniqueId ?? ""}",
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.idTxtColor))
                                        .paddingOnly(right: 3),
                                  ),
                                  Image.asset(
                                    AppAsset.copyIcon,
                                    height: 12,
                                    width: 12,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      /* SizedBox(
                        width: Get.width * 0.45,
                        child: Text(
                          Database.loginType == 2 ? Database.loginUserNickName : Database.loginUserEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.black),
                        ),
                      )*/
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        // Spacer(),
        GetBuilder<HomeScreenController>(
            id: Constant.idCoinUpdate,
            builder: (controller) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.myWalletScreen);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        AppAsset.starCoin,
                        height: 24,
                        width: 24,
                      ),
                      controller.isCoinLoading
                          ? Shimmer.fromColors(
                              baseColor: AppColors.lightGrey1,
                              highlightColor: AppColors.grey.withValues(alpha: 0.2),
                              child: Text(
                                Database.listenerCoin.toString(),
                                style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.orange),
                              ),
                            ).paddingOnly(left: 6, right: 6)
                          : Text(
                              Database.userCoin.toString(),
                              style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.orange),
                            ).paddingOnly(left: 6, right: 5)
                    ],
                  ),
                ).paddingOnly(right: 6),
              );
            }),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.userNotificationView);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppColors.lightRed.withValues(alpha: 0.5),
              // border: Border.all(
              //   color: AppColors.border,
              // ),
            ),
            child: Image.asset(
              AppAsset.notificationIconRed,
              height: 20,
              width: 20,
            ),
          ),
        ),
      ],
    ).paddingOnly(top: Get.height * 0.048, bottom: 10);
  }
}
