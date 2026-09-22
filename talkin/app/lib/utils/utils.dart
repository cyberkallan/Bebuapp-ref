import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:clipboard/clipboard.dart';

import 'app_color.dart';
import 'app_theme.dart';

class Utils {
  /// Shown on the profile page; keep in sync with pubspec.yaml.
  static const String appVersion = '1.7.2';

  static const sandboxVerifyReceiptUrl = false;

  static RxBool isAppOpen = false.obs;
  static String? playStoreId = "in.bebuapp.app";
  static String? appStoreId = "6747668315";

  // /// =================== Toast =================== ///
  // static showToast(BuildContext context, String msg, {ToastGravity gravity = ToastGravity.BOTTOM}) {
  //   return Fluttertoast.showToast(
  //     msg: msg,
  //     toastLength: Toast.LENGTH_LONG,
  //     gravity: gravity,
  //     backgroundColor: AppColors.appColor,
  //     textColor: AppColors.white,
  //     fontSize: 15,
  //   );
  // }

  /// =================== Toast =================== ///
  static showToast(
    BuildContext context,
    String msg, {
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_LONG, // default to 2 sec
  }) {
    return Fluttertoast.showToast(
      msg: msg,
      toastLength: toastLength,
      gravity: gravity,
      backgroundColor: AppColors.appColor,
      textColor: AppColors.white,
      fontSize: 15,
    );
  }

  /// =================== Current Focus Node =================== ///
  static currentFocus(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  /// 950 → "950", 1200 → "1.2K", 25000 → "25K", 1_500_000 → "1.5M".
  static String formatCompact(int n) {
    if (n.abs() < 1000) return n.toString();
    String trim(double v) => v.toStringAsFixed(v.truncateToDouble() == v || v >= 100 ? 0 : 1);
    if (n.abs() < 1000000) return '${trim(n / 1000)}K';
    return '${trim(n / 1000000)}M';
  }

  static String formatDateToApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatShortDate(DateTime date) {
    return "${date.day}/${date.month}";
  }
  // /// =================== Lunch URL =================== ///
  // static Future<void> launchURL(String value) async {
  //   var url = Uri.parse(value);
  //   if (await canLaunchUrl(url)) {
  //     launchUrl(url);
  //   } else {
  //     Utils.showToast(Get.context!, "Web page can't loaded");
  //     throw "Cannot load the page";
  //   }
  // }

  // /// =================== Clipboard (Copy Text) =================== ///
  // static copyText(String text) {
  //   FlutterClipboard.copy(text);
  // }

  /// =================== Console Log =================== ///
  static showLog(String text) {
    log(text);
  }

  // static void showLoading({String? message}) {
  //   Get.dialog(
  //     WillPopScope(
  //       onWillPop: () async => false,
  //       child: Center(
  //         child: CircularProgressIndicator(),
  //       ),
  //     ),
  //     barrierDismissible: false,
  //   );
  // }

  // static void hideLoading() {
  //   if (Get.isDialogOpen!) {
  //     Get.back();
  //   }
  // }

  static void onChangeStatusBar({
    required Brightness brightness,
    int? delay,
  }) {
    showLog("Change Status Bar => Brightness => $brightness => $delay");
    // Themed screens ask for light icons (dark background). When the light
    // theme is active their background is bright, so flip to dark icons.
    final effective = brightness == Brightness.light && BebuTheme.isLight ? Brightness.dark : brightness;
    Future.delayed(
      Duration(milliseconds: delay ?? 0),
      () => SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: effective,
        ),
      ),
    );
  }

  /// =================== Clipboard (Copy Text) =================== ///
  static copyText(String text) {
    FlutterClipboard.copy(text);
  }
}

extension HeightExtension on num {
  SizedBox get height => SizedBox(height: toDouble());
}

extension WidthExtension on num {
  SizedBox get width => SizedBox(width: toDouble());
}
