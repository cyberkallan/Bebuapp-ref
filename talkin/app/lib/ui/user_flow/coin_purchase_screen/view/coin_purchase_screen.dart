import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/widget/coin_purchase_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class CoinPurchaseScreen extends StatelessWidget {
  const CoinPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: Column(
        children: [
          CoinPurchaseTopView(),
          CoinPurchaseView(), // Takes remaining space
          Expanded(
            child: Container(
              width: Get.width,
              decoration: BoxDecoration(color: AppColors.white),
              child: Column(
                children: [
                  Spacer(),
                  PrimaryAppButton(
                    onTap: () {
                      // Your action here
                      Get.toNamed(AppRoutes.bottomBar);
                    },
                    height: 50,
                    color: AppColors.appColor,
                    child: Center(
                      child: Text(
                        EnumLocale.txtDone.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 16,
                          fontColor: AppColors.white,
                        ),
                      ),
                    ),
                  ).paddingOnly(left: 14, right: 14, bottom: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
