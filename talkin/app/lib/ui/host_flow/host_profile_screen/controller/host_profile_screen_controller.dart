import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_web_view/web_view_screen.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class HostProfileScreenController extends GetxController {
  Future<void> onClickPrivacyPolicy() async {
    final String privacyPolicyUrl = Database.settingApiModel?.data?.listenerPrivacyPolicyUrl.toString() ?? "";

    if (privacyPolicyUrl.isNotEmpty) {
      Get.to(() => WebViewScreen(url: privacyPolicyUrl, screen: "Privacy Policy"));
    } else {
      log('Invalid privacy policy URL');
    }
  }

  Future<void> onClickAboutUs() async {
    final String aboutUsUrl = Database.settingApiModel?.data?.aboutUsUrl.toString() ?? "";

    if (aboutUsUrl.isNotEmpty) {
      Get.to(() => WebViewScreen(
            url: aboutUsUrl,
            screen: "About Us",
          ));
    } else {
      log('Invalid privacy policy URL');
    }
  }

  // Future<void> onClickShare() async {
  //   var url = Uri.parse("https://play.google.com/store/apps/details?id=com.incodes.talkin");
  //   if (await canLaunchUrl(url)) {
  //     launchUrl(url, mode: LaunchMode.externalApplication);
  //     throw "Cannot load the page";
  //   }
  // }

  Future<void> onClickShare() async {
    Uri url;

    if (Platform.isAndroid) {
      url = Uri.parse("https://play.google.com/store/apps/details?id=${Utils.playStoreId}");
    } else if (Platform.isIOS) {
      url = Uri.parse("https://apps.apple.com/app/${Utils.appStoreId}");
    } else {
      // Other platforms (optional fallback)
      throw 'Unsupported platform';
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
