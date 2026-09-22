import 'dart:developer';
import 'dart:ui';

import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

Future<Locale> getLocale() async {
  log("Database.selectedLanguage********************** ${Database.selectedLanguage}");
  log("Database.selectedCountryCode********************** ${Database.languageCountryCode}");

  // String languageCode = Preference.shared.getString(Preference.selectedLanguage) ?? Constant.languageEn;
  // String countryCode = Preference.shared.getString(Preference.selectedCountryCode) ?? Constant.countryCodeEn;

  String languageCode = Database.selectedLanguage;
  String countryCode = Database.languageCountryCode;

  log("getLocale Updated $languageCode   $countryCode");
  return _locale(languageCode, countryCode);
}

Locale _locale(String languageCode, String countryCode) {
  return languageCode.isNotEmpty ? Locale(languageCode, countryCode) : const Locale(Constant.languageEn, Constant.countryCodeEn);
}
