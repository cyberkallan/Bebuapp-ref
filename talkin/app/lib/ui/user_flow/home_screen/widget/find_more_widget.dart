import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class FindMoreWidget extends StatelessWidget {
  const FindMoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppAsset.homeCallPerson, height: 112, width: 334).paddingOnly(top: 28, left: 20, right: 20),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: [0, 1],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xffF3F7FF),
                Color(0xffF3F7FF).withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                EnumLocale.txtHomeFastLalk.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(fontSize: 18, fontColor: AppColors.appColor),
              ).paddingOnly(top: 8),
              Text(
                EnumLocale.txtHomeDescription.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.grey),
              ).paddingOnly(top: 4, bottom: 10),
              Center(
                child: PrimaryAppButton(
                  height: 40,
                  // height: Get.height * 0.056,
                  // width: Get.width * 0.5,
                  onTap: () {
                    Get.toNamed(AppRoutes.allListeners)?.then(
                      (value) async {
                        UserCoinModel? userCoinModel;
                        userCoinModel = await UserCoinApi.callApi();
                        Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
                      },
                    );
                  },
                  widget: Image.asset(
                    AppAsset.arrowUp,
                    height: 15,
                    width: 15,
                  ),
                  text: EnumLocale.txtFindMoreListener.name.tr,
                  textStyle: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.white),
                ).paddingOnly(bottom: 10, left: Get.width * 0.22, right: Get.width * 0.22),
              ),
            ],
          ).paddingSymmetric(horizontal: 10),
        )
      ],
    );
  }
}
