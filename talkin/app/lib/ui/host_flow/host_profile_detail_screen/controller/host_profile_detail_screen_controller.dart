import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

class HostProfileDetailScreenController extends GetxController {
  bool isLoading = false;
  FetchListenerProfileModel? fetchListenerProfileModel;

  final List<Map<String, String>> statsList = [
    {
      'image': AppAsset.callGradiant,
      'title': EnumLocale.txtTotalCall.name.tr,
      'count': '369',
    },
    {
      'image': AppAsset.starRating,
      'title': EnumLocale.txtRating.name.tr,
      'count': '4.8',
    },
    {
      'image': AppAsset.experience,
      'title': EnumLocale.txtExperience.name.tr,
      'count': '8+',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    listenerProfile();
  }

  listenerProfile() async {
    try {
      isLoading = true;
      update([Constant.listenerProfile]);
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId,
      );

      statsList[0]['count'] = fetchListenerProfileModel?.data?.callCount?.toString() ?? '0';
      statsList[1]['count'] = fetchListenerProfileModel?.data?.rating?.toStringAsFixed(1) ?? '0.0';
      statsList[2]['count'] = fetchListenerProfileModel?.data?.experience == null ? '0+' : '${fetchListenerProfileModel?.data?.experience}+';
    } catch (e) {
      log('Error fetching Listener profile api: $e');
    } finally {
      isLoading = false;
      update([Constant.listenerProfile]);
    }
  }
}
