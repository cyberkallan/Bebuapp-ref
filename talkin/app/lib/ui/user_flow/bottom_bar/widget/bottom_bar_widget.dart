import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_bar/salomon_bottom_bar.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class BottomBarView extends StatelessWidget {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        return Container(
          height: Platform.isIOS ? 100 : 80,
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.5),
                offset: const Offset(
                  6.0,
                  6.0,
                ),
                blurRadius: 6.0,
                spreadRadius: 2.0,
              ), //BoxShadow
            ],
          ),
          child: OverflowBox(
            maxHeight: double.infinity,
            maxWidth: double.infinity,
            child: SalomonBottomBar(
              currentIndex: logic.selectIndex,
              onTap: (value) async {
                logic.onClick(value);
              },
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(left: 10, right: 10, top: 20),
              selectedColorOpacity: 1,
              items: [
                bottomBarItemView(
                  index: 0,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.homeFilled,
                  label: EnumLocale.txtHome.name.tr,
                ),
                bottomBarItemView(
                  index: 1,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.listener,
                  label: EnumLocale.txtListener.name.tr,
                ),
                bottomBarItemView(
                  index: 2,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.randomCall,
                  label: EnumLocale.txtRandomCall.name.tr,
                ),
                bottomBarItemView(
                  index: 3,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.chat,
                  label: EnumLocale.txtChat.name.tr,
                ),
                bottomBarItemView(
                  index: 4,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.calling,
                  label: EnumLocale.txtCalling.name.tr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

SalomonBottomBarItem bottomBarItemView({
  required final int index,
  required final int selectIndex,
  required final String image,
  required final String label,
}) {
  return SalomonBottomBarItem(
    icon: Image.asset(
      image,
      height: 26,
      width: 26,
      color: selectIndex == index ? AppColors.white : AppColors.unSelected,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: selectIndex == index ? FontWeight.w700 : FontWeight.w500,
        color: selectIndex == index ? AppColors.appColor : AppColors.unSelected,
      ),
    ).paddingOnly(bottom: 5),
    selectedColor: AppColors.appColor,
  );
}
