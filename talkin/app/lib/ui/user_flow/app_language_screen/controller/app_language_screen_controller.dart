import 'dart:ui';

import 'package:get/get.dart';
import 'package:talk_in/localization/localizations_delegate.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/preference.dart';
import 'package:talk_in/utils/utils.dart';

class AppLanguageScreenController extends GetxController {
  int checkedValue = Database.languageIndex;
  LanguageModel? languagesChosenValue;

  String? prefLanguageCode;
  String? prefCountryCode;
  @override
  void onInit() {
    getLanguageData();

    super.onInit();
  }

  getLanguageData() {
    prefLanguageCode = Preference.shared.getString(Preference.selectedLanguage) ?? 'en'; // Default to 'en' if null
    prefCountryCode = Preference.shared.getString(Preference.selectedCountryCode) ?? 'US'; // Default to 'US' if null

    languagesChosenValue =
        languages.where((element) => (element.languageCode == prefLanguageCode && element.countryCode == prefCountryCode)).toList()[0];
    update([Constant.idChangeLanguage]);
  }

  onChangeLanguage(LanguageModel value, int index) {
    // Print before language change
    Utils.showLog("======before languagesChosenValue=============== ${languagesChosenValue?.language}");

    languagesChosenValue = value;

    // Print after language change
    Utils.showLog("after languagesChosenValue===================== ${languagesChosenValue?.language}");

    checkedValue = index;
    Database.onSetLanguageIndex(checkedValue);
    Database.onSetSelectedLanguage(languagesChosenValue!.languageCode);
    Database.onSetSelectedLanguageCountryCode(languagesChosenValue!.countryCode);

    // Update the UI
    Get.updateLocale(Locale(languagesChosenValue!.languageCode, languagesChosenValue!.countryCode));

    update([Constant.idChangeLanguage]);
    Get.back();

    // Print the current language preference after the update
    Utils.showLog("Updated LanguageCode: ${languagesChosenValue?.languageCode}");
    Utils.showLog("Updated CountryCode: ${languagesChosenValue?.countryCode}");
  }

  onLanguageSave() {
    // Save the language selection in preferences
    Preference.shared.setString(Preference.selectedLanguage, languagesChosenValue!.languageCode.toString());
    Preference.shared.setString(Preference.selectedCountryCode, languagesChosenValue!.countryCode.toString());

    // Update the locale
    Get.updateLocale(Locale(languagesChosenValue!.languageCode, languagesChosenValue!.countryCode));

    // Print saved values to check
    Utils.showLog("Language saved: ${languagesChosenValue?.languageCode}");
    Utils.showLog("Country saved: ${languagesChosenValue?.countryCode}");

    Preference.selectedLanguage = languagesChosenValue?.languageCode ?? "en";
    Preference.selectedCountryCode = languagesChosenValue?.countryCode ?? "US";

    Utils.showLog("Preference Language saved: ${Preference.selectedLanguage}");
    Utils.showLog("Preference Country saved: ${Preference.selectedCountryCode}");

    // Update UI
    update([Constant.idChangeLanguage]);

    // Go back to previous screen
    Get.back();
  }
}
