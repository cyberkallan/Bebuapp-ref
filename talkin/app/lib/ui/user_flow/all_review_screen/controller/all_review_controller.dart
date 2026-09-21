import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/api/listener_review_api.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/model/listener_review_model.dart';
import 'package:talk_in/utils/constant.dart';

class AllReviewController extends GetxController {
  bool isLoading = false;
  String? listenerId;

  ListenerReviewModel? listenerReviewModel;
  List<Review>? reviews = [];

  @override
  void onInit() {
    super.onInit();
    listenerId = Get.arguments ?? '';
    log("Received listenerId: $listenerId");

    listenerReview();
  }

  listenerReview() async {
    isLoading = true;
    update([Constant.idGetListenerReview]);

    listenerReviewModel = await ListenerReviewApi.callApi(listenerId: listenerId ?? '');
    reviews?.addAll(listenerReviewModel?.reviews ?? []);

    isLoading = false;
    update([Constant.idGetListenerReview]);
  }
}
