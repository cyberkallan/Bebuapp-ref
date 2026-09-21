import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/api/listeners_request_check_api.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/model/listeners_request_check_model.dart';

class HostRequestSentSuccessfullyController extends GetxController {
  bool isLoading = false;
  ListenersRequestCheckModel? listenersRequestCheckModel;
  @override
  void onInit() {
    listenersRequestCheck();
    super.onInit();
  }

  /// listeners request check
  listenersRequestCheck() async {
    try {
      isLoading = true;
      update(); // notify UI
      listenersRequestCheckModel = await ListenersRequestCheckApi.callApi();
    } catch (e) {
      log('Error fetching FAQ: $e');
    } finally {
      isLoading = false;
      update();
    }
  }
}
