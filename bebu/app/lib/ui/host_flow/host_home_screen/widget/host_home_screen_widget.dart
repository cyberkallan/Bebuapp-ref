import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart' show Shimmer;
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/switch/switch.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/controller/host_bottom_bar_controller.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostTopHomeView extends StatelessWidget {
  const HostTopHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DottedBorder(
          borderType: BorderType.Circle,
          color: Colors.black,
          dashPattern: [3, 2],
          strokeWidth: 1,
          child: GestureDetector(
            onTap: () {
              Utils.showLog(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");

              Get.find<HostBottomBarController>().onClick(4);

              // Get.toNamed(AppRoutes.hostProfileScreen);
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
                image: Database.fetchListenerProfileModel?.data?.image ?? '',
              ),
            ),
          ),
        ).paddingOnly(right: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              maxLines: 1,
              Database.fetchListenerProfileModel?.data?.name ?? "",
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
            ).paddingOnly(right: 5, bottom: 3),
            /* Text(
              Database.loginType == 2
                  ? Database.fetchListenerProfileModel?.data?.nickName ?? ''
                  : Database.fetchListenerProfileModel?.data?.email ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.black),
            )*/
            GetBuilder<HostHomeScreenController>(builder: (controller) {
              return GestureDetector(
                onTap: () {
                  if (!controller.isToastVisible) {
                    Utils.copyText(Database.fetchLoginUserProfileModel?.user?.uniqueId ?? "");
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
                        child: Text("ID: ${Database.fetchListenerProfileModel?.data?.uniqueId ?? ""}",
                                overflow: TextOverflow.ellipsis, style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: AppColors.idTxtColor))
                            .paddingOnly(right: 3),
                      ),
                      Image.asset(
                        AppAsset.copyIcon,
                        height: 13,
                        width: 13,
                      )
                    ],
                  ),
                ),
              );
            })
          ],
        ),
        Spacer(),
        GetBuilder<HostHomeScreenController>(
            id: Constant.idCoinUpdate,
            builder: (controller) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.hostViewCoinHistory);
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
                        height: 26,
                        width: 26,
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
                              Database.listenerCoin.toString(),
                              style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.orange),
                            ).paddingOnly(left: 6, right: 6)
                    ],
                  ),
                ).paddingOnly(right: 8),
              );
            }),
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.hostNotificationView);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppColors.lightRed.withValues(alpha: 0.5),
            ),
            child: Image.asset(
              AppAsset.notificationIconRed,
              height: 21,
              width: 21,
            ),
          ),
        ),
      ],
    ).paddingOnly(top: Get.height * 0.042, bottom: 10);
  }
}

class HostImageView extends StatelessWidget {
  const HostImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostHomeScreenController>(
      init: HostHomeScreenController(),
      builder: (controller) {
        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 100,
                autoPlay: true,
                enlargeCenterPage: true,
                onPageChanged: controller.onPageChanged,
              ),
              items: controller.imageList.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.asset(
                      item,
                      fit: BoxFit.contain,
                      width: Get.width,
                    );
                  },
                );
              }).toList(),
            ).paddingOnly(top: 30),
            Text(
              EnumLocale.txtHomeFastLalk.name.tr,
              style: AppFontStyle.fontStyleW600(
                fontSize: 18,
                fontColor: AppColors.appColor,
              ),
            ).paddingOnly(top: 8),
            Text(
              EnumLocale.txtHomeDescription.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 12,
                fontColor: AppColors.grey,
              ),
            ).paddingOnly(top: 4, bottom: 10),

            /// Indicator using GetBuilder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.imageList.length, (index) {
                bool isSelected = controller.currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: isSelected ? 16 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.appColor : AppColors.indicatorColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ).paddingOnly(bottom: 10, top: 8),
          ],
        );
      },
    );
  }
}

class RandomCallView extends StatelessWidget {
  const RandomCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtAllowRandomCall.name.tr,
          style: AppFontStyle.fontStyleW800(
            fontSize: 18,
            fontColor: AppColors.appDarkColor,
          ),
        ).paddingOnly(top: 16),
        Row(
          children: [
            Image.asset(
              AppAsset.hostHomeImage,
              height: 195,
              width: 154,
            ).paddingOnly(right: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtEarnMoney.name.tr,
                    style: AppFontStyle.fontStyleW800(
                      fontSize: 20,
                      fontColor: AppColors.orange,
                    ),
                  ).paddingOnly(bottom: 1),
                  Text(
                    EnumLocale.txtHostHomeDescription.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 11,
                      height: 1.95,
                      fontColor: AppColors.otpScreenGrey,
                    ),
                  ).paddingOnly(bottom: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.yellow200,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAsset.starCoin,
                          height: 24,
                          width: 24,
                        ).paddingAll(5),
                        Expanded(
                          child: Text(
                            "Get ${Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall.toString() ?? 0.toString()} Coin/Min",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 14,
                              fontColor: AppColors.getCoinText,
                            ),
                          ).paddingOnly(right: 4),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ).paddingOnly(top: 14, bottom: 4)
      ],
    );
  }
}

class PermissionView extends StatelessWidget {
  const PermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtImAvailableFor.name.tr,
          style: AppFontStyle.fontStyleW800(
            fontSize: 18,
            fontColor: AppColors.appDarkColor,
          ),
        ).paddingOnly(bottom: 14),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: AppColors.black.withValues(alpha: 0.1),
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GetBuilder<HostHomeScreenController>(builder: (controller) {
              //   return CustomSwitchView(
              //     coinShow: false,
              //     text: EnumLocale.txtAvailableChat.name.tr,
              //     value: controller.isChatPermission,
              //     onChanged: (val) {
              //       controller.permissionSwitch(val, "isAvailableForChat");
              //     },
              //   );
              // }),
              GetBuilder<HostHomeScreenController>(builder: (controller) {
                return CustomSwitchView(
                  callCoin: Database.fetchListenerProfileModel?.data?.rateRandomAudioCall.toString() ?? '0',
                  coinShow: true,
                  text: EnumLocale.txtRanAudioCallConnect.name.tr,
                  value: controller.isAvailableForRandomAudioCall,
                  onChanged: (val) {
                    controller.permissionSwitch(val, "isAvailableForRandomAudioCall");
                  },
                );
              }),
              GetBuilder<HostHomeScreenController>(builder: (controller) {
                return CustomSwitchView(
                  callCoin: Database.fetchListenerProfileModel?.data?.rateRandomVideoCall.toString() ?? '0',
                  coinShow: true,
                  text: EnumLocale.txtRandomVideoCallConnect.name.tr,
                  value: controller.isAvailableForRandomVideoCall,
                  onChanged: (val) {
                    controller.permissionSwitch(val, "isAvailableForRandomVideoCall");
                  },
                );
              }),
              GetBuilder<HostHomeScreenController>(builder: (controller) {
                return CustomSwitchView(
                  callCoin: Database.fetchListenerProfileModel?.data?.ratePrivateAudioCall.toString() ?? '0',
                  coinShow: true,
                  text: EnumLocale.txtAvailableForAudioCall.name.tr,
                  value: controller.isAvailableForPrivateAudioCall,
                  onChanged: (val) {
                    controller.permissionSwitch(val, "isAvailableForPrivateAudioCall");
                  },
                );
              }),
              GetBuilder<HostHomeScreenController>(builder: (controller) {
                return CustomSwitchView(
                  callCoin: Database.fetchListenerProfileModel?.data?.ratePrivateVideoCall.toString() ?? '0',
                  coinShow: true,
                  text: EnumLocale.txtAvailableForVideoCall.name.tr,
                  value: controller.isAvailableForPrivateVideoCall,
                  onChanged: (val) {
                    controller.permissionSwitch(val, "isAvailableForPrivateVideoCall");
                  },
                );
              }),
            ],
          ).paddingOnly(left: 10),
        ),
      ],
    );
  }
}

class NoteView extends StatelessWidget {
  const NoteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtNote.name.tr,
          style: AppFontStyle.fontStyleW600(
            fontSize: 13,
            fontColor: AppColors.black,
          ),
        ).paddingOnly(top: 16),
        Text(
          EnumLocale.txtHostHomeNote.name.tr,
          style: AppFontStyle.fontStyleW500(
            fontSize: 11,
            height: 1.74,
            fontColor: AppColors.profileText,
          ),
        ).paddingOnly(bottom: 28)
      ],
    );
  }
}

class CustomSwitchView extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool coinShow;
  final String? callCoin;

  const CustomSwitchView({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
    required this.coinShow,
    this.callCoin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.fontStyleW500(
              fontSize: 13,
              fontColor: AppColors.otpScreenGrey,
            ),
          ),
        ),
        // Spacer(),
        coinShow == true
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lightYellow,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppAsset.starCoin,
                      height: 18,
                      width: 18,
                    ),
                    Text(
                      "${callCoin ?? ''}/Min",
                      style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: AppColors.orange),
                    ).paddingOnly(left: 6, right: 6)
                  ],
                ),
              ).paddingOnly(right: 10)
            : SizedBox(),
        CommonCupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: CupertinoColors.activeGreen,
          trackColor: CupertinoColors.destructiveRed,
          scale: 0.8,
        ),
      ],
    );
  }
}
