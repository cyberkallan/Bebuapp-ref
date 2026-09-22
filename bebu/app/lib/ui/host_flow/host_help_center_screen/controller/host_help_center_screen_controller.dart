import 'dart:developer';

import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/api/get_faq_api.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/model/faq_response_model.dart';
import 'package:talk_in/utils/constant.dart';

class HostHelpCenterScreenController extends GetxController {
  FaqModel? faqModel;
  List<Datum> faqList = [];
  int expandedIndex = -1;

  bool isLoading = false;

  @override
  void onInit() {
    getFaqData();
    super.onInit();
  }

  /// get faq
  getFaqData() async {
    try {
      isLoading = true;
      update([Constant.idFAQListeners]); // notify UI
      var data = await GetFaqApi.callApi(category: "Listener");
      faqModel = data;
      faqList = data?.data ?? [];
    } catch (e) {
      log('Error fetching FAQ: $e');
    } finally {
      isLoading = false;
      update([Constant.idFAQListeners]); // notify UI
    }
  }

  /// toggle expansion
  void toggleExpansion(int index) {
    if (expandedIndex == index) {
      expandedIndex = -1;
    } else {
      expandedIndex = index;
    }
    update([Constant.idFAQListeners]);
  }
}
