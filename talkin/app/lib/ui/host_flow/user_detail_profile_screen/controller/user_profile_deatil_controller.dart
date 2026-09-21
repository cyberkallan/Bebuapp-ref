import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/api/user_profile_api.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/model/user_profile_model.dart';
import 'package:talk_in/utils/constant.dart';

class UserProfileDetailController extends GetxController {
  bool isLoading = false;
  String? userId;
  UserProfileModel? userProfileModel;

  @override
  void onInit() {
    super.onInit();
    userId = Get.arguments ?? '';
    log("Received userId: $userId");
    userProfile();
  }

  /// User profile
  userProfile() async {
    try {
      isLoading = true;
      update([Constant.listenerProfile]);
      var data = await UserProfileApi.callApi(userId: userId ?? '');
      userProfileModel = data;
    } catch (e) {
      log('Error fetching User profile api: $e');
    } finally {
      isLoading = false;
      update([Constant.listenerProfile]);
    }
  }
}
