import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/api/listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/api/listener_review_api.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_profile_response_model.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_review_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class ProfileDetailScreenController extends GetxController {
  String? listenerId;
  bool isLoading = false;
  bool isBackProfile = true;
  bool isToastVisible = false;
  ListenerReviewModel? listenerReviewModel;
  List<Review>? reviews = [];

  ListenerProfileModel? listenerProfileModel;
  final List<Map<String, String>> statsList = [
    {
      'image': AppAsset.callGradiant,
      'title': EnumLocale.txtTotalCall.name.tr,
      'count': '',
    },
    {
      'image': AppAsset.starRating,
      'title': EnumLocale.txtRating.name.tr,
      'count': '',
    },
    {
      'image': AppAsset.experience,
      'title': EnumLocale.txtExperience.name.tr,
      'count': '',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    listenerId = Get.arguments ?? '';
    log("Received listenerId: $listenerId");
    listenerProfile();
    listenerReview();
  }

  /// listener profile
  listenerProfile() async {
    try {
      isLoading = true;
      update([Constant.listenerProfile]);
      var data = await ListenerProfileApi.callApi(listenerId: listenerId ?? '');
      listenerProfileModel = data;

      statsList[0]['count'] = listenerProfileModel?.data?.callCount?.toString() ?? '0';
      statsList[1]['count'] = listenerProfileModel?.data?.rating?.toStringAsFixed(1) ?? '0.0';
      statsList[2]['count'] = listenerProfileModel?.data?.experience == null ? '0+' : '${listenerProfileModel?.data?.experience}+';
    } catch (e) {
      log('Error fetching Listener profile api: $e');
    } finally {
      isLoading = false;
      update([Constant.listenerProfile]);
    }
  }

  /// get listener review
  listenerReview() async {
    isLoading = true;
    update([Constant.idGetListenerReview]);

    listenerReviewModel = await ListenerReviewApi.callApi(listenerId: listenerId ?? '');
    reviews?.clear();
    reviews?.addAll(listenerReviewModel?.reviews ?? []);

    isLoading = false;
    update([Constant.idGetListenerReview]);
  }

  onRefresh() async {
    // var data = await ListenerProfileApi.callApi(listenerId: listenerId ?? '');
    // listenerProfileModel = data;
    // listenerReviewModel = await ListenerReviewApi.callApi(listenerId: listenerId ?? '');
    // reviews?.addAll(listenerReviewModel?.reviews ?? []);
    listenerProfile();
    listenerReview();
  }
}
