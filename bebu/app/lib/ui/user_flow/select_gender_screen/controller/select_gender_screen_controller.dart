import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

class SelectGenderScreenController extends GetxController {
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
    final selectedGenderText = gender[selectedIndex]['txt'];
    genderTextController.text = selectedGenderText;

    // Save selected gender locally
    Database.onSetLoginUserGender(selectedGenderText);

    log("Database.loginUserGender :: ${Database.loginUserGender}");

    update([Constant.idGenderSelect]);
    update();
  }

  int selectedIndex = 0; // Already hase
}
