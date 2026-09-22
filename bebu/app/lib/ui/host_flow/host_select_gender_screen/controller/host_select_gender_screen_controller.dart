import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class HostSelectGenderScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    genderTextController.text = gender[selectedIndex]['txt'];
  }

  TextEditingController genderTextController = TextEditingController();

  List<Map<String, dynamic>> gender = [
    {
      "txt": EnumLocale.txtMale.name.tr,
      "image": AppAsset.maleImage,
    },
    {
      "txt": EnumLocale.txtFemale.name.tr,
      "image": AppAsset.femaleImage,
    },
  ];

  void selectGender(int index) {
    selectedIndex = index;
    genderTextController.text = gender[selectedIndex]['txt'];
    update([Constant.idGenderSelect]);
    update();
  }

  int selectedIndex = 0;
}
