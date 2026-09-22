import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:talk_in/socket/socket_listen.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/api/submit_call_rate_api.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/model/submit_call_rate_model.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/api/listener_review_api.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class CallCutController extends GetxController {
  String listenerService = 'yes';
  String favListener = 'yes';
  late Map<String, dynamic> args;
  String? receiverName;
  String? receiverImage;
  String? receiverId;
  String? callId;
  String? callDuration;
  String? date;
  String? usedBalance;
  int initialRating = 2; // New rating variable
  TextEditingController reviewCnt = TextEditingController();
  SubmitCallRateModel? submitCallRateModel;
  bool isProximitySupported = true;
  StreamSubscription<bool>? subsProximity;

  @override
  void onInit() async {
    callId = CallCutDataStorage.callId ?? "";
    callDuration = CallCutDataStorage.duration ?? "";
    date = CallCutDataStorage.date ?? "";
    usedBalance = CallCutDataStorage.balanceUsed ?? "";

    log("callId :::::::::$callId");
    log("callDuration :::::::::$callDuration");
    log("usedBalance :::::::::$usedBalance");
    log("date :::::::::$date");

    if (Get.arguments is Map) {
      args = Map<String, dynamic>.from(Get.arguments);
    } else {
      args = {};
    }
    getDataFromArgs();

    super.onInit();
  }

  getDataFromArgs() async {
    if (Get.arguments != null) {
      Map<String, dynamic> data = Get.arguments ?? {};

      receiverName = data["receiverName"] ?? "";
      receiverImage = data["receiverImage"] ?? "";
      receiverId = data["receiverId"] ?? "";
    }

    log("receiverName :::::::::$receiverName");
    log("receiverImage ::::::::::$receiverImage");
    log("receiverId :::::::::$receiverId");
    Future.delayed(Duration(seconds: 1));
    // isProximitySupported = await ProximityScreenLock.isProximityLockSupported();
    if (isProximitySupported == true) {
      await ProximityScreenLock.setActive(false);
      // Subscribe to proximity states
      subsProximity = ProximityScreenLock.proximityStates.listen((objectDetected) {
        log("call cut screen controller Proximity event (even though disabled): $objectDetected");
      });
    }
  }

  void setCallCutData(Map<String, dynamic> data) {
    callId = data['callId']?.toString();
    date = data['date']?.toString();
    usedBalance = data['balanceUsed']?.toString();
    callDuration = data['duration']?.toString();
    update(); // Notifies the view
  }

  void listenerServiceSelect(String value) {
    listenerService = value;
    update();
  }

  void favListenerSelect(String value) {
    favListener = value;
    update();
  }

  void updateRating(int rating) {
    initialRating = rating; // Update rating
    update([Constant.idRating]); // Update the UI
  }

  void submitListenerCallRate() async {
    log("Listener ID: ${Database.fetchListenerProfileModel?.data?.id}");

    // Get the rating and review from the controller
    String rating = initialRating.toString();
    String review = reviewCnt.text.trim();

    // Check for empty review
    if (review.isEmpty) {
      Utils.showToast(Get.context!, "Please enter a review.");
      return;
    }

    // Check for script injection
    if (containsDangerousScript(review)) {
      Utils.showToast(Get.context!, "Script tags are not allowed in the review.");
      reviewCnt.clear();
      return;
    }
    // Make the API call to submit the rate
    submitCallRateModel = await SubmitCallRateApi.callApi(
      listenerId: receiverId ?? '',
      review: review,
      rating: rating,
    );

    // Check API response status and show appropriate toast
    if (submitCallRateModel?.status == true) {
      Utils.showToast(Get.context!, submitCallRateModel?.message ?? 'Rating submitted successfully');
      log("API response: ${submitCallRateModel?.message}");
      Utils.showLog("Rating submitted successfully: ${submitCallRateModel?.message}");

      ListenerReviewApi.callApi(listenerId: receiverId ?? '');

      // Optionally, navigate back after successful submission
      Get.close(2);
    } else {
      // Handle error or failure
      Utils.showLog("Failed to submit rating.");
      Utils.showToast(Get.context!, "Failed to submit rating.");
    }
  }

  bool containsDangerousScript(String input) {
    final scriptTagRegex = RegExp(r'<\s*script[^>]*>', caseSensitive: false);
    return scriptTagRegex.hasMatch(input);
  }

  // Future<void> onClickShare() async {
  //   var url = Uri.parse("https://play.google.com/store/apps/details?id=in.bebuapp.app");
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

  @override
  void onClose() {
    // Clean up
    subsProximity?.cancel();
    reviewCnt.dispose();

    // (Optional) If your app enables the proximity lock elsewhere,
    // you can re-enable it here or leave it off depending on your flow:
    // if (isProximitySupported) {
    //   ProximityLockScreen.setActive(true);
    // }

    super.onClose();
  }
}
