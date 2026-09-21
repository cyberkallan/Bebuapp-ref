import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class TalkAboutBottomSheet extends StatefulWidget {
  const TalkAboutBottomSheet({super.key});

  @override
  State<TalkAboutBottomSheet> createState() => _TalkAboutBottomSheetState();
}

class _TalkAboutBottomSheetState extends State<TalkAboutBottomSheet> {
  ListenersScreenController controller = Get.put(ListenersScreenController());
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.6,
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAsset.talkAboutIcon,
                height: 28,
                width: 28,
                color: AppColors.blue,
              ),
              Text(
                EnumLocale.txtTalkAbout.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.blue,
                ),
              ).paddingOnly(bottom: 18, left: Get.width * 0.03),
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
          Text(
            EnumLocale.txtSelectTalkaboutTxt.name.tr,
            style: AppFontStyle.fontStyleW500(
              fontSize: 13,
              fontColor: AppColors.appTextColor,
            ),
          ).paddingOnly(bottom: 18),
          Expanded(
            child: GetBuilder<ListenersScreenController>(
              id: Constant.talkAboutTopic,
              builder: (controller) {
                return ListView.builder(
                  itemCount: controller.talkTopic.length,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final topic = controller.talkTopic[index];
                    // bool isSelected = controller.selectedTopic == index;
                    bool isSelected = controller.selectedTopics.contains(index);

                    return GestureDetector(
                      onTap: () => controller.selectTopic(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.appColor : AppColors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              topic.name.toString(),
                              style: isSelected
                                  ? AppFontStyle.fontStyleW600(
                                      fontSize: 14,
                                      fontColor: AppColors.appColor,
                                    )
                                  : AppFontStyle.fontStyleW500(
                                      fontSize: 14,
                                      fontColor: AppColors.appTextColor,
                                    ),
                            ),
                            Spacer(),
                            Container(
                              height: 22,
                              width: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? AppColors.transparent : AppColors.grey),
                                color: isSelected ? Colors.black : AppColors.white,
                              ),
                              child: isSelected
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        height: 22,
                                        width: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.white),
                                          color: AppColors.appColor,
                                        ),
                                      ).paddingAll(0.5),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ).paddingOnly(bottom: 16),
                    );
                  },
                );
              },
            ),
          ),
          // PrimaryAppButton(
          //   onTap: () {
          //     controller.filterListenerByTalkTopic();
          //     Get.back();
          //   },
          //   height: 50,
          //   borderRadius: 30,
          //   text: EnumLocale.txtSubmit.name.tr,
          //   textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
          // ).paddingOnly(bottom: 10),

          GetBuilder<ListenersScreenController>(
            id: Constant.talkAboutTopic,
            builder: (controller) {
              return Row(
                children: [
                  Expanded(
                    child: PrimaryAppButton(
                      onTap: () {
                        controller.filterListenerByTalkTopic();
                        Get.back();
                      },
                      height: 50,
                      borderRadius: 30,
                      text: EnumLocale.txtSubmit.name.tr,
                      textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                    ).paddingOnly(bottom: 10),
                  ),
                  controller.selectedTopics.isNotEmpty ? 15.width : Offstage(),
                  controller.selectedTopics.isNotEmpty
                      ? Expanded(
                          child: PrimaryAppButton(
                            onTap: () {
                              controller.clearSelectedTopics();
                            },
                            height: 50,
                            borderRadius: 30,
                            text: EnumLocale.txtClear.name.tr,
                            textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                          ).paddingOnly(bottom: 10),
                        )
                      : Offstage(),
                ],
              ).paddingOnly(top: 10);
            },
          ),
        ],
      ),
    );
  }
}
