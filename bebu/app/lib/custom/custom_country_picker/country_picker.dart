import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomCountryPicker {
  static String? name;

  static void pickCountry(
    final BuildContext context,
    final bool showWorldWide,
    final Function(Country) onSelect,
  ) {
    showCountryPicker(
      context: context,
      showWorldWide: showWorldWide,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: AppColors.white,
        textStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 15),
        searchTextStyle: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 15),
        bottomSheetHeight: Get.height / 1.5,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        inputDecoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          labelText: EnumLocale.txtSearch.name.tr,
          labelStyle: AppFontStyle.fontStyleW400(fontColor: AppColors.black, fontSize: 14),
          hintText: EnumLocale.txtTypeSomething.name.tr,
          hintStyle: AppFontStyle.fontStyleW400(fontColor: AppColors.black, fontSize: 14),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.black,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColors.black),
          ),
        ),
      ),
      onSelect: (Country country) {
        onSelect(country);
      },
    );
  }
}
