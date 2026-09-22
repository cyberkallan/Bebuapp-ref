import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomListeners extends StatelessWidget {
  final String name;
  final String? age;
  final num callCount;
  final String uniqueId;
  final String language;
  final List<String> talkTopicName;
  final String image;
  final String? status;
  final Widget? statusImage;
  final Color? statusColor;
  final Color statusTxtColor;
  final int index;
  final int talkTopicLength;
  final VoidCallback? talkNowOnTap;
  final VoidCallback? viewProfileOnTap;
  final bool availableForPrivateAudioCall;
  final bool availableForPrivateVideoCall;
  final bool fake;

  const CustomListeners({
    super.key,
    required this.name,
    this.age,
    required this.index,
    this.talkNowOnTap,
    this.viewProfileOnTap,
    required this.status,
    required this.talkTopicLength,
    required this.talkTopicName,
    required this.callCount,
    required this.language,
    required this.image,
    required this.statusImage,
    required this.statusColor,
    required this.statusTxtColor,
    required this.uniqueId,
    required this.availableForPrivateAudioCall,
    required this.availableForPrivateVideoCall,
    required this.fake,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                height: Get.height * 0.11,
                width: Get.height * 0.11,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: CustomListenerProfileImage(
                  image: image,
                  fit: BoxFit.cover,
                ),
              ).paddingOnly(right: 10, left: 8, top: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            "$name $age",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.appDarkColor),
                          ),
                        ),
                        // SizedBox(width: 4),

                        // Spacer(),
                        Container(
                          padding: EdgeInsets.only(right: 8, bottom: 3, top: 3, left: 7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: statusColor,
                          ),
                          child: Row(
                            children: [
                              if (statusImage != null)
                                Container(
                                  child: statusImage,
                                ).paddingOnly(right: 3),
                              Text(
                                status ?? '',
                                style: AppFontStyle.fontStyleW500(fontSize: 9, fontColor: statusTxtColor),
                              ),
                            ],
                          ),
                        ).paddingOnly(right: 6),
                      ],
                    ).paddingOnly(top: 8, bottom: 5),
                    Row(
                      children: [
                        Image.asset(
                          AppAsset.speakingBoy,
                          height: 15,
                        ).paddingOnly(right: 2),
                        Flexible(
                          child: Text(
                            language,
                            overflow: TextOverflow.ellipsis, // prevent long text from breaking layout
                            style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.appTextColor),
                          ).paddingOnly(right: 12),
                        ),
                        Image.asset(
                          AppAsset.callIcon,
                          height: 15,
                        ).paddingOnly(right: 2),
                        Text(
                          callCount.toString(),
                          style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.appTextColor),
                        ).paddingOnly(right: 16),
                        Image.asset(
                          AppAsset.uniqueIdIcon,
                          height: 15,
                        ).paddingOnly(right: 2),
                        Text(
                          uniqueId.toString(),
                          style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.appTextColor),
                        ).paddingOnly(right: 16),
                      ],
                    ).paddingOnly(bottom: 2),
                    Divider(
                      color: AppColors.lightGrey,
                    ).paddingOnly(right: 10, bottom: 4),
                    SizedBox(
                      height: Get.height * 0.026,
                      child: ListView.builder(
                        itemCount: talkTopicLength,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                talkTopicName[index],
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 10,
                                  fontColor: AppColors.grey,
                                ),
                              ),
                            ),
                          ).paddingOnly(right: 5);
                        },
                      ).paddingOnly(right: 6),
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: PrimaryAppButton(
                  onTap: viewProfileOnTap,
                  height: 38,
                  color: AppColors.white,
                  borderColor: AppColors.appColor,
                  text: EnumLocale.txtViewProfile.name.tr,
                  textStyle: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.appColor),
                ),
              ),
              if (availableForPrivateAudioCall || availableForPrivateVideoCall == true || fake == true) SizedBox(width: 14),
              availableForPrivateAudioCall || availableForPrivateVideoCall == true || fake == true
                  ? Expanded(
                      child: PrimaryAppButton(
                        onTap: talkNowOnTap,
                        height: 38,
                        color: AppColors.appColor,
                        borderColor: AppColors.appColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAsset.callIcon,
                              color: AppColors.white,
                              height: 20,
                            ).paddingOnly(right: 12),
                            Text(
                              EnumLocale.txtTalkNow.name.tr,
                              style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ).paddingOnly(top: 13, left: 6, right: 6, bottom: 10)
        ],
      ),
    );
  }
}
